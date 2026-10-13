# Évaluation de la formation au 12/10/2026 — est-elle au point par rapport à son but ?

> Rapprochement entre la spec de conception (`homelab/docs/superpowers/specs/2026-07-06-formation-homelab-design.md`,
> validée le 06/07/2026), le matériel réellement présent dans ce dépôt (4 cours, 33 chapitres,
> ~109 000 mots, 24 tags) et l'état du dépôt `homelab` (synchronisé jusqu'à `2d42e71`, `830f78e`,
> `3e44693`, `2171609`). Audit en lecture seule : quatre relectures de cours chapitre par chapitre,
> chaque défaut cité ci-dessous a été **revérifié dans les fichiers** avant d'être retenu.

## 1. Verdict

**La formation n'est pas prête à tourner.** Le fond pédagogique est solide et les encarts « vrai
matériel » sont désormais justes, mais **aucun des quatre labs élève ne s'exécute de bout en bout
tel qu'écrit** : le cours 0 ne dépose jamais la clé du poste dans les VMs, le cours 1 ne peut pas
tenir sa promesse `changed=0`, le cours 2 interroge des champs que son pipeline ne produit pas,
le cours 3 s'appuie sur un bridge que l'élève n'a jamais créé. Les 24 tags de correction datent
des 6-7 juillet et ne contiennent ni la revue du 11 juillet ni les correctifs d'octobre.

Le critère de succès n° 1 de la spec — « un débutant termine le cours 0 **sans aide extérieure** »
— ne serait pas atteint aujourd'hui, et le bêta-test qui devait le prouver n'a pas démarré
(`cours-0-fondations/beta-resultats.md` : 🔲 non démarré).

| Critère | C0 | C1 | C2 | C3 | Lecture |
|---|---|---|---|---|---|
| A. Conformité à la spec | 8 | 7 | 7 | 7 | Curriculum respecté ; pannes 💥 présentes sauf C2 ch.2/4/7 (« astuces ») |
| B. Cohérence interne | 6 | 5 | 5 | 6 | IPs/VMIDs/noms irréprochables ; **les sorties annoncées ne sont pas celles que le lab produit** |
| C. Exécutabilité élève | 5 | 6 | 7 | 3 | Le vrai sujet, voir §2 |
| D. Encarts « vrai matériel » | 9 | 8 | 7 | 9 | Post-pivot et sourcés ; 4 encarts oubliés le 11/10 (C1 ch.1 et ch.6, C2 ch.2 et ch.4) |
| E. Adéquation débutant | 7 | 8 | 8 | 7 | Analogies, résultats attendus, indices : bon niveau |
| F. Chaîne inter-cours | 4 | 6 | 8 | 6 | `lab-depart.md` collent entre eux ; mais le chemin A et les tags cassent le rattrapage |

Notes sur 10, attribuées par relecture indépendante de chaque cours puis vérifiées.

## 2. Les défauts qui bloquent un élève (tous vérifiés)

### Cours 0 — Fondations
1. **La clé SSH déployée dans les VMs est celle du nœud, pas celle du poste.** `qm set --sshkeys
   ~/.ssh/id_ed25519.pub` tourne sur le nœud (`chap-3/demo.sh:16`, `chap-5/correction/tp.sh:10`,
   script ch.3 : « si tu n'as pas de clé sur le nœud, `ssh-keygen` t'en fait une »). Le chapitre 0
   ne copie la clé du poste que vers le nœud. Résultat : `ssh alpha@IP_DE_TON_BASTION` depuis le
   poste (`cours-1-ansible/lab-depart.md:44`) échoue en `Permission denied` — le cours 1 ne démarre pas.
2. **Masquerade sans `ip_forward`** (`chap-4/demo.sh:31-36`) : la démo « on ouvre, on prouve, on
   referme » échoue au `ping`, et la règle NAT reste ouverte. Le forwarding n'est activé qu'au TP.
3. **`apt upgrade` sur un segment sans Internet** (`chap-5/tp.md:16-18`, `correction/tp.sh:13-17`,
   masqué par `|| true`) : le « template doré à jour » ne l'est pas, sans message.
4. **Chemin A (VirtualBox) : le bastion est injoignable depuis le poste.** Seuls 8006 et 2222→22
   sont redirigés vers le nœud (`labs/chemin-a-virtualbox.md:67-73`) ; la patte vmbr0 du bastion
   n'a pas de redirection. Tout le cours 1 (contrôleur = le poste) dépend de cet accès.

