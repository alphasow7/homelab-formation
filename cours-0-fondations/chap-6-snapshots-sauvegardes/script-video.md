# Chapitre 6 — Snapshots & sauvegardes : script vidéo

> 🔄 Encart « vrai matériel » réaligné le 11/10/2026 sur le parc post-pivot VDP, complété le 17/10/2026 — référence : [`docs/infra-reelle-2026-10.md`](../../docs/infra-reelle-2026-10.md).

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

**À filmer** : la GUI PBS (Proxmox Backup Server) de l'infra réelle
(`https://192.168.1.220:8007`) : le datastore `vm-backups`, les sauvegardes de la nuit
(toutes les VMs du cluster, 2 h du matin), la déduplication (montrer le ratio), le
verify-job du lundi. Puis Datacenter > Backup dans Proxmox : le job **natif du cluster**,
« toutes les VMs », et son mail en cas d'échec.

**À dire** : « Version industrielle : PBS, un serveur dédié aux sauvegardes.
Déduplication — les blocs identiques ne sont stockés qu'une fois : des VMs quasi
identiques, ça compresse très fort. Rétention automatique, vérification d'intégrité
planifiée, et un mail SEULEMENT en cas d'échec — un mail par nuit réussie finit ignoré,
et l'échec avec lui. Hors périmètre du cours 0, mais tu sais maintenant POURQUOI ça
existe. »

**Deux histoires vraies à raconter ici** (elles paient la morale du chapitre) :
- Pendant **un mois**, ma sauvegarde nocturne a échoué toutes les nuits : le script
  listait des numéros de VMs qui n'existaient plus depuis une refonte du parc
  (« unable to find VM »). Personne ne lisait l'erreur. Une liste de VMs écrite en dur,
  c'est exactement ce qui périme — d'où le job « toutes les VMs du cluster ».
- Pendant **deux mois**, la sauvegarde d'un composant critique (le coffre qui descelle
  Vault) visait une adresse qui, entre-temps, était devenue… un hyperviseur. Échec chaque
  nuit, en silence. Morale, encore : une sauvegarde qui n'alerte pas quand elle échoue
  vaut zéro — et une restauration testée reste le seul vrai test.
- Et l'honnêteté : mon PBS est sur un disque **de la même machine** que ce qu'il
  sauvegarde. Le feu, le vol, la panne d'alim : non couverts. Sache-le quand tu
  dimensionneras le tien.
- Et la plus sournoise, d'octobre : **la sauvegarde qui fait tomber ce qu'elle protège.**
  Trois nuits de suite, mon coffre-fort Vault a calé vers minuit — écritures refusées, six
  minutes de silence, alerte « service down ». Vault n'y était pour rien : sur ce nœud, un
  seul disque mécanique porte deux VMs, et pendant la sauvegarde de la voisine, l'outil
  lisait 16 morceaux en parallèle, éparpillés sur le plateau. Le disque saturait, Vault
  attendait. Correctif posé : deux lectures à la fois, une sauvegarde plus longue mais
  supportable (le vrai remède est un SSD). Retiens : une sauvegarde est une **charge**
  comme une autre — regarde ce qu'elle coûte aux voisins, pas seulement si elle réussit.

## 5. Annonce du TP (2 min)

**À dire** : « À toi : tu vas sauvegarder ton bien le plus précieux — le template doré du
chapitre 5 — le DÉTRUIRE (oui oui), et le faire renaître de la sauvegarde. Le grand saut
avec filet. 25 minutes. Ensuite, chapitre final : on assemble tout. »
