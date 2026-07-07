# Quiz chapitre 7 — Syslog réseau

## Question 1 — Qu'est-ce que syslog ?

- A. Un agent qu'on installe sur chaque machine pour lire ses fichiers de log
- B. Le protocole standard et universel d'émission/collecte des logs réseau ✅
- C. Un format de compression pour archiver les vieux logs
- D. Le nom de l'index Elasticsearch qui stocke les logs

**Explication** : syslog est un protocole (RFC 3164 / 5424) vieux de 40 ans, compris par
quasiment tout équipement réseau. L'émetteur *forwarde* ses logs vers un collecteur qui
écoute — pas de stockage ni de parsing côté émetteur. Ce n'est pas un agent (ça, c'est
Filebeat, chap 6).

## Question 2 — En rsyslog, quelle est la différence entre `@` et `@@` ?

- A. `@` envoie en clair, `@@` chiffre les logs
- B. `@` = UDP (une arobase), `@@` = TCP (double arobase) ✅
- C. `@` envoie tout, `@@` seulement les erreurs
- D. Aucune, ce sont deux écritures équivalentes

**Explication** : une seule arobase `@` = **UDP** (léger, "envoie et oublie", le syslog
historique) ; double `@@` = **TCP** (fiable, avec accusé de réception). Notre input
Logstash écoute les deux ; à la démo on a pris `@` (UDP).

## Question 3 — Pourquoi un pare-feu ou un switch managé n'a-t-il pas besoin d'un agent pour alimenter ELK ?

- A. Parce qu'ils sont trop peu puissants pour faire tourner un agent
- B. Parce qu'ils savent nativement forwarder leur syslog vers un collecteur ✅
- C. Parce qu'Elasticsearch va lire leurs logs tout seul à distance
- D. Parce que Logstash installe l'agent pour eux automatiquement

**Explication** : ce sont des boîtes fermées où l'on ne peut pas installer Filebeat — mais
elles parlent syslog nativement. Il suffit de leur indiquer *"envoie ton syslog vers cette
IP:port"*, et le collecteur (input 5514 de Logstash) le reçoit. C'est tout l'intérêt du
chapitre : brancher ce qui n'a pas d'agent.

## Question 4 — Par quelle adresse le nœud Proxmox joint-il Logstash ?

- A. Par `127.0.0.1`, en local
- B. Par l'IP publique du pare-feu
- C. Par l'IP de segment de kibana-logstash, `10.10.99.14`, grâce à sa patte vmbr1 en `10.10.99.254` ✅
- D. Par `10.10.99.11`, l'adresse d'elastic-1

**Explication** : le nœud a un pied dans le segment via le bridge `vmbr1` (adresse
`10.10.99.254`). Il est donc sur le même réseau que kibana-logstash (`10.10.99.14`) et lui
parle directement, sans routage. `10.10.99.11` est elastic-1 (Elasticsearch), pas le
collecteur syslog.

## Question 5 — Un log syslog n'arrive pas dans Kibana. Quelles sont les 3 choses à vérifier, dans l'ordre ?

- A. La RAM, le disque, le CPU du collecteur
- B. Le pare-feu (port 5514 ouvert ?), l'écoute de Logstash (`ss -tulnp | grep 5514`), le format (RFC 3164/5424) ✅
- C. Le mot de passe elastic, la CA TLS, l'index du jour
- D. Kibana, le navigateur, le cache

**Explication** : on trace de bout en bout avec `logger` + un tag unique, puis on remonte
les trois maillons : **(1)** le réseau/pare-feu laisse-t-il passer le 5514 ? **(2)**
Logstash écoute-t-il bien (tcp ET udp) sur kibana-logstash ? **(3)** le format est-il du
syslog standard ? — rsyslog l'émet par défaut, donc ce maillon est bon d'office avec lui.

---

**Réponses : 1-B, 2-B, 3-B, 4-C, 5-B.**