### Cours 1 — Ansible
5. **`changed=0` est impossible** : `roles/dns/templates/zone.j2:4` écrit `ansible_date_time.epoch`
   comme Serial (nouveau fichier à chaque run, handler déclenché) et `roles/web_status/tasks/main.yml:24`
   pose `changed_when: true`. Contredit la démo d'idempotence (ch.3), le ch.7 §2.2, le critère du
   projet final (`projet.md:86,101`) et `cours-2-elk/lab-depart.md:45`.
6. **Le phénix du ch.8 réinstalle bind9/nginx/fail2ban sur une VM neuve sans Internet** : le
   masquerade temporaire n'apparaît ni dans `projet.md` ni dans `phenix.sh` (seul le ch.3 le décrit).
7. **Tag `c1-chap7-fin` posé 8 minutes avant `c1-chap6-fin` et n'en descendant pas** : un
   `git checkout c1-chap7-fin` efface le rôle `web_status` et le `vault.yml.example` du ch.6.

### Cours 2 — ELK
8. **Le grok nginx ne produit pas les champs enseignés.** Logstash 9 tourne en
   `ecs_compatibility: v8` : `%{COMBINEDAPACHELOG}` sort `[http][response][status_code]`,
   `[source][address]`…, jamais `response`, `clientip`, `verb`. Or le ch.4 (script, demo, TP,
   correction `if [response] >= 400`), le ch.8 (TP, notes) et le projet final (`projet.md:127`,
   `generateur-incident.sh:58`) les utilisent. Fix minimal : `ecs_compatibility => disabled` dans ce grok.
9. **Le nginx du cours 1 répond 401 à tout** (`auth_basic` sur `location /`) : les TP qui attendent
   des codes 200 (ch.6, ch.8) et le scénario « erreurs 500 » du projet final
   (`generateur-incident.sh:60-62`) ne peuvent pas produire ce qu'ils annoncent.
10. **`machine` (ch.5) et `journald.unit` (ch.8, ch.9) n'existent pas** dans `logstash-*` : le champ
    du ch.2 vit dans l'index `journal`, et Filebeat nomme l'unité `systemd.unit`.

### Cours 3 — Sécurité
11. **`vmbr5` / `192.168.99.254` n'existent pas chez l'élève** : le cours 0 crée `vmbr1` et `vmbr2`
    seulement ; aucun bloc `/etc/network/interfaces` dans le cours 3. L'installation d'OPNsense
    (ch.2), les règles (ch.3), l'accès GUI (ch.3/5/7/8) tombent en cascade.
12. **pve-firewall n'est jamais activé** : `zone.fw.j2` pose `enable: 1` au niveau VM, mais ni
    `enable: 1` dans `cluster.fw` ni `firewall=1` sur les cartes réseau. Proxmox n'applique rien : la
    démo « dns-proxy → timed out » (`chap-4/demo.sh:45`) ne se produira pas.
13. **Le TP du ch.4 enferme l'élève hors de son bastion** : zone 9204 en `policy_in: DROP` avec SSH
    accepté depuis `10.10.99.2/32` — l'adresse du bastion lui-même (`correction/main.yml:17-22`).
    L'élève arrive par vmbr0 en 192.168.1.x : tout le lab devient injoignable.
14. **Vault** : `VAULT_ADDR=https://127.0.0.1:8200` avec certificat auto-signé et sans
    `VAULT_CACERT` → `vault operator init` échoue en x509 ; et le TP du ch.6 range la clé d'unseal
    dans `group_vars/vault/vault.yml` à la racine `ansible/`, dossier que ni l'inventaire
    (`inventory/`) ni les playbooks (`playbooks/`) ne chargent (le ch.7 utilise le bon chemin).

