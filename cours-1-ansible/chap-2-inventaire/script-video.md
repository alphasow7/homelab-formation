# Chapitre 2 — L'inventaire : script vidéo

> Durée cible : ~25 min. Prérequis élève : chapitre 1 fait (Ansible installé sur le
> poste), lab en place (3 VMs sur le segment 10.10.99.0/24, bastion opérationnel,
> clés SSH déjà déployées — voir `lab-depart.md`). Le poste de l'élève est le
> **contrôleur** Ansible : c'est lui qui commande, rien à installer sur les VMs.

---

## 1. Le concept (≤ 5 min) — « L'annuaire de ton parc »

### À dire (idées et phrases clés)
- « Au chapitre 1, tu as installé Ansible. Mais Ansible ne sert à rien tant qu'il ne
  sait pas QUI commander. C'est le rôle de l'**inventaire** : l'annuaire de ton parc.
  Chaque machine y a un nom, une adresse, et une étagère de rangement. »
- Les **groupes** = des étagères. « Au lieu de dire trois fois “fais ça sur elastic-1,
  puis sur kibana-logstash, puis sur dns-proxy”, tu ranges les trois sur l'étagère
  `lab` et tu commandes tout le groupe d'un seul mot. Trois machines aujourd'hui,
  trois cents demain : la commande ne change pas. »
- **YAML en 30 secondes** : « Le fichier est en YAML, un format de texte où
  **l'indentation fait la hiérarchie**. Ce qui est décalé sous `lab:` appartient à
  `lab`. Deux espaces, jamais de tabulation. C'est tout ce qu'il faut savoir pour
  aujourd'hui — on en reverra au fil des chapitres. »
- Le **ProxyJump** : « Souviens-toi du cours 0, chapitre 7 : ton lab est sur un segment
  isolé, tu ne peux l'atteindre qu'en sautant par le **bastion** — la machine de
  rebond qui a un pied dans les deux réseaux. Ansible n'a aucune magie : il parle SSH,
  comme toi. Donc **Ansible emprunte exactement le même chemin que toi : il saute par
  le bastion**. C'est la ligne `ansible_ssh_common_args` avec `-o ProxyJump`. »
- Le placeholder `IP_DE_TON_BASTION` : « Dans le fichier que je te fournis, tu vois
  `IP_DE_TON_BASTION` écrit en toutes lettres. Ce n'est pas une vraie adresse : chaque
  élève a la sienne, tu la remplaces par l'IP de TON bastion — celle que tu as notée
  dans `lab-depart.md`. Si tu oublies, Ansible essaiera littéralement de se connecter
  à une machine nommée IP_DE_TON_BASTION, et ça ne finira pas bien. »

### À montrer à l'écran
- Schéma ASCII (reprendre visuellement celui du cours 0 chap 7) :

```
  TON POSTE                BASTION                SEGMENT ISOLÉ 10.10.99.0/24
  (contrôleur Ansible)     (2 pattes réseau)
  ┌───────────┐   SSH    ┌───────────┐   SSH    ┌─────────────────┐
  │  ansible  │ ───────► │  bastion  │ ───────► │ elastic-1   .11 │
  │           │          │           │          │ kibana-log. .14 │
  └───────────┘          └───────────┘          │ dns-proxy   .12 │
                          ProxyJump             └─────────────────┘
```

