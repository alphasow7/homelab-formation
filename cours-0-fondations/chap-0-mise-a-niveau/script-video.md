# Chapitre 0 — Mise à niveau : script vidéo

> **« 30 minutes chrono pour parler la même langue. »**
> Durée cible : ~30 min. Prérequis élève : aucun — c'est justement le but de ce chapitre.
> Trois blocs : Terminal & SSH (12 min), Réseau minimal (12 min), C'est quoi une VM (6 min).
> Dérogation au gabarit (assumée) : chapitre de mise à niveau — pas d'encart « vrai
> matériel » ni de « panne du vrai monde », on pose le vocabulaire.
> Toutes les commandes montrées sont dans `demo.sh`, dans l'ordre, et doivent être rejouées
> avant tournage.

**À dire en intro (30 s)** : « Avant de toucher à Proxmox, on va s'assurer qu'on parle la
même langue. Si tu sais déjà te connecter en SSH avec une clé et que `ip route` ne te fait
pas peur, tu peux sauter directement au chapitre 1 — le quiz en bas de page te dira si tu
peux. Pour tous les autres : 30 minutes, trois blocs, et on est à niveau. »

---

## Bloc 1 — Terminal & SSH (12 min)

### 1.1 Se déplacer dans le terminal (4 min)

**À dire** : « Le terminal, c'est juste une autre façon de parler à ton ordinateur. Au lieu
de cliquer, tu écris. Quatre commandes suffisent pour ne jamais être perdu. »

Dérouler chaque commande avec son résultat à l'écran :

```bash
pwd
```
**Attendu** : un chemin, par exemple `/home/alpha`. « `pwd` = *print working directory* :
OÙ suis-je ? C'est ta boussole. Quand tu es perdu, tape `pwd`. »

```bash
ls
```
**Attendu** : la liste des fichiers et dossiers du répertoire courant. « `ls` = *list* :
QU'est-ce qu'il y a ici ? » Montrer aussi `ls -l` : « le `-l` (pour *long*) affiche les
détails — taille, date, permissions. On y reviendra. »

```bash
cd /tmp
pwd
```
**Attendu** : `pwd` répond maintenant `/tmp`. « `cd` = *change directory* : je vais
ailleurs. Et `cd` tout seul te ramène toujours à la maison, ton répertoire personnel. »

### 1.2 Lire et éditer un fichier (3 min)

```bash
cat /etc/hostname
```
**Attendu** : une seule ligne, le nom de la machine. « `cat` affiche tout le contenu d'un
fichier d'un coup. Parfait pour les petits fichiers. »

```bash
less /etc/services
```
**Attendu** : le fichier s'ouvre page par page. « Pour les gros fichiers, `less` : flèches
pour naviguer, `/` pour chercher, et **`q` pour quitter** — retiens le `q`, tout le monde
reste coincé dans `less` la première fois. »

```bash
nano /tmp/test.txt
```
**Attendu** : l'éditeur s'ouvre, on tape une phrase. « `nano`, c'est l'éditeur de texte le
plus simple : tu tapes, puis **Ctrl+O** pour enregistrer (O comme *Output*), Entrée pour
confirmer, **Ctrl+X** pour quitter. Les raccourcis sont affichés en bas de l'écran, le `^`
veut dire Ctrl. » Vérifier avec `cat /tmp/test.txt`.

### 1.3 sudo — le passe-droit (1 min)

