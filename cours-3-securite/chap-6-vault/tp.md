# TP chapitre 6 — Ton premier coffre-fort à secrets

**Temps cible : 25 min.** Sur la VM Vault (ssh via bastion) + ton arbre ansible pour le
bonus. Vault déjà déployé, initialisé et descellé (démo).

## Énoncé

1. **Ranger le mot de passe elastic dans Vault (KV)** — celui que tu as vaulté au cours 2.
   Écris-le dans le moteur KV puis **relis-le** :

   ```bash
   vault kv put secret/lab/elastic password=TON_MDP_ELASTIC
   vault kv get secret/lab/elastic
   ```

   > Tu as maintenant le même secret à **deux** endroits : dans ton `ansible-vault`
   > (fichier, pour le bootstrap) ET dans Vault (serveur, pour le runtime). Les deux
   > "vault" cohabitent — chacun son rôle.

2. **La panne du reboot** : redémarre la VM Vault, puis constate le sceau :

   ```bash
   vault status         # attendu : Sealed  true
   ```

   Descelle-la **avec le playbook** (depuis ton poste) :

   ```bash
   ansible-playbook playbooks/vault-unseal.yml   # attendu : sealed=false
   ```

3. **Bonus hygiène (écho cours 1, chapitre 6)** : range la clé d'unseal dans ton
   ansible-vault pour que le playbook la trouve tout seul — variable `vault_unseal_key`
   dans `group_vars/vault/vault.yml`.

## Critères de réussite

- [ ] `vault kv get secret/lab/elastic` affiche le mot de passe elastic
- [ ] Après reboot, `vault status` montre bien `Sealed  true`
- [ ] `ansible-playbook vault-unseal.yml` se termine sur `sealed=false`
- [ ] Bonus : `ansible-vault view group_vars/vault/vault.yml` montre `vault_unseal_key`,
      et le playbook tourne **sans** demander la clé en ligne de commande

## Indices

<details>
<summary>Indice 1 — le playbook réclame `vault_unseal_key` ?</summary>

`vault-unseal.yml` s'attend à trouver la variable `vault_unseal_key`. Tant qu'elle n'est
pas dans un `group_vars/vault/vault.yml`, passe-la à la main pour tester :
`ansible-playbook playbooks/vault-unseal.yml -e vault_unseal_key=LA_CLE`. Le bonus (étape 3)
consiste justement à la ranger dans l'ansible-vault pour ne plus avoir à la taper.
</details>

<details>
<summary>Indice 2 — créer le vault chiffré du groupe</summary>

Depuis `cours-1-ansible/ansible/`, exactement comme au cours 1 :
`ansible-vault create group_vars/vault/vault.yml`, puis à l'intérieur une ligne
`vault_unseal_key: "LA_CLE_NOTEE_AU_INIT"`. Le playbook la déchiffrera tout seul au run
(ton `.vault_pass` est déjà configuré).
</details>

Correction : [`correction/commandes.md`](correction/commandes.md).
