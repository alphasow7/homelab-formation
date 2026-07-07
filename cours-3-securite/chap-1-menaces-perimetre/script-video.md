# Chapitre 1 — Menaces & périmètre : penser comme un attaquant : script vidéo

> Durée cible : ~20 min. Prérequis élève : cours 0 (Proxmox), 1 (Ansible) et 2 (ELK)
> terminés — un lab de 4 VMs sur le segment isolé 10.10.99.0/24, et un SIEM ELK
> fonctionnel où arrivent DÉJÀ tous les logs du lab (Filebeat, syslog réseau, dashboards
> Kibana). C'est ce SIEM qui va tout changer dans ce cours.
>
> ⚠️ **Dérogation au gabarit, assumée** : ce chapitre est narratif. Pas de `demo.sh`,
> pas de TP, pas de commande à rejouer. Comme le chapitre 1 du cours ELK et le chapitre 1
> du cours Ansible : on pose la VISION et le MODÈLE MENTAL avant de poser les briques.
> C'est le seul chapitre du cours construit comme ça — dès le chapitre 2, on installe
> OPNsense pour de vrai.

---

## 1. Le modèle de menace d'un homelab (5 min)

### À dire (idées et phrases clés)

- Ouvrir SANS bonjour, direct sur la question qui dérange : « Qui attaque un lab à la
  maison ? Sérieusement. Tu n'as pas de données bancaires, pas de secrets industriels,
  personne ne te connaît. Alors qui perdrait son temps à s'en prendre à TES quatre VMs ?
  La réponse va te surprendre : personne. Et tout le monde. »
- **Nommer l'exercice** : « Pour se défendre, il faut d'abord penser comme un attaquant.
  Cet exercice a un nom : établir son **modèle de menace**. C'est une question simple —
  contre QUOI, exactement, est-ce que je me défends ? Et pour un homelab, la réponse tient
  en trois réalités très concrètes. »

- **Réalité 1 — les BOTS qui scannent tout, en continu** : « Sur Internet, il existe des
  programmes automatiques — des **bots** — dont le seul travail est de balayer l'intégralité
  des adresses IP de la planète, en boucle, jour et nuit. Toutes les adresses. Y compris la
  tienne. Ils ne te cherchent pas TOI : ils testent chaque porte de chaque maison, 24h/24.
  L'ordre de grandeur va te faire mal : dès qu'un port est exposé sur Internet, il est
  trouvé en **quelques minutes**. Pas quelques jours. Quelques minutes. Ce n'est pas de la
  malchance, c'est de l'arithmétique : il y a plus de bots qui scannent que de secondes
  dans une journée. »
- **Réalité 2 — le SERVICE exposé par erreur** : « Deuxième réalité, la plus humaine. Un
  soir, tu ouvres un port "juste pour tester" un truc depuis l'extérieur. Ça marche, tu es
  content, tu passes à autre chose. Et tu oublies de le refermer. Ce port oublié, ce
  n'est pas un détail — c'est une porte grande ouverte que les bots de la réalité 1 vont
  trouver en minutes. La plupart des intrusions de homelab ne commencent pas par un génie
  du hacking : elles commencent par un `docker run -p` lancé un mardi soir et jamais
  rangé. »
- **Réalité 3 — le service compromis qui veut SORTIR** : « Troisième réalité, la plus
  sournoise, parce qu'elle vient de l'intérieur. Imagine qu'un de tes conteneurs, un de
  tes services, se fasse compromettre — une image Docker piégée, une dépendance vérolée.
  L'attaquant est maintenant DANS ton lab. Que fait-il ? Il essaie de se déplacer : d'une
  VM à l'autre, d'un segment à l'autre, vers tes données, vers Internet pour appeler chez
  lui. Ce déplacement a un nom : le **mouvement latéral**. La menace n'est plus à la porte
  d'entrée — elle est dans le couloir. »

- **La phrase qui recadre tout** (regard caméra, débit lent) : « Retiens ceci, c'est le
  cœur de ce chapitre : **tu n'es pas une cible parce que tu es intéressant — tu es une
  cible parce que tu es À PORTÉE.** Les bots ne lisent pas ton CV. Ils testent ton IP
  parce qu'elle existe. La bonne nouvelle ? Se défendre contre ça, ce n'est pas de la
  magie. C'est de la méthode. Et c'est tout ce cours. »

