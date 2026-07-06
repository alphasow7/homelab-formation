#!/bin/bash
# Correction TP chapitre 4 — vmbr2 + routage inter-segments (nœud Proxmox, root)
set -euo pipefail

# 1. Le 2e bridge isolé
cat >> /etc/network/interfaces <<'EOF'

auto vmbr2
iface vmbr2 inet static
    address 10.10.98.254/24
    bridge-ports none
    bridge-stp off
    bridge-fd 0
EOF
ifreload -a

# 2. Déplacer la VM 9002
qm set 9002 --net0 virtio,bridge=vmbr2
qm set 9002 --ipconfig0 ip=10.10.98.10/24,gw=10.10.98.254
qm stop 9002 && qm start 9002
sleep 30

# 3. Isolement : depuis 9001, l'autre segment est injoignable
ssh -o StrictHostKeyChecking=accept-new alpha@10.10.99.10 \
  'ping -c2 -W2 10.10.98.10 || echo "ISOLES — attendu avant ip_forward"'

# 4. Le nœud devient routeur
sysctl -w net.ipv4.ip_forward=1

# 5. Preuve : les segments se parlent via le nœud
ssh alpha@10.10.99.10 'ping -c2 10.10.98.10 && echo "ROUTAGE OK"'
