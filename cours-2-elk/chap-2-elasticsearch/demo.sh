#!/bin/bash
# Chapitre 2 — Elasticsearch mono-nœud
set -euo pipefail

########## SUR LE POSTE (contrôleur Ansible) ##########
cd "$(dirname "$0")/../../cours-1-ansible/ansible"

# 0. Recopier le rôle de référence dans TON arbre (une fois)
cp -r ../../cours-2-elk/ansible-extraits/roles/elasticsearch roles/
cp ../../cours-2-elk/ansible-extraits/playbooks/elk.yml playbooks/

########## SUR LE NŒUD PROXMOX (root) — masquerade ON (~600 Mo à télécharger) ##########
# iptables -t nat -A POSTROUTING -s 10.10.99.0/24 -o vmbr0 -j MASQUERADE

########## SUR LE POSTE ##########
ansible-playbook playbooks/elk.yml

########## SUR LE NŒUD PROXMOX — masquerade OFF ##########
# iptables -t nat -D POSTROUTING -s 10.10.99.0/24 -o vmbr0 -j MASQUERADE

########## SUR LA VM elastic-1 (ssh via bastion) ##########
# /usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
#   → note le mot de passe (remplace LE_MDP ci-dessous)

# Premier contact — attendu : "You Know, for Search"
# curl -u elastic:LE_MDP http://localhost:9200

# Santé — attendu : "status" : "yellow" (NORMAL en mono-nœud !)
# curl -u elastic:LE_MDP "http://localhost:9200/_cluster/health?pretty"

# Indexer 2 documents puis chercher — attendu : total.value = 1
# curl -u elastic:LE_MDP -X POST "http://localhost:9200/journal/_doc" \
#   -H 'Content-Type: application/json' \
#   -d '{"date":"2026-07-07T10:00:00","machine":"elastic-1","evenement":"premier document indexé"}'
# curl -u elastic:LE_MDP -X POST "http://localhost:9200/journal/_doc" \
#   -H 'Content-Type: application/json' \
#   -d '{"date":"2026-07-07T10:05:00","machine":"dns-proxy","evenement":"rien à signaler"}'
# curl -u elastic:LE_MDP "http://localhost:9200/journal/_search?q=evenement:premier&pretty"
