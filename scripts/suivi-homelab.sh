#!/usr/bin/env bash
# Suivi de l'évolution du homelab pour la formation.
#
# Lit le hash « homelab-sync: <hash> » dans docs/infra-reelle-2026-10.md et liste
# tout ce qui a bougé dans le dépôt homelab depuis : commits, puis fichiers
# touchés, en mettant en avant ceux qui alimentent les encarts « vrai matériel »
# et les extraits Ansible de la formation.
#
# Usage : scripts/suivi-homelab.sh [chemin-du-depot-homelab]
set -euo pipefail

FORMATION="$(cd "$(dirname "$0")/.." && pwd)"
HOMELAB="${1:-${HOMELAB_DIR:-$HOME/Projects/homelab}}"
REF_DOC="${REF_DOC:-$FORMATION/docs/infra-reelle-2026-10.md}"

[ -d "$HOMELAB/.git" ] || { echo "dépôt homelab introuvable : $HOMELAB" >&2; exit 1; }
SYNC="$(grep -oE 'homelab-sync: [0-9a-f]{7,40}' "$REF_DOC" | head -1 | cut -d' ' -f2)"
[ -n "$SYNC" ] || { echo "aucune ligne « homelab-sync: <hash> » dans $REF_DOC" >&2; exit 1; }

git -C "$HOMELAB" cat-file -e "$SYNC^{commit}" 2>/dev/null \
  || { echo "le hash $SYNC n'existe pas dans $HOMELAB" >&2; exit 1; }

HEAD_H="$(git -C "$HOMELAB" rev-parse --short HEAD)"
echo "homelab : $HOMELAB"
echo "dernier commit intégré : $SYNC — HEAD actuel : $HEAD_H"
if [ -n "$(git -C "$HOMELAB" status --porcelain)" ]; then
  echo "note : l'arbre de travail homelab contient des modifications non commitées"
fi

N="$(git -C "$HOMELAB" rev-list --count "$SYNC..HEAD")"
if [ "$N" -eq 0 ]; then
  echo "rien de nouveau depuis $SYNC : la formation est alignée."
  exit 0
fi

echo
echo "== $N commit(s) non intégré(s) =="
git -C "$HOMELAB" log --reverse --format='%h %ad %s' --date=short "$SYNC..HEAD"

echo
echo "== fichiers touchés qui alimentent la formation =="
# Sources de vérité listées en tête de docs/infra-reelle-2026-10.md + rôles Ansible
# et playbooks dont cours 1/2/3 gardent une copie dans ansible-extraits/.
git -C "$HOMELAB" diff --stat "$SYNC..HEAD" -- \
  README.md Contexte.md docs/ ansible/inventory/ ansible/playbooks/ ansible/roles/ \
  ansible/group_vars/ ansible/host_vars/ vdp/ \
  | tail -n +1

echo
echo "== autres fichiers touchés =="
git -C "$HOMELAB" diff --name-only "$SYNC..HEAD" \
  | grep -vE '^(README\.md|Contexte\.md|docs/|ansible/(inventory|playbooks|roles|group_vars|host_vars)|vdp/)' \
  || echo "(aucun)"

cat <<TXT

Marche à suivre (voir docs/infra-reelle-2026-10.md §7 et la mémoire de session) :
  1. mettre à jour docs/infra-reelle-2026-10.md (§1 parc, §2 tableau, §4 banque d'incidents) ;
  2. réécrire les encarts « vrai matériel » concernés (script-video.md, encart daté) ;
  3. ne toucher au lab élève / ansible-extraits que si une leçon homelab change une
     pratique enseignée (ex. épinglage Elastic, grok syslog) — et alors déplacer les tags ;
  4. remplacer « homelab-sync: $SYNC » par le hash du dernier commit traité.
TXT
