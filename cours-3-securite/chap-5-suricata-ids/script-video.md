# Chapitre 5 — Suricata : l'IDS qui écoute le WAN : script vidéo

> Durée cible : ~35 min. Prérequis : OPNsense installé et joignable (chap 2-3), avec un
> **WAN** (DHCP box) et un **LAN** `192.168.99.1`. Le SIEM ELK du cours 2 tourne, avec un
> **input syslog Logstash sur 5514** déjà en place (cours 2, chap 7).
> Ici **pas de rôle Ansible** : Suricata se pilote dans le GUI OPNsense et sa console.
> Toutes les commandes montrées sont dans `demo.sh` et ont été rejouées sur le lab réel.

## 1. Le concept (5 min)

**À dire** : « Jusqu'ici ton pare-feu *bloque* selon des règles que TU écris (port, IP).
Mais il ne sait pas reconnaître une *attaque* dans le trafic qu'il laisse passer. C'est le
travail d'un **IDS** — un système de détection d'intrusion. Suricata en est un, et il est
intégré à OPNsense.

Deux mots à ne jamais confondre :

- **IDS** = *Intrusion Detection System*. Il **détecte et ALERTE**. Il regarde le trafic
  passer et lève la main : "attention, ça ressemble à un scan de ports / à un malware". Il
  ne touche à rien.
- **IPS** = *Intrusion Prevention System*. Il **détecte et BLOQUE**. Même moteur, mais il
  coupe la connexion suspecte.

**On commence TOUJOURS en IDS (mode détection).** Pourquoi ? Parce qu'une signature peut se
tromper — c'est un **faux positif** : elle crie à l'attaque sur du trafic parfaitement
légitime. En mode détection, un faux positif te fait juste une alerte de trop. En mode IPS,
il **coupe** ce trafic légitime — tu casses ta prod à cause d'une règle trop zélée. Donc :
on observe d'abord, on affine, et seulement une fois qu'on a confiance on passe en blocage.

Trois mots de vocabulaire et tu sais parler IDS :

- une **signature** : le "portrait-robot" d'une attaque connue. Une règle qui dit *"si tu
  vois tel motif dans un paquet, c'est probablement telle attaque"*.
- un **ruleset** : un paquet de signatures, maintenu et mis à jour par quelqu'un. Deux
  fournisseurs qu'on utilise : **ET open** (*Emerging Threats*, un grand catalogue gratuit
  de signatures — scans, exploits, malwares) et **abuse.ch** (des listes d'IP/domaines de
  malwares et de serveurs de commande **C2**, celui qui pilote un botnet).
- un **faux positif** : une alerte qui se déclenche à tort, sur du trafic sain.

Où on met Suricata ? Sur l'interface **WAN** — celle qui regarde le monde extérieur. On
surveille en priorité ce qui ARRIVE d'Internet vers chez toi. »

**Schéma à l'écran** :

```
   Internet ──► [ WAN ]  OPNsense  [ LAN 192.168.99.1 ] ──► ton réseau
                   │
                   └─ Suricata écoute ici (mode détection)
                        │  compare chaque paquet aux SIGNATURES
                        ▼
                   Alerte ──► onglet Alerts (OPNsense)
                          └─► syslog ──► Logstash 5514 ──► Kibana (ton SIEM)
```

## 2. Démo guidée (12 min)

> Rappel accès : GUI OPNsense depuis le poste d'admin (Proxmox) →
> `https://192.168.99.1`. Login `root` / mot de passe changé au 1er login.

### 2.1 Activer Suricata sur le WAN, en mode détection

**À montrer (dans le GUI OPNsense)** :

1. `Services > Intrusion Detection > Administration`.
2. Cocher **Enabled**.
3. **Interfaces** : choisir **WAN** (« on surveille ce qui vient du monde »).
4. **IPS mode** : **décoché** → on reste en **détection**. « On ne bloque rien pour
   l'instant : on regarde. »
5. **Save**, puis **Apply** en haut.

**À dire** : « Coché, WAN, IPS off. Pour l'instant Suricata tourne… mais avec **zéro
règle**. Un IDS sans signatures ne détecte rien. Allons lui en chercher. »

### 2.2 Télécharger et activer des rulesets

**À montrer (GUI)** :

