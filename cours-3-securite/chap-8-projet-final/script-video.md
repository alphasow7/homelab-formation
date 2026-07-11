# Projet final du cours 3 — ET DE LA FORMATION — La boucle complète : script vidéo

> Durée cible : ~30 min. C'est le dernier chapitre du dernier cours. Prérequis : tout le
> lab debout — OPNsense pare-feu de périmètre (WAN + LAN `192.168.99.1`, chap 2-4),
> Suricata actif sur le WAN (chap 5), SIEM ELK du cours 2 (**Kibana `10.10.99.14`**)
> recevant les alertes via syslog Logstash `5514`. `nmap` installé sur le poste.
> Toutes les commandes montrées sont dans `correction/attaque.sh` et ont été rejouées.

## 1. Le brief — la boucle complète (5 min)

**À dire** : « Pas de nouvelle notion aujourd'hui. Aujourd'hui, on **prouve** que tout ce
que tu as construit marche ENSEMBLE. Tu as passé quatre cours à empiler des compétences :
tu as **construit** un serveur virtualisé, tu l'as **automatisé** de A à Z, tu l'as
**observé** avec un SIEM, tu l'as **défendu** avec un pare-feu et un IDS. Chacune était
utile seule. Mais la sécurité, ce n'est pas une couche — c'est une **boucle**. La voici :

```
   ATTAQUE  ──►  DÉFENSE  ──►  DÉTECTION  ──►  OBSERVATION  ──►  RÉACTION
  (je scanne)  (le pare-feu   (Suricata      (l'alerte dans    (j'écris la
               bloque)         alerte)         Kibana)           règle)
```

On va la jouer en entier, en une seule séance. Et le twist : tu vas être **des deux
côtés**. D'abord l'**attaquant** — depuis ton poste, hors du LAN, tu scannes ta propre IP
WAN. Puis le **défenseur** — l'analyste SOC qui retrouve la trace dans Kibana et ferme la
porte. Tu attaques ton propre lab pour prouver qu'il tient. C'est ça, l'enjeu de synthèse :
non pas "est-ce que je sais faire X ?", mais "est-ce que mes quatre briques se **parlent** ?" »

**Schéma à l'écran** :

```
  [ TON POSTE ]            [ OPNsense — VM sur Proxmox ]        [ SIEM ELK ]
   l'attaquant   ─scan─►    WAN  ──(pare-feu DROP)──  LAN         Kibana
   (côté WAN)               │                                    10.10.99.14
                            └─ Suricata ─syslog─► relais nœud Proxmox ─► Logstash 5514 ─► ES ─┘
                                                                    ▲
                            l'analyste (toi) lit l'alerte ──────────┘
                            puis écrit la règle de blocage ──► retour sur OPNsense
```

## 2. Démo formateur (18 min)

### 2.1 L'attaque — le scan (étape 1)

**À montrer (depuis le poste)** :

```bash
date
sudo nmap -sS -p- 192.168.1.36     # IP WAN d'OPNsense (adapte)
```

**À dire** : « Je note l'heure — crucial, c'est ma clé pour retrouver l'alerte tout à
l'heure. Puis un scan SYN de **tous** les ports. C'est le premier geste de n'importe quel
attaquant : "qu'est-ce qui est ouvert sur cette IP ?". `-sS` exige root ; sans `sudo`,
nmap bascule tout seul en `-sT`, ça marche aussi. »

### 2.2 La défense — le pare-feu bloque (étape 2)

**À montrer** : la sortie de nmap.

**Attendu** :
```
All 65535 scanned ports ... are in ignored states.
Not shown: 65535 filtered tcp ports (no-response)
```

**À dire** : « `filtered` partout. Le pare-feu **avale** mes paquets sans répondre — drop
silencieux. Du point de vue de l'attaquant que je suis : **rien**. Aucun port ouvert,
aucun service à attaquer, que des timeouts. Première victoire : mon périmètre du chap 3-4
tient. Mais est-ce qu'il m'a **vu** ? »

### 2.3 La détection qui tombe EN DIRECT (étape 3)

**À montrer, écran partagé** : à gauche OPNsense `Services > Intrusion Detection >
Alerts` ; à droite **Kibana** en Discover, `logstash-syslog-*`, KQL :

```
syslog_hostname : "OPNsense.internal" and message : "SCAN"
```

