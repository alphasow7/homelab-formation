#!/usr/bin/env bash
# Chapitre 4 — Les rôles : les commandes de la démo.
# À exécuter depuis le poste de l'élève (le contrôleur Ansible).
# Prérequis : chapitre 3 fait, IP_DE_TON_BASTION remplacée dans inventory/hosts.yml.
set -euo pipefail

# On se place dans le dossier ansible/ (là où vivent ansible.cfg et roles/).
cd "$(dirname "$0")/../ansible"

# 1. Le refactor : le playbook du chapitre 3, réduit à une phrase grâce au rôle.
#    Attendu : ok=4 changed=0 (ou changed=1 + restart nginx au premier passage,
#    si le template diffère de l'ancienne page).
ansible-playbook playbooks/web-status-role.yml

# 2. Le vrai rôle : dns-proxy devient le serveur DNS du lab.
#    Attendu : ~ok=8 changed=6 au premier passage, zéro failed.
ansible-playbook playbooks/dns.yml

# 3. LA preuve — depuis le bastion (il est sur le segment du lab) :
#    on interroge notre serveur tout frais. Attendu : 10.10.99.11
# ssh alpha@IP_DE_TON_BASTION "dig @10.10.99.12 elastic-1.lab.local +short"

# ─────────────────────────────────────────────────────────────────────────────
# 💥 La panne du vrai monde : le doublon options{} (séquence manuelle, en démo)
# ─────────────────────────────────────────────────────────────────────────────

# CASSER — ajouter volontairement à la fin de
#   roles/dns/templates/named.conf.local.j2 :
#       options {
#           recursion yes;
#       };
#   puis déployer. Attendu : le handler "Restart bind9" ÉCHOUE en rouge.
# ansible-playbook playbooks/dns.yml

# OBSERVER — le journal DU service, sur LA machine (via le bastion) :
#   Attendu dans les 20 lignes :
#     /etc/bind/named.conf.local:9: 'options' already exists
#     loading configuration: already exists
# ssh alpha@IP_DE_TON_BASTION
# ssh alpha@10.10.99.12
# sudo journalctl -u named -n 20

# RÉPARER — corriger LE TEMPLATE (jamais la VM : le fix y serait écrasé
#   au prochain déploiement) : retirer le bloc options ajouté dans
#   named.conf.local.j2, puis redéployer et re-prouver au dig.
# ansible-playbook playbooks/dns.yml
# ssh alpha@IP_DE_TON_BASTION "dig @10.10.99.12 elastic-1.lab.local +short"
