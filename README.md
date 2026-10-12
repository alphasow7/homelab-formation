# Homelab DevSecOps — Formation

Matériel élève de la formation « Homelab DevSecOps » (Udemy + YouTube).

## Cours

| # | Cours | Statut |
|---|---|---|
| 0 | [Fondations : ton premier homelab avec Proxmox](cours-0-fondations/) | 📝 rédigé · revue de cohérence OK |
| 1 | [Ansible : automatise ton infra comme un pro](cours-1-ansible/) | 📝 rédigé · revue de cohérence OK |
| 2 | [ELK : ton propre SIEM/observabilité à la maison](cours-2-elk/) | 📝 rédigé · revue de cohérence OK |
| 3 | [Sécurité : OPNsense, Suricata, Vault](cours-3-securite/) | 📝 rédigé · revue de cohérence OK |

**Pipeline** : 📝 rédigé → 🧪 bêta-test → 🎬 tournage → ✅ publié. Les 4 cours sont écrits et
relus (fil rouge inter-cours vérifié : adressage, rôles Ansible, pannes, prérequis, quiz).

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
