#!/bin/bash
# Correction projet final cours 0 — squelette du lab (nœud Proxmox, root)
set -euo pipefail

deploy() {
  local id=$1 name=$2 mem=$3 ip=$4
  qm clone 9000 "$id" --name "$name"
  qm set "$id" --memory "$mem" --ipconfig0 "ip=${ip}/24,gw=10.10.99.254"
  qm start "$id"
}

deploy 9201 elastic-1        4096 10.10.99.11
deploy 9202 kibana-logstash  2048 10.10.99.14
deploy 9203 dns-proxy        1024 10.10.99.12

# Le bastion : un pied dans chaque monde
qm clone 9000 9204 --name bastion
qm set 9204 --memory 512
qm set 9204 --net0 virtio,bridge=vmbr0 --ipconfig0 ip=dhcp
qm set 9204 --net1 virtio,bridge=vmbr1 --ipconfig1 ip=10.10.99.2/24
qm start 9204

echo "Attente du boot (~60 s)..."
sleep 60

# Vérifications
qm list | grep -E 'elastic-1|kibana-logstash|dns-proxy|bastion'
for ip in 10.10.99.11 10.10.99.14 10.10.99.12 10.10.99.2; do
  ping -c1 -W2 "$ip" >/dev/null && echo "$ip OK"
done

# Snapshot d'état final sur les 4 VMs
for id in 9201 9202 9203 9204; do
  qm snapshot "$id" fin-cours-0 --description "état de départ des cours 1-3"
done
qm listsnapshot 9201

echo "SQUELETTE DU LAB DEPLOYE — prêt pour le cours 1"
