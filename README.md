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
relus (fil rouge inter-cours vérifié : adressage, rôles Ansible, pannes, prérequis, quiz) ;
prochaine étape, le bêta-test (voir [`cours-0-fondations/beta-test.md`](cours-0-fondations/beta-test.md)).

## Prérequis

- Un PC avec **16 Go de RAM** (ou un vieux PC dédié — les deux chemins sont couverts)
- Avoir déjà utilisé un terminal ; savoir ce qu'est une adresse IP
- Aucun achat requis

## Organisation

Chaque chapitre contient : `demo.sh` (les commandes vues en vidéo), `tp.md` (l'exercice),
`correction/` et `quiz.md`. Les corrections d'étape sont taguées : `git tag -l 'c0-*'`.