### Transversal
15. **Les 24 tags ne reflètent plus le matériel** : posés les 6-7 juillet, avant la revue de
    cohérence du 11 juillet (VMIDs 9201/9204 au lieu de 611/602, inventaire YAML, Filebeat sur 4
    VMs, `attaque.sh` sur la bonne API), avant le grok syslog (`c2-chap7-fin` ne l'a pas), avant
    l'épinglage Elastic (`c2-fin` est encore en `9.x`) et avant `OPNsense.localdomain`. Les
    rattrapages « `git checkout c1-fin` / `c2-fin` » promis par les `lab-depart.md` livrent du
    matériel connu comme faux. Aucun tag `c2-*` n'embarque les rôles ELK dans l'arbre élève.
16. **Quiz** : les 33 fichiers ont la ligne « Réponses : … » en double, dont une avant
    l'avertissement « ne lis cette section qu'après » — le correctif du 21/08 est incomplet.
17. **Durées** : `udemy-metadata.md` annonce 5 à 15 min de plus que les scripts sur une dizaine de
    chapitres ; les scripts totalisent 3,4 à 4,4 h par cours contre 6 à 8 h annoncées dans la spec
    (les TP ne sont pas comptés dans les scripts ; 22 TP sur 29 portent un temps cible).

## 3. Rapprochement avec le homelab

**Ce qui est vrai et bien tenu.** Les encarts « vrai matériel » décrivent le parc d'aujourd'hui
(cluster 4 nœuds, plateforme VDP, ELK 7.17 derrière OPNsense, PBS, bastion Tailscale + TOTP,
runner GitHub) et chaque fait renvoie à un commit ou un document du dépôt `homelab`. La banque
d'incidents réels (`infra-reelle-2026-10.md` §4) compte 54 pannes vécues depuis juillet, dont 36
déjà racontées dans les scripts et 18 en réserve. Le différenciateur annoncé par la spec — « la
panne du vrai monde » — est plus riche qu'au 06/07, pas moins. Le mécanisme de suivi
(`scripts/suivi-homelab.sh`, marqueur multi-têtes) garantit que la dérive d'août ne se reproduira pas.

**Ce que le pivot a changé, et que la spec ne dit plus.**

| La spec du 06/07 dit | La réalité du 12/10 |
|---|---|
| Encarts filmés sur « Proxmox i7/31 Go, 2 Lenovo K3S, OPNsense, switch » | Cluster `vortex-cluster` de 4 nœuds, plus de K3S, OPNsense en VM |
| « L'élève qui suit tout reconstruit l'équivalent du homelab réel » | L'élève reconstruit le homelab **de juillet**. Le réel a trois étages de plus (plateforme Rundeck/GitLab/Artifactory/vdp, supervision Metricbeat/Heartbeat/ElastAlert, accès distant durci) |
| Rôles fournis « dérivés du repo réel, épurés » | Les rôles élève (`dns`, `elasticsearch`, `kibana`, `logstash`, `vault`…) dérivent de rôles **archivés** côté homelab (`docs/archive/ansible-pre-pivot/`). Le réel déploie ELK par le moteur `vdp`, en 7.17. Seuls `common`, `filebeat` et les extraits firewall ont encore un jumeau actif |
| Hors périmètre v1 : « K3S/Longhorn, GitLab CI/CD selon traction » | K3S abandonné ; GitLab, runner GitLab, runner GitHub, Rundeck existent — un cours 4 « plateforme de déploiement » est devenu filmable sur du vrai |
| Cours 2 en « 2 nœuds Elasticsearch montrés sur l'infra réelle » | Le réel est mono-nœud (VM 300), jaune ; le cours est en 9.3.8, le réel en 7.17 — décision 2 du doc de référence, assumée dans les encarts |

Conséquence : la divergence lab élève / homelab réel est **structurelle et voulue** (le lab tient
dans 16 Go, le réel non), mais elle n'est écrite nulle part côté homelab. La spec n'a pas été
amendée depuis le 06/07 ; `docs/certifications-alignement-2026-09.md` §5 résume le projet en une
ligne (« rédigé, relu — bloqué sur une action humaine ») et identifie le vrai risque :
l'étalement.

**Ce que le homelab a appris et que la formation enseigne encore à l'envers.**
- Le homelab épingle ses versions, vérifie ses verrous et teste ses chaînes d'alerte en les
  faisant échouer ; le cours 2 annonce des champs qu'il ne vérifie jamais sur le lab (défaut 8).
- Le homelab a payé « ce qui n'est pas dans le dépôt n'existe pas » ; la formation promet des tags
  qui ne contiennent pas ses propres correctifs (défaut 15).
- Le homelab a appris que `onboot`, le BIOS et un SMTP absent rendent une reprise « automatique »
  fictive ; les labs élève n'ont jamais été rejoués après la relecture du 11 juillet — c'est le
  même mécanisme : un matériel vert sur le papier, jamais éprouvé.

## 4. Critères de succès de la spec — état

| Critère | État |
|---|---|
| Un débutant termine le cours 0 sans aide, validé par 2-3 bêta-testeurs | ❌ non testé, et quatre bloquants connus (défauts 1-4) |
| Chaque TP a une correction taguée et un temps cible | ⚠️ 24 tags présents mais périmés ; 22 TP/29 avec temps cible |
| Note Udemy ≥ 4,5 ; rétention YouTube ≥ 50 % | — rien publié |
| Pipeline 📝 → 🧪 → 🎬 → ✅ | Bloqué entre 📝 et 🧪 depuis le 21/08 |

## 5. Ce qu'il faut faire, dans l'ordre

1. **Rejouer les quatre labs sur une machine réelle avant toute autre chose** (chemin B, puis
   chemin A). Les 14 bloquants ci-dessus ont été trouvés en lisant ; une exécution en trouvera
   d'autres. C'est l'étape que le homelab appelle « éprouvé sur le parc ».
2. **Corriger les bloquants par cours**, du plus amont au plus aval : clé du poste et chemin A
   (C0), Serial DNS + `changed_when` + masquerade du phénix (C1), `ecs_compatibility` + 401 + noms
   de champs (C2), `vmbr5` + activation pve-firewall + source de management + Vault (C3).
3. **Reposer les 24 tags** à partir de `main` corrigé, dans l'ordre des chapitres, et vérifier la
   chaîne (`git merge-base --is-ancestor` entre tags successifs) ; publier en force sur les deux
   forges. Décider si les rôles ELK entrent dans l'arbre élève aux tags `c2-*`.
4. **Finir le réalignement** : encarts C1 ch.1 (BIND « au présent »), C1 ch.6 (unseal), C2 ch.2
   (« 2 nœuds, green, 150 shards »), C2 ch.4 (index `logstash-filebeat-*`) ; dédoublonner les 33
   quiz ; harmoniser `udemy-metadata.md` avec les scripts.
5. **Amender la spec côté homelab** (addendum daté) : parc post-pivot, divergence assumée lab/réel,
   rôles archivés comme source, cours 4 « plateforme » désormais possible.
6. **Lancer le bêta-test du cours 0** seulement après 1-3 : le protocole existe, il manque les
   testeurs et un matériel qui marche.

Tant que les points 1 à 3 ne sont pas faits, la bonne réponse à « est-ce que la formation est au
point ? » est : **le discours l'est, le lab ne l'est pas.**

## 6. Passe de correction du 12/10/2026 — ce qui a été fait

Tout ce qui pouvait l'être sans machine a été fait le jour même, en six commits (un par
cours, un pour quiz et durées) plus les tags :

