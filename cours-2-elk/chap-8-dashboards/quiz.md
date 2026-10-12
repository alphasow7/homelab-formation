# Quiz chapitre 8 — Dashboards de service

## Question 1 — À quoi sert un dashboard ?

- A. À stocker les logs plus longtemps qu'un index normal
- B. À répondre d'un coup d'œil à « est-ce que ça va ? » sans lire les logs un par un
- C. À remplacer Elasticsearch par une base plus rapide
- D. À exporter les logs vers un fichier PDF

---

## Question 2 — Qu'est-ce que Lens dans Kibana ?

- A. Un langage de requête pour interroger Elasticsearch
- B. L'éditeur de visualisations en glisser-déposer, sans code
- C. Un plugin de chiffrement des dashboards
- D. Le composant qui reçoit les logs de Filebeat

---

## Question 3 — Quel champ des logs journald/syslog porte la SÉVÉRITÉ d'une ligne ?

- A. `host.name`
- B. `systemd.unit`
- C. `log.syslog.priority` (le niveau : info, warning, error…)
- D. `process.name`

---

## Question 4 — Pourquoi filtrer le bruit `info` sur un dashboard ?

- A. Parce que les lignes `info` sont mal formatées
- B. Parce qu'elles prennent trop de place dans Elasticsearch
- C. Parce que 95 % des lignes sont des `info` normales : le signal utile est dans warning/error/critical
- D. Parce qu'Elasticsearch ne sait pas agréger les `info`

---

## Question 5 — Quel champ répond à « quel service systemd a émis cette ligne ? »

- A. `systemd.unit`
- B. `log.syslog.priority`
- C. `host.name`
- D. `message`

---

## Corrigé

> Ne lis cette section qu'après avoir répondu aux 5 questions.

**Réponses : 1-B, 2-B, 3-C, 4-C, 5-A.**

### Question 1 — réponse B

Discover sert à enquêter ligne par ligne ; un dashboard sert à
SURVEILLER — une page qui synthétise l'état (volume, sévérité, top services) et où une
anomalie saute aux yeux. Il ne stocke ni ne remplace rien : il lit les mêmes données ES.

### Question 2 — réponse B

Lens construit les visualisations à la souris — tu glisses un champ, il
devine la meilleure représentation (barres, camembert, table). Aucune requête à écrire.
Le langage de requête, c'est KQL ; la réception des logs, c'est Logstash/Beats.

### Question 3 — réponse C

la sévérité vit dans `log.syslog.priority` (ou le champ de niveau selon
le pipeline). `host.name` = la machine, `systemd.unit` = le service systemd, `process.name`
= le programme. Quatre champs, quatre questions différentes.

### Question 4 — réponse C

un serveur sain raconte sa vie en `info` — c'est du bruit de fond. Ce
qui mérite l'attention se cache dans `warning`, `error`, `critical`. Mettre l'`info` en
sourdine (ex. `not log.level : info`) fait ressortir le signal ; c'est tout l'intérêt du
camembert de sévérité.

### Question 5 — réponse A

`systemd.unit` porte l'unité systemd (`nginx.service`, `ssh.service`,
`cron.service`…). C'est le champ du panneau « top 10 des unités bavardes » — et celui qui,
au chapitre 9, trahira un service tué ou un service qui s'affole.