### À montrer à l'écran

- Slide d'ouverture : « Qui attaque un lab à la maison ? » en gros, sur fond noir.
- Les 3 réalités qui s'affichent une à une, chacune avec une image :
  BOTS = un scanner qui balaie une grille d'IP 🤖 / SERVICE OUBLIÉ = une porte
  entrouverte 🚪 / MOUVEMENT LATÉRAL = une flèche qui rebondit de VM en VM ↪️.
- La phrase en plein écran : « Tu es une cible parce que tu es À PORTÉE, pas parce que
  tu es intéressant. »

---

## 2. La défense en profondeur (6 min)

### À dire (idées et phrases clés)

- « Face à ces trois réalités, le réflexe du débutant, c'est de chercher LE mur. Le gros
  pare-feu qui arrête tout. Mauvaise idée. Un seul mur, ça se contourne, et le jour où il
  tombe, tout tombe. La vraie sécurité ne fonctionne pas comme un mur : elle fonctionne
  comme un OIGNON. Des **couches**. C'est le principe de la **défense en profondeur**. »
- « L'idée est simple et puissante : si l'attaquant franchit une couche, il en trouve une
  autre derrière. Et une autre. Chaque couche le ralentit, le fatigue, et surtout — garde
  cette idée pour la fin — chaque couche **le fait remarquer**. Voici les couches qu'on va
  poser, de l'extérieur vers le cœur : »

- **Couche 1 — le périmètre (le pare-feu)** : « La première ligne. Un **pare-feu** décide
  qui a le droit d'entrer et de sortir. C'est OPNsense, qu'on installe dès le chapitre 2.
  Le videur à l'entrée de la boîte. »
- **Couche 2 — la segmentation (les réseaux isolés)** : « Deuxième couche, et surprise :
  tu l'as DÉJÀ posée. Souviens-toi du cours 0 — tes segments `10.10.x`, tes réseaux
  isolés. Découper ton lab en zones qui ne se parlent pas librement, c'est ÇA la
  segmentation. Le jour où un service est compromis (réalité 3, le mouvement latéral), la
  segmentation, c'est ce qui l'empêche de se promener partout. Des cloisons étanches dans
  un navire : une brèche noie un compartiment, pas le bateau entier. »
- **Couche 3 — le moindre privilège** : « Troisième couche, une règle d'or : n'ouvrir que
  le **strict nécessaire**. Pas un port de plus, pas un droit de plus, pas un accès "au cas
  où". Chaque porte fermée est une porte que l'attaquant ne pourra jamais forcer. Le
  contraire exact du "juste pour tester" de la réalité 2. »