1. Onglet **Download**.
2. Cocher des rulesets **ET open** (ex. `emerging-scan`, `emerging-exploit`,
   `emerging-malware`) et des **abuse.ch** (`abuse.ch/SSL Blacklist`,
   `abuse.ch/Feodo Tracker`).
3. Cliquer **Download & Update** (en haut à droite).

**À dire pendant le téléchargement** : « ET open me donne les grandes familles d'attaques ;
abuse.ch me donne les IP/domaines de malwares du moment. Le bouton "Download & Update"
télécharge les signatures ET les charge dans Suricata. Retiens ce mot — *"& Update"* — on y
revient dans deux minutes, il cache un piège. »

### 2.3 Vérifier que des règles sont VRAIMENT chargées

**À montrer (console OPNsense, en SSH)** :

```sh
configctl ids status
```

**Attendu** : `Suricata (pid …) is running.`

« Running, bien. Mais "running" ne dit pas *combien de règles*. Comptons-les pour de vrai :
le nombre de lignes des fichiers de règles chargés. »

```sh
sh -c "wc -l /usr/local/etc/suricata/rules/*.rules | tail -1"
```

**Attendu** : plusieurs **dizaines de milliers** de lignes (sur le lab réel : ~69 500 pour
9 rulesets). « Voilà une preuve. Un chiffre à cinq zéros = des signatures réellement en
mémoire. Si c'était `0`… on aurait un IDS aveugle. Garde ça en tête. »

### 2.4 Déclencher une alerte : un scan de ports

**À montrer (DEPUIS LE POSTE, vers le WAN d'OPNsense)** :

```bash
sudo nmap -sS -T4 -p 1-1000 192.168.1.36    # IP WAN d'OPNsense (adapte-la)
```

**À dire** : « Un scan SYN de 1000 ports. C'est exactement le genre de comportement qu'un
attaquant fait en reconnaissance — et une signature ET open connaît ça par cœur. »

### 2.5 Voir l'alerte dans OPNsense

**À montrer (GUI)** : `Services > Intrusion Detection > Alerts`.

**Attendu** : une (des) ligne(s) avec une signature type `ET SCAN …`, source = ton poste,
destination = le WAN. « L'IDS a vu le scan et a levé la main. Il n'a rien bloqué — il a
**alerté**. C'est un IDS. »

### 2.6 Brancher les alertes vers ELK

**À dire** : « Une alerte dans OPNsense, c'est bien. Mais elle vit dans OPNsense. Si tu
veux la corréler avec le reste (tes logs SSH, tes conteneurs…) et la GARDER, elle doit
monter dans ton SIEM. Et là, attention au chemin : OPNsense est sur son **WAN**
(`192.168.1.x`, le LAN de la box), il ne voit PAS le segment interne `10.10.99.0/24` où
vit Logstash. Il ne peut donc pas parler à `10.10.99.14:5514` directement. On réutilise
le **relais syslog** monté au cours 2 chap 7 : le **nœud Proxmox** a un pied sur les deux
réseaux. OPNsense lui envoie son syslog sur son IP côté box (`192.168.1.200:514`), et le
nœud fait suivre à Logstash `10.10.99.14:5514`. Tu ne rebranches rien — tu ajoutes juste
une source à un chemin qui existe déjà. »

> ⚠️ Pré-requis du relais : au cours 2 chap 7, le nœud ne faisait que **forwarder son
> propre** syslog. Pour qu'il **relaie** celui d'OPNsense, il doit aussi **écouter** en
> entrée. Une ligne à ajouter dans sa conf rsyslog (`imudp`, port `514`) — voir `demo.sh`.

**À montrer (GUI)** : `System > Settings > Logging / targets` → **Add** une destination
syslog :
- **Transport** : UDP(4)
- **Applications** : (laisser tout, ou cibler `suricata`)
- **Hostname** : l'IP du relais/collecteur (sur le lab : `192.168.1.200:514`, le relais
  Proxmox qui pousse vers Logstash 5514)
- **Save**, **Apply**.

**À montrer (DEPUIS KIBANA)** : Discover → index `logstash-syslog-*` (ou `logstash-*`) →

```
syslog_hostname : "OPNsense.internal" and message : "SCAN"
```

**Attendu** : les alertes Suricata apparaissent, avec leur signature. « Ton IDS et ton
SIEM se parlent : tu **détectes** ET tu **gardes la trace**. »

