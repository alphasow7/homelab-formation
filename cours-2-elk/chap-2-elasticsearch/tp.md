# TP chapitre 2 — Ton journal de bord indexé

**Temps cible : 25 min.** Sur la VM elastic-1 (ssh via bastion) + ton arbre ansible pour
le bonus vault.

## Énoncé

1. Indexe **5 entrées** dans l'index `journal` (JSON : `date`, `machine`, `evenement`) —
   varie les machines et les dates (étale-les sur 2 jours).
2. **Recherche plein texte** : trouve toutes les entrées qui mentionnent un mot de ton
   choix (`?q=evenement:xxx`).
3. **Recherche par date** : les entrées d'aujourd'hui seulement — requête `range` en JSON :

```json
{ "query": { "range": { "date": { "gte": "2026-07-07T00:00:00" } } } }
```

   (à envoyer sur `_search` avec `-H 'Content-Type: application/json' -d '...'`)
4. **Compte** les documents de l'index (`GET /journal/_count`).
5. **Bonus hygiène (cours 1, chapitre 6)** : range le mot de passe `elastic` dans ton
   ansible-vault (`vault_elastic_password` dans `group_vars/lab/vault.yml`).

## Critères de réussite

- [ ] `_count` → `"count" : 5`
- [ ] La recherche plein texte remonte les bons documents (et seulement eux)
- [ ] La requête range filtre bien par date
- [ ] Bonus : `ansible-vault view` montre `vault_elastic_password`

## Indices

<details>
<summary>Indice 1 — la forme des commandes</summary>

Toutes les commandes sont des variantes de celles de `demo.sh` : POST pour indexer,
GET `_search` pour chercher, GET `_count` pour compter. Seul le `-d '...'` change.
</details>

<details>
<summary>Indice 2 — la range ne renvoie rien ?</summary>

Vérifie le format de tes dates à l'indexation (`2026-07-07T10:00:00`) : si ES ne les a
pas reconnues comme dates, la range ne matche pas. `GET /journal/_mapping?pretty` te
montre comment ES a interprété le champ `date` (il doit être de type `date`).
</details>

Correction : [`correction/commandes.md`](correction/commandes.md).
