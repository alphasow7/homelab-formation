#!/bin/bash
# Correction TP chapitre 2 — utilisateur GUI lecture seule
set -euo pipefail
# Change ce mot de passe — c'est un exemple public, ne le garde pas
pveum user add eleve@pve --password 'Formation2026!'
pveum acl modify / --users eleve@pve --roles PVEAuditor
echo "OK : connecte-toi avec eleve@pve / Formation2026! (realm PVE)"

# Étape D — le trousseau SSH du lab. PRÉREQUIS : ta clé de poste est déjà déposée
# (depuis ton poste : ssh-copy-id [-p 2222] root@<nœud>), sinon le trousseau
# ne contiendra que la clé du nœud et tes VMs te refuseront l'entrée.
[ -s /root/.ssh/authorized_keys ] || { echo "ERREUR : aucune clé déposée sur le nœud (ssh-copy-id depuis ton poste d'abord)"; exit 1; }
[ -f /root/.ssh/id_ed25519 ] || ssh-keygen -t ed25519 -N '' -f /root/.ssh/id_ed25519
cat /root/.ssh/authorized_keys /root/.ssh/id_ed25519.pub > /root/.ssh/lab-keys.pub
echo "Trousseau du lab : $(grep -c ssh- /root/.ssh/lab-keys.pub) clé(s) dans /root/.ssh/lab-keys.pub"
