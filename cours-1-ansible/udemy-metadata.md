# Métadonnées Udemy — Cours 1

## Titre (≤ 60 caractères)

**Ansible : automatise ton homelab comme un pro**
(47 caractères)

## Sous-titre

De la config à la main à l'infrastructure as code : inventaire, playbooks, rôles, secrets
chiffrés — jusqu'à détruire et reconstruire un serveur en une commande.

## Description (AIDA)

**[Attention]** Tu sais monter des serveurs (peut-être avec mon cours Fondations). Mais
sois honnête : si l'un d'eux mourait ce soir, saurais-tu le refaire à l'identique — chaque
paquet, chaque fichier de conf, chaque option ?

**[Intérêt]** Ce cours transforme ta façon de gérer des machines : la configuration
devient du CODE — versionné dans Git, relisible, rejouable à volonté. Tu apprends Ansible
sur un vrai fil rouge : le lab du cours Fondations (3 VMs sur un segment isolé + un
bastion), piloté depuis ton poste exactement comme les pros pilotent leurs parcs — y
compris le ProxyJump par machine de rebond.

**[Désir]** À la fin du cours :
- ton parc entier se configure en **une commande** (`site.yml`) et se vérifie en un `--check` ;
- tes rôles (serveur web, DNS, socle commun) sont **réutilisables** et paramétrés proprement
  (defaults → group_vars → host_vars) ;
- tes **secrets sont chiffrés dans Git** (ansible-vault) — et tu sais PROUVER qu'aucun
  mot de passe ne traîne en clair dans l'historique ;
- et surtout : tu passes le **test du phénix** — détruire ton serveur DNS et le faire
  renaître, configuré, en **moins de 5 minutes chrono**.

Toujours la rubrique **💥 « la panne du vrai monde »** : la zone DNS fantôme créée à la
main qui a tué mon serveur au redéploiement, la variable `0.0.0.0` qui rendait BIND muet,
le service qui démarrait avant le réseau (invisible jusqu'au premier reboot), les clés de
coffre-fort jamais sauvegardées… Des incidents réels de mon infra, rejoués et diagnostiqués
avec toi.

**[Action]** Rejoins le cours — repo Git fourni, corrections taguées chapitre par
chapitre, critères de réussite mesurables à chaque TP.

## Objectifs d'apprentissage (6)

1. Piloter un parc de machines depuis ton poste avec Ansible (inventaire, groupes, ad-hoc, ProxyJump)
2. Écrire des playbooks idempotents qui se lisent comme de la documentation
3. Structurer ton code en rôles réutilisables (tasks, templates Jinja2, handlers, defaults)
4. Paramétrer proprement : precedence des variables, group_vars, host_vars
5. Chiffrer tes secrets dans Git avec ansible-vault (et prouver l'hygiène de ton historique)
6. Diagnostiquer les pannes de déploiement : lire les journaux, tester après reboot, réparer le drift

## Prérequis

- Le cours « Homelab : monte ton premier serveur avec Proxmox VE » (ou un lab équivalent :
  3 VMs Debian + une machine de rebond — le rattrapage express est fourni)
- Un terminal (macOS, Linux, ou WSL sous Windows)
- Aucun niveau Ansible requis : on part de zéro

## Public cible

- Ceux qui ont fini le cours Fondations et veulent passer au niveau « industriel »
- Admins qui configurent encore à la main et veulent arrêter
- Futurs devops : Ansible est dans toutes les fiches de poste

## Prix

Prix catalogue : 59,99 € — lancement à 14,99 € (bundle avec le cours 0 à prévoir).

## Curriculum (sections = chapitres)

1. Pourquoi l'Infrastructure as Code (+ 💥 la zone DNS fantôme) — 20 min
2. L'inventaire : ton parc dans un fichier (+ ProxyJump bastion) — 35 min
3. Ton premier playbook (+ l'idempotence prouvée, le vandalisme réparé) — 40 min
4. Les rôles : le rangement des pros (+ 💥 le doublon qui tue BIND) — 45 min
5. Variables : d'usine, de groupe, d'exception (+ 💥 le 0.0.0.0 piégé) — 35 min
6. Secrets : chiffre tout dans Git (+ 💥 les clés jamais sauvegardées) — 35 min
7. site.yml : tout le parc en une commande (+ 💥 le service qui rate le réseau) — 40 min
8. Projet final : le phénix — détruire et reconstruire en < 5 min — 20 min + 45 min de projet
