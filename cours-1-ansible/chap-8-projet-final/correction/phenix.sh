#!/bin/bash
# Le phénix — détruire et faire renaître dns-proxy, chronométré (nœud Proxmox, root)
#
# Prérequis assumé : la clé SSH de ton poste est aussi autorisée pour root@noeud,
# et le nœud peut joindre 10.10.99.12 (il a une patte sur vmbr1). Si le nœud ne
# peut PAS ssh vers la VM, lance la boucle d'attente depuis TON POSTE à la place :
#   until ssh -o ProxyJump=alpha@IP_DE_TON_BASTION -o ConnectTimeout=3 \
#     alpha@10.10.99.12 true 2>/dev/null; do sleep 5; done
set -euo pipefail
SECONDS=0

qm stop 9203 --timeout 60 || true
qm destroy 9203
echo "détruite à t=${SECONDS}s"

qm clone 9000 9203 --name dns-proxy
qm set 9203 --memory 1024 --ipconfig0 ip=10.10.99.12/24,gw=10.10.99.254
qm start 9203
echo "clonée et démarrée à t=${SECONDS}s"

# attendre SSH (via l'IP du segment, depuis le nœud)
until ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=3 alpha@10.10.99.12 true 2>/dev/null; do
  sleep 5
done
echo "SSH up à t=${SECONDS}s"

echo "== À LANCER DEPUIS TON POSTE (contrôleur) =="
echo "cd cours-1-ansible/ansible && ansible-playbook playbooks/site.yml --limit dns-proxy"
echo "(le chrono continue dans ta tête — objectif total < 300 s)"
