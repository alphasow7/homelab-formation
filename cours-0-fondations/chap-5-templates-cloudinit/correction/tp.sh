#!/bin/bash
# Correction TP chapitre 5 — template doré 9000 (nœud Proxmox, root)
set -euo pipefail

# 1. VM 9000 depuis l'image cloud fraîche
qm create 9000 --name debian-gold --memory 1024 --cores 1 --net0 virtio,bridge=vmbr1
qm importdisk 9000 /var/lib/vz/template/iso/debian-12-cloud.qcow2 local-lvm
qm set 9000 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9000-disk-0
qm set 9000 --ide2 local-lvm:cloudinit --boot order=scsi0 --serial0 socket
qm set 9000 --ciuser alpha --sshkeys ~/.ssh/id_ed25519.pub

# 2. Un boot de mise à jour avec IP temporaire
qm set 9000 --ipconfig0 ip=10.10.99.99/24,gw=10.10.99.254
qm start 9000
sleep 45
ssh -o StrictHostKeyChecking=accept-new alpha@10.10.99.99 \
  'sudo apt update && sudo apt -y upgrade && sudo poweroff' || true
sleep 20

# 3. Neutraliser la config réseau puis figer le moule
qm set 9000 --ipconfig0 ip=dhcp
qm template 9000
qm config 9000 | grep -E 'template|ciuser|ipconfig0'

# 4. Clone jetable de vérification
qm clone 9000 9199 --name test-gold
qm set 9199 --ipconfig0 ip=10.10.99.50/24,gw=10.10.99.254
qm start 9199
sleep 45
ssh -o StrictHostKeyChecking=accept-new alpha@10.10.99.50 hostname
qm stop 9199 && qm destroy 9199
echo "TEMPLATE DORE PRET"
