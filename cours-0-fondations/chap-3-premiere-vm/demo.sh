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

# 3. Brancher cloud-init : utilisateur, clés SSH (le TROUSSEAU du chapitre 2 : ta clé
#    de poste + celle du nœud, fichiers PUBLICS !), IP en DHCP
qm set 9001 --ide2 local-lvm:cloudinit --boot order=scsi0 --serial0 socket
qm set 9001 --ciuser alpha --sshkeys /root/.ssh/lab-keys.pub --ipconfig0 ip=dhcp

# 4. Démarrer et trouver son IP
qm start 9001
# L'image cloud n'embarque pas l'agent QEMU : la GUI n'affichera PAS l'IP (Summary →
# « No Guest Agent configured »). Elle se lit sur la console série, où cloud-init
# affiche au boot un tableau « ci-info: Net device info » avec l'adresse reçue :
qm terminal 9001        # attendre le tableau ci-info, puis Ctrl+O pour sortir
# Variante sans console : interroger le DHCP depuis le nœud, par l'adresse MAC de la VM.
MAC="$(qm config 9001 | grep -oiE '([0-9a-f]{2}:){5}[0-9a-f]{2}' | head -1)"
ip neigh show dev vmbr0 | grep -i "$MAC" || echo "pas encore dans la table ARP : lis la console"

