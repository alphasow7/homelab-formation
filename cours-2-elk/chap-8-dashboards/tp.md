# TP chapitre 8 — Le dashboard "nginx" de dns-proxy

**Temps cible : 25 min.** Dans Kibana (`https://localhost:5601` via le tunnel SSH). Tu as
tagué les logs nginx de dns-proxy au chap. 6 (`log_source : "nginx"`) et le grok du chap. 4
a extrait le champ `response` (le code HTTP). On va en faire un vrai dashboard de service —
à la main, en Lens, comme "Santé du lab".

## Prépare tes données

Avant de construire, génère un peu de trafic pour avoir de quoi afficher (depuis ton poste,
via le bastion) :

```bash
for i in $(seq 1 30); do curl -s http://10.10.99.12/ >/dev/null; done
```

## Énoncé

Crée un **nouveau dashboard** nommé **"nginx — dns-proxy"** avec **3 panneaux** en Lens.
Chaque panneau ne regarde QUE les logs nginx : ajoute à chacun (ou au dashboard entier via
la barre de recherche) le filtre KQL **`log_source : "nginx"`**.

1. **Hits dans le temps** (barres) :
   - Type : **Bar (stacked)**.
   - Axe horizontal : **@timestamp**.
   - Axe vertical : **Count of records**.
   - → tu vois le rythme des requêtes ; ton `for` de tout à l'heure doit faire une bosse.

2. **Répartition des codes de réponse** (camembert) :
   - Type : **Pie**.
   - Découpage : **Terms** sur le champ **`response`** (issu du grok du chap. 4 ; sinon
     `http.response.status_code` selon ce que le pipeline a produit).
   - → en bonne santé : une part énorme de `200`. Les `4xx`/`5xx` doivent rester des miettes.

3. **Top des IP clientes** (table) :
   - Type : **Table**.
   - Rows : **Terms** sur **`clientip`** (grok) — ou `source.ip` / `client.ip` selon le
     pipeline — **taille 10**, trié par **Count** décroissant.
   - → qui frappe le serveur, et à quel volume.

**Sauvegarde** le dashboard.

## Critères de réussite

- [ ] Le dashboard "nginx — dns-proxy" existe et contient 3 panneaux
- [ ] Les 3 panneaux ne montrent QUE des logs nginx (filtre `log_source : "nginx"`)
- [ ] Le camembert des codes montre une écrasante majorité de `200`
- [ ] La table des IP clientes affiche au plus 10 lignes, ton IP en tête après le `for`

## Indices

<details>
<summary>Indice 1 — "je ne trouve pas le champ response / clientip dans Lens"</summary>

Ces champs viennent du **grok** du chap. 4 : ils n'existent que sur les lignes nginx qui
ont été parsées. Deux vérifs : (1) va dans **Discover**, filtre `log_source : "nginx"`,
clique sur une ligne — tu dois voir `response`, `clientip`, `verb`… dans le document. Si
tu ne les vois pas, le grok n'a pas tourné (relis le pipeline du chap. 4). (2) Pour une
agrégation Terms, Lens veut souvent la version **`.keyword`** du champ (`response.keyword`).
Si elle manque, ouvre la data view `logstash-*` et **rafraîchis les champs**.
</details>

<details>
<summary>Indice 2 — "le filtre log_source ne rend rien / le camembert est vide"</summary>

Ordre des réflexes du cours : d'abord **la fenêtre de temps** (en haut à droite : passe à
"Last 15 minutes" — ton trafic est récent). Ensuite **le nom exact du champ** : `log_source`
est un mot-clé, filtre exact `log_source : "nginx"` (avec les guillemets). Enfin, vérifie
que ton `for … curl` a bien écrit : dans Discover, tu dois voir apparaître les 30 lignes.
Pas de lignes = pas de trafic généré, ou input Filebeat nginx absent (chap. 6).
</details>

Correction : [`correction/notes.md`](correction/notes.md) — la démarche Lens panneau par
panneau (c'est manuel : pas de fichier à importer).
