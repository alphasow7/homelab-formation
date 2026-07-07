# Chapitre 1 — Observabilité : voir enfin ce qui se passe : script vidéo

> Durée cible : ~20 min. Prérequis élève : cours 0 et cours 1 terminés — 4 VMs vivantes
> (elastic-1 4 Go, kibana-logstash 2 Go, dns-proxy sur le segment isolé 10.10.99.0/24,
> plus le bastion), le tout géré par Ansible (`site.yml` passe en `changed=0`).
>
> ⚠️ **Dérogation au gabarit, assumée** : ce chapitre est narratif. Pas de `demo.sh`, pas
> de TP, pas de commande à rejouer. Comme le chapitre 1 du cours Ansible : on pose la
> VISION avant de poser les briques. C'est le seul chapitre du cours construit comme ça —
> dès le chapitre 2, on installe Elasticsearch pour de vrai.

---

## 1. Le scénario moteur : « hier à 23h » (4 min)

### À dire (idées et phrases clés)

- Ouvrir SANS bonjour, direct dans l'histoire : « Hier soir, à 23h, quelque chose a
  ralenti sur ton lab. Pas planté — ralenti. Ce matin, tout semble normal. Mais TOI, tu
  veux savoir. Qui ? Quoi ? Pourquoi 23h ? »
- **Sans logs centralisés — la ssh-archéologie** : « Voilà ta journée. Tu ouvres un
  terminal. `ssh bastion`. Tu fouilles `/var/log/` : `syslog`, `auth.log`, les logs de
  tes services… Rien de flagrant. Tu recommences sur dns-proxy. Puis sur elastic-1. Puis
  sur kibana-logstash. Quatre machines. Facilement quarante fichiers de logs, chacun avec
  SON format de date, SON niveau de détail, SES abréviations. Tu joues à `grep` en
  aveugle, tu croises les horodatages de tête… » Pause. « Et le pire ? L'information que
  tu cherches a peut-être déjà DISPARU. Les logs tournent — c'est la **rotation** :
  quand un fichier grossit trop, le système le compresse, puis le supprime. Le log de
  23h ? Peut-être écrasé pendant que tu dormais. Tu fais de l'archéologie sur un site
  qu'on rebouche en même temps que tu creuses. »
- **Avec un SIEM** : « Même question, autre monde. Tu ouvres UN onglet de navigateur.
  Une barre de recherche. Tu tapes une plage horaire : hier, 22h45 → 23h15. Tous les
  logs de TOUTES tes machines, au même endroit, dans le même format, triés par le temps.
  Trente secondes, et tu vois le pic, le service, la ligne exacte. La différence entre
  quatre heures de fouille et une requête. »
- **Nommer le concept** : « Ce qu'on vient de décrire, ça a un nom : l'**observabilité**.
  Les définitions savantes existent, en voici une simple et honnête : être observable,
  c'est **pouvoir répondre aux questions qu'on ne s'était pas encore posées**. Hier à
  23h, tu ne savais pas que tu aurais cette question aujourd'hui. Un système observable
  a quand même la réponse — parce qu'il a tout gardé, tout rangé, tout rendu
  interrogeable. C'est ÇA qu'on construit dans ce cours. »

### À montrer à l'écran

- Slide « 23:07 » en gros, avec un graphe qui fait une bosse.
- Split-screen : à gauche 4 terminaux empilés pleins de `grep` (la ssh-archéologie), à
  droite une seule barre de recherche Kibana.
- La définition en plein écran : « Observabilité = répondre aux questions qu'on ne
  s'était pas encore posées. »

---

## 2. Les 3 piliers de l'observabilité (5 min)

### À dire (idées et phrases clés)

- « L'observabilité tient sur trois piliers. Trois familles de données, trois questions
  différentes. Retiens les images, pas le jargon. »

- **Pilier 1 : les logs — « ce qui s'est passé »**. « Un log, c'est une ligne de texte
  qu'un programme écrit quand il fait quelque chose : "connexion SSH acceptée pour
  alpha", "requête DNS pour example.com", "erreur : disque plein". C'est le **journal de
  bord** du navire : chaque événement, daté, dans l'ordre. Quand tu veux reconstituer
  une histoire — qui s'est connecté, qu'est-ce qui a planté, dans quel ordre — tu ouvres
  le journal de bord. »
