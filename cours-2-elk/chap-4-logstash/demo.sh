#!/bin/bash
# Chapitre 4 — Logstash : le centre de tri
set -euo pipefail

########## SUR LE POSTE (contrôleur Ansible) ##########
cd "$(dirname "$0")/../../cours-1-ansible/ansible"

# 0. Recopier le rôle de référence + le playbook dans TON arbre (une fois)
cp -r ../../cours-2-elk/ansible-extraits/roles/logstash roles/
cp ../../cours-2-elk/ansible-extraits/playbooks/logstash.yml playbooks/

########## SUR LE NŒUD PROXMOX (root) — masquerade ON (Logstash à télécharger) ##########
# iptables -t nat -A POSTROUTING -s 10.10.99.0/24 -o vmbr0 -j MASQUERADE

########## SUR LE POSTE ##########
# Le play slurp la CA depuis elastic-1 : les deux hôtes dans le même inventaire.
ansible-playbook playbooks/logstash.yml

########## SUR LE NŒUD PROXMOX — masquerade OFF ##########
# iptables -t nat -D POSTROUTING -s 10.10.99.0/24 -o vmbr0 -j MASQUERADE

########## SUR LE BASTION — envoyer un événement de test ##########
# Une simple ligne de texte sur le port syslog 5514 de kibana-logstash.
echo "test $(date)" | nc 10.10.99.14 5514

# LE moment : une VRAIE ligne de log nginx (format combined).
echo '192.168.1.10 - - [07/Jul/2026:10:00:00 +0000] "GET /index.html HTTP/1.1" 200 1234 "-" "curl/8"' \
  | nc 10.10.99.14 5514

########## VÉRIF DANS ES (sur elastic-1, ou bastion avec la CA) ##########
# Remplace LE_MDP par le mot de passe elastic (vaulté).
CA=/etc/elasticsearch/certs/ca/ca.crt

# Retrouver l'événement de test — attendu : 1 hit, index logstash-YYYY.MM.dd
# curl --cacert $CA -u elastic:LE_MDP \
#   "https://10.10.99.11:9200/logstash-*/_search?q=message:test&pretty"

# Retrouver la ligne nginx par un CHAMP extrait par grok — attendu : clientip,
# verb, request, response=200, bytes=1234 dans le document.
# curl --cacert $CA -u elastic:LE_MDP \
#   "https://10.10.99.11:9200/logstash-*/_search?q=response:200&pretty"

########## ASTUCE — le compteur d'événements Logstash (sur kibana-logstash) ##########
# curl -s localhost:9600/_node/stats/events?pretty
#   → in / filtered / out : renvoie une ligne avec nc et regarde "in" monter.
