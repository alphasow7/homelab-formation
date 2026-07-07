# Métadonnées Udemy — Cours 3

## Titre (≤ 60 caractères)

**Sécurité homelab : pare-feu, IDS et coffre-fort**
(48 caractères)

## Sous-titre

OPNsense, Suricata et HashiCorp Vault : protège ton lab en profondeur — jusqu'à détecter
une attaque et la bloquer, la trace remontant dans ton SIEM.

## Description (AIDA)

**[Attention]** Ton lab est en ligne, donc il est scanné — en ce moment même, par des bots
qui balaient l'Internet entier. La vraie question n'est pas de savoir si on t'attaque, mais
si tu le **vois** et si tu peux **réagir**.

**[Intérêt]** Ce cours — le dernier de la série — transforme le lab que tu as construit,
automatisé et observé en une forteresse à plusieurs couches. Tu déploies un vrai pare-feu
de périmètre (OPNsense), un système de détection d'intrusion (Suricata), et un coffre-fort
à secrets (HashiCorp Vault) — et chaque défense produit des alertes qui remontent dans le
SIEM ELK du cours précédent. Tu ne défends pas à l'aveugle : tu vois tes défenses.

**[Désir]** À la fin du cours :
- un **pare-feu OPNsense** installé sur disque (persistant !), WAN/LAN, règles au moindre
  privilège ;
- un **firewall par zone** dans le lab (si une VM tombe, la casse est contenue) ;
- **Suricata** qui détecte les scans et intrusions, alertes branchées sur ton SIEM ;
- **HashiCorp Vault** : init, unseal, secrets dynamiques, PKI — et tu sais pourquoi il se
  rescelle à chaque reboot ;
- l'hygiène qui fait la différence : mots de passe par défaut, rotation, ta CA au trousseau ;
- et l'épreuve finale, synthèse des 4 cours : une **attaque réelle** (scan nmap) que tu
  bloques, détectes, observes dans Kibana, puis neutralises par une règle — la boucle
  complète attaque → défense → détection → réaction.

Toujours la rubrique **💥 « la panne du vrai monde »**, et ce cours en est plein : le
pare-feu dont la config disparaissait à chaque reboot (image live en RAM), le LAN mis par
erreur sur l'adresse de la box qui casse tout le réseau, les règles Suricata « téléchargées »
mais jamais chargées, le coffre-fort dont les clés d'ouverture n'avaient jamais été
sauvegardées. Des incidents réels de mon infra — tu apprends à dépanner, pas juste à cliquer.

**[Action]** Rejoins le cours : repo Git fourni (rôles Ansible dérivés d'une vraie infra),
corrections taguées, critères de réussite mesurables. Et boucle la série.

## Objectifs d'apprentissage (6)

1. Déployer un pare-feu de périmètre OPNsense (WAN/LAN, install persistante, règles)
2. Segmenter et durcir en profondeur (firewall par zone, moindre privilège)
3. Détecter les intrusions avec Suricata (signatures, mode détection, alertes vers le SIEM)
4. Gérer des secrets avec HashiCorp Vault (init/unseal, KV, PKI)
5. Appliquer l'hygiène de sécurité : rotation, mots de passe par défaut, PKI de confiance
6. Mener la boucle complète attaque → défense → détection → réaction sur un incident réel

## Prérequis

- Les cours Proxmox, Ansible et ELK de la série (le projet final relie les quatre)
- De quoi lancer un scan réseau depuis ton poste (nmap)
- Aucun niveau sécurité requis : on part des menaces de base

## Public cible

- Ceux qui ont bouclé les 3 premiers cours et veulent la dernière couche : la sécurité
- Aspirants analystes SOC / ingénieurs sécurité qui veulent un lab défensif complet
- Admins et devops qui veulent arrêter de laisser des `admin/admin` derrière eux

## Prix

Prix catalogue : 64,99 € — lancement à 16,99 € (bundle des 4 cours fortement conseillé).

## Curriculum (sections = chapitres)

1. Menaces & périmètre : le modèle de menace d'un homelab, la défense en profondeur — 20 min
2. OPNsense : installation (+ 💥 la config qui ne survit pas au reboot) — 40 min
3. LAN/WAN & règles (+ 💥 le LAN = l'adresse de la box qui casse tout) — 35 min
4. Firewall par zone (+ 💥 le service joignable de nulle part) — 35 min
5. Suricata IDS (+ 💥 les règles « téléchargées » mais 0 chargée) — 40 min
6. HashiCorp Vault (+ 💥 scellé au reboot & les clés perdues) — 40 min
7. Rotation & hygiène (+ 💥 le mot de passe par défaut oublié 3 semaines) — 30 min
8. Projet final : l'attaque et sa trace — la boucle complète — 25 min + 45 min de projet
