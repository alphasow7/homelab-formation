#!/usr/bin/env bash
# Chapitre 3 — Le premier playbook : la démo complète (3 runs + vandalisme).
#
# ATTENTION, deux machines différentes interviennent :
#   - TON POSTE (le contrôleur Ansible)  → les commandes ansible-playbook et ssh
#   - LE NŒUD PROXMOX                    → les commandes iptables (masquerade)
# Les blocs sont étiquetés en majuscules : lis AVANT de copier-coller.
#
# Prérequis : chapitre 2 fait (IP_DE_TON_BASTION remplacé dans inventory/hosts.yml,
# `ansible lab -m ping` renvoie 3 pongs). Remplace aussi IP_DE_TON_BASTION ci-dessous.
set -euo pipefail

# On se place dans le dossier ansible/ (là où vit ansible.cfg).
cd "$(dirname "$0")/../ansible"

# ============================================================================
# BLOC 0 — MASQUERADE ON — À EXÉCUTER SUR LE NŒUD PROXMOX (PAS SUR TON POSTE)
# ============================================================================
# Le segment 10.10.99.0/24 n'a pas d'Internet (c'est voulu, cours 0 chap 4),
# mais apt doit télécharger nginx. On ouvre la sortie NAT LE TEMPS DU PLAYBOOK.
# Adapter -o vmbr0 si ton interface de sortie a un autre nom (voir `ip route`).
#
#   iptables -t nat -A POSTROUTING -s 10.10.99.0/24 -o vmbr0 -j MASQUERADE

# ============================================================================
# DEPUIS TON POSTE — la démo Ansible
# ============================================================================

# 1. Run 1 : la construction.
#    Attendu : PLAY RECAP → ok=4 changed=3 failed=0
#    (nginx installé, page déposée, service activé — on part de zéro).
ansible-playbook playbooks/web-status.yml

# 2. La preuve : on demande au bastion (qui a un pied dans le segment)
#    d'aller chercher la page.
#    Attendu : le HTML "Lab de alpha — géré par Ansible" + hostname + Debian.
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12

# 3. Run 2 : l'idempotence.
#    Attendu : PLAY RECAP → changed=0. RIEN n'a été refait : l'état voulu
#    est déjà là. C'est ce qui rend le rejeu sans danger.
ansible-playbook playbooks/web-status.yml

# 4. Le vandalisme : on écrase la page À LA MAIN sur la VM (= le drift).
#    Attendu au re-curl : la page ne dit plus que "VANDALISME".
ssh -J alpha@IP_DE_TON_BASTION alpha@10.10.99.12 \
  "echo VANDALISME | sudo tee /var/www/html/index.html"
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12

# 5. Run 3 : la réparation par simple rejeu.
#    Attendu : changed=1 sur "Déployer la page de statut" + le handler
#    "Restart nginx" qui se déclenche. Puis le re-curl montre la vraie page.
ansible-playbook playbooks/web-status.yml
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12

# ============================================================================
# BLOC FINAL — MASQUERADE OFF — À EXÉCUTER SUR LE NŒUD PROXMOX (PAS SUR TON POSTE)
# ============================================================================
# Un accès temporaire, ÇA SE REFERME. Le segment redevient étanche.
# (Même règle qu'à l'ouverture : adapter -o vmbr0 si besoin.)
#
#   iptables -t nat -D POSTROUTING -s 10.10.99.0/24 -o vmbr0 -j MASQUERADE
