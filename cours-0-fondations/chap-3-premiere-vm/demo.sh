#!/bin/bash
# Chapitre 3 — première VM cloud-init (à exécuter SUR le nœud Proxmox, en root)
set -euo pipefail

# 1. Télécharger l'image cloud Debian 12 (~350 Mo)
wget -nc https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2 \
  -O /var/lib/vz/template/iso/debian-12-cloud.qcow2

# 2. Créer la VM et lui donner ce disque
qm create 9001 --name demo-vm --memory 1024 --cores 1 --net0 virtio,bridge=vmbr0
qm importdisk 9001 /var/lib/vz/template/iso/debian-12-cloud.qcow2 local-lvm
qm set 9001 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9001-disk-0

# 3. Brancher cloud-init : utilisateur, clé SSH (fichier PUBLIC !), IP en DHCP
qm set 9001 --ide2 local-lvm:cloudinit --boot order=scsi0 --serial0 socket
qm set 9001 --ciuser alpha --sshkeys ~/.ssh/id_ed25519.pub --ipconfig0 ip=dhcp

# 4. Démarrer et trouver son IP
qm start 9001
sleep 20
qm guest cmd 9001 network-get-interfaces 2>/dev/null \
  || echo "agent pas encore prêt — l'IP est visible dans la GUI (VM 9001 > Summary)"
