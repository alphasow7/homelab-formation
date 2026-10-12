#!/bin/bash
# Chapitre 2 — commandes de la démo (à exécuter SUR le nœud Proxmox, en root)
set -euo pipefail

# 0. (facultatif, pour la vidéo) montrer l'erreur 401 AVANT la bascule :
#    apt update   # → 401 Unauthorized sur enterprise.proxmox.com : normal, pas d'abonnement

# 1. Désactiver les dépôts enterprise (format deb822 de PVE 9 : fichiers .sources)
sed -i 's/^Enabled: true/Enabled: false/' /etc/apt/sources.list.d/pve-enterprise.sources 2>/dev/null || true
grep -q '^Enabled: false' /etc/apt/sources.list.d/pve-enterprise.sources || \
  echo 'Enabled: false' >> /etc/apt/sources.list.d/pve-enterprise.sources
grep -q '^Enabled: false' /etc/apt/sources.list.d/ceph.sources || \
  echo 'Enabled: false' >> /etc/apt/sources.list.d/ceph.sources

# 2. Ajouter le dépôt communautaire no-subscription (deb822)
cat > /etc/apt/sources.list.d/proxmox.sources <<'EOF'
Types: deb
URIs: http://download.proxmox.com/debian/pve
Suites: trixie
Components: pve-no-subscription
Signed-By: /usr/share/keyrings/proxmox-archive-keyring.gpg
EOF

# 3. Mise à jour
apt update && apt -y full-upgrade

# 4. Vérifications montrées à l'écran
pveversion                    # version PVE
ss -tlnp | grep 8006          # la GUI écoute ici
df -h /                       # espace disque
free -h                       # RAM

# 5. Si un nouveau noyau a été installé par le full-upgrade : reboot (on le fait
#    dans la vidéo — un lab frais, ça se reboote sans état d'âme)
# reboot

# 6. Le TROUSSEAU SSH du lab : le fichier de clés que recevront TOUTES les VMs
#    (chapitres 3, 5, 7). Il contient deux clés : celle de TON POSTE et celle du nœud.
#    a) DEPUIS TON POSTE, d'abord (une seule fois) — dépose ta clé sur le nœud :
#         chemin A :  ssh-copy-id -p 2222 root@localhost
#         chemin B :  ssh-copy-id root@192.168.1.240
#       (Windows : depuis Git Bash ou WSL — c'est cette clé-là qui servira tout le cours.)
#    b) SUR LE NŒUD — une clé pour le nœud lui-même : c'est lui qui se connecte aux VMs
#       dans les démos et les corrections.
[ -f /root/.ssh/id_ed25519 ] || ssh-keygen -t ed25519 -N '' -f /root/.ssh/id_ed25519
#    c) Le trousseau = ta clé (déposée en a) + celle du nœud, dans UN fichier.
cat /root/.ssh/authorized_keys /root/.ssh/id_ed25519.pub > /root/.ssh/lab-keys.pub
cat /root/.ssh/lab-keys.pub      # attendu : 2 lignes "ssh-ed25519 …" (poste, nœud)
