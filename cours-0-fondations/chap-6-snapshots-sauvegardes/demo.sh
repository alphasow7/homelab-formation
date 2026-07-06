#!/bin/bash
# Chapitre 6 — snapshots et sauvegardes (à exécuter SUR le nœud Proxmox, en root)
set -euo pipefail

# 1. Snapshot AVANT la bêtise (le filet de sécurité)
qm snapshot 9101 avant-betise --description "filet de sécurité avant démonstration"

# 2. La bêtise (dans le clone-1) : on casse volontairement des fichiers système
ssh -o StrictHostKeyChecking=accept-new alpha@10.10.99.21 \
  'sudo rm -rf /etc/ssh /etc/network && echo "CASSE : ssh et réseau supprimés"'

# 3. Le rollback : retour à l'état du snapshot
qm stop 9101
qm rollback 9101 avant-betise
qm start 9101
sleep 45
ssh alpha@10.10.99.21 'ls /etc/ssh >/dev/null && echo "REPARE — comme si rien ne s était passé"'

# 4. Une VRAIE sauvegarde (vzdump) : sort du disque de la VM
vzdump 9101 --storage local --mode snapshot --compress zstd
ls -lh /var/lib/vz/dump/ | tail -2

# 5. LE test qui compte : restaurer vers un NOUVEL id et vérifier
LAST_BACKUP=$(ls -t /var/lib/vz/dump/vzdump-qemu-9101-*.vma.zst | head -1)
qmrestore "$LAST_BACKUP" 9198 --storage local-lvm
qm set 9198 --name restore-test --ipconfig0 ip=10.10.99.98/24,gw=10.10.99.254
qm start 9198
sleep 45
ssh -o StrictHostKeyChecking=accept-new alpha@10.10.99.98 hostname \
  && echo "RESTAURATION VERIFIEE — c est une vraie sauvegarde"

# 6. Ménage
qm stop 9198 && qm destroy 9198