- Puis le fichier `ansible/inventory/hosts.yml` plein écran, en le lisant de haut en
  bas : `all` contient tout ; `lab` est le groupe des 3 VMs ; sous `vars`,
  `ansible_user: alpha` (l'utilisateur SSH) et le ProxyJump. Surligner le placeholder
  `IP_DE_TON_BASTION` et le remplacer en direct.
- Montrer aussi `ansible/ansible.cfg` 20 secondes : « Ce petit fichier dit à Ansible
  où trouver l'inventaire. Grâce à lui, plus besoin de `-i` à chaque commande. On
  reparlera de `host_key_checking` en fin de vidéo. »

---

## 2. Démo guidée (12 min) — les commandes ad-hoc

> Toutes les commandes sont dans `demo.sh`, exécutées dans l'ordre, DEPUIS le poste de
> l'élève, dans le dossier `cours-1-ansible/ansible/` (là où vit `ansible.cfg`).
> Rejouer le script sur le lab avant tournage. Le placeholder du bastion doit être
> remplacé AVANT la démo.

### 2.1 — Le premier contact : `ansible lab -m ping`

```bash
ansible lab -m ping
```

**À dire** : « Décodons la commande : `ansible`, la **cible** (`lab`, notre groupe),
`-m` pour **module** — un module, c'est une brique d'action toute prête — et le module
s'appelle `ping`. Attention, piège classique : ce ping-là n'a RIEN à voir avec la
commande `ping` réseau et ses paquets ICMP. Le module `ping` d'Ansible fait le tour
complet : connexion SSH (à travers le bastion !), vérification que Python répond sur
la machine, et retour. Si tu vois `pong`, c'est que TOUTE la chaîne fonctionne. »

**Résultat attendu** : 3 blocs verts, un par VM :

```
elastic-1 | SUCCESS => {
    "ansible_facts": { "discovered_interpreter_python": "/usr/bin/python3" },
    "changed": false,
    "ping": "pong"
}
kibana-logstash | SUCCESS => { ... "ping": "pong" }
dns-proxy | SUCCESS => { ... "ping": "pong" }
```

« Trois pongs verts. Ansible vient de traverser le bastion et de parler aux trois VMs
du segment isolé, en une seule commande. Savoure : c'est LE moment fondateur. »

### 2.2 — Une commande brute : `ansible lab -a "uptime"`

```bash
ansible lab -a "uptime"
```

**À dire** : « Ici pas de `-m` : quand tu ne précises pas de module, Ansible utilise
le module `command`, qui exécute une commande brute. `-a`, ce sont les **arguments**
— ici la commande `uptime`. Résultat : l'uptime des trois machines d'un coup. Fais le
calcul : en SSH manuel, c'est trois connexions, trois commandes, trois copier-coller. »

**Résultat attendu** : 3 blocs `CHANGED | rc=0` (rc = return code, 0 = succès), chacun
avec une ligne du type :

```
elastic-1 | CHANGED | rc=0 >>
 14:02:11 up 3 days,  2:14,  0 users,  load average: 0.08, 0.05, 0.01
```

« Note le `CHANGED` en orange : Ansible ne sait pas si une commande brute a modifié
quelque chose, alors il suppose que oui. On en reparlera au chapitre sur
l'idempotence. »

### 2.3 — Les facts : `ansible dns-proxy -m setup | head -30`

```bash
ansible dns-proxy -m setup | head -30
```

**À dire** : « Cette fois la cible est UNE machine, `dns-proxy` — on peut cibler un
groupe ou un hôte, au choix. Le module `setup` collecte les **facts** : tout ce
qu'Ansible sait découvrir sur la machine — OS, IPs, RAM, CPU, disques, des centaines
d'infos. Le `| head -30` coupe l'affichage aux 30 premières lignes, sinon on y passe
la soirée. Retiens l'idée : **Ansible SAIT tout des machines** — et on se servira de
ces facts dans nos playbooks pour prendre des décisions. »

**Résultat attendu** : le début d'un gros bloc JSON :

```
dns-proxy | SUCCESS => {
    "ansible_facts": {
        "ansible_all_ipv4_addresses": [
            "10.10.99.12"
        ],
        "ansible_architecture": "x86_64",
        ...
```

« Tu reconnais le `10.10.99.12` ? C'est bien la machine qu'on a déclarée dans
l'inventaire. Ansible confirme. »

### 2.4 — Comment Ansible voit ton annuaire : `ansible-inventory --list`

```bash
ansible-inventory --list
```

**À dire** : « Dernier outil du jour : `ansible-inventory` te montre l'inventaire tel
qu'Ansible le comprend, une fois digéré — en JSON. C'est TON fichier YAML, vu de
l'intérieur. Quand ton inventaire grossira et que tu douteras (“cette machine est dans
quel groupe déjà ?”), c'est ici que tu viendras vérifier. »