**À dire, en pointant l'alerte qui apparaît** : « Regardez — **en direct**. Je viens de
scanner, et l'alerte tombe. À gauche, la vue brute d'OPNsense : signature `ET SCAN`,
source = mon poste. Et à droite, la même alerte est **remontée dans mon SIEM**. Elle a
voyagé : Suricata → syslog → Logstash 5514 → Elasticsearch → mon écran. Sans que je touche
à OPNsense. Voilà la corrélation attaque/détection en chair et en os. »

**L'analyse (à voix haute, en pointant les champs)** :
- **`src_ip`** = l'IP de mon poste → l'attaquant, c'est moi.
- **la signature** → `ET SCAN Potential SYN Scan` → c'est bien un scan de ports.
- **`@timestamp`** → il colle à la seconde près à mon `date` de tout à l'heure.

« Qui, quoi, quand. Un analyste SOC ne dit jamais "il y a un point rouge" — il dit "IP X a
lancé un scan à telle heure". C'est ce que je viens de lire. »

### 2.4 La réaction — la règle de blocage (étape 4)

**À dire** : « Le pare-feu bloquait par défaut. Maintenant je vais **cibler l'attaquant**.
Deux voies, et je vais expliquer mon choix. »

**Voie A — IPS (à montrer)** : `Intrusion Detection > Administration` → **IPS mode** ON →
Apply ; puis action **Drop** sur la catégorie scan. « Suricata ne se contente plus
d'alerter : il **coupe**. Ça bloque le *type d'attaque* pour tout le monde — mais un faux
positif casserait du trafic sain. »

**Voie B — règle firewall (à montrer)** : `Firewall > Rules > WAN` → Add → **Block**,
source = l'IP de mon poste. « Je blackliste *cet* attaquant précis. Plus chirurgical, plus
simple à raisonner. »

« Je choisis la voie B pour la démo : je bloque l'IP source. Et je le **documente** — pas
de règle magique, un choix raisonné. »

### 2.5 La preuve — le 2e scan est mort (étape 5)

**À montrer** :
```bash
date
sudo nmap -sS -p- 192.168.1.36
```
Et `Firewall > Log Files > Live View` : les paquets bloqués par **ma** règle.

**À dire** : « Le 2e scan ne passe même plus la première règle WAN. Mon IP est
blacklistée. J'ai trouvé une porte en attaquant, je l'ai vue s'ouvrir dans mon SIEM, et je
l'ai **fermée**. Boucle bouclée : attaque, défense, détection, observation, réaction. »

## 3. 🎉 La célébration finale de la formation (5 min)

**À dire, posément, en regardant la caméra** :

« Arrête-toi une seconde. Regarde le chemin.

Au tout premier chapitre du cours 0, tu ne savais peut-être pas ce qu'est un
**hyperviseur**. Aujourd'hui, tu as un **datacenter miniature**. Virtualisé — Proxmox.
Automatisé de A à Z — Ansible : ton infra est du code, elle renaît en cinq minutes.
Entièrement observé — ELK : tu vois ce qui s'y passe sans te connecter à une seule
machine. Et défendu en profondeur — pare-feu, IDS, coffre-fort à secrets.

Tu as **construit**. Tu as **automatisé**. Tu as **vu**. Tu as **défendu**. Et
aujourd'hui tu viens même d'**attaquer et de réagir**.

Ce ne sont pas quatre compétences. C'est un **métier**. Plusieurs, même : sysadmin,
devops, SRE, analyste SOC — tu as touché à chacun. Et ce lab, ce n'est pas un exercice
qu'on jette : c'est ton **portfolio vivant**. Tu peux l'ouvrir, le montrer, le casser, le
reconstruire, l'améliorer. Il est à toi.

Sois fier. Vraiment. Peu de gens vont au bout de ces quatre cours. Toi, tu l'as fait. »

## 4. Ouvertures — la suite t'appartient (2 min)

**À dire** : « Et maintenant ? Le socle est là, tu peux construire dessus :

- **Orchestration** — tes deux nœuds K3S attendent : Kubernetes, les conteneurs à
  l'échelle.
- **CI/CD** — ton GitLab est déjà là : automatise le déploiement de ton propre code.
- **Haute disponibilité** — plusieurs nœuds, du failover, que rien ne tombe.
- **VPN d'accès** — rejoindre ton lab de l'extérieur, en sécurité (WireGuard sur OPNsense).

Aucune n'est un mur. Ce sont des **portes**, et tu as maintenant la clé de chacune. La
suite t'appartient. Merci d'avoir fait tout ce chemin. À toi de jouer. »
