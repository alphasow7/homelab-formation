#!/bin/bash
# Chapitre 5 — Kibana : la salle de lecture
set -euo pipefail

########## SUR LE POSTE (contrôleur Ansible) ##########
cd "$(dirname "$0")/../../cours-1-ansible/ansible"

# 0. Recopier le rôle de référence dans TON arbre (une fois)
cp -r ../../cours-2-elk/ansible-extraits/roles/kibana roles/
cp ../../cours-2-elk/ansible-extraits/playbooks/kibana.yml playbooks/

# Prérequis : le compte de service kibana_system doit avoir un mot de passe vaulté.
#   Sur elastic-1 (ssh via bastion) :
#     /usr/share/elasticsearch/bin/elasticsearch-reset-password -u kibana_system
#   Puis dans ton vault : vault_kibana_system_password: "<le mdp>"

########## SUR LE NŒUD PROXMOX (root) — masquerade ON (Kibana à télécharger) ##########
# iptables -t nat -A POSTROUTING -s 10.10.99.0/24 -o vmbr0 -j MASQUERADE

########## SUR LE POSTE ##########
ansible-playbook playbooks/kibana.yml

########## SUR LE NŒUD PROXMOX — masquerade OFF ##########
# iptables -t nat -D POSTROUTING -s 10.10.99.0/24 -o vmbr0 -j MASQUERADE

########## ACCÈS À KIBANA — tunnel SSH via le bastion ##########
# Sur ton poste (laisse ce terminal ouvert) :
#   ssh -L 5601:10.10.99.14:5601 -J alpha@BASTION alpha@10.10.99.14
# Puis dans le navigateur : https://localhost:5601
#   Login = elastic / <vault_elastic_password>   (PAS kibana_system : lui, c'est en coulisses)

########## IMPORTER LE BUNDLE DE DASHBOARDS VIA L'API ##########
# Depuis ton poste, AVEC le tunnel SSH ouvert ci-dessus (localhost:5601 → Kibana).
# On récupère la CA pour --cacert (le cert Kibana est signé par NOTRE CA) :
#   scp -J alpha@BASTION alpha@10.10.99.11:/etc/elasticsearch/certs/ca/ca.crt /tmp/elk-ca.crt
#
# BUNDLE=../../cours-2-elk/ansible-extraits/dashboards/lab-observabilite.ndjson
# curl -s --cacert /tmp/elk-ca.crt -u elastic:LE_MDP \
#   -H "kbn-xsrf: true" \
#   "https://localhost:5601/api/saved_objects/_import?overwrite=true" \
#   -F file=@"$BUNDLE" | python3 -m json.tool
#
# ⚠️ LIS LE CORPS DE LA RÉPONSE — pas juste le code HTTP :
#   "success": true,  "successCount": 3     → OK
#   "success": false, "errors": [ ... ]     → PAS OK, même en HTTP 200 !
#                                             (missing_references, conflict, etc.)
