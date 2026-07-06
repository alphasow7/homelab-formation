#!/bin/bash
# Correction TP chapitre 2 — utilisateur GUI lecture seule
set -euo pipefail
# Change ce mot de passe — c'est un exemple public, ne le garde pas
pveum user add eleve@pve --password 'Formation2026!'
pveum acl modify / --users eleve@pve --roles PVEAuditor
echo "OK : connecte-toi avec eleve@pve / Formation2026! (realm PVE)"
