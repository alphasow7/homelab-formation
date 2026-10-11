#!/usr/bin/env bash
# Suivi de l'évolution du homelab pour la formation.
#
# Lit la ligne « homelab-sync: <hash> [<hash>…] » de docs/infra-reelle-2026-10.md
# (une tête par branche homelab déjà intégrée) et liste tout commit, de toute
# branche locale ou distante du dépôt homelab, qui ne descend d'aucune de ces
# têtes : commits, puis fichiers touchés, en mettant en avant ceux qui
# alimentent les encarts « vrai matériel » et les extraits Ansible.
#
# Usage : scripts/suivi-homelab.sh [chemin-du-depot-homelab]
#   REF_DOC=<fichier> pour lire le marqueur ailleurs (tests) ;
#   DEPUIS=<date> pour changer la date plancher (défaut : 2026-08-01, le pivot).
#   Lancer `git -C ~/Projects/homelab fetch --all` avant, si les forges ont pu
#   recevoir des commits depuis une autre machine.
set -euo pipefail

FORMATION="$(cd "$(dirname "$0")/.." && pwd)"
HOMELAB="${1:-${HOMELAB_DIR:-$HOME/Projects/homelab}}"
REF_DOC="${REF_DOC:-$FORMATION/docs/infra-reelle-2026-10.md}"

[ -d "$HOMELAB/.git" ] || { echo "dépôt homelab introuvable : $HOMELAB" >&2; exit 1; }
SYNC_LINE="$(grep -oE 'homelab-sync: ([0-9a-f]{7,40} ?)+' "$REF_DOC" | head -1 || true)"
[ -n "$SYNC_LINE" ] || { echo "aucune ligne « homelab-sync: <hash>… » dans $REF_DOC" >&2; exit 1; }
read -r -a SYNC <<< "${SYNC_LINE#homelab-sync: }"

EXCL=()
for h in "${SYNC[@]}"; do
  git -C "$HOMELAB" cat-file -e "$h^{commit}" 2>/dev/null \
    || { echo "le hash $h n'existe pas dans $HOMELAB" >&2; exit 1; }
  EXCL+=("^$h")
done

echo "homelab : $HOMELAB (branche courante : $(git -C "$HOMELAB" rev-parse --abbrev-ref HEAD))"
echo "têtes intégrées : ${SYNC[*]}"
if [ -n "$(git -C "$HOMELAB" status --porcelain)" ]; then
  echo "note : l'arbre de travail homelab contient des modifications non commitées"
fi

# Toutes les branches locales et distantes, moins ce qui descend des têtes intégrées.
# Les branches abandonnées d'avant le pivot (juin 2026 : K3S, WireGuard, Nextcloud…)
# ne concernent plus la formation : on ne regarde que depuis le pivot.
DEPUIS="${DEPUIS:-2026-08-01}"
RANGE=(--branches --remotes --since="$DEPUIS" "${EXCL[@]}")
N="$(git -C "$HOMELAB" rev-list --count "${RANGE[@]}")"
if [ "$N" -eq 0 ]; then
  echo "rien de nouveau sur aucune branche depuis $DEPUIS : la formation est alignée."
  exit 0
fi

echo
echo "== $N commit(s) non intégré(s), toutes branches confondues =="
git -C "$HOMELAB" log --reverse --format='%h %ad %d %s' --date=short "${RANGE[@]}"

FILES="$(git -C "$HOMELAB" log --format= --name-only "${RANGE[@]}" | grep -v '^$' | sort -u)"
# Sources de vérité listées en tête de docs/infra-reelle-2026-10.md + rôles et
# playbooks dont cours 1/2/3 gardent une copie dans ansible-extraits/.
PAT='^(README\.md|Contexte\.md|docs/|ansible/(inventory|playbooks|roles|group_vars|host_vars)|vdp/)'

echo
echo "== fichiers touchés qui alimentent la formation =="
echo "$FILES" | grep -E "$PAT" || echo "(aucun)"
echo
echo "== autres fichiers touchés =="
echo "$FILES" | grep -vE "$PAT" || echo "(aucun)"

cat <<TXT

Marche à suivre (voir docs/infra-reelle-2026-10.md §7-§8 et la mémoire de session) :
  1. mettre à jour docs/infra-reelle-2026-10.md (§1 parc, §2 tableau, §4 banque d'incidents) ;
  2. réécrire les encarts « vrai matériel » concernés (script-video.md, encart daté) ;
  3. ne toucher au lab élève / ansible-extraits que si une leçon homelab change une
     pratique enseignée (ex. épinglage Elastic, grok syslog) — et alors déplacer les tags ;
  4. remplacer « ${SYNC_LINE} » par les têtes traitées, puis noter la passe au §8.
TXT
