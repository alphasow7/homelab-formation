# TP — Chapitre 5 : Prouver l'entonnoir de précédence (≈ 20 min)

## Objectif

Prouver toi-même, `curl` à l'appui, que chaque étage de l'entonnoir écrase le
précédent sur la page de statut de `dns-proxy` :

1. **group_vars** — dans `inventory/group_vars/lab.yml`, remplace le titre de la
   démo par un titre PERSONNEL (ton prénom, le nom de ton lab… ce que tu veux,
   du moment que c'est reconnaissable). Rejoue, `curl` : ton titre s'affiche.
2. **host_vars** — crée un fichier host_vars pour `dns-proxy` qui surcharge
   ENCORE `web_status_title` avec un troisième titre (« l'exception d'une
   machine »). Rejoue, `curl` : c'est le titre host_vars qui gagne, alors que le
   group_vars est toujours là.
3. **-e** — lance un run avec `-e` et un quatrième titre. `curl` : l'ordre
   direct gagne sur tout.

Tu ne touches NI au rôle `web_status`, NI au playbook : tout se joue dans
l'inventaire et sur la ligne de commande. C'est le but du chapitre.

## Critère de réussite (non négociable)

**Trois `curl` successifs montrant trois titres différents**, un par étage :

1. après l'étape 1 : ton titre group_vars ;
2. après l'étape 2 : ton titre host_vars (preuve que host_vars > group_vars) ;
3. après l'étape 3 : le titre passé en `-e` (preuve que `-e` > tout).

Bonus de compréhension : rejoue une dernière fois SANS `-e` — quel titre
revient, et pourquoi ?

## Indices

<details>
<summary>Indice 1 — où vit host_vars, et comment il s'appelle</summary>

Même logique que `group_vars`, mais par HÔTE : le fichier va dans
`inventory/host_vars/` et son nom DOIT être le nom de l'hôte tel qu'il apparaît
dans `hosts.yml` — donc :

```
ansible/inventory/host_vars/dns-proxy.yml
```

Le dossier `host_vars/` n'existe pas encore : crée-le
(`mkdir -p inventory/host_vars`). Dedans, un YAML tout simple :

```yaml
---
web_status_title: "..."
```
</details>

<details>
<summary>Indice 2 — l'ordre de précédence (le schéma du cours)</summary>

Du plus faible au plus fort — « plus c'est spécifique, plus c'est fort » :

```
defaults/ du rôle  <  group_vars/  <  host_vars/  <  -e en ligne de commande
(réglages d'usine)    (le groupe)     (la machine)    (l'ordre direct)
```

Si ton `curl` de l'étape 2 montre encore le titre group_vars : vérifie le NOM du
fichier (`dns-proxy.yml`, exactement comme dans l'inventaire) et son emplacement
(`inventory/host_vars/`, pas à la racine). Et pour l'étape 3, la syntaxe :

```bash
ansible-playbook playbooks/web-status-role.yml -e 'web_status_title="..."'
```
</details>

## Vérification

```bash
# Étape 1 — group_vars
ansible-playbook playbooks/web-status-role.yml
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12     # titre group_vars

# Étape 2 — host_vars
ansible-playbook playbooks/web-status-role.yml
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12     # titre host_vars

# Étape 3 — -e
ansible-playbook playbooks/web-status-role.yml -e 'web_status_title="..."'
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12     # titre du -e
```

Correction complète : `correction/host_vars-dns-proxy.yml` (le fichier host_vars
attendu) et `correction/commandes.md` (les runs et les curl attendus).
