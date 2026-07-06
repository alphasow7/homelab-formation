#!/bin/bash
# Correction TP chapitre 6 — backup/destroy/restore du template doré (nœud, root)
set -euo pipefail

# 1. Sauvegarde (mode stop : un template ne tourne pas)
vzdump 9000 --storage local --mode stop --compress zstd
LAST_BACKUP=$(ls -t /var/lib/vz/dump/vzdump-qemu-9000-*.vma.zst | head -1)
ls -lh "$LAST_BACKUP"

# 2. Destruction (le grand saut)
qm destroy 9000
qm config 9000 2>/dev/null && echo "ERREUR: existe encore" || echo "détruit — comme prévu"

# 3. Renaissance
qmrestore "$LAST_BACKUP" 9000 --storage local-lvm
qm config 9000 | grep -E 'template|ciuser|ipconfig0'

# 4. Preuve par le clone
qm clone 9000 9199 --name test-restore
qm set 9199 --ipconfig0 ip=10.10.99.50/24,gw=10.10.99.254
qm start 9199
sleep 45
ssh -o StrictHostKeyChecking=accept-new alpha@10.10.99.50 hostname
qm stop 9199 && qm destroy 9199
echo "SAUVEGARDE PROUVEE"
