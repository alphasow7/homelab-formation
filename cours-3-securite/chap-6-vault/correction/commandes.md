# Correction — TP chapitre 6 (Vault)

## 1. Ranger et relire le mot de passe elastic (KV)

Sur la VM Vault (VAULT_ADDR déjà exporté, session authentifiée avec le root token) :

```bash
vault kv put secret/lab/elastic password='TON_MDP_ELASTIC'
vault kv get secret/lab/elastic
```

Attendu :

```
====== Data ======
Key         Value
---         -----
password    TON_MDP_ELASTIC
```

Le secret vit maintenant dans Vault (serveur) EN PLUS de l'ansible-vault (fichier).

## 2. Reboot → sceau → descellage par le playbook

Sur la VM :

```bash
sudo reboot
# (reconnexion ssh)
vault status
```

Attendu :

```
Sealed          true
```

Depuis le poste (contrôleur Ansible) :

```bash
cd cours-1-ansible/ansible
# tant que la clé n'est pas dans l'ansible-vault, on la passe à la main :
ansible-playbook playbooks/vault-unseal.yml -e vault_unseal_key='LA_CLE_NOTEE_AU_INIT'
```

Attendu :

```
TASK [Afficher l'état du sceau] ...
ok: [dns-proxy] => { "msg": "sealed=false" }
```

Vérification : `vault status` sur la VM → `Sealed  false`.

## 3. Bonus — ranger la clé d'unseal dans l'ansible-vault

Depuis `cours-1-ansible/ansible/` :

```bash
ansible-vault create group_vars/vault/vault.yml
```

Contenu :

```yaml
---
vault_unseal_key: "LA_CLE_NOTEE_AU_INIT"
```

Désormais le descellage ne réclame plus rien :

```bash
ansible-playbook playbooks/vault-unseal.yml   # → sealed=false
```

Le playbook déchiffre `vault_unseal_key` tout seul (ton `.vault_pass` est déjà configuré).
La tâche qui soumet la clé est en `no_log: true` : la clé n'apparaît jamais dans la sortie.

> Rappel de la morale du chapitre : la clé est **générée** (au `init`) → **sauvegardée
> chiffrée** (ici, dans l'ansible-vault) → **testée** (ce playbook), dans la même session.
> C'est ce qui transforme un « coffre scellé au reboot » (normal) en simple formalité, au
> lieu d'un « coffre perdu » (presse-papier).
