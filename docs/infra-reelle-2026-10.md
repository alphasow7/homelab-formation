# L'infra réelle au 11/10/2026 — référence des encarts « vrai matériel »

> La formation a été écrite en juillet 2026 sur l'infra de l'époque : une tour Proxmox,
> 9 VMs Debian sur 4 segments internes, deux Lenovo en cluster K3S. **Le homelab a pivoté
> en août** (`vdp/plan.md`) et n'a plus cessé de bouger depuis. Les labs élève n'en
> dépendent pas — ils sont autonomes — mais chaque encart « vrai matériel », le tour
> filmé du chapitre 1 et les teasers décrivaient un parc qui n'existe plus. Tourner en
> l'état aurait produit du contenu faux dès la publication.
>
> Ce document est la **source unique** de ce que les encarts peuvent montrer et dire. Les
> scripts ont été réécrits le 11/10/2026 à partir de lui (§7). Le relire la veille de
> chaque tournage, et le mettre à jour quand le parc bouge — il bouge.
>
> Source de vérité côté homelab (dépôt `homelab/`) : `README.md`, le bloc « ÉTAT AU
> 02/09/2026 » en tête de `Contexte.md`, `ansible/inventory/hosts.yml`,
> `docs/opnsense.md`, `docs/supervision.md`, `docs/acces-distant.md`,
> `docs/certifications-alignement-2026-09.md`.
>
> **Point de synchronisation.** Commits du dépôt `homelab` jusqu'auxquels la formation est
> alignée, **une tête par branche** (le homelab travaille en branches, pas seulement sur `main`) :
> `homelab-sync: 0972fa2 2171609` — `main` du 13/10 (bastion, supervision et runner GitHub
> fusionnés : Kibana depuis l'iPhone par `tailscale serve`) et la branche docs du lab Elastic (03/09). Le script `scripts/suivi-homelab.sh` lit cette ligne et liste tout commit
> de toute branche, locale ou distante, qui n'en descend pas. Après chaque passe, remplacer
> les hashs par les têtes traitées (une tête fusionnée dans une autre peut être retirée).

## 1. Le parc aujourd'hui

```
                    Internet / Box FAI (192.168.1.1)
                            │
              Switch 5 ports, non managé (LS1005G)
       ┌────────────┬───────┴──────┬──────────────┐
       ▼            ▼              ▼              ▼
   pve .200     pve01 .50      pve02 .51      pve03 .52
   tour         Lenovo         Lenovo         Lenovo        cluster « vortex-cluster »
   i7 / 31 Go   16 Go          16 Go          16 Go         Proxmox VE 9.2.11
       │            │              │              │
       │        rundeck-vortex  gitlab-vortex   bastion .56 (VM 220)
       │        .53 (VM 210)    .54 (VM 211)    Tailscale + clé + TOTP
       │        artifactory     (+ Vault
       │        .55 (VM 212)    unsealer)
       │
       ├── vmbr2 ── OPNsense .254 (VM 600) ── vxse-lab-01 10.10.20.61 (VM 300)
       │            filtre réellement           stack ELK 7.17, joignable du parc
       │                                        en 192.168.1.61 (VIP + NAT 1:1)
       ├── vmbr1 ── PBS (LXC 500) 10.10.10.20, aussi sur le LAN en .220
       ├── vmbr5/vmbr6 ── LAN d'OPNsense (192.168.99.1) et 2e patte
       └── vmbr7/vmbr8 ── segments des labs de certification (10.10.99.x / 10.10.98.x)
```

| Machine | Rôle | Vit sur | Adresse |
|---|---|---|---|
| `pve` | tour, nœud « routeur » : seuls bridges internes, apt-cacher-ng, relais syslog, PBS | — | 192.168.1.200 |
| `pve01` / `pve02` / `pve03` | les 3 Lenovo M715q, réinstallés en hyperviseurs le 31/08/2026 | — | .50 / .51 / .52 |
| `rundeck-vortex` (VM 210) | Rundeck + **Vault principal** (auto-unseal par transit) | pve01 | .53 |
| `gitlab-vortex` (VM 211) | GitLab CE + runner GitLab + **Vault unsealer** (:8210) + runner **GitHub Actions** (08/10, sortie HTTPS seule : la CI joue dans le lab sans port entrant) | pve02 | .54 |
| `artifactory-vortex` (VM 212) | Artifactory OSS + moteur `vdp` + PKI Vault | pve01 | .55 |
| `bastion` (VM 220) | seule porte SSH depuis l'extérieur (Tailscale), aucun secret **ni aucune clé** : Mac (Secure Enclave) et iPhone (Termius) enrôlés les 11-12/10, clé + TOTP, puis rebond vers les hôtes internes. **Tailnet Lock** actif (signataires Mac + iPhone, jamais le bastion). Filebeat + Metricbeat ; **un mail à chaque session depuis le tailnet** et un à 3 échecs du TOTP en 10 min — validé de bout en bout le 12/10. **Kibana depuis l'iPhone** par `tailscale serve` (proxy TLS de tailscaled, certificat Let's Encrypt, écoute tailnet seulement, téléphone seul autorisé) : aucun port ouvert, 13/10 | pve03 | .56 |
| `vxse-lab-01` (VM 300) | cible VDP : stack ELK **7.17** (VXSE/VXLO/VXKI/VXFB), TLS par PKI Vault | pve, vmbr2 | 10.10.20.61 ↔ 192.168.1.61 |
| OPNsense (VM 600) | pare-feu, `onboot: 1`, 2 vCPU / 4 Go ; LAN vmbr5, WAN vmbr0, patte vmbr2 | pve | 192.168.99.1 / DHCP box |
| PBS (LXC 500) | PBS 3.4.8, datastore `vm-backups` sur HDD ~1 To | pve | 10.10.10.20 et 192.168.1.220 |

**Ce que fait le parc** : une chaîne Rundeck → moteur `vdp` → Artifactory → Ansible
reconstruit une stack ELK de zéro (critère atteint le 02/08/2026) ; Metricbeat sur les
9 machines supervisées, Heartbeat et ElastAlert sur `rundeck-vortex`, chien de garde
Rundeck, relais SMTP ; deux écrans Kibana (« Homelab — Vue d'ensemble », « Déploiements
VDP ») ; une alerte réelle éprouvée de bout en bout, panne → courrier en 3 minutes
(02/09). **Deux jours plus tard, la stack s'est arrêtée pour un mois (04/09 → 08/10) sans
un seul mail** — cinq défauts muets, §4 C2 ch.9 ; corrigés le 08/10 : job de renouvellement
des certificats importé par Ansible, jeton PKI prolongé par un timer, SMTP sur Rundeck,
`onboot` sur la VM 300, BIOS des Lenovo en *Power On*.

**Ansible** : 26 rôles, `site.yml` = 16 plays + import de `monitoring.yml`, groupes
`proxmox` (`proxmox_routeur` / `proxmox_noeuds`), `plateforme`, `cibles_elk`, `backup`,
`acces`, `supervision` (groupe de groupes). `ansible all -m ping` → 10 hôtes. Plus de
`ProxyJump` dans l'inventaire : la plateforme vit sur le LAN plat (décision révisable,
`vdp/plan.md` §6).

## 2. Ce que disaient les scripts, et ce qui est vrai

| Dans les scripts de juillet | Aujourd'hui | Où c'est corrigé |
|---|---|---|
| « 2 Lenovo, cluster K3S » | 3 Lenovo, **hyperviseurs Proxmox** ; K3S libéré en août, archivé dans `docs/archive/` ; l'entraînement Kubernetes se fait sur des mini-labs kubeadm jetables (`cka/`, `cks/`) | C0 ch.1 (script, plan, quiz), C2 ch.6, C3 ch.8 |
| « 10 VMs Debian » sur un nœud | 7 invités permanents sur 4 nœuds (3 VMs plateforme Rocky 9, cible ELK, bastion, OPNsense, LXC PBS) + labs de certification éphémères (91xx) | C0 ch.1-3, 5-7, YouTube |
| « 4 segments 10.10.10/20/30/40 » | la plateforme est sur le **LAN plat** ; seul le segment ELK `10.10.20.0/24` est habité, derrière OPNsense ; `vmbr7`/`vmbr8` pour les labs ; les Lenovo n'ont que `vmbr0` | C0 ch.4 |
| « ELK, GitLab, Vault sans Internet » | seule la cible ELK est sur un segment interne ; GitLab et Vault sont sur le LAN | C0 ch.4 |
| PBS « hors périmètre, 10 VMs » | job vzdump **natif du cluster**, toutes les VMs, 02:00, rétention 7j/4s/2m, verify lundi 05:00, mail sur échec, joignable en `.220` ; restauration prouvée (28/06 et 02/08) ; **même châssis** que les données | C0 ch.6 |
| inventaire avec `ProxyJump` via Proxmox, groupes `elk`/`devsecops`/`services` | groupes `proxmox`/`plateforme`/`cibles_elk`/`backup`/`acces`/`supervision`, variables par hôte (`vdp_vmid`, `vdp_noeud`, `vortex_fqdns`), bastion dédié | C1 ch.2 |
| « 24 rôles », `roles/dns` + `dig @10.10.40.11` | **26 rôles** ; `dns` archivé (`docs/archive/ansible-pre-pivot/`), résolution par `/etc/hosts` généré depuis l'inventaire (`vortex_socle`) ; montrer `syslog_relay` | C1 ch.4 |
| `group_vars/elk`, `devsecops`, `elk/vars.yml` | `group_vars/all`, `backup/`, `supervision.yml` + `host_vars/` par VM ; `vortex_vault_seal_transit` en host_vars (panne du 23/09) | C1 ch.5 |
| `site.yml` « 10 plays, une trentaine de rôles » | **16 plays** + import supervision ; ordre documenté en tête ; a dérivé un mois (12 groupes disparus) | C1 ch.3, ch.7 |
| « VMs recréables depuis les playbooks » | `provision-plateforme.yml` pour la plateforme, **`vdp rebuild`** (job Rundeck) pour la cible ELK | C1 ch.8 |
| Kibana « 2 millions de documents », dashboards par service (DNS, proxy, K3S…) | Kibana **7.17** en HTTPS authentifié, index `vortex-logs-*` / `vortex-metrics-*` / `vortex-uptime-*`, 2 tableaux de bord générés par playbook ; compteur à relever le jour J | C2 ch.1, ch.5, ch.8 |
| « la même CA signe ES, Kibana, GitLab et Vault » | racine « Vortex Homelab CA », **moteur PKI Vault** `*.vortex.local`, certs 72 h renouvelés tous les 2 jours (job Rundeck) ; racine sans `keyUsage` (dette, `docs/supervision.md` §8 quinquies) | C2 ch.3, C3 ch.6 |
| Filebeat partout + DaemonSet K3S | Filebeat multi-distro sur la plateforme et PBS, Metricbeat sur 9 machines ; plus de K3S | C2 ch.6 |
| OPNsense → « 5514 de Logstash », index `logstash-syslog-*`, `syslog_hostname: OPNsense.internal` | OPNsense → relais `pve:514` (rôle `syslog_relay`) → Logstash **5140/udp** → `vortex-logs-*`, `application: opnsense`, équipement d'origine en `logsource` | C2 ch.7, ch.9, C3 ch.1, ch.5 |
| OPNsense « Phase 1 lab, VM laissée arrêtée » | **en service**, `onboot: 1`, filtre réellement : VIP `192.168.1.61` NAT 1:1 → `10.10.20.61`, seuls 22/5044/5140udp/9200/5601 passent, prouvé (port 9999 refusé du parc) | C3 ch.1-3, ch.5 |
| `proxmox_firewall` « zones management/elk/devsecops » | `cluster.fw` (4 nœuds) + `host.fw` + zones par VM ; recentré sur `proxmox_routeur` (`pct` ne marche que localement) ; `log_level_in` invalide au niveau cluster | C3 ch.4 |
| Vault : `vault-unseal.yml`, clés dans le vault Ansible `devsecops`, cert « CA ELK » | **auto-unseal par transit** (unsealer sur gitlab-vortex), aucune clé sur le disque du principal, Shamir = recovery ; cert de la racine Vortex ; `vault-unseal.yml` archivé | C3 ch.6 |
| « tes deux nœuds K3S attendent », « WireGuard sur OPNsense » | kubeadm sur 2 VMs ; accès distant = **bastion + Tailscale**, clé liée à l'appareil + TOTP — Mac enrôlé le 11/10, iPhone le 12/10/2026 ; WireGuard archivé | C3 ch.8 (script + projet) |
| Teaser des 4 cours dans C0 ch.1 (ordre et contenus faux : « cours 1 réseau, 2 services, 3 automatisation ») | ordre réel 0 Fondations, 1 Ansible, 2 ELK, 3 Sécurité — incohérence antérieure au pivot, corrigée au passage | C0 ch.1 §6 |

## 3. Ce qui n'a pas bougé (à filmer tel quel)

- La tour : i7-6700K, 31 Go, `192.168.1.200`, port 8006, PVE 9 en dépôts deb822 (la
  version mineure a bougé : lire `pveversion` à l'écran).
- cloud-init partout, jamais d'installateur. Template Debian 12 `901` sur la tour
  (`scripts/create-templates.sh`) — vérifier qu'il existe encore avant de le filmer.
- `apt-cacher-ng` sur la tour pour les segments sans Internet ; masquerade **temporaire**
  pour installer des paquets (désormais posé et retiré par le rôle `proxmox_lab_bridges`).
- OPNsense VM 600 : LAN `192.168.99.1` sur `vmbr5`, WAN DHCP sur `vmbr0`, 2 vCPU / 4 Go,
  installé sur disque (la panne tmpfs du C3 ch.2 reste vraie et résolue), Suricata en
  détection sur le WAN avec 9 rulesets (7 ET open + 2 abuse.ch), syslog vers
  `192.168.1.200:514`.
- Le relais syslog sur la tour (C2 ch.7) : même mécanisme, désormais un rôle.
- Le switch non managé TP-Link LS1005G, le T2600G en réserve.
- Le fiasco Vault du 06/07 (clés jamais sauvegardées, réinit) : historique, toujours vrai.
- `host_key_checking`, ProxyJump via un bastion, `--limit/--check/--diff` : inchangés.

## 4. Pannes réelles survenues depuis juillet, rangées par chapitre

Toutes sont documentées dans le dépôt `homelab` (hash de commit ou document). Celles
marquées ✍️ sont déjà intégrées au script ; les autres sont en réserve pour la FAQ, un
hors-série ou une V2.

| Cours · chap. | Panne | Source homelab |
|---|---|---|
| C0 ch.3 ✍️ | cloud-init régénère `/etc/hosts` à chaque boot ; `manage_etc_hosts: false` ne suffit pas (user-data Proxmox prioritaire), retirer `update_etc_hosts` | `0218f7f` |
| C0 ch.3 ✍️ | CPU `kvm64` par défaut : Rocky 9/10 panique au boot (« CPU does not support x86-64-v2 ») → `--cpu host` | `certifications-alignement-2026-09.md` §3a |
| C0 ch.5 ✍️ | `qm clone` d'image cloud sur ZFS → kernel panic ; `import-from` à la place | `provision-plateforme.yml` (en-tête) |
| C0 ch.6 ✍️ | la cron vzdump listait des VMIDs disparus au pivot : échec chaque nuit pendant un mois | `9019900` |
| C0 ch.6 ✍️ | la sauvegarde de l'unsealer visait une adresse devenue un hyperviseur : deux mois sans sauvegarde, en silence | `6e9fa8a` |
| C0 ch.6 ✍️ | PBS sur un disque du même châssis : risque hors-boîtier non couvert | `Contexte.md` |
| C0 ch.4 ✍️ | un bridge sans port physique n'existe que sur son nœud : une VM posée dessus y est clouée | `proxmox_lab_bridges` |
| C1 ch.4 ✍️ | rôle `dns` archivé avec le parc qu'il servait ; archiver du code, pas supprimer à la main | `714d34c` |
| C1 ch.4 | `common` codait en dur `/usr/lib/openssh/sftp-server` (Debian) : sur Rocky, SFTP mort, Ansible retombe en silence sur un transfert dégradé | `5001cd8` |
| C1 ch.5 ✍️ | `vortex_vault_seal_transit` posée dans `site.yml` seulement : `vortex-vault.yml` lancé seul retirait le sceau → Vault scellé | `724fb25` |
| C1 ch.7 ✍️ | `site.yml` orchestrait 12 groupes disparus : plus jouable pendant un mois | `714d34c` |
| C1 ch.7 | `/etc/hosts` et templates d'index à rejouer après tout `vdp rebuild` (cloud-init, réplicas) | `e05bd3e` |
| C1 ch.6 (secrets) | un mot de passe personnel en `user.email` dans **207 commits** poussés ; garde-fou de commit versionné, rotation à faire | `docs/secret-dans-l-historique.md`, `c636217` |
| C1 ch.6 (secrets) | `scripts/secret --poser` : une lecture ratée (jeton expiré, Vault scellé) retombait sur un secret vide et l'écriture kv-v2 effaçait les autres champs → check-and-set | `306a6d4` |
| C2 ch.2 | le dépôt apt/dnf `9.x` sert la dernière 9.x (9.5.2 le 02/09) alors que l'examen est en 9.3 : **épingler** la version | `b34cd84`, `elastic/DEMARRAGE.md` |
| C2 ch.2 | le canal du dépôt n'est pas la version : `packages/7.x/` existe, `packages/7.17/` non (404 muet) | `9cccda7` #1 |
| C2 ch.3 ✍️ | CA racine sans `keyUsage` : acceptée par curl, refusée par Python/Debian 13 → `uri` vers Vault échoue depuis les hyperviseurs seulement | `docs/supervision.md` §8 quinquies |
| C2 ch.4 | input syslog : `host` en chaîne vs objet des Beats → 400 silencieux dans l'index partagé ; RFC 3164 attendu, `logger` émet du 5424 | `3f78fcc` |
| C2 ch.4 | ILM avec rollover sans alias : chaque index en ERROR step, la phase delete jamais atteinte, disque qui se remplit | `9cccda7` #5 |
| C2 ch.5 ✍️ | bundle NDJSON visant `logstash-*` importé sans erreur sur du vide ; un panneau importé peut rester vide | `7736286` |
| C2 ch.6 ✍️ | Beat en clair vers Logstash TLS : « connection reset by peer », événements jetés | `9cccda7` #2 |
| C2 ch.6 ✍️ | Metricbeat sur la cible visait Logstash par l'adresse publique (épingle via OPNsense) : 455 reconnexions, 0 métrique de la machine qui porte la stack | `7736286` |
| C2 ch.7 ✍️ | relais syslog vers une VM décommissionnée pendant un mois, aucune erreur (UDP) | `3f78fcc` |
| C2 ch.7 | 5 sondes sur 8 visaient la mauvaise cible : Kibana en https/401, GitLab en clair, Artifactory 403, « switch » sans IP, « OPNsense » = la box | `9cccda7` #6 |
| C2 ch.8 ✍️ | `system.cpu.total.pct` non normalisé par cœur : 101,2 % affichés | `7736286` |
| C2 ch.8 ✍️ | sonde ICMP vers une VIP derrière un pare-feu TCP-only : down sur 1 217 contrôles, rien en panne | `7736286`, `heartbeat/defaults` |
| C2 ch.8 ✍️ | ElastAlert alertait sur ses propres index (réplica impossible en mono-nœud → cluster jaune) | `a547a3c` |
| C2 ch.8 | un play qui échoue ne déclenche pas ses handlers : Heartbeat a sondé 18 h avec une conf périmée → `force_handlers: true` ; Heartbeat ne relit sa conf qu'au démarrage → rendre, valider, puis mettre en service | `7736286` |
| C2 ch.9 ✍️ | ElastAlert n'avait **jamais** tourné : PermissionError au démarrage, relancé en boucle par systemd, `active (running)` à chaque cycle | `1617754` |
| C2 ch.9 ✍️ | chaîne d'alerte éprouvée : sonde → Logstash → ES → ElastAlert → webhook Rundeck → mail, 3 min ; le chien de garde existait en fichier depuis 10 jours sans avoir été importé | `254fe2a` |
| C3 ch.3 ✍️ | `blockpriv` sur un WAN qui donne sur un LAN privé bloque tout le parc | `4bb3c6f`, `docs/opnsense.md` |
| C3 ch.3 ✍️ | `reply-to` renvoie les réponses à la box quand le demandeur est sur le même segment : « timed out during banner exchange » | idem |
| C3 ch.3 ✍️ | retour en épingle : depuis l'intérieur `localhost`, depuis l'extérieur l'adresse d'accès | idem |
| C3 ch.3 ✍️ | VIP et NAT 1:1 ne s'écrivent pas dans `config.xml` à la main (alias 127.0.0.1 posé) | idem |
| C3 ch.4 ✍️ | `log_level_in` refusé au niveau cluster, ignoré en silence | `a64c6d6` |
| C3 ch.4 ✍️ | `firewalld` installé mais arrêté : invisible, puis actif au premier reboot, coupe le 8200 de Vault | `0218f7f`, `a64c6d6` |
| C3 ch.4 ✍️ | `pct` ne fonctionne que sur le nœud hébergeant le conteneur : rôle recentré sur la tour | `a64c6d6` |
| C3 ch.5 ✍️ | OPNsense en `onboot: 0` : la détection aurait disparu au prochain reboot de la tour, en silence ; surveillé par ce qu'il émet (règle « hôte muet ») | `920e561` |
| C3 ch.6 ✍️ | `cut -d=` tronque le padding base64 d'une clé d'unseal (43 car. au lieu de 44) : catastrophe évitée | `vdp/runbook-vault-autounseal-transit.md` |
| C3 ch.6 ✍️ | auto-unseal par transit vérifié par un vrai reboot ; `Restart=on-failure` sinon une panne de courant est fatale | `0218f7f` |
| C3 ch.7 (hygiène) | voir C1 ch.6 : secret dans l'historique git, garde-fou, `scripts/secret` | ci-dessus |
| C3 ch.8 / bastion | 1 Go de RAM : `dnf` tué par l'OOM ; `PermitOpen` non trié → sshd redémarrait à chaque passage ; politique Tailscale collée en commentaire = règle par défaut active, révélé seulement par le filtre compilé | `docs/acces-distant.md` |
| C3 ch.8 / bastion | `LoginGraceTime 20` : Face ID + saisie du code TOTP dépassaient 20 s depuis l'iPhone, et chaque dépassement coûte 90 s de pénalité (`PerSourcePenalties`, OpenSSH ≥ 9.8) → 60 s. Termius : le champ *Password* de l'hôte doit rester vide, sinon l'app répond seule à l'invite TOTP | `50213c4` |
| C3 ch.8 / bastion | compromis assumé et écrit : la clé de l'iPhone (Termius) est exportable, celle du Mac (Secure Enclave) non ; compensé par Face ID, TOTP et bientôt Tailnet Lock. Élargir la politique Tailscale (téléphone → 22 **et** 443) impose de réécrire ses `tests` — c'est le but | `50213c4`, `docs/tailscale-policy.hujson` |
| C0 ch.7 · C1 ch.2 | le bastion ne détient **aucune clé** : la clé de l'appareil est posée sur les hôtes internes (rôle `cles_distantes`, `exclusive: false` pour ne pas écraser celles de cloud-init et du moteur vdp) et l'authentification part du téléphone jusqu'à la machine cible, en rebond. Piège client : `IdentitiesOnly yes` avec un agent (Secretive) exige un `IdentityFile` pointant sur la **clé publique**, sinon la clé n'est jamais proposée | `84ed3d3`, `docs/acces-distant.md` |
| C3 ch.7 | les clés **publiques** des appareils sont versionnées en clair (`scripts/keys/*.pub`) et chargées par `lookup('file')` ; les privées ne quittent jamais l'appareil — l'exact inverse du trousseau `ansible-vault` | `50213c4` |
| C2 ch.9 ✍️ · C3 ch.5 ✍️ | **un détecteur sans liste d'IP** : depuis le tailnet sshd exige clé PUIS TOTP, depuis le LAN clé seule ; « `Accepted keyboard-interactive/pam` » n'apparaît donc QUE pour une session venue de l'extérieur. Règle ElastAlert `bastion-connexion` : un mail par session (`realert: 0`), `bastion-echecs` : 3 échecs en 10 min (`realert: 30`). Testée en vrai depuis l'iPhone : 2 sessions 23:28-23:29, règle exécutée 23:30, mails reçus | `39569d9`, `3a7e8bf`, `docs/acces-distant.md` phase 4 |
| C2 ch.6 | sur Rocky l'unité s'appelle `sshd`, pas `ssh` : `journalctl -u ssh` rend une sortie **vide sans erreur**. Même famille que « rules download OK, 0 règle » : une commande qui réussit sans rien dire | `3a7e8bf` |
| C2 ch.9 | contrôle rapide d'ElastAlert sans lire ses logs : les index `elastalert_status` (alertes émises, `alert_sent`) et `elastalert_status_status` (runs, nombre de correspondances) | `3a7e8bf` |
| C3 ch.8 / bastion | **Tailnet Lock** : aucun appareil n'entre dans le réseau maillé sans signature du Mac ou de l'iPhone — le bastion n'est jamais signataire ; deux secrets de désactivation sur papier. Pièges CLI : sans `--confirm`, `lock init` n'est qu'un aperçu et n'active rien ; `--gen-disablements N` ; `tailscale ping` répond « timed out » les premières secondes. Un bastion reconstruit reste « locked out » tant qu'il n'est pas signé | `39569d9`, `docs/acces-distant.md` |
| C3 ch.8 / bastion | avant d'accuser le bastion : l'app Tailscale de l'iPhone était simplement déconnectée (le bastion la voyait hors ligne). Vérifier le client avant le serveur | `3a7e8bf` |
| C2 ch.5 ✍️ · C3 ch.1 ✍️ | **Kibana sur le téléphone sans ouvrir un port** : `tailscale serve` sur le bastion proxifie Kibana en HTTPS sur l'adresse tailnet seulement ; l'appareil est authentifié par Tailscale + Tailnet Lock, la personne par la mire Kibana. Effet de bord accepté : le nom `bastion.<tailnet>.ts.net` apparaît dans les journaux de transparence des certificats (nom seul) | `bc422ec`, `docs/acces-distant.md` |
| C2 ch.3 ✍️ | un processus Go (tailscaled) ne relit pas le magasin de confiance système : chaîne de CA installée, proxy qui refuse toujours Kibana — jusqu'au redémarrage du service (`flush_handlers` avant de configurer) | `bc422ec` |
| C3 ch.8 / bastion | `tailscale serve` sans « Serve » activé sur le tailnet affiche un lien puis **attend sans fin** : play bloqué 10 min. Borné par `timeout 60 … --yes`, refus expliqué. Et `pkill -f "tailscale serve"` lancé via `ssh host '…'` tue la session ssh elle-même (le motif est dans la ligne de commande du shell distant) : ancrer avec `^` | `bc422ec` |
| C3 ch.3 ✍️ | Safari envoie en **http (port 80)** quand on tape le nom sans `https://` ; la politique ne laisse passer que le 443 → « Kibana ne répond plus ». Journal tailscaled : `Drop: TCP{… > …:80} no rules matched`. Choix assumé : on n'ouvre pas le 80, même pour rediriger — on épingle l'URL complète | `8725bc7` |
| C3 ch.7 | en réserve : des clés publiques dont le **commentaire** est un mot de passe (pve, VMs) — un secret qui se promène en clair dans `authorized_keys` | `docs/acces-distant.md` « Reprendre ici » |
| C2 ch.9 ✍️ | **la panne d'un mois** (04/09 → 08/10) : certificats Metricbeat (TTL 72 h) expirés car le job de renouvellement avait disparu, jeton PKI mort, VM 300 sans `onboot` ; le chien de garde a vu la panne **391 fois** mais Rundeck n'avait pas de SMTP, chaque mail échouait. Qui surveille le surveillant ? Tester la chaîne d'alerte en la faisant **échouer** | `830f78e`, `docs/supervision.md` §8 quater |
| C1 ch.8 ✍️ | un job Rundeck créé **à la main** le 02/08 (hors dépôt) a disparu à la reconstruction du 31/08 — et avec lui le renouvellement des certificats. Ce qui n'est pas dans le dépôt n'existe pas ; désormais importé par le rôle `vortex_rundeck_projet` | `830f78e` |
| C3 ch.6 ✍️ | un jeton Vault **périodique** (720 h) ne se prolonge pas en servant : seul `renew-self` le fait. Mort début octobre, il bloquait même le renouvellement manuel. Timer systemd nocturne, `Persistent=true` | `830f78e` |
| C3 ch.1 ✍️ | piloter le lab de l'extérieur **sans ouvrir un port** : runner GitHub Actions sur gitlab-vortex qui interroge github.com en sortie ; vault pass et clé SSH restent dans le lab. Workflow : lint à chaque push, `ansible all -m ping` et `site.yml --check --diff` à la demande | `3e44693`, `docs/github-runner.md` |
| C0 ch.3 / ch.7 | VM 300 sans `onboot` : après chaque coupure, tout le parc revenait sauf la stack ; BIOS des Lenovo en *After Power Loss = Last State* → `Power On` (`think-lmi`). Vérifier `onboot` et le BIOS avant de parler de « reprise automatique » | `830f78e` |
| C1 ch.3 | CI du dépôt : `yamllint`, `ansible-lint --offline` (profil production) et `--syntax-check` sur chaque push, dans le lab | `3e44693` |
| C1 ch.2 ✍️ | `ansible.cfg` n'est lu que dans le **répertoire courant** et porte `inventory` et `roles_path` en relatif : lancé depuis la racine du dépôt, « No inventory was parsed » puis « role … was not found » alors que le rôle est là. C'est la raison du `cd` en tête de chaque `demo.sh` | `89d25bf` |
| C2 ch.2 ✍️ | un pin posé **avant** l'installation ne verrouille rien (`dnf versionlock` sur un paquet absent écrit une ligne par version du dépôt, 49 pour kibana, et la liste est un allowlist) ; aucun message, le lock « existe ». Épingler après, et **vérifier** le pin : une ligne par paquet | `89d25bf` |

## 5. À trancher avant tournage

1. **Épingler la version Elastic du cours 2 — fait le 11/10/2026.** Les quatre rôles
   distinguent désormais le canal du dépôt (`*_repo_channel`, `9.x`) de la version du
   paquet (`*_version`, `9.3.8`, figée par `dpkg hold`), avec `elastic_version` /
   `elastic_repo_channel` surchargeables d'un bloc dans `group_vars/lab`. 9.3.8 = la
   version de l'examen Elastic Certified Engineer et du lab `elastic/` du homelab,
   vérifiée disponible le 02/09/2026 (`b34cd84`). Non rejoué sur le lab ; les tags
   `c2-*` restent sur la version non épinglée.
2. **Kibana 7.17 à l'écran, cours en 9.x.** L'écart d'interface se voit. Deux options :
   l'assumer en une phrase (fait dans C2 ch.1), ou filmer les encarts Kibana sur le lab
   Elastic 9.3 de `elastic/` (3 nœuds, mais pas de Suricata ni de supervision dessus).
3. **Quel switch est branché ?** `README.md` (01/09) dit LS1005G ; `Contexte.md` note un
   SG3424P d'occasion câblé le 02/08, verrouillé, laissé en L2. Vérifier le jour J ; le
   script dit « switch cinq ports non managé », ce qui est vrai dans les deux cas.
4. **Ne pas rejouer le lab élève sur la tour sans précaution** : `10.10.99.0/24` est
   désormais pris par `vmbr7` (labs RHCSA/RHCE/CKA/Elastic, VMIDs 91xx ; es-01..03 en
   `.41`-`.43` depuis le 02/09, `2171609`), et le lab élève utilise le même réseau sur
   `vmbr1` et des VMIDs 9000-9204 — `.11`, `.12`, `.14`, `.2` libres côté vmbr7 mais le
   routage ne saurait pas lequel des deux bridges viser. Collision garantie. Filmer
   les démos élève sur le chemin A (VirtualBox) ou sur un nœud sans lab.
5. **`--cpu host`** : sans objet tant que le lab élève est en Debian 12. Si un jour le lab
   passe sur Rocky, c'est un prérequis du chapitre 3 du cours 0.
6. **C3 ch.7 (rotation & hygiène)** n'a pas d'encart « vrai matériel » ; la panne du
   mot de passe dans 207 commits (`docs/secret-dans-l-historique.md`) en est un
   candidat évident — à écrire quand la rotation aura été faite, pour pouvoir la montrer.
7. **Les VMs de labs de certification** (91xx) apparaissent dans la vue Datacenter quand
   elles existent. Les arrêter ou les détruire (`reset-*.sh` les recrée) avant de filmer
   le chapitre 1 : « chaque VM a son métier » ne tient pas avec des `servera`/`cks-node`.

8. **Défaut lab-élève trouvé au passage — corrigé le 11/10/2026 (fix b ci-dessous).** Le cours 3
   (ch.5 et ch.8 : `demo.sh`, `tp.md`, `correction/commandes.md`, `attaque.sh`, `projet.md`,
   les deux quiz et les scripts) envoie l'élève chercher les alertes Suricata dans l'index
   **`logstash-syslog-*`** avec le filtre **`syslog_hostname : "OPNsense.internal"`**. Ce
   sont les noms de l'**ancienne infra réelle** (`docs/opnsense.md` de juillet), pas ceux
   du lab : le pipeline du cours 2 (`ansible-extraits/roles/logstash/templates/pipeline.conf.j2`)
   écrit tout dans `logstash-%{+YYYY.MM.dd}` via des inputs `tcp`/`udp` typés `syslog`,
   sans grok syslog — il n'existe ni index `logstash-syslog-*` ni champ `syslog_hostname`.
   Le TP du chapitre 5 et le projet final ne peuvent pas aboutir tels quels. Deux fixes
   possibles : (a) côté cours 3 seulement, filtrer `logstash-*` sur
   `type : "syslog" and message : "OPNsense"` ; (b) côté cours 2 ch.7, ajouter un grok
   syslog au pipeline (champ `logsource` ou `syslog_hostname`) et un index dédié — plus
   juste pédagogiquement, mais ça rouvre les tags `c2-chap7-fin` et suivants.
   **Fait (b)** : le chapitre 7 du cours 2 gagne une étape 2.5/2.6 — grok syslog
   (`syslog_hostname`, `syslog_program`, `syslog_pid`, `syslog_message`, tag
   `_syslogparsefailure`) et sortie `logstash-syslog-*` dans le template du rôle
   `logstash` ; démo, TP et correction du chapitre 7 filtrent sur `syslog_hostname` ; le
   cours 3 reste tel quel, hormis le hostname d'exemple, passé de `OPNsense.internal`
   (ancienne infra réelle) au défaut OPNsense `OPNsense.localdomain`. **À valider sur le
   lab** (le motif grok a été testé hors ligne sur les formats rsyslog/syslog-ng, pas sur
   un Logstash réel), puis déplacer les tags `c2-chap7-fin`, `c2-chap8-fin`, `c2-fin` et
   `c3-*` si l'on veut qu'un `git checkout` d'étape embarque le correctif.

9. **Prérequis Ansible — fait le 11/10/2026** : le cours 1 demande désormais `≥ 2.16`
   (le homelab l'exige et épingle `ansible-core` en CI ; 2.15 n'est plus maintenu).

## 6. Ce qui reste à vérifier sur le parc, le jour J

- `qm list` sur chaque nœud : VMs permanentes 210/211/212/220/300/600 + LXC 500, template
  901 présent.
- Kibana (`https://192.168.1.61:5601`) : les deux tableaux de bord alimentés, sondes
  vertes, un document `application: opnsense` de moins d'une minute.
- OPNsense : `Services > Intrusion Detection` running, nombre de règles à lire.
- PBS (`https://192.168.1.220:8007`) : dernière sauvegarde de la nuit OK, ratio de dédup.
- `ansible all -m ping` → 10 pongs ; `ansible-playbook playbooks/site.yml --check` vert.
- `vault status` sur rundeck-vortex : `Sealed false`, `Seal Type transit`.
- Depuis le tailnet (Mac) : `ssh bastion-ts` accepté (Touch ID puis code TOTP), et un
  `ssh pve01-ts hostname` en rebond. Adresse `100.x` jamais à l'écran.
- Rundeck : le job `vdp/renew-certs-nova` a tourné cette nuit (succès), et un job d'échec
  jetable produit un **mail reçu** — pas seulement « envoyé ».
- Bastion : une session depuis le tailnet (Mac ou iPhone) déclenche le mail
  « connexion au bastion depuis le tailnet » dans les 2 minutes (règle ElastAlert, index
  `elastalert_status` à montrer). `tailscale lock status` = ENABLED sur le bastion.
- iPhone : Kibana s'ouvre sur `https://bastion.<tailnet>.ts.net` (app Tailscale connectée),
  mire de login puis « Homelab — Vue d'ensemble ». Le nom du tailnet ne passe pas à l'écran.
- GitHub → Actions : dernier workflow `homelab-ansible` vert, runner `gitlab-vortex` *Idle*.

## 7. Fichiers modifiés le 11/10/2026

Chaque script modifié porte, sous son titre, la note « 🔄 Encart « vrai matériel »
réaligné le 11/10/2026 ».

- `README.md` — paragraphe « Réalignement ».
- Cours 0 : `chap-1/plan-tournage-infra-reelle.md` (réécrit), `chap-1/script-video.md`
  (tour, schéma, teaser des 4 cours), `chap-1/quiz.md` (Q5 option A), `chap-2`, `chap-3`,
  `chap-4`, `chap-5`, `chap-6`, `chap-7` (`script-video.md`), `youtube-video-appel.md`.
- Cours 1 : `chap-2`, `chap-3`, `chap-4`, `chap-5`, `chap-7`, `chap-8` (`script-video.md`).
- Cours 2 : `chap-1`, `chap-3`, `chap-5`, `chap-6`, `chap-7`, `chap-8`, `chap-9`
  (`script-video.md`).
- Cours 3 : `chap-1`, `chap-2`, `chap-3`, `chap-4`, `chap-5`, `chap-6`, `chap-8`
  (`script-video.md`), `chap-8/projet.md`.

**Non modifiés le 11/10, volontairement** : tout le matériel élève, les extraits Ansible et
les tags — le lab élève est autonome et ne dépend pas du parc réel. (Le 12/10, l'audit a
ensuite corrigé le matériel élève pour ses défauts propres et reposé les tags : §8 et
`evaluation-2026-10-12.md`.)

## 8. Journal des synchronisations avec le dépôt `homelab`

Une entrée par passe de `scripts/suivi-homelab.sh` ayant donné lieu à des modifications.

- **11/10/2026** — point de départ, `5e0feb5` (bastion : TOTP depuis le tailnet). Réalignement
  complet des encarts (§7), correctif syslog du cours 2 ch. 7, épinglage Elastic 9.3.8.
- **12/10/2026** — `50213c4`, `84ed3d3`, `2d42e71` (bastion : enrôlement du Mac et de
  l'iPhone, rôle `cles_distantes`, `LoginGraceTime` 60 s). Mis à jour : §1 (ligne bastion),
  §2, §4 (cinq lignes bastion / clés), §6 ; encarts de C0 ch.7, C1 ch.2, C3 ch.7 et C3 ch.8.
  Matériel élève intact : aucune pratique enseignée ne change.
- **12/10/2026 (bis)** — le script ne regardait que la branche courante : deux branches
  homelab non fusionnées n'avaient jamais été vues. `830f78e` (`fix/supervision-certs-et-alertes` :
  la panne d'un mois de la stack ELK, cinq défauts muets) et `3e44693`
  (`feat/github-runner-ci` : runner GitHub Actions dans le lab). Marqueur multi-têtes,
  scan de toutes les branches (depuis le pivot, 08/2026). Également `2171609`
  (`docs/elastic-pieges-demarrage`, 03/09 : `ansible.cfg` lu dans le seul répertoire
  courant, pin inerte posé avant l'installation, vmbr7 partagé). Mis à jour : §1
  (gitlab-vortex, paragraphe supervision), §4 (huit lignes), §5 décision 4, §6 ; encarts
  de C1 ch.2, C1 ch.8, C2 ch.2, C2 ch.9, C3 ch.1, C3 ch.6 et C3 ch.8.
- **12/10/2026 (ter)** — audit complet de la formation contre sa spec et le homelab
  (`docs/evaluation-2026-10-12.md`) : 14 bloquants élève corrigés, 24 tags reposés depuis
  `main`, 4 encarts oubliés réalignés (C1 ch.1 et ch.6, C2 ch.2 et ch.4), quiz et durées.
  Addendum de spec déposé côté homelab :
  `docs/superpowers/specs/2026-10-12-formation-addendum-post-pivot.md`. Aucun commit
  homelab nouveau : marqueur inchangé.
- **12/10/2026 (quater)** — `39569d9`, `3a7e8bf` (bastion : Tailnet Lock, Filebeat +
  Metricbeat sur le bastion, règles ElastAlert `bastion-connexion` / `bastion-echecs`,
  validées par mails reçus). Mis à jour : §1 (ligne bastion), §4 (cinq lignes), §6 ;
  encarts de C0 ch.7, C2 ch.9, C3 ch.5 et C3 ch.8. Matériel élève intact.
- **13/10/2026** — `bc422ec`, `8725bc7`, puis fusion des branches dans `main` (`0972fa2`) :
  Kibana depuis l'iPhone par `tailscale serve`, port 80 refusé par la politique. Mis à
  jour : §1 (ligne bastion), §4 (cinq lignes), §6 ; encarts de C2 ch.3, C2 ch.5, C3 ch.1 et
  C3 ch.3. Marqueur réduit à deux têtes (`main` + la branche docs Elastic). Matériel élève intact.
