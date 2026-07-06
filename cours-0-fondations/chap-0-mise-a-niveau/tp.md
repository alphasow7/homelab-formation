# TP chapitre 0 — SSH sans mot de passe

**Temps cible : 15 min.** Tout se fait depuis TON poste (ton PC de tous les jours).

## De quelle machine as-tu besoin ?

Il te faut une machine Linux accessible en SSH, n'importe laquelle :

- **Chemin B (PC dédié)** : parfait, utilise ta machine du lab.
- **N'importe quel autre Linux accessible** : un Raspberry Pi, un vieux portable sous
  Linux, un petit serveur loué… tout compte.
- **Chemin A (VirtualBox) et pas d'autre machine sous la main ?** Pas de panique : ce TP
  se fera naturellement au **chapitre 3**, avec ta première VM. Lis-le quand même, fais le
  quiz, et passe au chapitre suivant.

> **⚠️ Poste sous Windows ?** `ssh-copy-id` n'existe pas dans le OpenSSH natif de Windows.
> Deux options : utiliser **Git Bash** ou **WSL** (qui l'ont), ou copier la clé à la main
> depuis PowerShell :
> `type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh utilisateur@ip "cat >> ~/.ssh/authorized_keys"`

## Objectif

À la fin de ce TP :
- tu as TA paire de clés SSH (`ed25519`) sur ton poste ;
- tu te connectes à la machine distante **sans taper de mot de passe** ;
- tu sais expliquer où est le « cadenas » et où est « la clé ».

## Étape A — Générer ta paire de clés

1. Sur ton poste, génère une paire de clés de type ed25519 (revois la démo si besoin).
2. Vérifie que les deux fichiers existent dans `~/.ssh/` : la clé privée et la `.pub`.

> Si `ls ~/.ssh/` montre déjà un `id_ed25519`, tu as déjà une clé : ne la régénère pas,
> passe directement à l'étape B avec la clé existante.

## Étape B — Poser ton cadenas sur la machine distante

1. Copie ta clé publique sur la machine cible avec la commande vue en démo. C'est la
   **dernière fois** que tu tapes le mot de passe.
2. Connecte-toi : `ssh utilisateur@ip` — aucun mot de passe ne doit être demandé
   (sauf la passphrase de ta clé si tu en as mis une : c'est normal, c'est autre chose).

## Étape C — Vérification finale

Depuis ton poste :

```bash
ssh utilisateur@ip hostname
```

Cette commande se connecte, exécute `hostname` là-bas, affiche le résultat et se
déconnecte — le tout **sans demander de mot de passe**. Si le nom de la machine distante
s'affiche directement, c'est gagné.

## ✅ Critères de réussite

- [ ] `ls ~/.ssh/` montre `id_ed25519` et `id_ed25519.pub`
- [ ] `ssh utilisateur@ip hostname` affiche le nom de la machine distante
- [ ] Aucun mot de passe demandé pendant la commande ci-dessus
- [ ] Tu sais dire lequel des deux fichiers ne doit JAMAIS quitter ton poste

---

## Indices (déplie seulement si tu bloques)

<details>
<summary>Indice 1 — je ne retrouve plus les commandes</summary>

Deux commandes suffisent, dans cet ordre :
`ssh-keygen -t ed25519` (accepte les questions avec Entrée), puis
`ssh-copy-id utilisateur@ip`. Elles sont aussi dans [`demo.sh`](demo.sh), bloc 1.4,
avec les commentaires.
</details>

<details>
<summary>Indice 2 — le mot de passe est encore demandé après ssh-copy-id</summary>

Vérifie dans l'ordre : (1) `ssh-copy-id` a-t-il bien affiché `Number of key(s) added: 1` ?
(2) Tu te connectes avec le MÊME utilisateur que celui utilisé pour `ssh-copy-id` ?
(3) Si on te demande une « passphrase for key », ce n'est pas le mot de passe de la
machine : c'est celle de TA clé, tout fonctionne. (4) Sur la machine distante,
`cat ~/.ssh/authorized_keys` doit contenir une ligne commençant par `ssh-ed25519` —
si le fichier est vide, rejoue `ssh-copy-id`.
</details>

La correction complète est dans [`correction/tp.sh`](correction/tp.sh).
