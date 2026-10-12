#!/bin/bash
# Chapitre 4 — Le firewall par zone (pve-firewall)
#
# ⚠️ DEUX endroits d'exécution — les blocs le disent en clair :
#   [SUR LE POSTE ÉLÈVE]  : recopie du rôle + ansible-playbook (cible le nœud)
#   [SUR LE NŒUD PROXMOX] : lecture des règles réellement appliquées
#   [DEPUIS UNE VM]       : tests de connectivité (nc)
#
# Toutes les commandes ont été rejouées sur le lab avant tournage.
set -euo pipefail

ARBRE=~/Projects/homelab-formation/cours-1-ansible/ansible
EXTRAITS=~/Projects/homelab-formation/cours-3-securite/ansible-extraits

########## [SUR LE POSTE ÉLÈVE] — recopier le rôle dans SON arbre ##########
cp -r "$EXTRAITS/roles/zone_firewall"        "$ARBRE/roles/"
cp    "$EXTRAITS/playbooks/zone-firewall.yml" "$ARBRE/playbooks/"

# Regarder la liste des VMs durcies (elastic-1 = vmid 9201) et ses 2 autorisations.
cat "$ARBRE/roles/zone_firewall/defaults/main.yml"

########## [SUR LE POSTE ÉLÈVE] — déclarer le NŒUD dans l'inventaire (une fois) ##########
# Le playbook fait hosts: proxmox, mais le nœud n'est PAS dans le groupe `lab`.
# Ajoute un groupe `proxmox` dans inventory/hosts.yml (sous all: children:) :
#     proxmox:
#       hosts:
#         pve-node:
#           ansible_host: IP_DE_TON_NOEUD   # IP de management du nœud (le web :8006)
#           ansible_user: root
#           ansible_ssh_common_args: ''     # accès direct — PAS le ProxyJump du lab

########## [SUR LE POSTE ÉLÈVE] — appliquer les zones (playbook -> NŒUD) ##########
cd "$ARBRE"
# hosts: proxmox — le playbook écrit /etc/pve/firewall/9201.fw SUR LE NŒUD.
ansible-playbook playbooks/zone-firewall.yml

########## [DEPUIS UNE VM] — vérifier que la vie normale marche encore ##########
# DEPUIS kibana-logstash (10.10.99.14) : Logstash est autorisé sur le 9200 -> OK.
# ssh alpha@10.10.99.14
nc -vz -w 3 10.10.99.11 9200      # attendu : "... succeeded!"

########## [DEPUIS UNE VM] — vérifier que le voisin est refusé ##########
# DEPUIS dns-proxy (10.10.99.12) : même segment, mais AUCUNE règle -> refusé.
# ssh alpha@10.10.99.12
nc -vz -w 3 10.10.99.11 9200      # attendu : blocage puis "timed out"


########## 💥 SÉQUENCE PANNE : le service joignable de nulle part ##########

### 1) CASSER — appliquer une règle trop stricte (on "oublie" le 9200) ###
# [SUR LE POSTE ÉLÈVE] : commente/supprime la ligne 9200 dans le defaults, puis :
cd "$ARBRE"
ansible-playbook playbooks/zone-firewall.yml
# [DEPUIS kibana-logstash] : Logstash ne joint plus ES.
nc -vz -w 3 10.10.99.11 9200      # attendu : "timed out" -> Kibana se vide

### 2) OBSERVER — le FAUX réflexe (accuser le service) : il ne mène à rien ###
# [DEPUIS le bastion] "c'est ES qui plante ?" -> NON, tout va bien côté service :
# ssh alpha@10.10.99.11 'systemctl restart elasticsearch'    # ne change RIEN
# ssh alpha@10.10.99.11 'journalctl -u elasticsearch -n 50'  # aucune erreur !

### 2bis) OBSERVER — le BON réflexe : lire les RÈGLES, SUR LE NŒUD ###
# [SUR LE NŒUD PROXMOX] : les règles réellement compilées pour la VM 9201.
pve-firewall compile | grep -A20 'VM 9201'   # le 9200 a DISPARU de la liste
iptables -L -n | grep 9200                  # (rien = port non autorisé)

### 3) RÉPARER — remettre la règle 9200 et réappliquer ###
# [SUR LE POSTE ÉLÈVE] : décommente la ligne 9200 dans le defaults, puis :
cd "$ARBRE"
ansible-playbook playbooks/zone-firewall.yml
# [DEPUIS kibana-logstash] : la connexion repasse, Kibana se remplit.
nc -vz -w 3 10.10.99.11 9200      # attendu : "... succeeded!"