- **Pilier 2 : les métriques — « comment ça va »**. « Une métrique, c'est un chiffre
  mesuré à intervalle régulier : CPU à 34 %, RAM à 78 %, 12 requêtes par seconde. C'est
  le **tableau de bord de la voiture** : compteur de vitesse, jauge d'essence,
  température moteur. Tu ne sais pas POURQUOI le moteur chauffe — mais tu vois QU'il
  chauffe, et depuis quand. »
- **Pilier 3 : la disponibilité — « est-ce que ça répond »**. « La question la plus
  bête et la plus vitale : le service est-il vivant, là, maintenant ? On envoie une
  petite requête régulièrement et on chronomètre la réponse. C'est **prendre le pouls**.
  Pas besoin de comprendre le patient pour savoir si son cœur bat. »
- **Le choix du cours, assumé** : « Ce cours, c'est les **LOGS d'abord**. Pourquoi ?
  Parce que c'est le pilier le plus RICHE : une métrique te dit "le CPU est monté", un
  log te dit "voilà QUI a fait QUOI pour que le CPU monte". C'est aussi le pilier dont
  le cours 3 — la sécurité — aura besoin : un intrus ne laisse pas de trace dans une
  jauge de CPU, il en laisse dans les logs. Les deux autres piliers ? Le stack qu'on va
  monter sait les faire aussi : **Metricbeat** pour les métriques, **Heartbeat** pour la
  disponibilité — même famille d'outils que le Filebeat qu'on installera au chapitre 6.
  Je te les montre "pour aller plus loin" en fin de cours, mais ils sont hors périmètre :
  on fait UNE chose, à fond. »

### À montrer à l'écran

- Les 3 piliers qui s'affichent un à un, chacun avec son image :
  LOGS = journal de bord 📖 / MÉTRIQUES = tableau de bord 🚗 / DISPONIBILITÉ = pouls 🫀.
- Une vraie ligne de log (auth.log du bastion) vs une métrique (CPU %) vs un check
  up/down — côte à côte, pour rendre la différence concrète.
- Slide : « Ce cours = LES LOGS. Metricbeat/Heartbeat : pour aller plus loin. »

---

## 3. L'architecture ELK : la chaîne du log (6 min)

### À dire (idées et phrases clés)

- « Le stack qu'on va construire s'appelle **ELK** — trois lettres pour trois logiciels :
  **E**lasticsearch, **L**ogstash, **K**ibana. Plus un quatrième mousquetaire, Filebeat.
  Voici le trajet complet d'une ligne de log, de ta VM jusqu'à ton écran. »

- Schéma à commenter en le pointant, brique par brique, UNE phrase chacune :

```
  ┌───────────────────────────────────────────────┐
  │  TES MACHINES (bastion, dns-proxy, …)         │
  │                                               │
  │   /var/log/…  ──►  FILEBEAT  = le facteur     │
  │                    (ramasse et expédie)       │
  └───────────────────────┬───────────────────────┘
                          ▼
  ┌───────────────────────────────────────────────┐
  │  LOGSTASH  = le centre de tri                 │
  │  (ouvre, nettoie, étiquette, redirige)        │
  └───────────────────────┬───────────────────────┘
                          ▼
  ┌───────────────────────────────────────────────┐
  │  ELASTICSEARCH  = la bibliothèque indexée     │
  │  (stocke tout, retrouve tout en un instant)   │
  └───────────────────────┬───────────────────────┘
                          ▼
  ┌───────────────────────────────────────────────┐
  │  KIBANA  = la salle de lecture                │
  │  (la barre de recherche, les graphiques)      │
  └───────────────────────────────────────────────┘
```

- **Filebeat, le facteur** : « Un petit agent, léger, installé sur CHAQUE machine : il
  surveille les fichiers de logs et expédie chaque nouvelle ligne — il ne lit pas le
  courrier, il le livre. »
