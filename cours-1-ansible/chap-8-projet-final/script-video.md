# Chapitre 8 — Projet final : script vidéo

> 🔄 Encart « vrai matériel » réaligné le 11/10/2026 sur le parc post-pivot VDP, complété le 12/10/2026 — référence : [`docs/infra-reelle-2026-10.md`](../../docs/infra-reelle-2026-10.md).

> Durée cible : ~20 min de vidéo (le gros du chapitre, c'est le projet de l'élève, 45 min).
> Format projet, comme le chap. 7 du cours 0 : pas de nouvelle notion — on cadre, on
> montre le résultat attendu, on donne la méthode. Dérogation au gabarit assumée.

## 1. Le brief (5 min)

**À dire** : « Au chapitre 1, je t'ai fait une promesse : si ton infra est du code, une
VM n'est plus précieuse. Aujourd'hui, on la tient — pour de vrai. Tu vas DÉTRUIRE
dns-proxy. Pas l'éteindre, pas la snapshotter : `qm destroy`, disque effacé. Puis tu vas
la faire renaître en moins de 5 minutes, chronomètre en main, sans jamais ouvrir la GUI
ni taper une commande dans la VM. C'est le test pets vs cattle : un “pet”, on le soigne à
la main et sa mort est un drame ; du “cattle”, on le remplace à l'identique sans y
penser. Si le phénix réussit, dns-proxy était du cattle. Si tu hésites à taper la
commande de destruction… c'est que quelque part, tu n'as pas encore tout mis dans le
code. »

**À montrer** : le schéma en 3 temps : photo de l'état → destruction (VM barrée) →
renaissance (clone + cloud-init + `site.yml`), avec le chrono « < 300 s » sur la flèche
de renaissance.

## 2. La méthode (5 min)

**À dire** : « Trois conseils de pro. (1) **Photographie AVANT de détruire** : garde les
sorties de `curl` et `dig` dans un fichier — sans photo “avant”, pas de preuve “après”.
(2) **Prépare tes deux terminaux** : un sur le nœud (destruction + clone), un sur ton
poste (le playbook). Le chrono tourne pendant que tu cherches ta fenêtre. (3) **Le piège
du known_hosts** : la nouvelle VM a la même IP mais de NOUVELLES clés d'hôte SSH. Ton
poste va hurler `REMOTE HOST IDENTIFICATION HAS CHANGED` — c'est le comportement attendu
ici : la machine derrière 10.10.99.12 a réellement changé d'identité, tu l'as tuée
toi-même. `ssh-keygen -R 10.10.99.12` sur le poste (et sur le bastion si besoin), et ça
repart. Retiens la nuance : ce message est NORMAL après un phénix volontaire, et
ALARMANT quand personne n'a détruit de VM. »

**À montrer** : le message HOST KEY CHANGED en plein écran, puis `ssh-keygen -R
10.10.99.12` qui le résout — que l'élève l'ait déjà vu avant de le vivre.

## 3. La démo du formateur, chronométrée (7 min)

**À montrer** : la démo complète avec un **vrai chrono incrusté à l'écran** (overlay au
montage, ou `SECONDS` affiché par le script) :

1. La photo : `curl http://10.10.99.12/` (la page de statut avec le secret vaulté du
   chap. 6) et `dig @10.10.99.12 elastic-1.lab.local +short` → `10.10.99.11`.
2. Sur le nœud : `correction/phenix.sh` — `qm stop`, `qm destroy`. Montrer la GUI en
   spectatrice : la VM a disparu. `dig` → `connection timed out`, `curl` → mort. « Là,
   version d'avant Ansible : sueurs froides. Version d'aujourd'hui : on regarde le
   chrono. »
3. Le script enchaîne : clone du 9000, `qm set` (RAM + ipconfig0), start, boucle
   d'attente SSH. Commenter les jalons `t=…s` qui s'affichent.
4. Depuis le poste : `ansible-playbook playbooks/site.yml --limit dns-proxy`. Pendant
   que ça déroule : « chaque ligne que tu vois passer, c'est une chose que tu aurais
   faite à la main. »
5. Le verdict : mêmes `curl` et `dig` qu'en 1, mêmes résultats, chrono arrêté sous les
   5 minutes. Puis le run bonus : `changed=0` — « pas “à peu près” reconstruite :
   identique, prouvé par l'idempotence. »

**Encart vrai matériel (2 min)** : sur l'infra réelle du formateur, montrer que c'est le
même pattern, poussé un cran plus loin : les 3 VMs de la plateforme sont recréables par
`provision-plateforme.yml`, et la stack ELK entière est **détruite et reconstruite de
zéro par un job Rundeck** (`vdp rebuild`) — c'était le critère de réussite du chantier,
atteint le 02/08/2026. À filmer : le job dans l'interface Rundeck et son journal
d'exécution. Ce qui est précieux, c'est le dépôt Git et les données — jamais la VM.
Et la leçon inverse, payée cher : un job créé **à la main** dans Rundeck, hors du dépôt,
a disparu à la reconstruction suivante — avec lui le renouvellement des certificats de ma
supervision, et un mois de panne silencieuse (tu l'entendras au cours 2). **Ce qui n'est
pas dans le dépôt n'existe pas.** Aujourd'hui ce job est un fichier versionné, importé par
un rôle, et chaque push du dépôt est vérifié par une CI qui tourne dans le lab.

## 4. Célébration et suite (3 min)

**À dire** : « Prends dix secondes. Tu viens de détruire une machine de production de ton
lab — volontairement, sereinement — et de la faire renaître en moins de cinq minutes,
sans GUI, sans une seule commande tapée dans la VM. C'était la promesse du chapitre 1 —
tenue. Ta VM était du bétail ; ton code, lui, est immortel tant qu'il est dans Git. Mais
il reste un angle mort : ton infra renaît en 5 minutes… sais-tu ce qu'elle FAIT à chaque
instant ? Qui l'interroge, qu'est-ce qui rame, qu'est-ce qui échoue en silence ? Au
cours 2, on branche les yeux : ELK — Elasticsearch, Logstash, Kibana. Et tes deux VMs
`elastic-1` et `kibana-logstash` attendent déjà sur le segment. À très vite. »

**À filmer (encart final)** : le tableau de bord Kibana « Homelab — Vue d'ensemble » de
l'infra réelle en teaser — « voilà les yeux qu'on branche au cours 2 ».