- **Couche 4 — la détection (l'IDS)** : « Les trois premières couches EMPÊCHENT. La
  quatrième REGARDE. Un **IDS** — système de détection d'intrusion, ce sera Suricata —
  surveille le trafic et lève une alerte quand il voit quelque chose de louche. Parce
  qu'aucune défense n'est parfaite : il faut aussi SAVOIR quand quelqu'un frappe aux
  murs. »
- **Couche 5 — les secrets protégés (le coffre-fort)** : « Dernière couche, la plus
  intérieure. Au cœur de ton lab il y a des **secrets** : mots de passe, clés, jetons.
  Les laisser en clair dans un fichier, c'est laisser les clés sur la porte du coffre. On
  les mettra dans un vrai coffre-fort : **Vault**. Même si tout le reste tombe, le trésor
  reste chiffré. »

- **Le schéma des couches concentriques** — à commenter en le pointant, de l'extérieur
  vers le centre :

```
        ╔═══════════════════════════════════════════════╗
        ║                  INTERNET                     ║
        ║        (bots, scans, tout le bruit)           ║
        ║   ┌───────────────────────────────────────┐   ║
        ║   │        PARE-FEU  (OPNsense)            │   ║
        ║   │   qui entre ? qui sort ?  chap 2-3     │   ║
        ║   │   ┌───────────────────────────────┐   │   ║
        ║   │   │   SEGMENT ISOLÉ  10.10.x       │   │   ║
        ║   │   │   (déjà là — cours 0 !) chap 4 │   │   ║
        ║   │   │   ┌───────────────────────┐   │   │   ║
        ║   │   │   │   VM DURCIE           │   │   │   ║
        ║   │   │   │  moindre privilège    │   │   │   ║
        ║   │   │   │   + IDS qui veille    │   │   │   ║
        ║   │   │   │   ┌───────────────┐   │   │   │   ║
        ║   │   │   │   │  SECRET dans  │   │   │   │   ║
        ║   │   │   │   │  LE COFFRE 🔒 │   │   │   │   ║
        ║   │   │   │   │   (Vault)     │   │   │   │   ║
        ║   │   │   │   └───────────────┘   │   │   │   ║
        ║   │   │   └───────────────────────┘   │   │   ║
        ║   │   └───────────────────────────────┘   │   ║
        ║   └───────────────────────────────────────┘   ║
        ╚═══════════════════════════════════════════════╝
```

- **La révélation à marteler** (regard caméra) : « Regarde bien ce schéma. La deuxième
  couche en partant de l'extérieur, la segmentation — tu l'as construite au cours 0, sans
  même savoir que tu faisais de la sécurité. Tes segments `10.10.x`, c'était DÉJÀ de la
  défense en profondeur. Tu as posé une couche sans le savoir. Aujourd'hui, on ajoute
  toutes les autres — et on les ajoute en connaissance de cause. »

### À montrer à l'écran

- Slide « UN mur ❌ → DES couches ✅ » avec l'image de l'oignon.
- Le schéma des cercles concentriques ci-dessus, plein écran, chaque couche surlignée
  quand on en parle.
- Slide qui isole la couche segmentation avec la mention « ← tu l'as déjà posée au
  cours 0 ».

---

## 3. Le plan du cours + LA boucle (5 min)

### À dire (idées et phrases clés)

- « On a le modèle de menace, on a le principe des couches. Voici comment on les pose,
  chapitre par chapitre, une phrase chacun : »
  - **Chapitres 2-3 — le périmètre** : on installe et on configure **OPNsense**, le
    pare-feu. Qui entre, qui sort : on reprend le contrôle de la porte d'entrée.
  - **Chapitre 4 — les zones** : on structure la **segmentation** — les réseaux du cours 0
    deviennent une architecture de sécurité pensée, avec des règles entre zones.
  - **Chapitre 5 — la détection** : on installe **Suricata**, l'IDS. Le lab se met à
    VOIR le trafic suspect et à lever des alertes.
  - **Chapitre 6 — les secrets** : on monte **Vault**, le coffre-fort. Fini les mots de
    passe en clair dans les fichiers.
  - **Chapitre 7 — l'hygiène** : les bons réflexes du quotidien — durcissement des VMs,
    mises à jour, moindre privilège appliqué partout.
  - **Chapitre 8 — l'épreuve** : le grand final, on y revient dans une minute.

- **LA boucle — le fil rouge du cours** (ralentir, c'est le passage le plus important) :
  « Et maintenant, la chose que je veux que tu retiennes de tout ce chapitre. Toutes ces
  défenses ont un point commun : **chacune produit des logs**. Un pare-feu qui bloque une
  connexion : c'est un log. Un IDS qui repère un scan : c'est une alerte, donc un log. Une
  tentative d'accès au coffre : un log. Et ces logs — tu sais DÉJÀ où ils vont. »
- « Tu as passé tout le cours 2 à construire un endroit où TOUS les logs de ton lab
  arrivent, rangés, cherchables : ton **SIEM**, ton Kibana. Eh bien la sécurité qu'on
  ajoute aujourd'hui se branche DESSUS. Un pare-feu qui bloque, un IDS qui alerte : ça
  n'atterrit pas dans un coin oublié — **ça arrive dans Kibana**, à côté de tes logs
  système et réseau. »
- « Voilà pourquoi le cours 2 était le prérequis. Sans SIEM, tu te défendrais à l'aveugle :
  tes murs bloqueraient des choses, mais tu ne le saurais jamais. Avec ton SIEM, **tu ne
  défends pas à l'aveugle — tu VOIS tes défenses travailler.** Chaque blocage, chaque
  alerte, sous tes yeux, dans une barre de recherche. C'est ça, la boucle : la sécurité
  produit des logs, les logs remontent au SIEM, le SIEM te rend la sécurité visible. »

### À montrer à l'écran

- Le sommaire des chapitres 2 → 8 qui s'affiche ligne par ligne.
- Un schéma simple de LA boucle : PARE-FEU / IDS / VAULT → (flèches "logs") → KIBANA
  (SIEM du cours 2) → 👁️ « tu vois tes défenses ».
- Slide : « Tu ne défends pas à l'aveugle. Tu VOIS tes défenses. »

---

## 4. Encart vrai matériel : mes défenses, en direct (2 min)

### À filmer sur l'infra réelle

- Écran de l'infra réelle du formateur, en direct, sans coupe :
  1. Le **tableau de bord OPNsense réel** : la page d'accueil du pare-feu, le trafic en
     temps réel, la liste des règles, le compteur de connexions bloquées qui grimpe tout
     seul. « Ces blocages, personne ne les a demandés à la main. C'est le bruit d'Internet
     — les bots de tout à l'heure — qui tape contre mon périmètre, en continu. »
  2. Bascule vers **Kibana** : une **alerte Suricata qui apparaît en direct** dans le SIEM.
     « Et voilà la boucle, en vrai, chez moi. Mon IDS vient de repérer quelque chose sur
     mon réseau, et l'alerte tombe ICI, dans le même Kibana que celui du cours 2, à côté
     de tous mes autres logs. Le pare-feu bloque, l'IDS détecte, le SIEM me le montre. »

### À dire

- « Tout ce que tu vois tourne sur le même genre de matériel que le tien, et sera
  configuré par les mêmes rôles Ansible que tu vas écrire. **Voilà les couches qu'on va
  poser, une par une** — et à la fin, ton tableau de bord ressemblera à ça. »

---

## 5. Annonce : l'épreuve finale (2 min)

### À dire

- **Le teaser du projet final** (regard caméra, débit lent) : « Laisse-moi te dire où on
  va. À la fin de ce cours, chapitre 8, tu vas jouer l'attaquant contre ta propre
  forteresse. Voici la scène. »
- « **Depuis l'extérieur, tu lanceras un scan `nmap` sur ton pare-feu** — exactement ce
  que font les bots dont on a parlé au début. **OPNsense le bloquera.** **Suricata le
  détectera.** Et **l'alerte tombera dans ton SIEM**, sous tes yeux, dans Kibana. Tu
  verras ton attaque se faire repérer par tes propres défenses, en temps réel. »
- « Et le bouquet final : **tu écriras la règle qui bloque définitivement l'attaquant.**
  Tu boucleras la boucle de tes propres mains. Attaque, défense, détection, réaction : les
  quatre temps de la sécurité, tu les auras tous joués, sur TON lab. »
- « C'est ça, la promesse de ce cours. Pas de la théorie sur des slides : une forteresse
  que tu construis couche par couche, et que tu attaques toi-même pour prouver qu'elle
  tient. »
- « Pas de TP aujourd'hui — c'était le chapitre des idées et du modèle mental. Le quiz est
  là pour vérifier que les trois réalités du modèle de menace, les couches de la défense
  en profondeur, et surtout LA boucle vers le SIEM sont bien en place. Au prochain
  chapitre : on installe OPNsense, et ton lab prend enfin une porte d'entrée. À tout de
  suite. »

### À montrer à l'écran

- Slide « L'ÉPREUVE (chap 8) » avec les 4 temps qui s'affichent : ATTAQUE (nmap) →
  DÉFENSE (OPNsense bloque) → DÉTECTION (Suricata alerte) → RÉACTION (tu écris la règle).
- Slide finale : « Une forteresse que tu construis couche par couche — et que tu attaques
  toi-même pour prouver qu'elle tient. »
