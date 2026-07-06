# TP chapitre 5 — Ton template doré

**Temps cible : 20 min.** Sur le nœud Proxmox (shell root).

## Objectif

Fabriquer le **template 9000 « debian-gold »** : le moule officiel de ton lab, qui servira
aux cours 1, 2 et 3. Il doit partir d'une image cloud **fraîche** (pas de la VM 9001, qui
a déjà vécu).

## Énoncé

1. Crée une VM **9000** depuis l'image cloud Debian 12 (méthode du chapitre 3), nommée
   `debian-gold`, 1 Go RAM, 1 vCPU, `vmbr1`, cloud-init : utilisateur `alpha`, ta clé,
   `ip=dhcp` (chaque clone recevra SA config — le moule reste neutre).
2. Démarre-la UNE fois avec une IP temporaire statique (ex. `10.10.99.99/24`), connecte-toi
   et mets-la à jour : `sudo apt update && sudo apt -y upgrade`, puis éteins-la proprement
   (`sudo poweroff`).
3. Remets `ip=dhcp` (neutre), puis fige : `qm template 9000`.
4. Vérifie en clonant un jetable : clone 9199 avec une IP du segment, il doit répondre en
   SSH ; puis détruis-le (`qm stop 9199 && qm destroy 9199`).

## Critères de réussite

- [ ] `qm config 9000` montre `template: 1`, `ciuser: alpha`, `ipconfig0: ip=dhcp`
- [ ] Le clone de test répondait en SSH avant destruction
- [ ] Tu sais expliquer pourquoi le moule reste en `ip=dhcp`

## Indices

<details>
<summary>Indice 1 — l'ordre des opérations</summary>

créer (chap. 3, blocs 2-3 avec id 9000) → démarrer avec IP temporaire → apt upgrade →
poweroff → `qm set 9000 --ipconfig0 ip=dhcp` → `qm template 9000`. Le template se fige en
DERNIER.
</details>

<details>
<summary>Indice 2 — le clone de test ne répond pas ?</summary>

As-tu bien donné une IP statique AU CLONE (`qm set 9199 --ipconfig0 ip=10.10.99.50/24,gw=10.10.99.254`) ?
Le moule est en dhcp, et il n'y a pas de serveur DHCP sur vmbr1 — c'est le clone qui doit
recevoir sa config.
</details>

Correction : [`correction/tp.sh`](correction/tp.sh).
