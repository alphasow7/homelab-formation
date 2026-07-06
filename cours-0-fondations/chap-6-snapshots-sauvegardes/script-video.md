# Chapitre 6 — Snapshots & sauvegardes : script vidéo

> Durée cible : ~35 min. Prérequis : chapitre 5 (clones 9101-9103 en marche).
> Toutes les commandes montrées sont dans `demo.sh`, rejouées sur le lab avant tournage.

## 1. Le concept (5 min)

**À dire** : « Deux outils qui se ressemblent et qu'il ne faut JAMAIS confondre. Le
**snapshot** : une photo de ta VM à l'instant T, instantanée, parfaite avant une
manipulation risquée — mais elle vit **sur le même disque** que la VM. Si le disque meurt,
la photo meurt avec. La **sauvegarde** (backup) : une copie complète, **ailleurs** —
elle survit à la mort du disque. Snapshot = filet du trapéziste ; sauvegarde = assurance
incendie. Il te faut les deux, pour des raisons différentes. »

**À montrer** : schéma — VM + snapshot sur le même disque (un seul incendie les emporte) ;
backup sur un autre stockage.

## 2. Démo guidée (18 min)

### 2.1 Le filet : snapshot, bêtise, rollback

**À montrer** : blocs 1-3 de `demo.sh`, dans l'ordre dramatique :
1. `qm snapshot 9101 avant-betise` — « la photo est prise » (montrer l'onglet Snapshots
   de la GUI).
2. La bêtise : on **supprime `/etc/ssh` et `/etc/network`** dans le clone — une vraie
   catastrophe, la machine est morte au prochain reboot.
3. `qm rollback` + start. **Attendu** : `REPARE — comme si rien ne s'était passé`.

**À dire** : « Voilà pourquoi on snapshotte AVANT chaque manipulation risquée. Ça coûte
une commande et dix secondes. »

### 2.2 La vraie sauvegarde : vzdump

**À montrer** : bloc 4 — `vzdump ... --mode snapshot --compress zstd`, puis le fichier
dans `/var/lib/vz/dump/`.

**À dire** : « `--mode snapshot` : la VM reste allumée pendant la sauvegarde. Le fichier
`.vma.zst`, c'est TOUTE la VM : disque, config, tout. Ici il reste sur le même serveur —
en vrai, tu l'enverrais ailleurs : un NAS, un autre disque, un serveur de sauvegarde
dédié. » (transition vers l'encart)

## 3. 💥 La panne du vrai monde (5 min)

**Mise en scène** : « Une sauvegarde qui n'a jamais été restaurée n'est PAS une
sauvegarde — c'est un fichier qui te rassure. Sur l'infra réelle de ce cours, la première
chose qu'on a faite après avoir installé le serveur de sauvegarde, c'est **restaurer une
VM pour de vrai** — AVANT d'en avoir besoin. Et c'est ce jour-là qu'on trouve les
mauvaises surprises : le stockage qui manque, la config firewall qui bloque, le mot de
passe oublié… Trouve-les un mardi tranquille, pas le jour du crash. »

**À montrer** : bloc 5 — `qmrestore` vers un **nouvel id** (9198), la VM restaurée
démarre et répond en SSH. **Attendu** : `RESTAURATION VERIFIEE`.

**Morale** : « La restauration testée est la seule vraie sauvegarde. »

## 4. Encart vrai matériel (3 min)

**À filmer** : la GUI PBS (Proxmox Backup Server) de l'infra réelle : le datastore, les
sauvegardes des 10 VMs, la déduplication (montrer le ratio).

**À dire** : « Version industrielle : PBS, un serveur dédié aux sauvegardes.
Déduplication — les blocs identiques ne sont stockés qu'une fois : 10 VMs Debian quasi
identiques, ça compresse très fort. Rétention automatique, vérification d'intégrité
planifiée. Hors périmètre du cours 0, mais tu sais maintenant POURQUOI ça existe. »

## 5. Annonce du TP (2 min)

**À dire** : « À toi : tu vas sauvegarder ton bien le plus précieux — le template doré du
chapitre 5 — le DÉTRUIRE (oui oui), et le faire renaître de la sauvegarde. Le grand saut
avec filet. 25 minutes. Ensuite, chapitre final : on assemble tout. »
