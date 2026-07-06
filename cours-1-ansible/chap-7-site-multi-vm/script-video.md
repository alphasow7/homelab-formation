# Chapitre 7 — site.yml : tout le parc en une commande : script vidéo

> Durée cible : ~30 min. Prérequis élève : chapitres précédents faits — les rôles
> `dns` et `web_status` fonctionnent sur dns-proxy, `ansible lab -m ping` renvoie
> 3 pongs verts. Toutes les commandes se lancent depuis `cours-1-ansible/ansible/`
> sur le poste de l'élève, sauf mention SUR LE NŒUD PROXMOX ou SUR LA VM.

---

## 1. Le concept (≤ 5 min) — « site.yml, la partition de l'orchestre »

### À dire (idées et phrases clés)
- « Jusqu'ici tu joues tes playbooks un par un : un pour le DNS, un pour la page de
  statut… Ça marche à 3 machines. À 30, tu deviens le chef d'orchestre qui court de
  pupitre en pupitre. La réponse a un nom consacré : **`site.yml`**, le playbook
  maître. C'est la **partition de l'orchestre** : plusieurs plays dans UN fichier,
  chacun cible un groupe de machines, et une seule commande met TOUT le parc dans
  l'état voulu. »
- « Regarde le nôtre : deux plays. Le premier applique le rôle `common` — le SOCLE —
  à tout le groupe `lab` : l'heure synchronisée (chrony), l'anti brute-force SSH
  (fail2ban), la bannière de connexion. Le second transforme dns-proxy en serveur
  DNS + page de statut. **L'ordre compte** : le socle d'abord, les métiers ensuite —
  comme on coule les fondations avant de monter les murs. »
- « Un nouveau rôle apparaît ici : `common`. C'est tout ce qu'une machine doit avoir
  QUEL QUE SOIT son métier. Sur mon infra réelle, c'est le rôle le plus joué :
  chaque machine le reçoit en premier. »
