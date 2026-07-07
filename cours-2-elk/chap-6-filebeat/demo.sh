#!/bin/bash
# Chapitre 6 — Filebeat : l'agent léger sur les 4 VMs
set -euo pipefail

########## SUR LE POSTE (contrôleur) ##########
cd "$(dirname "$0")/../../cours-1-ansible/ansible"
cp -r ../../cours-2-elk/ansible-extraits/roles/filebeat roles/
cp ../../cours-2-elk/ansible-extraits/playbooks/filebeat.yml playbooks/
# (ou : ajouter le rôle filebeat au play elk.yml en hosts: lab)

# Masquerade ON (apt tire le paquet filebeat sur des VMs sans Internet), puis :
ansible-playbook playbooks/filebeat.yml
# Masquerade OFF

########## VÉRIF : les 4 facteurs postent ##########
# Dans Kibana -> Discover, data view logstash-* :
#   - des documents arrivent en quelques secondes
#   - champ host.name : elastic-1, kibana-logstash, dns-proxy, bastion (les 4)
#   - filtre KQL :  host.name : "dns-proxy"
#
# En ligne de commande, compter côté Elasticsearch (sur elastic-1) :
# curl --cacert /etc/elasticsearch/certs/ca/ca.crt -u elastic:MDP \
#   "https://localhost:9200/logstash-*/_count?pretty"      # attendu : > 0

########## 💥 PANNE : « 0 documents » (agent vert, rien n'arrive) ##########
#
# --- CASSER : pointer un fichier qui n'existe pas -------------------------------
# Dans roles/filebeat/templates/filebeat.yml.j2, remplacer TEMPORAIREMENT le bloc
# filebeat.inputs par :
#   filebeat.inputs:
#     - type: filestream
#       id: casse
#       paths:
#         - /var/log/rien.log
# puis redéployer :
# ansible-playbook playbooks/filebeat.yml
#
# --- OBSERVER LE SILENCE (sur la VM, ssh via bastion) ---------------------------
# systemctl status filebeat        # active (running) -> VERT. Tout va « bien ».
#   ... et pourtant, dans Kibana, plus aucun document neuf pour cet host.
#
# --- OBSERVER LE POURQUOI : Filebeat en avant-plan -------------------------------
# systemctl stop filebeat
# filebeat -e -c /etc/filebeat/filebeat.yml
#   Attendu à l'écran : « no such file » / « no paths were found » / harvester KO.
#   -> il DIT qu'il attend des fichiers absents. Un fichier manquant n'est PAS une
#      erreur pour lui : c'est une attente éternelle et silencieuse.
#   Ctrl-C pour sortir.
#
# --- RÉPARER : revenir à journald ------------------------------------------------
# Restaurer le bloc filebeat.inputs d'origine (- type: journald) dans le template,
# puis :
# ansible-playbook playbooks/filebeat.yml
# systemctl status filebeat        # vert ET, cette fois, les docs repartent :
#   dans Kibana Discover, les documents de la VM réapparaissent en quelques secondes.
#
# MORALE : un agent vert qui n'envoie rien -> demande-toi ce qu'il REGARDE.
