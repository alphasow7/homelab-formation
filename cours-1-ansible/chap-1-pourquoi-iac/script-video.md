# Chapitre 1 — Pourquoi l'Infrastructure as Code ? : script vidéo

> Durée cible : ~20 min. Prérequis élève : cours 0 terminé — 4 VMs vivantes (elastic-1,
> kibana-logstash, dns-proxy sur le segment isolé 10.10.99.0/24, plus le bastion).
>
> ⚠️ **Dérogation au gabarit, assumée** : ce chapitre est narratif. Pas de `demo.sh`, pas
> de TP, pas de commande à rejouer. On ne tape rien : on pose la VISION. C'est le seul
> chapitre du cours construit comme ça — dès le chapitre 2, on remet les mains dans le
> terminal et on ne les ressort plus.

---

## 1. Le drame du serveur artisanal (5 min)

### À dire (idées et phrases clés)

- Ouvrir SANS bonjour, direct dans l'histoire : « Laisse-moi te raconter la mort d'un
  serveur. »
- **Le récit** : « Il y a un serveur, dans une boîte. Configuré à la main, patiemment,
  pendant deux ans. Un paquet installé par-ci, un fichier de conf modifié par-là, un petit
  script cron ajouté un soir de rush — tu sais, "temporairement". Celui qui l'a construit
  connaissait chaque recoin par cœur. Et puis il est parti. Nouvelle boîte, meilleure
  paie, bonne route. Le serveur, lui, continue de tourner. Personne n'ose y toucher.
  Personne ne sait exactement ce qu'il y a dedans. Il tourne, c'est tout ce qu'on lui
  demande. »
- « Et un vendredi — c'est TOUJOURS un vendredi — le disque meurt. Le serveur ne reboote
  plus. Et là, la vraie question tombe : on le reconstruit comment ? Quels paquets ?
  Quelles versions ? Quels fichiers modifiés, avec quelles valeurs ? Le petit script cron,
  quelqu'un s'en souvient ? Silence. Panique. Week-end foutu, et des semaines à
  redécouvrir à tâtons ce que ce serveur faisait. » Ce serveur artisanal, unique,
  impossible à reproduire, les admins l'appellent un **serveur flocon de neige** — beau,
  unique… et qui fond.
- **Question à l'audience, regard caméra** : « Maintenant, question pour TOI. Ton lab du
  cours 0 — elastic-1, kibana-logstash, dns-proxy, le bastion. Si je te l'efface ce soir…
  tu saurais le refaire à l'identique ? Toutes les options que tu as cochées, tous les
  fichiers que tu as édités, toutes les commandes que tu as tapées en suivant les
  vidéos ? » Pause. « Réponse honnête : non. Moi non plus, de tête. Et ce n'est pas grave —
  c'est humain. Le problème, ce n'est pas ta mémoire. C'est la méthode. »
- **La solution a un nom** : l'**Infrastructure as Code**, ou **IaC** — littéralement
  « l'infrastructure en tant que code ». L'idée : la configuration de tes machines n'est
  plus une suite de gestes dans un terminal, la configuration **EST du code**. Des
  fichiers texte, versionnés dans **Git** (l'outil qui garde l'historique de chaque
  modification — tu l'as croisé au cours 0), relisibles par n'importe qui, rejouables à
  volonté.
- **Les 3 promesses de l'IaC** (à l'écran, une par une) :
  1. **Reproductible** — la machine meurt ? On rejoue le code sur une machine neuve.
     Même résultat, à chaque fois.
  2. **Documentée par nature** — plus besoin d'un wiki jamais à jour : le code ne ment
     pas. Ce qui est écrit, c'est ce qui est installé. Lire le code = lire la machine.
  3. **Réparable** — une config cassée ? On regarde l'historique Git, on voit QUI a changé
     QUOI et QUAND, on revient en arrière ou on corrige, on rejoue.

### À montrer à l'écran

- Slide unique pendant le récit : un serveur avec un ❄️ et la légende « serveur flocon de
  neige : unique, artisanal, irremplaçable ».
- Les 3 promesses qui s'affichent une à une : REPRODUCTIBLE / DOCUMENTÉ / RÉPARABLE.

---

## 2. Ansible en 3 mots (6 min)

### À dire (idées et phrases clés)

- « L'IaC, c'est l'idée. L'outil qu'on va utiliser pour la mettre en pratique s'appelle
  **Ansible**. Et je peux te le résumer en trois mots. Trois mots un peu barbares, mais
  chacun cache une idée simple. »