- Les trois options qui sauvent (les écrire à l'écran) :
  - **`--limit dns-proxy`** — « ne joue la partition QUE pour ce pupitre. Tu as
    modifié un truc côté DNS ? Pas besoin de rejouer tout le parc. »
  - **`--check`** — « la répétition générale : Ansible déroule tout, te dit ce
    qu'il FERAIT, et ne touche à RIEN. »
  - **`--diff`** — « montre les différences ligne à ligne, comme un `git diff`
    entre l'état réel et l'état voulu. Combiné à `--check`, c'est LA commande
    avant tout déploiement qui fait peur. »

### À montrer à l'écran
- Schéma ASCII :

```
          site.yml — la partition
  ┌─────────────────────────────────────┐
  │ Play 1 : Socle commun     hosts: lab│──► elastic-1, kibana-logstash, dns-proxy
  │   roles: [common]                   │    (chrony, fail2ban, motd, drop-ins)
  ├─────────────────────────────────────┤
  │ Play 2 : Serveur DNS  hosts: dns-proxy ──► dns-proxy seulement
  │   roles: [dns, web_status]          │    (BIND9 + page de statut)
  └─────────────────────────────────────┘
       UNE commande = TOUT le parc.
   --limit : un pupitre | --check : répétition | --diff : le détail
```

---

## 2. Démo guidée (10 min)

> Toutes les commandes sont dans `demo.sh`, exécutées dans l'ordre depuis
> `cours-1-ansible/ansible/`. Rejouer sur le lab avant tournage.
> ⚠️ `apt` doit télécharger fail2ban : ouvrir le masquerade sur le nœud Proxmox
> AVANT (bloc 0 de demo.sh), le refermer APRÈS (bloc final).

### 2.1 — Run 1 : tout le parc, chrono en main

```bash
time ansible-playbook playbooks/site.yml
```

**À dire** : « Chrono en main. Une commande. » **Résultat attendu** : les deux plays
s'enchaînent — le socle sur les 3 VMs, puis DNS + web sur dns-proxy. PLAY RECAP :
du `changed` partout (fail2ban et le motd sont nouveaux), zéro `failed`, en une à
deux minutes. « Trois machines configurées, deux métiers déployés, le temps d'un
café court. À la main : une demi-journée, et des oublis. »

### 2.2 — Run 2 : l'idempotence traverse le playbook maître

```bash
ansible-playbook playbooks/site.yml
```

**Résultat attendu** : `changed=0` sur les 3 machines. **À dire** : « Ce que tu
savais d'un playbook reste vrai pour dix : l'état voulu est là, Ansible n'a rien
refait. Le rejeu du site.yml complet est un geste SANS DANGER — c'est ça qui permet
de le lancer tous les jours, voire à chaque commit. »

### 2.3 — La répétition générale : `--check --diff`

On modifie le titre de la page de statut (sans toucher au rôle, via une variable) :

```bash
ansible-playbook playbooks/site.yml --check --diff -e web_status_title="Lab v2"
```

**Résultat attendu** : la tâche du template passe en `changed` (jaune), et le
`--diff` affiche les lignes `-` / `+` du HTML : l'ancien titre part, le nouveau
arrive. **Mais** un `curl` de la page montre que RIEN n'a changé sur la machine.
**À dire** : « Ansible vient de te montrer EXACTEMENT ce qu'il ferait, ligne par
ligne, sans rien faire. Avant un déploiement sensible, c'est le réflexe : `--check
--diff`, tu lis, TU décides. »

### 2.4 — Le clin d'œil du chapitre 1 : le motd

```bash
ssh -J alpha@IP_DE_TON_BASTION alpha@10.10.99.11
```

**Résultat attendu** : à la connexion, la bannière s'affiche :

```
⚙️  Machine gérée par Ansible — ne modifie RIEN à la main : change le code, rejoue.
```

**À dire** : « Souviens-toi du chapitre 1 : le drift, le vandalisme, la machine
flocon de neige. Maintenant chaque machine du parc PRÉVIENT celui qui se connecte.
Ce petit message, sur une vraie équipe, évite plus de pannes qu'un pare-feu. »

---

## 3. Encart vrai matériel (2 min)

**À dire** : « Voici le `site.yml` de mon infra réelle : **10 plays, une trentaine
de rôles**. Play après play : le socle sur tout le parc, puis le DNS, le proxy,
GitLab, Vault, le cluster Elasticsearch, Kibana… La même idée que ton fichier de
deux plays, **à l'échelle** : l'infra ENTIÈRE — celle qui fait tourner ce cours —
tient dans UN fichier lisible du haut vers le bas. Quand quelqu'un me demande
“elle ressemble à quoi, ton infra ?”, je n'ouvre pas un schéma : j'ouvre site.yml. »

**Plans à filmer sur l'infra réelle** :
1. Scroll lent du `site.yml` réel, du play 1 au play 10.
2. `grep -c 'hosts:' site.yml` → le nombre de plays, en une commande.
3. Un run réel `ansible-playbook site.yml --check` : le PLAY RECAP avec tous les
   hôtes verts.

---

## 4. 💥 La panne du vrai monde (8 min) — le service qui démarre avant le réseau

> Panne 100 % vécue sur l'infra du formateur, rejouée en direct sur le lab.

**Mise en situation — à dire** : « Celle-là est vicieuse, parce qu'elle est
INVISIBLE. Sur mon infra, le serveur DNS — `named` — démarrait parfois AVANT que la
VM ait reçu son adresse IP. Au moment où il choisit ses adresses d'écoute, il ne
voit que `127.0.0.1`… alors il ne s'attache qu'à ça. Résultat : DNS parfaitement
fonctionnel EN LOCAL, muet depuis le réseau. Et le pire : `systemctl status` dit
**active**, les logs sont propres. Tout a l'air normal… jusqu'au premier reboot.
C'est une **course** entre deux coureurs au boot : le service et la configuration
réseau. La plupart du temps le réseau gagne. Parfois non. On la rejoue. »

**On la déclenche (à l'écran)** — redémarrer dns-proxy, commande côté nœud :

```bash
# SUR LE NŒUD PROXMOX :
qm list | grep dns-proxy        # trouver le VMID
qm reboot <VMID>
```

Puis, une fois la VM revenue :

```bash
# DEPUIS LE BASTION :
dig @10.10.99.12 elastic-1.lab.local +short
```

**Symptôme attendu** : `;; connection timed out ; no servers could be reached`.
(La course ne se perd pas à CHAQUE boot — si le dig répond, rebooter encore une
fois ou deux : c'est justement ce qui rend cette panne traître.)

**Diagnostic guidé — à dire** : « Le service est-il mort ? Vérifions. » :

```bash
# SUR LA VM (ssh -J alpha@IP_DE_TON_BASTION alpha@10.10.99.12) :
systemctl is-active named       # → active  (!!)
sudo ss -ulnp | grep 53
```

**À montrer** : la sortie de `ss` — surligner qu'on ne voit QUE :

```
UNCONN  0  0  127.0.0.1:53  ...  users:(("named",...))
```

« Lis-la : named écoute bien le port 53… mais **uniquement sur 127.0.0.1**. Pas de
ligne `10.10.99.12:53`. Le service tourne, il est juste sourd côté réseau. Voilà
pourquoi tout semblait normal : localement, tout MARCHE. »

**L'explication (schéma au tableau)** : « Au boot, systemd lance les services en
parallèle. `named` a démarré au moment T, l'interface a reçu son IP au moment T+1.
named a listé les adresses disponibles à T : il n'y avait que la loopback. Il faut
dire à systemd : “ce service-là, tu ne le lances que quand le réseau est VRAIMENT
en ligne”. »

**Le fix DURABLE — à dire** : « Et on corrige où ? Pas par un `systemctl restart`
sur la VM — ça règle CE boot-ci, pas le suivant. On corrige dans le CODE : le rôle
`common` sait poser un **drop-in systemd** pour chaque service listé dans
`common_network_waits`. Il ne reste qu'à dire, dans les variables de dns-proxy,
que `named` en fait partie. » Montrer le fichier `inventory/host_vars/dns-proxy.yml` :

```yaml
---
common_network_waits: [named]
```

« host_vars : la variable ne vaut que pour CETTE machine — elastic-1 n'a pas de
named, il ne recevra pas de drop-in. » Montrer aussi le contenu déposé :

```
[Unit]
After=network-online.target      ← démarre APRÈS le réseau
Wants=network-online.target      ← et demande à ce que le réseau soit lancé
```

Déployer, vérifier, re-rebooter :

```bash
ansible-playbook playbooks/site.yml --limit dns-proxy
# SUR LA VM : systemctl cat named   → le drop-in override.conf apparaît
# SUR LE NŒUD PROXMOX : qm reboot <VMID>
# DEPUIS LE BASTION :
dig @10.10.99.12 elastic-1.lab.local +short   # → 10.10.99.11
```

**Résultat attendu** : le dig répond `10.10.99.11` à chaque reboot, plus de course.

**Morale — à dire** : « **Un service qui marche n'est pas un service qui
REdémarre.** Cette panne était invisible tant que la machine restait allumée —
et une machine, ça finit toujours par rebooter : mise à jour noyau, coupure de
courant, migration. Teste tes déploiements APRÈS un reboot — c'est le reboot qui
dit la vérité. Et remarque le trajet du fix : pas une commande sur la VM, une
LIGNE de variable dans le code. La cicatrice reste gravée dans le rôle. »

---

## 5. Annonce du TP

**À dire** : « À toi de piloter le parc. Le TP : trois missions autour du site.yml.
Un, tu poses toi-même le fix de la panne — le host_vars de dns-proxy avec
`common_network_waits` — et tu vérifies le drop-in avec `systemctl cat named`.
Deux, tu débrayes fail2ban sur elastic-1 UNIQUEMENT, par host_vars, et tu prouves
qu'il est inactif là-bas et actif partout ailleurs — la puissance du réglage par
machine. Trois, le juge de paix : tu reboot-testes dns-proxy et le dig doit
répondre au retour. Compte 20 minutes, deux indices dans `tp.md`, correction dans
`correction/`. Au prochain cours, on quitte Ansible pour l'étage au-dessus. »
