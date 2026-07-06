# Métadonnées Udemy — Cours 0

## Titre (≤ 60 caractères)

**Homelab : monte ton premier serveur avec Proxmox VE**
(59 caractères — alternative si pris : « Proxmox VE : construis ton homelab de zéro »)

## Sous-titre

De zéro à un mini-datacenter chez toi : virtualisation, réseau segmenté, sauvegardes
prouvées — 100 % réalisable sans rien acheter.

## Description (structure AIDA)

**[Attention]** Tu as déjà voulu apprendre la virtualisation, le réseau ou le métier de
sysadmin/devops… mais les tutos partent dans tous les sens et tu n'as pas de serveur sous
la main ?

**[Intérêt]** Ce cours te fait construire un vrai homelab, pas à pas, à partir d'un
simple PC 16 Go de RAM (tout en virtuel avec VirtualBox) ou d'un vieux PC ressorti du
placard. Pas un empilement de démos : un fil rouge unique — le même lab grandit chapitre
après chapitre, jusqu'à un projet final digne d'une infra pro (réseau isolé + bastion).

**[Désir]** À la fin du cours, tu auras :
- un serveur **Proxmox VE** installé et correctement configuré (dépôts, mises à jour, utilisateurs) ;
- des VMs **cloud-init** créées en 2 minutes, et un **template doré** pour en cloner à volonté ;
- un **réseau segmenté** comme en entreprise (bridges isolés, routage, machine de rebond) ;
- des **sauvegardes dont tu as PROUVÉ la restauration** (le TP le plus important du cours) ;
- le squelette de lab sur lequel s'appuient mes cours suivants (Ansible, ELK, Sécurité).

Le petit plus qui n'existe nulle part ailleurs : la rubrique **💥 « la panne du vrai
monde »** — dans chaque chapitre, je rejoue avec toi un incident réellement rencontré sur
ma propre infra (clé SSH cloud-init périmée, « pas d'Internet » qui n'est pas une panne,
GUI injoignable…) et on le diagnostique ensemble, méthodiquement. Tu n'apprends pas juste
à construire : tu apprends à dépanner.

**[Action]** Rejoins le cours — tout le matériel (scripts, TPs, corrections, quiz) est
fourni dans un repo Git public, et chaque étape est vérifiable par des critères mesurables.

## Objectifs d'apprentissage (6)

1. Installer et post-configurer Proxmox VE (sur PC dédié ou dans VirtualBox)
2. Créer des VMs en un éclair avec les images cloud et cloud-init
3. Fabriquer un template « doré » et cloner des VMs à la chaîne
4. Segmenter un réseau virtuel (bridges isolés, routage, bastion) comme en entreprise
5. Protéger son lab : snapshots, sauvegardes vzdump et restaurations PROUVÉES
6. Diagnostiquer méthodiquement les pannes classiques d'un lab de virtualisation

## Prérequis (affichés)

- Un PC avec 16 Go de RAM (ou un vieux PC dédié, même 8 Go)
- Avoir déjà utilisé un terminal (taper des commandes ne te fait pas peur)
- Savoir ce qu'est une adresse IP — le chapitre 0 remet tout le monde à niveau
- Aucun achat requis

## Public cible

- Étudiants en informatique qui veulent du concret à mettre sur leur CV
- Admins/techniciens juniors qui veulent monter en virtualisation et réseau
- Autodidactes curieux qui veulent enfin un fil conducteur au lieu de tutos éparpillés
- Futurs devops : ce cours est le socle de ma série (Ansible, ELK, Sécurité)

## Prix

Prix catalogue : 49,99 € — lancement à 12,99 € (code promo dans la vidéo YouTube d'appel,
durée limitée pour amorcer les avis).

## Curriculum (sections Udemy = chapitres)

0. Mise à niveau express (terminal, SSH, réseau) — 30 min
1. C'est quoi un homelab ? (+ visite de mon infra réelle) — 15 min
2. Installer Proxmox (+ 💥 la GUI ne répond pas) — 40 min
3. Ta première VM cloud-init (+ 💥 la clé SSH périmée) — 40 min
4. Le réseau : bridges et segmentation (+ 💥 « pas d'Internet » voulu) — 40 min
5. Templates : clone ta première flotte — 30 min
6. Snapshots & sauvegardes (+ 💥 la restauration jamais testée) — 35 min
7. Projet final : le squelette de ton lab, avec bastion — 20 min + 45 min de projet
