# TP chapitre 2 — Post-installation + utilisateur en lecture seule

**Temps cible : 20 min.** Tout se fait sur TON lab (chemin A : `https://localhost:8006`,
chemin B : `https://192.168.1.240:8006`). Les commandes s'exécutent sur le nœud, en root
(GUI → nœud → Shell, ou SSH).

## Objectif

À la fin de ce TP :
- ton Proxmox est à jour et utilise les dépôts communautaires ;
- tu as un utilisateur `eleve@pve` qui voit tout mais ne peut rien modifier ;
- tu as constaté par toi-même la différence entre root et un compte en lecture seule.

## Étape A — Post-installation complète

1. Bascule les dépôts sur `pve-no-subscription` et supprime les dépôts enterprise
   (comme dans la démo).
2. Mets tout à jour (`apt update` puis `apt -y full-upgrade`).
3. Vérifie : `apt update` ne doit afficher **aucune erreur 401**, et `pveversion` doit
   répondre.

## Étape B — Créer l'utilisateur `eleve@pve`

1. Crée un utilisateur GUI nommé `eleve` dans le realm **pve** (Proxmox VE authentication
   server), avec un mot de passe de ton choix.
2. Donne-lui le rôle **`PVEAuditor`** sur le chemin **`/`** (tout le datacenter).

> Tu peux le faire en GUI (Datacenter → Permissions) ou en ligne de commande avec `pveum`.
> Les deux comptent.

## Étape C — Tester la lecture seule

1. Déconnecte-toi de la GUI (bouton en haut à droite).
2. Reconnecte-toi avec `eleve` — **attention au menu « Realm »** : choisis
   *Proxmox VE authentication server*, pas *Linux PAM*.
3. Constate :
   - tu vois le nœud, ses graphes, son résumé — tout est visible ;
   - essaie de créer une VM (bouton « Create VM » en haut à droite) : le bouton est grisé
     ou la création est refusée. Normal : auditor = lecture seule.

## ✅ Critères de réussite

- [ ] `apt update` sans erreur 401
- [ ] `pveversion` affiche la version
- [ ] Connexion GUI avec `eleve@pve` (realm PVE) fonctionne
- [ ] Impossible de créer une VM avec `eleve@pve`

---

## Indices (déplie seulement si tu bloques)

<details>
<summary>Indice 1 — je ne sais pas comment créer l'utilisateur</summary>

En GUI : **Datacenter → Permissions → Users → Add**, choisis le realm
« Proxmox VE authentication server ». En ligne de commande, l'outil s'appelle `pveum`
(Proxmox VE User Manager) : regarde `pveum user add --help`. N'oublie pas le suffixe
`@pve` dans le nom d'utilisateur.
</details>

<details>
<summary>Indice 2 — l'utilisateur existe mais ne voit rien (ou tout est vide après login)</summary>

Créer l'utilisateur ne suffit pas : sans **permission**, il ne voit rien. Il faut lui
attribuer le rôle `PVEAuditor` sur le chemin `/` : en GUI **Datacenter → Permissions →
Add → User Permission** (Path `/`, User `eleve@pve`, Role `PVEAuditor`), ou en CLI avec
`pveum acl modify / --users eleve@pve --roles PVEAuditor`. Et si le login échoue
carrément : vérifie que tu as bien choisi le realm PVE, pas Linux PAM.
</details>

La correction complète est dans [`correction/tp.sh`](correction/tp.sh).
