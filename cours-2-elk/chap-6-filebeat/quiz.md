# Quiz chapitre 6 — Filebeat

## Question 1 — Le rôle de Filebeat, c'est…

- A. Ranger les documents dans les index Elasticsearch
- B. Parser et enrichir les logs avant de les stocker
- C. Ramasser les logs sur chaque machine et les poster à Logstash — sans les traiter ✅
- D. Afficher les logs dans des dashboards

**Explication** : Filebeat est l'agent léger, « un facteur par machine » : il collecte et
expédie, point. Le tri (parsing, enrichissement) est le travail de Logstash ; le stockage,
celui d'Elasticsearch ; l'affichage, celui de Kibana.

## Question 2 — Sur nos VMs, pourquoi lire journald plutôt que `/var/log/syslog` ?

- A. journald est plus rapide que les fichiers
- B. Ces Debian minimales n'ont pas de rsyslog : `/var/log/syslog` n'existe pas, alors que
  le journal systemd, lui, est toujours là ✅
- C. Filebeat ne sait pas lire les fichiers plats
- D. journald chiffre les logs, c'est plus sûr

**Explication** : sans rsyslog, personne n'écrit `/var/log/syslog`. systemd, en revanche,
journalise toujours dans journald. Pas de rsyslog → input journald : c'est la règle du
chapitre.

## Question 3 — `systemctl status filebeat` est vert, mais Kibana affiche 0 document. Que vérifies-tu d'abord ?

- A. Ce que Filebeat REGARDE (ses inputs) — un chemin peut viser un fichier absent ✅
- B. Rien : vert = tout fonctionne, c'est forcément Kibana
- C. Tu réinstalles Elasticsearch
- D. Tu ajoutes de la RAM à la VM

**Explication** : « vert » ne prouve que le processus tourne, pas qu'il a quelque chose à
lire. Le réflexe : lancer `filebeat -e` en avant-plan pour VOIR ce qu'il fait — il dira
qu'il attend des fichiers absents.

## Question 4 — Pour Filebeat, un chemin de fichier qui n'existe pas, c'est…

- A. Une erreur fatale : le service refuse de démarrer
- B. Un avertissement qui remonte immédiatement dans Kibana
- C. Rien d'anormal : il attend, en silence, qu'un fichier apparaisse — peut-être jamais ✅
- D. Un fichier créé automatiquement et rempli

**Explication** : c'est tout le piège de la panne. Un fichier absent n'est pas traité comme
une erreur ; Filebeat reste vert et attend éternellement. D'où la bascule vers journald,
qui existe toujours.

## Question 5 — Pourquoi Filebeat envoie tout à Logstash, et jamais directement à Elasticsearch ?

- A. Filebeat est incapable de parler à Elasticsearch
- B. Pour que Logstash — le centre de tri — parse/enrichisse et soit le seul à parler
  (HTTPS) à ES et à ranger les documents ✅
- C. Parce qu'Elasticsearch refuse les connexions des agents
- D. Pour chiffrer les logs, ce que Filebeat ne sait pas faire

**Explication** : l'architecture du cours fait transiter tout le flux par Logstash (input
beats 5044) : un seul point de tri et d'écriture vers ES. Filebeat *pourrait* écrire direct
dans ES, mais on ne le veut pas — d'où l'absence volontaire d'`output.elasticsearch`.

---

**Réponses : 1-C, 2-B, 3-A, 4-C, 5-B.**
