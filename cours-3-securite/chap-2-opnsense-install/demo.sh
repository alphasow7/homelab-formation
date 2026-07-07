#!/bin/bash
# Chapitre 2 — OPNsense : installation sur disque
# Les commandes qm se lancent SUR LE NŒUD PROXMOX (root).
# L'installation elle-même se fait DANS LA CONSOLE noVNC (voir le bloc en bas).
set -euo pipefail

########## SUR LE NŒUD PROXMOX (root) — créer la VM OPNsense ##########
# Adapte : VMID (600), les bridges, le chemin de l'ISO DVD téléchargée.
VMID=600
ISO="local:iso/OPNsense-DVD.iso"     # la version DVD, PAS l'image -serial !
BR_WAN="vmbr0"                        # bridge avec Internet  -> WAN (net0)
BR_LAN="vmbr5"                        # bridge ISOLÉ 192.168.99.0/24 -> LAN (net1)

# Créer la VM : 2 vCPU, 1 Go RAM (4 Go sur l'infra réelle), console VGA (noVNC)
# car l'installeur ncurses ne se pilote PAS proprement en série.
qm create $VMID \
  --name opnsense \
  --memory 1024 --cores 2 \
  --vga std \
  --scsihw virtio-scsi-single

# Disque système 8 Go (la cible de l'install UFS)
qm set $VMID --scsi0 local-lvm:8

# DEUX cartes réseau — l'ordre compte : net0 = WAN, net1 = LAN
qm set $VMID --net0 virtio,bridge=$BR_WAN   # WAN : côté monde (Internet)
qm set $VMID --net1 virtio,bridge=$BR_LAN   # LAN : bridge ISOLÉ (piège du subnet évité)

# Monter l'ISO DVD en CD/DVD
qm set $VMID --ide2 $ISO,media=cdrom

# Booter d'abord sur le CD (le temps d'installer), puis on basculera sur le disque
qm set $VMID --boot order='ide2;scsi0'

# Démarrer et ouvrir la console noVNC (Proxmox > VM 600 > Console)
qm start $VMID

########## DANS LA CONSOLE noVNC — l'installation (à filmer) ##########
# 1. Login installeur :            installer / opnsense
# 2. Keymap : Continue with default keymap
# 3. Menu : *** Install (UFS) ***   -> ON INSTALLE SUR DISQUE, pas en live
# 4. Choisir le disque cible (da0) -> OK -> confirmer l'effacement du disque
# 5. Mot de passe root (laisser 'opnsense' pour le lab, à changer au 1er login GUI)
# 6. Complete Install -> NE PAS rebooter tout de suite

########## SUR LE NŒUD PROXMOX — retirer l'ISO et booter sur le disque ##########
# Détacher le CD et pointer le boot sur le disque
qm set $VMID --ide2 none
qm set $VMID --boot order='scsi0'
# Rebooter la VM : elle démarre maintenant DEPUIS LE DISQUE
qm reboot $VMID
#   Attendu au boot : "Root file system: /dev/gpt/rootfs" (plus depuis le CD)

########## DIAGNOSTIC DE LA PANNE — live-installer vs install disque ##########
# Sur le shell OPNsense (menu console option 8, login root), la commande qui tranche :
#   mount | grep conf
#   -> /conf sur tmpfs  = ALERTE : live-system, la config sera PERDUE au reboot
#   -> /conf sur /dev/da0 (UFS) = OK : la config PERSISTE sur disque
