# Correction — TP 6 : Faire tourner un secret sans jamais l'exposer

> Toutes les commandes se lancent depuis `cours-1-ansible/ansible/` sur ton
> poste. Les curl passent par le bastion.

## a) Changer le mot de passe et redéployer

```bash
# 1. Éditer le coffre (déchiffré dans l'éditeur, re-chiffré à la sortie).
#    Grâce à vault_password_file dans ansible.cfg, aucune passphrase demandée.
ansible-vault edit inventory/group_vars/lab/vault.yml
```

Dans l'éditeur, on remplace la valeur — exemple :

```yaml
---
vault_web_status_password: "Nouveau-Secret-2026"
```

```bash
# 2. Vérifier ce qu'on vient d'écrire, puis redéployer.
ansible-vault view inventory/group_vars/lab/vault.yml
ansible-playbook playbooks/site.yml --limit dns-proxy
# Attendu : changed sur « Créer le fichier htpasswd » (changed_when: true,
# et no_log — le mot de passe n'apparaît nulle part dans la sortie).

# 3. La preuve, ancien puis nouveau :
ssh alpha@IP_DE_TON_BASTION "curl -s -o /dev/null -w '%{http_code}\n' -u admin:change-moi-Formation2026 http://10.10.99.12/"
# → 401 : l'ancien mot de passe est mort.
ssh alpha@IP_DE_TON_BASTION "curl -s -o /dev/null -w '%{http_code}\n' -u admin:Nouveau-Secret-2026 http://10.10.99.12/"
# → 200 : le nouveau fonctionne.
```

## b) Prouver l'hygiène du repo

```bash
# 1. L'historique ne contient AUCUN vault en clair.
git log --all -p -- '**/vault.yml'
# Attendu : AUCUNE sortie. Le fichier n'a jamais été suivi par Git — c'est
# vault.yml.example (sans secret réel) qui est versionné, pas vault.yml.

# 2. Git ignore bien les deux fichiers sensibles.
git check-ignore -v .vault_pass inventory/group_vars/lab/vault.yml
# Attendu (les chemins des règles depuis la racine du repo) :
#   .gitignore:5:cours-1-ansible/ansible/.vault_pass	.vault_pass
#   .gitignore:6:cours-1-ansible/ansible/inventory/group_vars/lab/vault.yml	inventory/group_vars/lab/vault.yml
```

Si `git check-ignore` ne répond rien pour l'un des deux : le fichier N'EST PAS
ignoré → ne pas commiter avant d'avoir corrigé le `.gitignore`.

## c) Bonus — rekey

```bash
# Changer la passphrase DU coffre (l'ancienne est lue via .vault_pass,
# la nouvelle est demandée deux fois au clavier).
ansible-vault rekey inventory/group_vars/lab/vault.yml

# Mettre la clé locale à jour, sinon plus rien ne se déchiffre :
echo 'ma-nouvelle-passphrase' > .vault_pass
chmod 600 .vault_pass

# Preuve : view fonctionne à nouveau sans rien taper.
ansible-vault view inventory/group_vars/lab/vault.yml
```

## Le piège classique (si l'étape a échoue)

- **`ansible-vault edit` redemande une passphrase** : la ligne
  `vault_password_file = .vault_pass` n'est pas sous `[defaults]` dans
  `ansible.cfg`, ou la commande n'est pas lancée depuis `ansible/` (le chemin
  est relatif).
- **Le nouveau mot de passe répond 401** : vérifier avec `ansible-vault view`
  que la nouvelle valeur est bien sauvegardée, puis que le run affiche
  `changed` sur la task htpasswd. Le fichier `/etc/nginx/.htpasswd` est relu à
  chaque requête : pas besoin de redémarrer nginx pour lui.
