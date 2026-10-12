#!/usr/bin/env bash
# Chapitre 2 — L'inventaire : les 4 commandes de la démo.
# À exécuter depuis le poste de l'élève (le contrôleur Ansible).
# Prérequis : avoir remplacé IP_DE_TON_BASTION dans inventory/hosts.yml.
set -euo pipefail

# On se place dans le dossier ansible/ (là où vit ansible.cfg,
# qui pointe déjà vers l'inventaire — plus besoin de -i).
cd "$(dirname "$0")/../ansible"

# 1. Le premier contact : le module ping.
#    Ce n'est PAS un ping ICMP : c'est un test SSH (via le bastion) + Python.
#    Attendu : 3 blocs verts "SUCCESS => ... \"ping\": \"pong\"".
ansible lab -m ping

# 2. Une commande brute sur tout le groupe (module implicite : command).
#    Attendu : 3 blocs "CHANGED | rc=0" avec l'uptime de chaque VM.
ansible lab -a "uptime"

# 3. Les facts : tout ce qu'Ansible sait découvrir sur une machine.
#    On cible un seul hôte et on coupe aux 30 premières lignes.
#    Attendu : début d'un gros JSON, avec l'IP 10.10.99.12 dans
#    ansible_all_ipv4_addresses.
ansible dns-proxy -m setup | head -30

# 4. L'inventaire tel qu'Ansible le comprend (ton YAML, digéré en JSON).
#    Attendu : _meta.hostvars + les groupes lab et bastion.
ansible-inventory --list
