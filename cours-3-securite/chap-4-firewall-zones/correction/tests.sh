#!/bin/bash
# CORRECTION TP chap 4 — commandes de test.
# Après avoir complété defaults/main.yml (voir main.yml de ce dossier) :
set -euo pipefail

ARBRE=~/Projects/homelab-formation/cours-1-ansible/ansible

########## [SUR LE POSTE ÉLÈVE] — appliquer la nouvelle zone bastion ##########
cd "$ARBRE"
ansible-playbook playbooks/zone-firewall.yml   # écrit /etc/pve/firewall/9204.fw

########## [DEPUIS TON POSTE] — le bastion reste joignable ##########
ssh -o ConnectTimeout=5 alpha@10.10.99.2 'echo "bastion OK"'   # attendu : bastion OK

########## [DEPUIS dns-proxy 10.10.99.12] — SSH du bastion refusé ##########
# ssh alpha@10.10.99.12  puis :
nc -vz -w 3 10.10.99.2 22       # attendu : "timed out" (refusé)
ping -c 2 10.10.99.2            # attendu : répond (ICMP laissé par le template)

########## [SUR LE NŒUD PROXMOX] — vérifier les règles compilées ##########
# pve-firewall compile | grep -A20 'VM 9204'   # policy DROP + seule règle : 22 depuis le management
