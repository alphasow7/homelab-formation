# TP chapitre 5 — Ta 2ᵉ visualisation, et le retour dans Git

**Temps cible : 25 min.** Dans Kibana (`https://localhost:5601` via le tunnel SSH), après
avoir importé le bundle `lab-observabilite.ndjson`.

## Énoncé

1. **Construis une 2ᵉ visualisation en Lens** : *top 5 des machines par volume*.
   - Type : barres horizontales (ou camembert).
   - Métrique (axe vertical / taille) : **Count** (nombre d'enregistrements).
   - Découpage (axe horizontal / tranches) : agrégation **Terms** sur le champ
     `machine.keyword` (ou `host.name` selon ce que Logstash a produit), **taille 5**.
2. **Ajoute-la au dashboard** "Lab — Observabilité" (Edit > Add from library, ou "Save and
   return to dashboard"). Sauvegarde le dashboard.
3. **Ré-exporte** le dashboard en NDJSON : **Stack Management > Saved Objects**, coche le
   dashboard, **Export** (avec ses objets liés). Tu obtiens un `.ndjson`.
4. **Compare** ton export au bundle fourni (`lab-observabilite.ndjson`) : combien de lignes ?
   quels `type` ? Retrouves-tu ta nouvelle visu et la data view partagée ?

## Critères de réussite

- [ ] La visu "top 5 machines" affiche bien au plus 5 barres/parts
- [ ] Elle apparaît dans le dashboard "Lab — Observabilité"
- [ ] Le ré-export contient : `dashboard` + 2 × `lens` + 1 × `index-pattern` (data view)
- [ ] Tu sais dire quelle ligne du NDJSON est quoi (un objet JSON par ligne)

## Indices

<details>
<summary>Indice 1 — "aucun champ machine.keyword" dans Lens ?</summary>

Un champ texte a deux formes dans ES : `machine` (analysé, pour la recherche plein texte)
et `machine.keyword` (exact, agrégeable). Les agrégations Terms ont besoin de la version
**`.keyword`**. Si tu ne la vois pas, ouvre la data view et rafraîchis les champs, ou
vérifie le nom réel du champ dans **Discover** (clique sur un document).
</details>

<details>
<summary>Indice 2 — l'export a plus de lignes que prévu ?</summary>

Kibana exporte le dashboard **et toutes ses dépendances** (les 2 visus + la data view
partagée), plus souvent une dernière ligne `{"exportedCount":N,...}`. C'est normal : un
NDJSON est **auto-suffisant**. Note que la data view n'apparaît **qu'une fois** même si
deux visus s'en servent — elles la référencent par le même `id`. C'est exactement ce qui
évite la panne "missing references" du cours.
</details>

Correction : [`correction/`](correction/) (notes + NDJSON attendu — structure, non figé).