```bash
sudo cat /etc/shadow | head -1
```
**Attendu** : sans `sudo`, `cat /etc/shadow` répond « Permission denied » (le montrer
d'abord !) ; avec `sudo`, ça marche après avoir tapé son mot de passe. « `sudo` = *super
user do* : fais cette commande en tant qu'administrateur. Certains fichiers et certaines
actions sont protégés — `sudo` est le passe-droit. Règle d'or : ne l'utilise que quand
c'est nécessaire. »

### 1.4 SSH — piloter une machine à distance (4 min)

**À dire** : « Tout ce qu'on vient de faire, on l'a fait EN LOCAL. Mais un serveur, il est
dans un placard, sans écran ni clavier. Comment on lui parle ? SSH — *Secure Shell* : un
terminal à distance, chiffré. C'est LA commande de toute la formation. »

```bash
ssh utilisateur@ip
```
**Attendu** (avec un vrai user/IP à l'écran) : première connexion → question sur le
*fingerprint* (« tape `yes`, c'est SSH qui te demande si tu fais confiance à cette machine
la première fois »), puis demande de mot de passe, puis… un terminal sur l'autre machine.
Montrer `hostname` pour prouver qu'on est ailleurs. `exit` pour revenir.

**Le problème** : « Taper son mot de passe à chaque fois, c'est pénible et c'est moins
sûr. La solution : une paire de clés. »

**L'analogie cadenas/clé (schéma à l'écran)** :
> - La **clé publique**, c'est un **cadenas**. Tu peux en distribuer des copies partout,
>   sur toutes les machines du monde : un cadenas ne permet pas d'ouvrir, seulement de
>   fermer. Aucun risque.
> - La **clé privée**, c'est **LA clé** qui ouvre ces cadenas. Elle ne quitte JAMAIS ton
>   poste. Jamais. Si quelqu'un te demande ta clé privée, c'est une arnaque.

```bash
ssh-keygen -t ed25519
```
**Attendu** : trois questions (emplacement → Entrée pour accepter le défaut,
*passphrase* → « un mot de passe qui protège ta clé privée elle-même ; pour le lab tu peux
laisser vide, en entreprise on en met une »), puis un joli *randomart*. « `-t ed25519`,
c'est le type de clé — le standard moderne, court et solide. Résultat : deux fichiers dans
`~/.ssh/` : `id_ed25519` (la clé privée, LA clé) et `id_ed25519.pub` (la publique, le
cadenas — c'est le `.pub` qu'on distribue). »

```bash
ssh-copy-id utilisateur@ip
```
**Attendu** : dernière fois qu'on tape le mot de passe ; le message
`Number of key(s) added: 1`. « Cette commande pose ton cadenas sur la machine distante —
concrètement, elle ajoute ta clé publique dans le fichier
`~/.ssh/authorized_keys` de l'autre machine. »

```bash
ssh utilisateur@ip
```
**Attendu** : connexion **sans mot de passe**. Moment de satisfaction à jouer. « Voilà. À
partir de maintenant, dans toute la formation, on se connecte comme ça. »

---

## Bloc 2 — Réseau minimal (12 min)

**À dire en transition** : « Deuxième langue à parler : le réseau. Pas besoin d'être
ingénieur réseau — quatre notions et quatre commandes. »

### 2.1 IP et masque — « ta maison, ta rue » (3 min)

**À dire (schéma à l'écran)** : « Une adresse IP, c'est l'adresse postale de ta machine :
`192.168.1.37`. Le **masque** dit quelle partie de l'adresse désigne la RUE et quelle
partie désigne la MAISON. Avec le masque `/24` (le plus courant chez toi), les trois
premiers nombres sont la rue — `192.168.1` — et le dernier est le numéro de la maison —
`37`. Deux machines dans la même rue se parlent directement. »

```bash
ip a
```
**Attendu** : plusieurs blocs ; pointer la ligne `inet 192.168.1.x/24` de l'interface
active (et expliquer que `lo` / `127.0.0.1`, c'est la machine qui se parle à elle-même).
« `ip a` (pour *address*) : QUELLE est mon adresse ? Ta deuxième boussole après `pwd`. »

### 2.2 La passerelle — « la sortie du quartier » (3 min)

**À dire** : « Et si la machine que je veux joindre n'est PAS dans ma rue — un serveur sur
Internet par exemple ? Je passe par la **passerelle** (*gateway*) : la sortie du quartier.
Chez toi, c'est ta box Internet. Toute machine qui veut sortir doit connaître l'adresse de
sa sortie. »

```bash
ip route
```
**Attendu** : première ligne du type `default via 192.168.1.1 dev ...`. « Lis-la comme une
phrase : *par défaut, pour tout ce qui n'est pas dans ma rue, passe via 192.168.1.1* —
c'est la passerelle, ta box. »

### 2.3 DHCP — « l'agent qui attribue les adresses » (2 min)

**À dire** : « Mais qui a donné son adresse à ta machine ? Tu ne l'as jamais configurée…
C'est le **DHCP** : un service qui attribue automatiquement les adresses. Quand une machine
arrive sur le réseau, elle crie *quelqu'un peut me donner une adresse ?* et le serveur DHCP
— chez toi, c'est encore ta box — lui répond : *tiens, prends 192.168.1.37, la passerelle
est en .1, et voilà l'annuaire*. C'est un bail : l'adresse est prêtée, pas donnée à vie.
On verra au chapitre 4 pourquoi un serveur, lui, préfère une adresse FIXE. »

### 2.4 DNS — « l'annuaire » (2 min)

**À dire** : « Dernière pièce : quand tu tapes `example.com`, ta machine a besoin de
l'adresse IP qui se cache derrière ce nom. Le **DNS**, c'est l'annuaire : tu donnes un nom,
il te rend une adresse. »

```bash
dig +short example.com
```
**Attendu** : une ou plusieurs adresses IP (example.com en renvoie aujourd'hui une
demi-douzaine, des `23.x` — les sites sérieux ont plusieurs adresses, on y reviendra).
« `dig` interroge
l'annuaire ; `+short` lui demande de répondre juste l'essentiel : l'adresse. Sans le
`+short`, tu verrais toute la conversation technique — utile plus tard, illisible
aujourd'hui. »

### 2.5 ping — « est-ce que tu m'entends ? » (2 min)

```bash
ping -c 3 192.168.1.1
```
**Attendu** : trois lignes de réponses avec un temps en millisecondes, puis un résumé
`3 packets transmitted, 3 received, 0% packet loss`. « `ping` envoie un *coucou* et
mesure le temps de réponse. `-c 3` = trois essais puis stop, sinon ça ping à l'infini.
C'est LE premier outil de diagnostic réseau : ma passerelle répond ? Internet répond ? »

```bash
ping -c 3 example.com
```
**Attendu** : mêmes réponses, mais remarque à faire : « regarde la première ligne — ping
a d'abord demandé au DNS l'adresse d'example.com, PUIS il a pingé. Tout se combine. »

**Récap à l'écran (slide, 20 s)** :
> IP + masque = ta maison, ta rue · passerelle = la sortie du quartier ·
> DHCP = l'agent qui attribue les adresses · DNS = l'annuaire
> `ip a` · `ip route` · `ping` · `dig +short`

---

## Bloc 3 — C'est quoi une VM ? (6 min)

**À dire** : « Dernier concept, et c'est le cœur de toute la formation : la **machine
virtuelle**, VM pour les intimes. Une VM, c'est un PC complet… dans une fenêtre. Elle a son
processeur, sa mémoire, son disque, sa carte réseau, son système d'exploitation — sauf que
tout ça est simulé par un logiciel, sur TON vrai PC. »

**Schéma à l'écran** :

```
      ┌──────────┐  ┌──────────┐  ┌──────────┐
      │   VM 1   │  │   VM 2   │  │   VM 3   │
      │ (Linux)  │  │ (Linux)  │  │(Windows?)│
      └──────────┘  └──────────┘  └──────────┘
      ┌────────────────────────────────────────┐
      │            HYPERVISEUR                 │
      │  (le logiciel qui découpe le vrai PC   │
      │        en plusieurs faux PCs)          │
      └────────────────────────────────────────┘
      ┌────────────────────────────────────────┐
      │        TON VRAI PC (le matériel)       │
      └────────────────────────────────────────┘
```

**À dire** :
- « Le logiciel qui fait ce découpage s'appelle un **hyperviseur** : il prend un vrai PC et
  le découpe en plusieurs faux. Chaque VM croit dur comme fer qu'elle est une vraie
  machine, seule au monde. Proxmox, qu'on installe au prochain chapitre, c'est exactement
  ça. »
- « Pourquoi c'est PARFAIT pour apprendre ? Parce qu'une VM, ça se casse sans conséquence.
  Tu fais une bêtise ? Tu supprimes la VM et tu en recrées une en deux minutes. Tu veux
  tester un truc risqué ? Tu prends une photo de la VM avant (un *snapshot* — on verra ça
  au chapitre 6) et tu reviens en arrière si ça tourne mal. **On casse, on recommence** :
  c'est la méthode de toute cette formation, et c'est comme ça qu'on apprend vraiment. »
- « En entreprise, c'est pareil : quasiment plus aucun service ne tourne directement sur
  une machine physique. Tout est VM ou conteneur. Ce que tu apprends ici, c'est le socle
  du métier. »

---

## Annonce du TP (1 min)

**À dire** : « À toi de jouer. Le TP de ce chapitre : générer TA paire de clés SSH et
configurer l'accès sans mot de passe vers une machine. Quinze minutes, tout est dans
`tp.md`, avec des indices si tu bloques. Si tu n'as pas encore de machine Linux sous la
main, pas de panique : tu referas exactement ça au chapitre 3, sur ta première VM. Ensuite,
le quiz — cinq questions — et on se retrouve au chapitre 1 pour parler de ce qu'on va
construire ensemble. »
