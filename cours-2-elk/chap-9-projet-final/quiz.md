# Quiz chapitre 9 — Projet final : l'aiguille dans la botte de foin

## Question 1 — Quelle est la bonne méthode pour investiguer un incident dans les logs ?

- A. Ouvrir Discover et lire les lignes une par une du début à la fin
- B. Partir large puis resserrer : repérer l'anomalie sur un dashboard, puis filtrer machine puis service ✅
- C. Se connecter en SSH à chaque VM pour vérifier ce qui tourne
- D. Chercher directement le mot « erreur » dans tous les index

**Explication** : l'entonnoir. On repère d'abord OÙ et QUAND ça cloche sur une vue
d'ensemble (dashboard), puis on descend étape par étape en filtrant. Lire tout à la main,
c'est se noyer ; et se connecter aux VMs, c'est justement ce que le SIEM doit t'éviter.

## Question 2 — Pourquoi commencer une investigation par le TEMPS ?

- A. Parce que c'est le seul champ que Kibana sait trier
- B. Parce que trouver QUAND l'anomalie survient réduit la fenêtre à fouiller avant de chercher où et quoi ✅
- C. Parce que les logs sont stockés par date dans Elasticsearch
- D. Parce que l'heure est le seul indice fiable dans un log

**Explication** : localiser le moment de l'anomalie (un pic, un creux, une flambée de
sévérité) transforme « chercher dans toute la botte de foin » en « chercher dans une
poignée ». Une fois la fenêtre de temps posée, OÙ et QUOI se déduisent vite. C'est
l'ordre : quand → où → quoi.

## Question 3 — Comment un brute-force SSH se voit-il dans les logs ?

- A. Par un log unique « intrusion détectée »
- B. Par l'arrêt du service ssh
- C. Par une rafale rapprochée de `Failed password` / `Invalid user` sur sshd, en quelques secondes ✅
- D. Par une hausse du trafic nginx

**Explication** : un brute-force, c'est un grand nombre de tentatives d'authentification
ratées en très peu de temps. La signature : un pic de volume sur la machine ciblée, et
dans Discover une salve de `Failed password for invalid user…` (`process.name : sshd`)
concentrée sur quelques secondes.

## Question 4 — Comment un service tué (ex. nginx arrêté) se voit-il dans les logs ?

- A. Par un pic massif de nouvelles lignes de ce service
- B. Par l'ARRÊT de ses logs — un creux/une absence, souvent précédé d'un log « Stopped » ✅
- C. Par un code HTTP 500 dans tous les autres services
- D. Il ne se voit pas, il faut se connecter à la machine

**Explication** : un service arrêté cesse d'émettre. Le signal est une ABSENCE — la
couleur qui maigrit sur le dashboard, l'unité qui chute dans le top, souvent un dernier
log `Stopped nginx…` juste avant le silence. Une absence est plus dure à repérer qu'un
pic : d'où l'intérêt de surveiller les creux et le top des unités, pas seulement les pics.

## Question 5 — Qu'est-ce qu'un SIEM, en pratique ?

- A. Un pare-feu qui bloque les connexions suspectes
- B. Un outil qui centralise les logs de toute l'infra pour surveiller et enquêter depuis une seule console ✅
- C. Une base de données de sauvegarde des VMs
- D. Un antivirus installé sur chaque machine

**Explication** : SIEM = Security Information and Event Management. En pratique, c'est
exactement ce que tu as bâti : les logs de toutes les machines rassemblés au même endroit
(ES + Kibana), où l'on surveille, corrèle et enquête sans se connecter aux serveurs. Le
pare-feu et la détection d'intrusion, eux, ALIMENTENT le SIEM — c'est le cours 3.

---

**Réponses : 1-B, 2-B, 3-C, 4-B, 5-B.**
