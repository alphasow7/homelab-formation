#!/bin/bash
# Correction TP chapitre 3 — demo-vm2 en IP statique (à exécuter SUR le nœud, en root)
# Variante chemin A (VirtualBox). Pour le chemin B : remplace l'ipconfig0 par
#   ip=192.168.1.245/24,gw=192.168.1.1
set -euo pipefail

qm create 9002 --name demo-vm2 --memory 1024 --cores 1 --net0 virtio,bridge=vmbr0
qm importdisk 9002 /var/lib/vz/template/iso/debian-12-cloud.qcow2 local-lvm
qm set 9002 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9002-disk-0
qm set 9002 --ide2 local-lvm:cloudinit --boot order=scsi0 --serial0 socket
qm set 9002 --ciuser alpha --sshkeys ~/.ssh/id_ed25519.pub \
  --ipconfig0 ip=10.0.2.50/24,gw=10.0.2.2
qm start 9002

echo "Attente du boot (~30 s)..."
sleep 30
ssh -o StrictHostKeyChecking=accept-new alpha@10.0.2.50 hostname