- **Logstash, le centre de tri** : « Il reçoit le courrier de tous les facteurs, ouvre
  chaque enveloppe, met les lignes brutes au propre — extrait la date, l'IP, le nom du
  service — colle les bonnes étiquettes et redirige vers le bon rayon. »
- **Elasticsearch, la bibliothèque indexée** : « Le cœur du système. Pas juste un
  entrepôt : une bibliothèque avec un fichier d'index géant — chaque mot de chaque ligne
  est répertorié. Demande "toutes les lignes qui contiennent failed password ce mois-ci"
  et la réponse tombe en millisecondes, même avec des millions de documents. »
- **Kibana, la salle de lecture** : « La seule brique que tu verras au quotidien : une
  interface web avec LA barre de recherche du début de la vidéo, plus des graphiques,
  des tableaux de bord, des alertes. »
- « Et où ça s'installe chez toi ? Elasticsearch, le gourmand, tout seul sur
  **elastic-1** — les 4 Go de RAM, c'est pour lui. Logstash et Kibana colocataires sur
  **kibana-logstash** — le nom de ta VM prend enfin tout son sens. Filebeat, partout.
  Et TOUT sera installé par Ansible, évidemment — on n'a pas appris l'IaC pour
  recommencer à cliquer. »
- **Définir SIEM** : « Un mot que tu vas croiser partout, sur les fiches de poste comme
  dans ce cours : **SIEM** — *Security Information and Event Management*. Ça a l'air
  intimidant, mais tu viens de voir ce que c'est : **un centre de tri + une bibliothèque
  + une salle de lecture, ORIENTÉS sécurité**. Le même stack — mais au lieu de chercher
  "pourquoi c'est lent", tu cherches "qui essaie d'entrer". Les logs d'authentification,
  les alertes d'intrusion, les connexions suspectes. Le même outil, l'usage en plus.
  À la fin de ce cours, tu auras les deux : l'observabilité au quotidien, et un SIEM qui
  n'attend que les sondes de sécurité du cours 3. »

### À montrer à l'écran

- Le schéma ASCII ci-dessus, plein écran, chaque brique surlignée quand on en parle.
- Une même ligne de log montrée à chaque étape : brute chez Filebeat → découpée en
  champs chez Logstash → retrouvée par une recherche dans Kibana.
- Slide : « SIEM = le même stack + l'usage sécurité ».

---

## 4. Pourquoi ELK et pas Prometheus/Grafana ? (3 min)

### À dire (idées et phrases clés)

- « Question légitime, et je te dois une réponse honnête. Si tu as déjà traîné sur des
  forums de homelab, tu as vu passer **Prometheus** et **Grafana** — le duo star pour la
  supervision. Alors pourquoi ELK ici ? Trois raisons, et je les assume comme
  CONTEXTUELLES — ce sont MES raisons, dans MON contexte. »
- **Raison 1 — l'expertise est déjà là** : « ELK, c'est mon métier. Je travaille dessus
  tous les jours. Je peux t'enseigner ses pièges parce que je suis tombé dedans, ses
  bonnes pratiques parce que je les applique en production. Un formateur qui enseigne
  son terrain de jeu, c'est toujours mieux qu'un formateur qui a lu la doc la veille. »
- **Raison 2 — un seul stack pour tout** : « Prometheus est un spécialiste des
  MÉTRIQUES — il excelle sur ce pilier-là. Mais notre priorité, ce sont les LOGS, et
  ELK fait les deux dans UN seul stack : logs d'abord, métriques quand tu voudras, avec
  les mêmes outils, la même interface. Sur un homelab où chaque Go de RAM compte, un
  stack unique, ça pèse. »
- **Raison 3 — le cours 3 arrive** : « Au cours 3, on installe un **IDS** — un système
  de détection d'intrusion, Suricata — et ses alertes se brancheront DIRECTEMENT sur le
  stack qu'on monte maintenant. ELK est le SIEM open source le plus répandu ; ce que tu
  apprends ici, tu le retrouveras en entreprise, tel quel. »