- **Mot 1 : agentless** (« sans agent »). « Beaucoup d'outils d'automatisation exigent
  d'installer un petit logiciel — un *agent* — sur chaque machine à gérer. Ansible, non.
  Rien à installer sur tes VMs. Ansible se connecte en **SSH** — oui, LE SSH que tu
  utilises déjà depuis le cours 0 pour te connecter à ton bastion. Si tu peux faire
  `ssh` vers une machine, Ansible peut la gérer. Point. Tes 4 VMs sont déjà prêtes, sans
  le savoir. »

- **Mot 2 : déclaratif**. « C'est la bascule mentale la plus importante du cours. Avec un
  script classique, tu écris la liste des ACTIONS : télécharge ceci, décompresse cela,
  copie ce fichier, redémarre ce service. C'est l'approche **impérative** : le COMMENT.
  Avec Ansible, tu décris l'ÉTAT que tu VEUX : "je veux que le paquet nginx soit installé,
  que ce fichier existe avec ce contenu, que ce service tourne". Le QUOI. Et Ansible
  calcule tout seul le chemin pour y arriver. Tu passes de la recette de cuisine à la
  photo du plat : tu montres le résultat, Ansible cuisine. »

- **Mot 3 : idempotent**. « Le mot fait peur, l'idée est géniale. Idempotent = tu peux
  rejouer la même chose dix fois, le résultat est identique. Tu rejoues un **playbook** —
  c'est le nom des fichiers de recettes Ansible, on les écrira dès le chapitre 3 — sur une
  machine déjà configurée ? Ansible vérifie : "nginx installé ? Oui. Fichier conforme ?
  Oui. Service démarré ? Oui." Zéro changement, zéro danger. Compare avec un script bash
  relancé deux fois : doublons, erreurs, dégâts. Avec Ansible, rejouer n'est pas un
  risque — c'est même LE réflexe : dans le doute, on rejoue. »

