#!/bin/bash
# Chapitre 7 — Syslog réseau : brancher ce qui n'a pas d'agent
# Deux temps : (1) rsyslog À LA MAIN sur le NŒUD PROXMOX forwarde vers l'input syslog
# de Logstash (tcp/udp 5514, en place depuis le chap 4) ; (2) on apprend à Logstash à
# LIRE le syslog (grok) et à le ranger dans son propre index `logstash-syslog-*`.
# Aucun nouveau rôle : on retouche UN bloc du pipeline du rôle logstash (cours 2).
set -euo pipefail

########## 1. SUR LE NŒUD PROXMOX (root) — forwarder son syslog ##########
# Le nœud a une patte dans notre segment (bridge vmbr1 = 10.10.99.254), il joint donc
# directement kibana-logstash (10.10.99.14) sans routage.

# 1.1 Déclarer le forward syslog. UNE seule ligne suffit.
#     *.*  = toutes les catégories (auth, kern, daemon…), tous les niveaux.
#     @    = UDP  (une seule arobase)  <-- "envoie et oublie", le syslog historique
#     @@   = TCP  (double arobase)     <-- fiable, accusé de réception (non utilisé ici)
#     Notre input Logstash écoute les DEUX. On prend UDP (@), le plus simple/répandu.
cat > /etc/rsyslog.d/90-forward-elk.conf <<'EOF'
*.* @10.10.99.14:5514
EOF

# 1.2 Recharger rsyslog pour prendre la conf.
systemctl restart rsyslog

# 1.3 Fabriquer une ligne de log de test, avec un tag UNIQUE pour la retrouver.
#     -p auth.warning = catégorie "auth", niveau "warning" (comme une vraie ligne sécurité).
logger -p auth.warning "TEST-SYSLOG-depuis-proxmox"

# (Astuce diagnostic — À FAIRE SUR kibana-logstash, PAS ici — vérifier que Logstash
#  écoute bien le 5514 en tcp ET udp. On doit voir deux lignes.)
# ss -tulnp | grep 5514


########## 2. DANS KIBANA — AVANT : ça arrive, mais brut ##########
# Discover → data view "logstash-*" → requête KQL :
#
#     message : "TEST-SYSLOG-depuis-proxmox"
#
# Attendu : 1 document. REGARDE-LE BIEN :
#   - `message` = toute la ligne syslog brute : "<36>Oct 11 05:22:01 pve root: TEST-…"
#   - `host.ip`  = 10.10.99.254 : l'adresse de QUI A ENVOYÉ LE PAQUET. Ici c'est le nœud,
#     donc ça tombe juste. Mais le jour où un RELAIS forwarde pour d'autres (cours 3 :
#     OPNsense passe par ce nœud), `host.ip` sera celle du relais — et l'équipement
#     d'origine ne sera NULLE PART, sauf dans le texte du message.
# Le hostname, le programme, la sévérité sont dans l'EN-TÊTE syslog. Il faut les LIRE.


########## 3. SUR LE POSTE — apprendre à Logstash à LIRE le syslog ##########
# Dans roles/logstash/templates/pipeline.conf.j2 (ton arbre ansible/ du cours 1) :
#
#   a) dans `filter { … }`, APRÈS le bloc grok nginx, ajouter :
#
#   if [type] == "syslog" {
#     grok {
#       match => { "message" => "(?:<%{POSINT:syslog_pri}>)?(?:1 )?(?:%{SYSLOGTIMESTAMP:syslog_timestamp}|%{TIMESTAMP_ISO8601:syslog_timestamp8601}) %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?:? %{GREEDYDATA:syslog_message}" }
#       tag_on_failure => ["_syslogparsefailure"]
#     }
#   }
#
#      Lecture : PRI optionnel (<36>), horodatage RFC 3164 OU ISO 8601, le HOSTNAME
#      (-> syslog_hostname), le programme et son pid optionnel (-> syslog_program,
#      syslog_pid), puis le message nettoyé (-> syslog_message).
#
#   b) dans `output { … }`, router le syslog vers SON index :
#
#   if [type] == "syslog" {
#     elasticsearch { …mêmes hosts/user/password/ssl…  index => "logstash-syslog-%{+YYYY.MM.dd}" }
#   } else {
#     elasticsearch { …                                index => "logstash-%{+YYYY.MM.dd}" }
#   }
#
#   (Le fichier complet est dans ../ansible-extraits/roles/logstash/templates/pipeline.conf.j2.)
#
# Puis redéployer (depuis cours-1-ansible/ansible, comme aux chapitres 4 et 6) —
# Ansible rend le template et redémarre Logstash (handler) :
ansible-playbook playbooks/logstash.yml
# Attendu : changed=1 (le pipeline), Logstash redémarré. ~30 s avant qu'il réécoute.


########## 4. SUR LE NŒUD PROXMOX — rejouer le test ##########
logger -p auth.warning "TEST-SYSLOG-depuis-proxmox-2"


########## 5. DANS KIBANA — APRÈS : des CHAMPS, et un index dédié ##########
# Stack Management → Data Views → logstash-* → "Refresh field list" (nouveaux champs).
# Discover → data view "logstash-*" (elle couvre aussi logstash-syslog-*) → KQL :
#
#     syslog_hostname : "pve" and message : "TEST-SYSLOG-depuis-proxmox-2"
#
# Attendu : 1 document, dans l'index logstash-syslog-<date>, avec :
#   syslog_hostname = pve        <-- l'équipement d'ORIGINE, lu dans l'en-tête
#   syslog_program  = root       <-- ce qui a émis (ici `logger`, tag = l'utilisateur)
#   syslog_message  = TEST-SYSLOG-depuis-proxmox-2
#   tags            = non_nginx  (et PAS _syslogparsefailure : le grok a matché)
# Les logs de l'HYPERVISEUR arrivent dans le SIEM, sans agent — et ils sont LISIBLES.

# --- Variante : vérifier directement dans Elasticsearch (depuis kibana-logstash) ---
#   curl -s --cacert /etc/logstash/certs/ca.crt -u elastic \
#     "https://10.10.99.11:9200/logstash-syslog-*/_search?q=syslog_hostname:pve&pretty"
