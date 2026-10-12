#!/bin/bash
# Le phénix — détruire et faire renaître dns-proxy, chronométré (nœud Proxmox, root)
#
# Prérequis : le trousseau du lab (/root/.ssh/lab-keys.pub, cours 0 chap. 2) contient
# la clé du nœud — c'est elle qui lui permet de ssh vers la VM renée par vmbr1.
set -euo pipefail
SECONDS=0

# Sortie Internet temporaire : site.yml va réinstaller des paquets sur la VM neuve.
WAN_IF="$(ip route | awk '/default/{print $5;exit}')"
nat_on()  { sysctl -w net.ipv4.ip_forward=1 >/dev/null; iptables -t nat -A POSTROUTING -s 10.10.99.0/24 -o "$WAN_IF" -j MASQUERADE; echo "masquerade ON"; }

qm stop 9203 --timeout 60 || true
qm destroy 9203
echo "détruite à t=${SECONDS}s"

qm clone 9000 9203 --name dns-proxy
qm set 9203 --memory 1024 --ipconfig0 ip=10.10.99.12/24,gw=10.10.99.254
qm start 9203
echo "clonée et démarrée à t=${SECONDS}s"

# attendre SSH (via l'IP du segment, depuis le nœud)
until ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=3 alpha@10.10.99.12 true 2>/dev/null; do
  sleep 5
done
echo "SSH up à t=${SECONDS}s"

nat_on
echo "== À LANCER DEPUIS TON POSTE (contrôleur) =="
echo "cd cours-1-ansible/ansible && ansible-playbook playbooks/site.yml --limit dns-proxy"
echo "(le chrono continue dans ta tête — objectif total < 300 s)"
echo "== PUIS, ICI, quand le dig répond : refermer la sortie Internet =="
echo "   iptables -t nat -D POSTROUTING -s 10.10.99.0/24 -o $WAN_IF -j MASQUERADE"
