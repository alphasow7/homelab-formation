#!/bin/bash
# Chapitre 2 — commandes de la démo (à exécuter SUR le nœud Proxmox, en root)
set -euo pipefail

# 1. Dépôts communautaires (pas d'abonnement entreprise)
cat > /etc/apt/sources.list.d/pve-no-subscription.list <<'EOF'
deb http://download.proxmox.com/debian/pve trixie pve-no-subscription
EOF
rm -f /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/ceph.list

# 2. Mise à jour
apt update && apt -y full-upgrade

# 3. Vérifications montrées à l'écran
pveversion                    # version PVE
ss -tlnp | grep 8006          # la GUI écoute ici
df -h /                       # espace disque
free -h                       # RAM
