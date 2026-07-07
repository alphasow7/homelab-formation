#!/usr/bin/env bash
#
# generateur-incident.sh — Projet final cours 2 (ELK)
#
# Provoque UN incident discret et aléatoire sur le lab, via ansible ad-hoc.
# Se lance sur le POSTE de l'élève ; cible une VM à travers le bastion (ProxyJump
# de l'inventaire du cours 1). L'élève ne doit PAS savoir quel scénario tombe :
# il le découvre dans Kibana. La solution est écrite dans un fichier "à ne pas
# regarder" pour l'auto-correction.
#
set -euo pipefail

# --- Configuration (surchargeable par variables d'environnement) --------------
INVENTORY="${INVENTORY:-../../cours-1-ansible/ansible/inventory/hosts.yml}"
SOLUTION_FILE="${SOLUTION_FILE:-/tmp/solution-NEPASREGARDER.txt}"
# Hôtes du lab (doivent correspondre à l'inventaire du cours 1)
HOST_DNS="${HOST_DNS:-dns-proxy}"
HOST_BASTION="${HOST_BASTION:-bastion-vm}"
HOST_ELASTIC="${HOST_ELASTIC:-elastic-1}"

command -v ansible >/dev/null || { echo "ansible introuvable sur ce poste." >&2; exit 1; }
[ -f "$INVENTORY" ] || { echo "Inventaire introuvable : $INVENTORY" >&2; exit 1; }

# ansible ad-hoc : exécute une commande shell sur un hôte de l'inventaire.
run() { # run <host> <shell-command>
  ansible -i "$INVENTORY" "$1" -m shell -a "$2" >/dev/null
}

SCENARIO=$(( (RANDOM % 4) + 1 ))
STARTED_AT=$(date '+%Y-%m-%d %H:%M:%S %Z')
echo "Incident lancé. Attends ~1 min que les logs remontent, puis ouvre Kibana."
echo "Ne regarde PAS $SOLUTION_FILE avant d'avoir rendu ta réponse."

case "$SCENARIO" in
  1) # SERVICE TUÉ : nginx arrêté sur dns-proxy.
     # -> Dans Kibana : nginx.service cesse d'émettre (creux/absence), un log
     #    "Stopped nginx" juste avant le silence. La couleur dns-proxy maigrit.
     LABEL="Service tué : nginx arrêté sur $HOST_DNS"
     run "$HOST_DNS" "sudo systemctl stop nginx"
     ;;
  2) # BRUTE-FORCE SSH : ~20 connexions ratées vers localhost sur le bastion.
     # -> Dans Kibana : pic de logs sshd, rafale de "Failed password" /
     #    "Invalid user baduser" en quelques secondes sur le bastion.
     LABEL="Brute-force SSH : rafale d'échecs d'auth sur $HOST_BASTION"
     run "$HOST_BASTION" \
       "for i in \$(seq 1 20); do ssh -o ConnectTimeout=2 -o StrictHostKeyChecking=no -o BatchMode=no baduser@localhost true 2>/dev/null || true; done"
     ;;
  3) # DISQUE QUI SE REMPLIT : ballast + logger d'alerte répété sur elastic-1.
     # -> Pas de métriques dans ce cours : l'incident se voit via un logger
     #    explicite ("disk usage high") répété, en warning, sur elastic-1.
     LABEL="Disque qui se remplit : alertes 'disk usage high' sur $HOST_ELASTIC"
     run "$HOST_ELASTIC" "fallocate -l 500M /tmp/ballast 2>/dev/null || dd if=/dev/zero of=/tmp/ballast bs=1M count=500 2>/dev/null"
     run "$HOST_ELASTIC" \
       "for i in \$(seq 1 6); do logger -p daemon.warning -t diskmon 'disk usage high on /tmp (ballast detected)'; sleep 2; done"
     ;;
  4) # NGINX 500 : requêtes vers une URL qui renvoie 500 sur dns-proxy.
     # -> Dans Kibana : le camembert des codes voit apparaître du 5xx là où il
     #    n'y avait que du 200. response >= 500 dans les logs nginx.
     LABEL="Erreurs 500 nginx : pic de codes 5xx sur $HOST_DNS"
     # /nonexistent-boom force nginx à répondre en erreur ; on martèle l'URL.
     run "$HOST_DNS" \
       "for i in \$(seq 1 25); do curl -s -o /dev/null 'http://localhost/nonexistent-boom-500' || true; done"
     ;;
esac

# Solution pour l'auto-correction (l'élève NE DOIT PAS l'ouvrir avant sa réponse).
{
  echo "=== SOLUTION — À NE REGARDER QU'APRÈS AVOIR RENDU TA RÉPONSE ==="
  echo "Scénario n°$SCENARIO"
  echo "Incident : $LABEL"
  echo "Heure de début : $STARTED_AT"
} > "$SOLUTION_FILE"

echo "C'est parti. Chrono : 10 minutes dans Kibana, sans SSH."