| Défaut (§2) | Correctif |
|---|---|
| 1 clé du poste jamais déployée | **Trousseau du lab** (`/root/.ssh/lab-keys.pub` = clé du poste + clé du nœud) créé au chap. 2 du cours 0 ; `--sshkeys` le prend partout |
| 2 masquerade sans routage | `ip_forward` dans la démo, refermeture garantie même si le test échoue |
| 3 `apt upgrade` sans Internet | masquerade temporaire autour de la mise à jour, plus de `\|\| true` |
| 4 chemin A sans bastion | bastion en `10.0.2.20` fixe + redirection VirtualBox `2223` ; test signature depuis le poste |
| 5 `changed=0` impossible | Serial = variable `dns_zone_serial` ; htpasswd vérifié (`-v`) avant écriture |
| 6 phénix sans Internet | bloc masquerade écrit une fois (`lab-depart`), appelé par ch. 6 et ch. 8 |
| 7 tag ch. 7 mal posé | tags reposés depuis `main`, chaîne vérifiée |
| 8 champs grok inexistants | `ecs_compatibility => disabled` sur le grok nginx ; index syslog réservé aux lignes lues |
| 9 nginx répond 401 | curls authentifiés ; scénario 4 = scan d'URL (4xx), ce que nginx produit vraiment |
| 10 `machine`, `journald.unit` | Lens et KQL sur `tags.keyword` ; `systemd.unit` |
| 11 `vmbr5` absent | créé au chap. 2 du cours 3 ; GUI par tunnel SSH via le nœud |
| 12 pve-firewall inactif | `cluster.fw enable: 1`, `firewall=1` sur chaque carte, `pve-firewall compile` ; rôle testé contre un `qm` simulé |
| 13 bastion verrouillé | `zone_firewall_admin_source` (réseau du poste) ; le nœud garde toujours la main |
| 14 Vault | `VAULT_CACERT` exporté, kv-v2 monté, clé d'unseal dans `inventory/group_vars` |
| 15 tags périmés | 24 tags reposés (périmètre d'origine, contenu de `main`), syntaxe vérifiée |
| 16 quiz | une seule ligne « Réponses », dans le corrigé |
| 17 durées | `udemy-metadata.md` = durées des scripts |
| 4 encarts oubliés | C1 ch. 1 et 6, C2 ch. 2 et 4 réalignés |

Non fait, parce qu'impossible sans matériel : **rejouer les labs**. Les correctifs ci-dessus
sont vérifiés par lecture, `--syntax-check`, `ansible-lint` et, pour le pare-feu, par une
exécution contre des commandes simulées. Ils n'ont **pas** été exécutés sur un Proxmox.
Points à valider en priorité lors du rejeu : la redirection VirtualBox vers une VM imbriquée
(chemin A), le routage LAN d'OPNsense → segment ELK via le nœud, le grok hors ECS sur un
Logstash 9.3.8 réel, le `htpasswd -v` d'apache2-utils.
