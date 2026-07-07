# Correction TP chapitre 2 — checklist d'installation OPNsense

> La procédure pas à pas, dans l'ordre. Les commandes `qm` se lancent **sur le nœud
> Proxmox** ; les étapes d'installation, **dans la console noVNC** de la VM 600.

## 0. Vérifier la VM avant de booter (Proxmox)

```bash
qm config 600 | grep -E 'net0|net1|ide2|scsi0|vga|boot'
```

**Attendu** :
- `net0: virtio,bridge=vmbr0`  → WAN (bridge avec Internet)
- `net1: virtio,bridge=vmbr5`  → LAN (bridge ISOLÉ 192.168.99.0/24)
- `ide2: local:iso/OPNsense-DVD.iso,media=cdrom`  → l'ISO **DVD** (pas -serial)
- `scsi0: …8G`  → le disque cible
- `vga: std`  → console noVNC (l'installeur ncurses ne se pilote pas en série)
- `boot: order=ide2;scsi0`  → on boote d'abord sur le CD

## 1. Installation sur disque (console noVNC)

1. `qm start 600`, ouvrir **Console** dans Proxmox.
2. Login installeur : **`installer`** / **`opnsense`**.
3. Keymap : *Continue with default keymap*.
4. Menu : choisir **`Install (UFS)`** → **installation sur disque**.
5. Disque cible : **`da0`** → *OK* → confirmer l'effacement du disque (VM vierge).
6. Attendre la copie du système.
7. Mot de passe root : laisser **`opnsense`** (lab) → *Complete Install*.
8. **NE PAS rebooter tout de suite.**

## 2. Retirer l'ISO et basculer sur le disque (Proxmox)

```bash
qm set 600 --ide2 none                 # détacher le CD
qm set 600 --boot order='scsi0'        # booter sur le disque
qm reboot 600
```

**Attendu au boot** (console) : `Root file system: /dev/gpt/rootfs` — plus de montage CD.

## 3. Configurer le LAN (menu console OPNsense)

- Option **`2) Set interface IP address`** → **LAN** → statique → **`192.168.99.1`** /
  **`24`** → pas de DHCP serveur pour ce TP → *revenir en https ? non*.

## 4. Vérifier que c'est bien sur disque (le test qui compte)

Option **`8) Shell`**, login `root`, puis :

```
mount | grep conf
```

**Attendu** : `/conf` sur `/dev/da0…` en **ufs**.
**Interdit** : `/conf` sur **`tmpfs`** → tu serais sur un live-installer, la config
serait perdue au reboot (la panne du chapitre). Si tu vois `tmpfs`, tu n'as pas fait
`Install (UFS)` — recommence l'étape 1.

## 5. Reboot-test de persistance

```bash
qm reboot 600
```

Après redémarrage, sur la console : l'IP du LAN doit **toujours** être **`192.168.99.1`**.
Si elle est revenue à `192.168.1.1` → la config n'a pas survécu (live-system).

## 6. GUI

Depuis Proxmox (sur vmbr5, `192.168.99.254`) :

```bash
curl -k -o /dev/null -s -w '%{http_code}\n' https://192.168.99.1
```

**Attendu** : `200`. Puis dans le navigateur `https://192.168.99.1`, login **`root`** /
`opnsense`, et **changer le mot de passe** à la première connexion.

## Tous les critères

- [ ] Boot disque : `Root file system: /dev/gpt/rootfs`
- [ ] `mount | grep conf` → UFS/`da0` (jamais `tmpfs`)
- [ ] LAN persisté après reboot : `192.168.99.1`
- [ ] GUI : `https://192.168.99.1` → HTTP 200
