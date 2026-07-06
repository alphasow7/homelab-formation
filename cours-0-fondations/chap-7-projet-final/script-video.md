# Chapitre 7 — Projet final : script vidéo

> Durée cible : ~20 min de vidéo (le gros du chapitre, c'est le projet de l'élève, 45 min).
> Format différent : pas de nouvelle notion — on cadre le projet, on montre le résultat
> attendu, on donne la méthode de travail. Dérogation au gabarit assumée.

## 1. Le brief (5 min)

**À dire** : « Examen de sortie. Tu vas déployer le squelette de TON lab : 4 VMs, dont un
**bastion** — la seule machine à cheval entre ton réseau et le segment isolé. C'est comme
ça qu'on fait en vrai : on n'expose jamais un segment interne, on y entre par une machine
de rebond. Tout ce dont tu as besoin, tu l'as déjà : le template (chap. 5), le segment
(chap. 4), cloud-init (chap. 3), les snapshots (chap. 6). »

**À montrer** : le tableau du cahier des charges (projet.md) + un schéma : poste → bastion
(vmbr0+vmbr1) → les 3 VMs du segment.

## 2. La méthode (5 min)

**À dire** : « Conseils de pro : (1) déploie les VMs UNE par une, vérifie à chaque fois —
pas les 4 d'un coup ; (2) le bastion en dernier, c'est le seul cas nouveau (2 cartes
réseau : la 2ᵉ SANS passerelle, sinon la VM ne sait plus par où sortir) ; (3) termine par
les snapshots `fin-cours-0` : c'est ton point de départ officiel des cours suivants. »

## 3. Le résultat attendu (5 min)

**À montrer** : sur le lab du formateur, le résultat final — `qm list` avec les 4 VMs,
le ping des 4 IP, et LE test signature : ssh vers le bastion, puis DU bastion vers
elastic-1. « Ton poste ne voit pas 10.10.99.11. Ton bastion, si. C'est exactement le but. »

## 4. Célébration et suite (5 min)

**À dire** : « Prends 10 secondes : au chapitre 0, tu ne savais peut-être pas ce qu'était
un hyperviseur. Là, tu as un serveur de virtualisation, un template industriel, un réseau
segmenté avec bastion, des sauvegardes PROUVÉES, et 4 VMs prêtes pour la suite. C'est un
vrai socle d'infrastructure, le même pattern que l'infra pro que tu as vue dans les
encarts. Au cours 1, on ajoute le super-pouvoir : Ansible — détruire et reconstruire tout
ça en UNE commande. La première chose qu'on fera ? Détruire dns-proxy. À très vite. »

**À filmer (encart final)** : l'infra réelle en guise de « voilà où ce chemin mène » —
la GUI avec les 10 VMs + un dashboard Kibana.
