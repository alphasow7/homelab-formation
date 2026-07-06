# TP chapitre 4 — Deux segments, un routeur

**Temps cible : 30 min.** Sur le nœud Proxmox (shell root).

## Objectif

Créer un **2ᵉ segment isolé** et faire dialoguer les deux segments **via le nœud**,
comme un vrai routeur inter-réseaux.

## Énoncé

1. Crée le bridge `vmbr2` : réseau `10.10.98.0/24`, le nœud en `10.10.98.254`
   (même méthode que `vmbr1` au chapitre).
2. Déplace ta VM **9002** sur `vmbr2` avec l'IP `10.10.98.10/24`, gw `10.10.98.254`
   (n'oublie pas le stop/start).
3. **Prouve l'isolement** : depuis 9001 (`10.10.99.10`), `ping 10.10.98.10` → échec.
4. **Active le routage** sur le nœud : `sysctl -w net.ipv4.ip_forward=1`
5. **Re-teste** : le ping 9001 → 9002 passe maintenant. Explique pourquoi en une phrase
   (indice : qui est la passerelle de chaque VM ?).

## Critères de réussite

- [ ] `ip -4 addr show vmbr2` → `10.10.98.254/24`
- [ ] Avant `ip_forward` : ping inter-segments KO ; après : OK
- [ ] Tu sais dire pourquoi (le nœud, passerelle des deux segments, accepte de router)

## Indices

<details>
<summary>Indice 1 — le bloc vmbr2</summary>

C'est le bloc 1 de `demo.sh` en remplaçant `vmbr1` → `vmbr2` et `10.10.99.254` →
`10.10.98.254`, puis `ifreload -a`.
</details>

<details>
<summary>Indice 2 — le ping ne passe toujours pas après ip_forward ?</summary>

Vérifie que les DEUX VMs ont bien leur **gw** en `.254` de LEUR réseau (GUI > Cloud-Init),
et que tu as fait stop/start après le changement. Sans passerelle correcte, la VM ne sait
pas à qui remettre les paquets destinés à l'autre réseau.
</details>

> **Note** : `sysctl -w` ne survit pas au reboot du nœud — c'est voulu ici. La version
> persistante (et filtrée par un pare-feu !) est le sujet du cours 3.

Correction : [`correction/tp.sh`](correction/tp.sh).
