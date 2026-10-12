# Homelab DevSecOps — Formation

Matériel élève de la formation « Homelab DevSecOps » (Udemy + YouTube).

## Cours

| # | Cours | Statut |
|---|---|---|
| 0 | [Fondations : ton premier homelab avec Proxmox](cours-0-fondations/) | 📝 rédigé · audité et corrigé le 12/10 · **à rejouer sur machine** |
| 1 | [Ansible : automatise ton infra comme un pro](cours-1-ansible/) | 📝 rédigé · audité et corrigé le 12/10 · **à rejouer sur machine** |
| 2 | [ELK : ton propre SIEM/observabilité à la maison](cours-2-elk/) | 📝 rédigé · audité et corrigé le 12/10 · **à rejouer sur machine** |
| 3 | [Sécurité : OPNsense, Suricata, Vault](cours-3-securite/) | 📝 rédigé · audité et corrigé le 12/10 · **à rejouer sur machine** |

**Pipeline** : 📝 rédigé → 🔁 rejoué sur machine → 🧪 bêta-test → 🎬 tournage → ✅ publié.
Les 4 cours sont écrits, relus, et audités le 12/10/2026 : quatorze défauts qui empêchaient
un élève d'aller au bout ont été corrigés et les 24 tags d'étape reposés — voir
[`docs/evaluation-2026-10-12.md`](docs/evaluation-2026-10-12.md). Prochaine étape : rejouer
chaque lab sur une vraie machine avant le bêta-test.

**Réalignement du 11/10/2026** — le homelab qui sert de base a pivoté en août 2026
(cluster Proxmox de 4 nœuds, plateforme de déploiement en VMs, ELK derrière OPNsense,
bastion Tailscale en octobre). Les labs élève ne changent pas ; les **encarts « vrai
matériel »** des scripts, le plan de tournage et les teasers ont été réécrits sur le parc
réel, et les pannes vécues depuis juillet sont rangées par chapitre. État de référence :
[`docs/infra-reelle-2026-10.md`](docs/infra-reelle-2026-10.md) — à relire la veille de
chaque tournage. La formation suit le homelab en continu : `scripts/suivi-homelab.sh`
liste ce qui a bougé dans le dépôt `homelab` depuis le dernier commit intégré (marqueur
`homelab-sync:` en tête du document de référence).

**Prochaine étape — le bêta-test du cours 0**, porte d'entrée du tournage :
[protocole](cours-0-fondations/beta-test.md) · [kit de recrutement](cours-0-fondations/beta-recrutement.md) ·
[grille testeur](cours-0-fondations/beta-grille.md) · [résultats](cours-0-fondations/beta-resultats.md).
Le matériel est prêt ; il reste l'**action formateur** : recruter 2-3 testeurs débutants.

## Prérequis

- Un PC avec **16 Go de RAM** (ou un vieux PC dédié — les deux chemins sont couverts)
- Avoir déjà utilisé un terminal ; savoir ce qu'est une adresse IP
- Aucun achat requis

## Organisation

Chaque chapitre contient : `demo.sh` (les commandes vues en vidéo), `tp.md` (l'exercice),
`correction/` et `quiz.md`. Les corrections d'étape sont taguées : `git tag -l 'c0-*'`.
