# TP chapitre 7 — L'audit d'hygiène de ton lab

**Temps cible : 20 min.** Sur ton lab (OPNsense, ELK, Vault) + ton arbre ansible
(`cours-1-ansible/ansible/`). Aucun outil nouveau : que des réflexes.

## Énoncé

### 1. Auditer — la liste des comptes encore par défaut

Fais le tour de tes services et note ceux qui tournent **encore avec leur identifiant
d'usine**. Rien à installer : juste vérifier. Suspects habituels :

- **OPNsense** : `root/opnsense` (le défaut public) — essaie de te connecter avec, s'il
  passe, c'est qu'il n'a jamais été changé ;
- **Kibana / elastic** : le mot de passe `elastic` a-t-il été roté et vaulté (cours 2) ?
- **PBS, GitLab, Proxmox, un NAS, une caméra…** : tout ce qui a une page de login.

Écris la liste. C'est la partie la plus importante du TP : on ne protège que ce qu'on a vu.

### 2. En roter UN, proprement, et le ranger dans l'ansible-vault

Choisis-en un (idéalement **OPNsense**, notre exemple fil rouge) et change son mot de passe
**de façon qui PERSISTE** — via le système de config, pas une édition à la main
(cf. démo §2.1). Reboot-test à l'appui : l'ancien mot de passe ne doit plus marcher.

Puis range le nouveau dans ton trousseau chiffré :

```bash
cd cours-1-ansible/ansible
ansible-vault edit inventory/group_vars/opnsense/vault.yml
#   vault_opnsense_root_password: "TON-NOUVEAU-MDP-FORT"
```

### 3. Importer ta CA interne dans ton navigateur

Récupère `ca.crt` (la CA du cours 2) et importe-la dans le trousseau de ton navigateur ou
de ton OS (cf. démo §2.3). Puis **vérifie qu'un service interne passe au vert** : rafraîchis
Kibana (ou Vault, ou OPNsense) — le cadenas doit devenir vert, sans « Accepter le risque ».

## Critères de réussite

- [ ] Tu as une liste écrite des services audités (défaut / roté)
- [ ] Après reboot, l'**ancien** mot de passe OPNsense ne fonctionne plus (persistance OK)
- [ ] `ansible-vault view inventory/group_vars/opnsense/vault.yml` montre
      `vault_opnsense_root_password`
- [ ] Ta CA interne est importée et **au moins un service interne** affiche un cadenas vert

## Indices

<details>
<summary>Indice 1 — mon changement de mot de passe OPNsense ne survit pas au reboot</summary>

C'est exactement la panne du chapitre 2. Ne touche **jamais** `/conf/config.xml` à la main :
OPNsense le réécrit au boot depuis son cache mémoire. Passe par le **système de config** —
le **Save** du GUI (`System ▸ Access ▸ Users`) ou un `write_config()` en console. C'est
`write_config()` qui grave le changement sur disque.
</details>

<details>
<summary>Indice 2 — où trouver le fichier ca.crt à importer</summary>

C'est la CA que tu as créée au cours 2 (chap 3), celle qui signe les certs ELK. Elle vit sur
le nœud Elasticsearch :
`scp root@elastic-1:/etc/elasticsearch/certs/ca/ca.crt ~/homelab-ca.crt`.
Vérifie que c'est bien une racine auto-signée :
`openssl x509 -in ~/homelab-ca.crt -noout -subject -issuer` (subject == issuer).
</details>

Correction : [`correction/commandes.md`](correction/commandes.md) —
checklist : [`correction/checklist-hygiene.md`](correction/checklist-hygiene.md).