- **Une phrase sur la concurrence** (simplification assumée, l'annoncer comme telle) :
  « Pour situer Ansible dans le paysage, en une phrase et en simplifiant volontairement :
  **Puppet** et **Chef** font le même métier mais exigent un agent sur chaque machine ;
  **Terraform**, lui, sert à CRÉER l'infrastructure — les VMs, les réseaux — là où Ansible
  sert à la CONFIGURER une fois qu'elle existe. Nous, on a déjà créé nos VMs au cours 0 à
  la main ; Ansible va maintenant les configurer. »

### À montrer à l'écran

- Les 3 mots qui s'empilent : AGENTLESS / DÉCLARATIF / IDEMPOTENT.
- Schéma ASCII (slide ou terminal plein écran), à commenter en le pointant :

```
  ┌──────────────────────┐
  │   TON POSTE          │
  │   (ansible installé) │
  └──────────┬───────────┘
             │  SSH (rien d'autre !)
             ▼
  ┌──────────────────────┐
  │   BASTION            │
  └──────────┬───────────┘
             │
   ┌─────────┼─────────────┐
   ▼         ▼             ▼
┌─────────┐ ┌───────────────┐ ┌───────────┐
│elastic-1│ │kibana-logstash│ │ dns-proxy │
└─────────┘ └───────────────┘ └───────────┘
        segment isolé 10.10.99.0/24
```

- « Regarde bien : c'est EXACTEMENT le chemin que tu prends déjà à la main pour te
  connecter à tes VMs. Ansible ne fait rien de magique — il emprunte ta route, mais il ne
  se trompe jamais et il ne se fatigue jamais. »

---

## 3. 💥 La panne du vrai monde (6 min) — « La zone DNS fantôme »

**Mise en scène** : « Cette histoire n'est pas inventée. Elle vient de MON infra, celle
que tu vois dans les encarts "vrai matériel" depuis le cours 0. Et elle illustre le piège
numéro 1 de l'IaC — celui dans lequel tout le monde tombe une fois. Une seule fois, en
général, parce que ça vaccine. »

**Le contexte (à raconter)** : « Sur mon infra, il y a un serveur DNS — **BIND**, le
logiciel de référence pour ça, tu le connaîtras bien dans ce cours. Il est géré par
Ansible : sa configuration vit dans du code, versionnée dans Git. Tout est propre. Sauf
qu'un jour, pressé, j'ai eu besoin d'une zone DNS de plus — une zone, c'est un domaine
que le serveur connaît, ici "alphahome" pour mon réseau maison. Et qu'est-ce que j'ai
fait ? Je l'ai ajoutée À LA MAIN, direct dans le fichier de conf sur le serveur. Deux
minutes, ça marche, je passe à autre chose. Le code Ansible, lui, n'a jamais entendu
parler de cette zone. »

**Le symptôme (à raconter, ton faussement détendu)** : « Des SEMAINES plus tard, je rejoue
mon playbook DNS pour une modification banale. Ansible déroule, tout est vert… et
`named` — le service BIND — refuse de redémarrer. Le message dans les logs :
`loading configuration: already exists`. C'est tout. "Already exists". QUOI existe déjà ?
Où ? Merci du détail. »

**Le diagnostic (à dérouler à voix haute, étape par étape)** :
1. « Premier réflexe : c'est forcément mon changement d'aujourd'hui. Je relis ma modif —
   rien de suspect. »
2. « Deuxième piste : je compare le fichier de conf SUR le serveur avec ce que le template
   Ansible est censé produire. Et là… le template a ÉCRASÉ ma config manuelle. Ma zone
   "alphahome" ajoutée à la main a été mélangée avec la config générée : certaines
   directives se retrouvent EN DOUBLE. BIND voit deux fois la même déclaration →
   "already exists" → il refuse de démarrer. Une heure de ma vie pour comprendre ça. »
3. « Le vrai coupable, ce n'est pas Ansible. Ce n'est pas BIND. C'est moi, des semaines
   avant, avec ma modif "vite fait" à la main. La machine et le code racontaient **deux
   histoires différentes** — et le jour où le code a repris la parole, les deux histoires
   sont entrées en collision. »

**Nommer le concept (à l'écran)** : « Ce phénomène a un nom : le **drift** — la dérive.
C'est l'écart qui se creuse entre l'état RÉEL de la machine et ce que dit le CODE. Chaque
modification manuelle sur une machine gérée par Ansible creuse le drift. Et le drift ne
pardonne pas : il ne casse pas tout de suite — il attend des semaines, le moment où tu as
tout oublié, et il explose avec un message cryptique. »

**Morale (phrase clé, à l'écran en gros et en gras)** :
> **« On ne modifie JAMAIS à la main ce qu'Ansible gère. Si tu dois changer quelque
> chose : change le CODE, rejoue. »**

« Grave-la maintenant. À partir du chapitre 3, ta souris et ton `nano` sur les VMs, c'est
terminé : tout passe par le code. »

---

## 4. Annonce du programme (3 min)

### À dire

- « Voilà pour la vision. Concrètement, le programme, chapitre par chapitre, une phrase
  chacun : »
  - **Chapitre 2** : on installe Ansible sur ton poste et on écrit l'**inventaire** — la
    liste de tes 4 VMs, avec le bastion en passe-plat SSH.
  - **Chapitre 3** : ton premier **playbook** — tu configures une vraie chose sur une
    vraie VM, en code.
  - **Chapitre 4** : les **variables et templates** — un seul code, des configs
    différentes par machine.
  - **Chapitre 5** : les **rôles** — ranger ton code en briques réutilisables, comme les
    pros.
  - **Chapitre 6** : les **handlers et conditions** — redémarrer un service uniquement
    quand c'est nécessaire.
  - **Chapitre 7** : les **secrets avec Vault** — les mots de passe chiffrés DANS Git,
    sans honte.
  - **Chapitre 8** : le grand final.
- **LA promesse** (regard caméra, débit lent) : « Et ce grand final, le voilà. Au
  chapitre 8, tu prendras une de tes VMs — une vraie, une qui marche — et tu la
  **détruiras**. Volontairement. Complètement. Et ensuite, tu la feras **renaître,
  configurée au poil, en UNE commande et moins de 5 minutes**. Le serveur flocon de neige
  du début de cette vidéo ? Chez toi, ça n'existera plus. C'est ça, la différence entre
  bricoler son infra et la maîtriser. »
- « Pas de TP aujourd'hui — c'était le chapitre des idées. Le quiz est là pour vérifier
  que les trois mots et le drift sont bien rentrés. Au prochain chapitre : on installe
  Ansible et on écrit ta première ligne d'inventaire. À tout de suite. »

### À montrer à l'écran

- Le sommaire des chapitres 2 → 8 qui s'affiche ligne par ligne.
- Slide finale : « Chapitre 8 : détruire une VM → la faire renaître en 1 commande,
  < 5 min ».
