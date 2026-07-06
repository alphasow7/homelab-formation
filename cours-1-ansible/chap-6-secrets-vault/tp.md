# TP — Chapitre 6 : Faire tourner un secret sans jamais l'exposer (≈ 20 min)

**Prérequis :** la démo du chapitre est faite — `vault.yml` chiffré,
`.vault_pass` en place, la page http://10.10.99.12/ répond 401 sans
mot de passe.

## a) Changer le mot de passe et redéployer (10 min)

1. Ouvre le coffre en édition :
   ```bash
   ansible-vault edit inventory/group_vars/lab/vault.yml
   ```
   Remplace la valeur de `vault_web_status_password` par un nouveau mot de
   passe de ton choix, sauvegarde, quitte.
2. Redéploie :
   ```bash
   ansible-playbook playbooks/site.yml --limit dns-proxy
   ```
3. **Prouve** le changement (les curl passent par le bastion, comme d'habitude) :
   ```bash
   ssh alpha@IP_DE_TON_BASTION "curl -s -o /dev/null -w '%{http_code}\n' -u admin:change-moi-Formation2026 http://10.10.99.12/"
   ssh alpha@IP_DE_TON_BASTION "curl -s -o /dev/null -w '%{http_code}\n' -u admin:TON-NOUVEAU-MDP http://10.10.99.12/"
   ```
   Attendu : **401** pour l'ancien, **200** pour le nouveau.

## b) Prouver l'hygiène du repo (7 min)

Deux vérifications, deux preuves :

1. L'historique Git ne contient AUCUN vault en clair :
   ```bash
   git log --all -p -- '**/vault.yml'
   ```
   Attendu : **rien** — le fichier n'a jamais été suivi par Git.
2. Git ignore bien les deux fichiers sensibles :
   ```bash
   git check-ignore -v .vault_pass inventory/group_vars/lab/vault.yml
   ```
   Attendu : une ligne par fichier, avec la règle du `.gitignore` qui
   l'attrape.

## c) Bonus (3 min) — changer la passphrase du coffre

Le mot de passe DANS le coffre, c'est fait. Et la passphrase DU coffre ?

```bash
ansible-vault rekey inventory/group_vars/lab/vault.yml
```

N'oublie pas de mettre `.vault_pass` à jour avec la nouvelle passphrase,
puis vérifie que `ansible-vault view` fonctionne toujours sans rien taper.

## Indices

<details>
<summary>Indice 1 — « ansible-vault edit » me demande une passphrase alors que j'ai un .vault_pass</summary>

Vérifie que `ansible.cfg` contient bien `vault_password_file = .vault_pass`
**sous la section `[defaults]`**, et que tu lances la commande depuis
`cours-1-ansible/ansible/` (le chemin `.vault_pass` est relatif).
</details>

<details>
<summary>Indice 2 — le nouveau mot de passe répond quand même 401</summary>

Le fichier `/etc/nginx/.htpasswd` n'est réécrit que si le playbook a bien
rejoué la task htpasswd : vérifie que le run affiche `changed` pour
« Créer le fichier htpasswd », et que nginx a redémarré (le handler
« Restart nginx » se déclenche via la conf, pas via htpasswd — un simple
re-run suffit car htpasswd est relu à chaque requête, pas au démarrage).
Vérifie aussi que tu as bien sauvegardé dans `ansible-vault edit` :
`ansible-vault view` doit montrer le NOUVEAU mot de passe.
</details>

**Correction :** [correction/commandes.md](correction/commandes.md)
