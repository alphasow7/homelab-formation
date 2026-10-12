# TP chapitre 2 — Post-installation + utilisateur en lecture seule

**Temps cible : 20 min.** Tout se fait sur TON lab (chemin A : `https://localhost:8006`,
chemin B : `https://192.168.1.240:8006`). Les commandes s'exécutent sur le nœud, en root
(GUI → nœud → Shell, ou SSH).

## Objectif

À la fin de ce TP :
- ton Proxmox est à jour et utilise les dépôts communautaires ;
- tu as un utilisateur `eleve@pve` qui voit tout mais ne peut rien modifier ;
- tu as constaté par toi-même la différence entre root et un compte en lecture seule ;
- le **trousseau SSH du lab** (`/root/.ssh/lab-keys.pub`) existe sur le nœud : c'est lui que
  recevront toutes les VMs des chapitres suivants.

## Étape A — Post-installation complète

1. Bascule les dépôts sur `pve-no-subscription` comme dans la démo : désactive les
   dépôts enterprise (`Enabled: false` dans les fichiers `.sources`) et crée
   `/etc/apt/sources.list.d/proxmox.sources` au format deb822.
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

## Étape D — Le trousseau SSH du lab

Les VMs que tu créeras à partir du chapitre 3 n'auront **pas de mot de passe** : on y
entre par clé, et uniquement par clé. Il faut donc décider maintenant QUELLES clés auront
le droit d'entrer. Deux : celle de ton poste (c'est toi), et celle du nœud (c'est lui qui
se connecte aux VMs dans les démos).

1. **Depuis ton poste** — dépose ta clé sur le nœud (c'est le TP du chapitre 0, appliqué
   au nœud) : chemin A `ssh-copy-id -p 2222 root@localhost`, chemin B
   `ssh-copy-id root@192.168.1.240`. Vérifie : `ssh root@… hostname` répond `pve-lab`
   sans mot de passe. Sous Windows, fais-le depuis Git Bash ou WSL — et garde ce même
   environnement pour tout le cours, c'est cette clé qui compte.
2. **Sur le nœud** — crée-lui sa propre clé : `ssh-keygen -t ed25519 -N '' -f /root/.ssh/id_ed25519`.
3. **Sur le nœud** — assemble le trousseau :
   `cat /root/.ssh/authorized_keys /root/.ssh/id_ed25519.pub > /root/.ssh/lab-keys.pub`.

Ce fichier est le seul argument que tu donneras à `--sshkeys` au chapitre 3. Si un jour
tu changes de poste, tu refais l'étape 1, puis l'étape 3 — et les VMs déjà créées
reçoivent le nouveau trousseau par `qm set <id> --sshkeys /root/.ssh/lab-keys.pub` suivi
d'un stop/start.

## ✅ Critères de réussite

- [ ] `apt update` sans erreur 401
- [ ] `pveversion` affiche la version
- [ ] Connexion GUI avec `eleve@pve` (realm PVE) fonctionne
- [ ] Impossible de créer une VM avec `eleve@pve`
- [ ] Depuis ton poste : `ssh root@<nœud> hostname` sans mot de passe
- [ ] `cat /root/.ssh/lab-keys.pub` montre **2 lignes** `ssh-ed25519`

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
