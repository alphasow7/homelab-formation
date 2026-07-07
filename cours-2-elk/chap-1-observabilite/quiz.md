# Quiz chapitre 1 — Observabilité

## Question 1 — Les trois piliers de l'observabilité sont…

- A. CPU, RAM, disque
- B. Logs, métriques, disponibilité ✅
- C. Elasticsearch, Logstash, Kibana
- D. Collecte, stockage, suppression

**Explication** : les logs racontent ce qui s'est passé, les métriques disent comment ça
va, la disponibilité dit si ça répond — trois questions différentes, trois piliers.

## Question 2 — Associe la brique à son rôle : « le centre de tri » c'est…

- A. Filebeat
- B. Elasticsearch
- C. Logstash ✅
- D. Kibana

**Explication** : Logstash reçoit tout, nettoie, découpe et étiquette — Filebeat est le
facteur, Elasticsearch la bibliothèque, Kibana la salle de lecture.

## Question 3 — Un SIEM, c'est…

- A. Un antivirus pour serveurs
- B. Un pare-feu applicatif
- C. Un stack de collecte/recherche de logs orienté sécurité ✅
- D. Un scanner de vulnérabilités

**Explication** : mêmes briques que l'observabilité, mais nourries de logs d'auth, de
pare-feu et d'intrusion — et regardées avec des lunettes de défenseur.

## Question 4 — Pourquoi centraliser les logs plutôt que les lire sur chaque machine ?

- A. Pour économiser du disque sur les machines
- B. Parce que les logs locaux sont chiffrés
- C. Pour chercher en un endroit, corréler entre machines, et survivre à la rotation ✅
- D. Parce que ssh est trop lent

**Explication** : la ssh-archéologie ne passe pas à l'échelle — et l'information locale
finit effacée par la rotation ; centralisée, elle reste interrogeable.

## Question 5 — Le projet final de ce cours consiste à…

- A. Installer ELK en moins de 10 minutes
- B. Trouver un incident caché sur le lab en < 10 min, sans quitter Kibana ✅
- C. Écrire un dashboard pour chaque VM
- D. Réussir un audit de sécurité complet

**Explication** : un script cache un incident (service tué, brute-force, disque plein…) —
toi, ta barre de recherche, et le chrono.

---

**Réponses : 1-B, 2-C, 3-C, 4-C, 5-B.**
