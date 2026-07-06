#!/bin/bash
# Correction TP chapitre 0 — SSH sans mot de passe
# À exécuter depuis TON poste. Remplace UTILISATEUR@IP_DE_TA_MACHINE.
set -euo pipefail

# Étape A — générer la paire de clés (ne rien faire si elle existe déjà)
[ -f ~/.ssh/id_ed25519 ] || ssh-keygen -t ed25519
ls ~/.ssh/id_ed25519 ~/.ssh/id_ed25519.pub   # la privée reste ici, la .pub se distribue

# Étape B — poser la clé publique sur la machine distante (dernier mot de passe)
ssh-copy-id UTILISATEUR@IP_DE_TA_MACHINE

# Étape C — vérification : doit afficher le hostname distant SANS mot de passe
ssh UTILISATEUR@IP_DE_TA_MACHINE hostname
