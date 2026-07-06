#!/bin/bash
# Chapitre 5 — du moule aux clones (à exécuter SUR le nœud Proxmox, en root)
set -euo pipefail

# 1. Transformer la VM 9001 en template (= le moule ; elle ne démarrera plus jamais)
qm stop 9001 || true
qm template 9001

# 2. Cloner 3 VMs en une minute — chrono à l'écran !
for i in 1 2 3; do
  qm clone 9001 910$i --name clone-$i
  qm set 910$i --ipconfig0 ip=10.10.99.2$i/24,gw=10.10.99.254
  qm start 910$i
done

# 3. La preuve
qm list | grep clone
sleep 45
for i in 1 2 3; do
  ssh -o StrictHostKeyChecking=accept-new alpha@10.10.99.2$i hostname
done