## 3. 💥 La panne du vrai monde — "règles téléchargées OK" mais 0 chargée (8 min)

> Panne **réelle**, vécue sur l'infra (`docs/opnsense.md`, section IDS re-appliqué sans GUI).

**Le récit** : « Sur le vrai lab, je re-configure Suricata sans le GUI, par la console. Je
lance la mise à jour des règles. Le message répond… **OK**. Parfait ? Je lance l'IDS. Il
tourne. Tout est vert. Sauf que : Suricata tournait avec **ZÉRO règle**. Un IDS qui ne
détectait **rien**. Le message disait OK, la réalité disait le contraire. »

**La cause** : « Dans le GUI, il y a un bouton **Apply** qui, en coulisses, régénère la
configuration à partir des cases que tu as cochées. En console, ce Apply n'existe pas —
c'est une commande séparée, et je l'avais **oubliée**. Résultat : le fichier
`rule-updater.config` (la liste des rulesets à télécharger) était resté **vide**. Du coup
`configctl ids update` répondait "OK"… mais n'avait littéralement **rien** à télécharger
ni charger. OK de "je n'ai rien à faire", pas OK de "c'est chargé". »

**Rejouée à l'écran** :

```sh
configctl ids update            # répond "OK"
sh -c "wc -l /usr/local/etc/suricata/rules/*.rules | tail -1"   # → 0
```

**Le diagnostic** : « Ne crois pas le message. Regarde l'**effet**. Combien de règles
chargées ? `0`. Une alerte de test tombe-t-elle quand je scanne ? Non. Donc l'update, même
"OK", n'a rien fait. »

**Le fix — le "Apply" en CLI, DANS LE BON ORDRE** :

```sh
configctl template reload OPNsense/IDS   # <-- l'équivalent du bouton Apply ; remplit rule-updater.config
configctl ids update                     # MAINTENANT il a la liste → télécharge + charge
configctl ids start
sh -c "wc -l /usr/local/etc/suricata/rules/*.rules | tail -1"   # → des dizaines de milliers ✅
```

« **`template reload` AVANT `update`.** Le reload régénère `rule-updater.config` depuis ta
config (comme le Apply du GUI) ; l'update ne peut télécharger que ce que le reload lui a
listé. Inverse l'ordre et tu retombes dans le "OK qui ne fait rien". »

**Morale (à afficher en gras à l'écran)** :

> **Un "OK" n'est pas une preuve. Vérifie l'EFFET, pas le message de succès — ici :
> compte les règles chargées et déclenche une alerte de test.**

**Nommer l'écho** : « Tu as DÉJÀ rencontré ce cousin. Cours 2 chap 5 : l'**import Kibana
qui "réussit" sans rien importer**. Et la règle générale du chantier OPNsense : **Apply
GUI ≠ CLI** — une action du GUI a souvent une commande console séparée, oublie-la et ta
config ne s'applique pas. Même famille, même piège, même parade : ne te fie jamais au
message "succès", vérifie que la chose a **réellement** eu lieu. »

## 4. Encart vrai matériel (2 min)

**À filmer sur l'infra réelle** :
- OPNsense (VM 600), `Services > Intrusion Detection` : Suricata **running**, mode
  détection, WAN, **9 rulesets** actifs (7 ET open — scan, exploit, malware,
  attack_response, botcc, compromised, drop — + abuse.ch sslblacklist & feodotracker),
  **~69 500 lignes** de règles chargées.
- Kibana `logstash-syslog-*`, filtre `syslog_hostname: "OPNsense.internal"` : les alertes
  Suricata frais dans le SIEM, corrélables avec le reste des logs — et **persistant après
  un reboot** de la VM.

**À dire** : « C'est en place pour de vrai : le pare-feu de périmètre détecte les
intrusions ET les envoie au SIEM. Détecter + garder la trace, sur le vrai matériel. »

## 5. Annonce du TP (1 min)

**À dire** : « À toi : tu ajoutes **un ruleset abuse.ch de plus**, tu **déclenches une
alerte de test** (un scan de ports vers ton WAN), et tu la **retrouves dans Kibana**,
filtrée par le hostname OPNsense. Et surtout : après ton update, tu **vérifies l'effet** —
tu comptes les règles, tu ne te contentes pas du "OK". 25 minutes. Au prochain chapitre :
Vault, pour arrêter de balader des mots de passe en clair. »
