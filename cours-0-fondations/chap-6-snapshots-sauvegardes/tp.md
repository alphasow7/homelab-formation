# TP chapitre 6 — Détruire et faire renaître le template doré

**Temps cible : 25 min.** Sur le nœud Proxmox (shell root).

## Objectif

Prouver que ta sauvegarde du **template doré 9000** fonctionne — en le détruisant
réellement, puis en le restaurant. Après ce TP, tu n'auras plus jamais peur de perdre une
VM (et tu sauras pourquoi il ne faut pas avoir CONFIANCE, mais des PREUVES).

## Énoncé

1. **Sauvegarde** le template 9000 avec `vzdump` (compression zstd).
2. Vérifie que le fichier existe dans `/var/lib/vz/dump/` et note sa taille.
3. **Détruis** le template : `qm destroy 9000` (oui, vraiment — tu as la sauvegarde…
   n'est-ce pas ?). Constate : `qm config 9000` → n'existe plus.
4. **Restaure**-le avec `qmrestore`, même id 9000.
5. Vérifie : `qm config 9000` montre `template: 1` et ta config cloud-init intacte, et un
   clone jetable (9199) démarre et répond en SSH comme au chapitre 5.

## Critères de réussite

- [ ] Le fichier `vzdump-qemu-9000-*.vma.zst` existe
- [ ] Après destruction, `qm config 9000` échoue ; après restauration, il remontre `template: 1`
- [ ] Un clone du template restauré répond en SSH (puis est détruit)

## Indices

<details>
<summary>Indice 1 — les commandes clefs</summary>

`vzdump 9000 --storage local --mode stop --compress zstd` (un template ne tourne pas :
mode stop) ; `qm destroy 9000` ; `qmrestore /var/lib/vz/dump/vzdump-qemu-9000-<date>.vma.zst 9000 --storage local-lvm`.
</details>

<details>
<summary>Indice 2 — la restauration ne redonne pas un template ?</summary>

Si `template: 1` a disparu après restauration : `qm template 9000` le refige (le contenu
du disque, lui, est intact). Selon les versions, le flag template est bien conservé dans
la sauvegarde — vérifie avant de refiger.
</details>

Correction : [`correction/tp.sh`](correction/tp.sh).
