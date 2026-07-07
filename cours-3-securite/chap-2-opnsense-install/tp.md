# TP chapitre 2 — Installer OPNsense sur disque (et prouver qu'il a une mémoire)

**Temps cible : 30 min.** VM OPNsense 600 sur Proxmox (2 NICs : net0→WAN Internet,
net1→LAN bridge isolé `192.168.99.0/24`), ISO DVD montée, console noVNC ouverte.

## Énoncé

### (a) Installation sur disque de bout en bout

Dans la **console noVNC** de la VM :

1. Boote sur l'ISO, connecte-toi à l'installeur : `installer` / `opnsense`.
2. Choisis **`Install (UFS)`** — **sur le disque**, pas le mode live.
3. Sélectionne le disque cible (`da0`), confirme l'effacement.
4. Définis le mot de passe root (`opnsense` suffit pour le lab).
5. **Retire l'ISO** puis reboote **sur le disque** (voir Indice 1).

### (b) LE reboot-test de persistance (le cœur du TP)

1. Depuis le **menu console** d'OPNsense, option **`2) Set interface IP address`** →
   interface **LAN** → adresse statique **`192.168.99.1`**, masque **`/24`**.
2. **Vérifie** que le système est bien sur disque, pas en live — shell (option `8`,
   login `root`) puis :

   ```
   mount | grep conf
   ```

   `/conf` doit être sur `/dev/da0…` (UFS), **PAS sur `tmpfs`**.
3. **Reboote** la VM (`qm reboot 600` côté Proxmox, ou le menu console option `6`).
4. Après le redémarrage, **reviens sur la console** et lis l'IP du LAN : elle doit
   **toujours** être `192.168.99.1`. Si elle est revenue à `192.168.1.1` → ta config n'a
   pas survécu (tu étais en live).

### (c) Accéder au GUI en https

Depuis un poste sur le segment isolé (ton Proxmox est en `192.168.99.254` sur `vmbr5`) :

```
https://192.168.99.1
```

Login : voir Indice 2. Change le mot de passe root à la première connexion.

## Critères de réussite (mesurables)

- [ ] Au boot, la VM affiche `Root file system: /dev/gpt/rootfs` (démarrage disque, plus l'ISO)
- [ ] `mount | grep conf` → `/conf` sur **UFS/`da0`**, jamais sur `tmpfs`
- [ ] **LAN persisté** : après reboot, l'IP LAN est **toujours `192.168.99.1`**
- [ ] **GUI joignable après reboot** : `https://192.168.99.1` répond (HTTP 200, page de login)

## Indices

<details>
<summary>Indice 1 — après l'install, il reboote encore sur l'ISO ?</summary>

Deux choses à faire AVANT de rebooter : **détacher le CD** (Proxmox → VM 600 → Hardware →
lecteur CD/DVD → *Do not use any media*, ou `qm set 600 --ide2 none`) **et** remettre le
boot order sur le disque (`qm set 600 --boot order='scsi0'`). Tant que le CD est monté et
prioritaire, la VM rebootera sur l'installeur en boucle.
</details>

<details>
<summary>Indice 2 — le login du GUI</summary>

C'est le compte **`root`**, avec le mot de passe root défini à l'installation
(`opnsense` par défaut pour le lab). Ce n'est PAS `installer` — celui-là ne servait qu'à
lancer l'installeur. Change ce mot de passe dès la première connexion au GUI.
</details>

Correction : [`correction/checklist-install.md`](correction/checklist-install.md).