- **L'honnêteté finale, regard caméra** : « Prometheus est excellent — si ton contexte
  diffère, ton choix peut différer. Peut-être que ton lab à toi finira sous Grafana, et
  ce sera très bien. Ce qu'on apprend ici — centraliser, parser, indexer, chercher,
  visualiser, alerter — ce sont des CONCEPTS. Ils se transposent à n'importe quel outil.
  On apprend une manière de penser ; ELK est notre véhicule. »

### À montrer à l'écran

- Slide « Pourquoi ELK ? » avec les 3 raisons : EXPERTISE / UN SEUL STACK / LE COURS 3.
- Slide finale de la section : « Ton contexte ≠ mon contexte → ton choix peut différer.
  Les concepts, eux, se transposent. »

---

## 5. Encart vrai matériel : mon Kibana en production (2 min)

### À filmer sur l'infra réelle

- Écran du Kibana réel de l'infra du formateur, en direct, sans coupe :
  1. La page d'accueil, puis Discover : le compteur de documents — **plus de 2 millions
     de documents** indexés. « Deux millions de lignes de logs. Essaie de `grep` ça. »
  2. Une recherche en live sur une plage horaire : le résultat qui tombe instantanément.
  3. Les **dashboards par service** : un pour le DNS, un pour le système, un pour le
     réseau — quelques secondes sur chacun, sans expliquer les détails.
  4. Le clou : une **alerte Suricata qui arrive en direct** dans l'interface — « ça,
     c'est mon IDS, celui du cours 3, qui vient de signaler quelque chose sur mon réseau.
     Le SIEM en action, en vrai, chez moi. »

### À dire

- « Tout ce que tu vois tourne sur le même genre de matériel que le tien, configuré par
  les mêmes rôles Ansible que tu vas écrire. **Voilà la maison qu'on va construire,
  pièce par pièce** : chapitre 2 les fondations, et à la fin, ton Kibana ressemblera à
  ça. »

---

## 6. Annonce du programme (2 min)

### À dire

- « Le programme, chapitre par chapitre, une phrase chacun : »
  - **Chapitre 2** : on installe **Elasticsearch** sur elastic-1 — la bibliothèque
    d'abord, en rôle Ansible, et on y range nos premiers documents à la main.
  - **Chapitre 3** : **TLS et PKI** — on chiffre les communications du stack, parce
    qu'un SIEM qui parle en clair, c'est un coffre-fort avec la porte ouverte.
  - **Chapitre 4** : **Logstash** — le centre de tri, et l'art de découper une ligne de
    log brute en champs propres.
  - **Chapitre 5** : **Kibana** — la salle de lecture s'ouvre : première recherche,
    premiers graphiques sur TES données.
  - **Chapitre 6** : **Filebeat** — le facteur tourne sur toutes tes VMs : chaque log de
    ton lab part au centre de tri, automatiquement.
  - **Chapitre 7** : **syslog réseau** — même tes équipements qui ne peuvent pas
    héberger d'agent envoient leurs logs dans le stack.
  - **Chapitre 8** : **dashboards et alertes** — tu construis tes tableaux de bord et le
    lab te prévient tout seul quand quelque chose cloche.
  - **Chapitre 9** : le grand final.
- **LA promesse** (regard caméra, débit lent) : « Et ce grand final, le voilà. Au
  chapitre 9, un **incident sera caché quelque part sur ton lab**. Je ne te dirai pas
  où. Je ne te dirai pas quoi. Et tu le trouveras — la machine, le service, l'heure, la
  cause — **en moins de 10 minutes, sans quitter Kibana**. Pas de ssh-archéologie. Pas
  de `grep` en aveugle. Une barre de recherche, et ta tête. Le scénario "hier à 23h" du
  début de cette vidéo ? À la fin du cours, c'est une formalité. »
- « Pas de TP aujourd'hui — c'était le chapitre des idées. Le quiz est là pour vérifier
  que les trois piliers et les quatre briques sont bien en place. Au prochain chapitre :
  on installe Elasticsearch, et ton lab commence à avoir de la mémoire. À tout de
  suite. »

### À montrer à l'écran

- Le sommaire des chapitres 2 → 9 qui s'affiche ligne par ligne.
- Slide finale : « Chapitre 9 : un incident caché → trouvé en < 10 min, sans quitter
  Kibana ».
