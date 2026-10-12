#!/bin/bash
# Chapitre 4 — bridges et segmentation (à exécuter SUR le nœud Proxmox, en root)
set -euo pipefail

# 1. Créer le bridge interne vmbr1 (aucun port physique = un switch isolé)
cat >> /etc/network/interfaces <<'EOF'

auto vmbr1
iface vmbr1 inet static
    address 10.10.99.254/24
    bridge-ports none
    bridge-stp off
    bridge-fd 0
EOF
ifreload -a
ip -4 addr show vmbr1        # le nœud a un pied dans ce réseau : 10.10.99.254

# 2. Déplacer la VM de démo sur le bridge interne (IP statique du segment)
qm set 9001 --net0 virtio,bridge=vmbr1
qm set 9001 --ipconfig0 ip=10.10.99.10/24,gw=10.10.99.254
qm stop 9001 && qm start 9001
sleep 30

# 3. Depuis le nœud : la VM répond
ping -c2 10.10.99.10

# 4. Depuis la VM : Internet ne répond PAS (c'est le but !)
ssh -o StrictHostKeyChecking=accept-new alpha@10.10.99.10 \
  'ping -c2 -W2 8.8.8.8 || echo "PAS D INTERNET — normal, segment isolé !"'

# 5. Masquerade NAT temporaire : on ouvre, on prouve, on REFERME
#    Deux verrous à ouvrir : le nœud doit ACCEPTER de router (ip_forward, à 0 par
#    défaut sur Proxmox) ET réécrire l'adresse source (MASQUERADE). L'un sans l'autre
#    ne donne rien — et une règle NAT oubliée est une porte ouverte.
WAN_IF="$(ip route | awk '/default/{print $5;exit}')"
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -s 10.10.99.0/24 -o "$WAN_IF" -j MASQUERADE
ssh alpha@10.10.99.10 'ping -c2 8.8.8.8' \
  && echo "INTERNET OK (temporaire)" \
  || echo "toujours pas d'Internet — vérifie l'interface de sortie : WAN_IF=$WAN_IF"
# On referme TOUJOURS, même si le test a échoué (d'où le || au-dessus : avec set -e,
# un ping raté aurait arrêté le script ici et laissé la porte ouverte).
iptables -t nat -D POSTROUTING -s 10.10.99.0/24 -o "$WAN_IF" -j MASQUERADE
sysctl -w net.ipv4.ip_forward=0
ssh alpha@10.10.99.10 'ping -c2 -W2 8.8.8.8 || echo "refermé — le segment est de nouveau isolé"'
