#!/bin/bash
# Chapitre 3 — TLS / PKI interne
set -euo pipefail

########## SUR LE POSTE (contrôleur) ##########
cd "$(dirname "$0")/../../cours-1-ansible/ansible"
cp -r ../../cours-2-elk/ansible-extraits/roles/elk_certs roles/
# ajouter le rôle elk_certs au play elk.yml (après elasticsearch), puis :
ansible-playbook playbooks/elk.yml

########## SUR LA VM elastic-1 (ssh via bastion) ##########
# CA=/etc/elasticsearch/certs/ca/ca.crt

# http est mort — attendu : connection reset
# curl http://localhost:9200

# chiffré mais NON vérifié (le -k est un aveu)
# curl -k -u elastic:MDP https://localhost:9200

# chiffré ET vérifié (on donne le tampon du notaire)
# curl --cacert "$CA" -u elastic:MDP https://localhost:9200

########## 💥 PANNE : la CA générée deux fois ##########
# OBSERVER d'abord l'empreinte actuelle (à noter) :
# openssl x509 -in "$CA" -noout -fingerprint -sha256
#
# CASSER : forcer une 2e CA
# rm /etc/elasticsearch/certs/ca.zip /etc/elasticsearch/certs/ca -rf
# /usr/share/elasticsearch/bin/elasticsearch-certutil ca --silent --pem \
#   --out /etc/elasticsearch/certs/ca.zip --days 3650
# unzip -o /etc/elasticsearch/certs/ca.zip -d /etc/elasticsearch/certs
#
# OBSERVER : la nouvelle empreinte DIFFÈRE → tout cert signé par l'ancienne CA
# n'est plus reconnu par les machines qui ont la nouvelle.
# openssl x509 -in "$CA" -noout -fingerprint -sha256
#
# RÉPARER : re-signer proprement TOUT depuis LA CA (re-déployer elk_certs après
# avoir restauré une seule CA), et vérifier que les empreintes concordent partout.