**Résultat attendu** : un JSON avec `_meta.hostvars` (les variables de chaque hôte, où
on retrouve `ansible_host`, `ansible_user` et le ProxyJump), puis les groupes :

```
{
    "_meta": {
        "hostvars": {
            "elastic-1": {
                "ansible_host": "10.10.99.11",
                "ansible_ssh_common_args": "-o ProxyJump=alpha@...",
                "ansible_user": "alpha"
            },
            ...
        }
    },
    "all": { "children": ["ungrouped", "lab", "bastion"] },
    "lab": { "hosts": ["elastic-1", "kibana-logstash", "dns-proxy"] },
    ...
}
```

---

## 3. Encart vrai matériel (3 min)

**À dire** : « Ton inventaire a 4 machines. Voilà le MIEN, celui de mon infra réelle.
Regarde bien : c'est exactement le même format. Juste plus d'étagères : un groupe
`elk` pour la stack Elastic, un groupe `devsecops` pour GitLab et ses copains, un
groupe `services`… Et regarde la ligne `ansible_ssh_common_args` : le MÊME ProxyJump
que toi — chez moi, le rebond se fait par le serveur Proxmox, qui joue le rôle de
bastion vers mes segments internes. Ce pattern, tu viens de l'apprendre — il tient
jusqu'à des centaines de machines. Les grosses boîtes ont des inventaires générés
automatiquement depuis le cloud, mais la logique groupes + variables reste la même. »

**Plans à filmer sur l'infra réelle** :
1. Le `hosts.yml` réel plein écran, scroll lent : montrer les groupes (elk,
   devsecops, services…) et surligner le ProxyJump.
2. `ansible all -m ping` sur l'infra réelle : la cascade de pongs verts (plus de 3 !).
3. `ansible-inventory --graph` (bonus visuel) : l'arbre des groupes en une commande.

---

## 4. 💡 L'astuce du vrai monde (3 min) — `host_key_checking = False`

> Pas de panne dédiée ce chapitre — dérogation assumée : la vraie leçon du jour est
> une ligne de config qu'il faut comprendre AVANT qu'elle te joue des tours en prod.

**À dire** : « Retour sur `ansible.cfg` et cette ligne : `host_key_checking = False`.
Tu connais le message SSH “The authenticity of host … can't be established” : à la
première connexion, SSH mémorise l'empreinte de la machine, et hurle si elle change.
C'est la **protection anti-usurpation** de SSH : si quelqu'un se fait passer pour ton
serveur, l'empreinte ne correspond plus et SSH refuse. Dans notre lab, on recrée les
VMs sans arrêt — mêmes IPs, nouvelles empreintes à chaque fois — et sans cette ligne,
Ansible se bloquerait à chaque reconstruction. Donc dans un LAB : `False`, c'est OK et
c'est confortable. En PROD : on ne désactive pas cette protection sans réfléchir —
c'est précisément elle qui te préviendrait qu'une machine n'est pas celle qu'elle
prétend être. En prod, on distribue les empreintes proprement (known_hosts géré, ou
certificats SSH) au lieu de fermer les yeux. Retiens la règle : **chaque fois que tu
désactives une sécurité pour ton confort, sache nommer ce que tu viens de désactiver.** »

**À montrer** : la ligne dans `ansible.cfg` surlignée, puis (préparé à l'avance) le
message d'erreur qu'on aurait sans elle : `Host key verification failed.`

---

## 5. Annonce du TP

**À dire** : « À toi de jouer. Le TP du chapitre : uniquement des commandes ad-hoc,
pas encore de playbook. Tu vas redémarrer le service `chrony` — le service de
synchronisation de l'heure — sur TOUT le groupe lab d'une seule commande, vérifier
qu'il est actif partout, et en bonus, demander aux facts la RAM de chaque VM sans
ouvrir une seule session SSH à la main. Compte 15 minutes, les indices sont dans
`tp.md` si tu bloques, la correction dans `correction/`. Au prochain chapitre : on
arrête de taper des commandes une par une — on écrit notre premier playbook. »
