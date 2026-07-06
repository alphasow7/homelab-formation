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
