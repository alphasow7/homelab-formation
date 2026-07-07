# Correction TP chapitre 8 — dashboard "nginx — dns-proxy"

> Rien à importer : ce chapitre apprend à CONSTRUIRE en Lens. Voici la démarche exacte,
> panneau par panneau. Un formateur la rejoue à la souris avant tournage.

## 0. Avant de commencer

Générer du trafic pour avoir de la matière :

```bash
for i in $(seq 1 30); do curl -s http://10.10.99.12/ >/dev/null; done
```

Puis **Analytics > Dashboard > Create dashboard**. Data view : `logstash-*`. Fenêtre de
temps : "Last 15 minutes". On peut poser le filtre nginx une fois pour tout le dashboard
via la barre de recherche KQL : `log_source : "nginx"` — ou le remettre dans chaque
panneau (plus explicite pour l'élève). La correction le met par panneau.

## Panneau (a) — Hits dans le temps (barres)

1. **Create visualization** → Lens.
2. Sélecteur de type (haut droit) : **Bar (stacked)**.
3. Glisser **@timestamp** sur **Horizontal axis** → histogramme temporel automatique.
4. **Vertical axis** : laisser **Count of records** (proposé par défaut).
5. Barre KQL du panneau : `log_source : "nginx"`.
6. **Save and return.**

Attendu : une bosse de ~30 hits correspondant au `for`.

## Panneau (b) — Répartition des codes de réponse (camembert)

1. **Create visualization** → Lens.
2. Type : **Pie**.
3. **Slice by** : glisser **`response`** (ou `response.keyword` si Lens réclame un
   agrégeable ; sinon `http.response.status_code` selon le pipeline). Agrégation **Terms**,
   taille 5.
4. **Size** : **Count of records**.
5. Filtre panneau : `log_source : "nginx"`.
6. **Save and return.**

Attendu : une part écrasante de **200**. Sur un lab sain, pas ou peu de 4xx/5xx — c'est le
but : le camembert doit être quasi monochrome tant que tout va bien. (Ce panneau devient
le détecteur du scénario "nginx 500" du chapitre 9.)

## Panneau (c) — Top des IP clientes (table)

1. **Create visualization** → Lens.
2. Type : **Table**.
3. **Rows** : glisser **`clientip`** (ou `clientip.keyword` / `source.ip` selon le
   pipeline). Agrégation **Terms**, **taille 10**, tri par **Count** décroissant.
4. **Metrics** : **Count of records**.
5. Filtre panneau : `log_source : "nginx"`.
6. **Save and return.**

Attendu : au plus 10 lignes ; ton IP (ou celle du bastion via lequel tu sors) en tête
après le `for`.

## Sauvegarde

**Save** → titre **"nginx — dns-proxy"**. Vérifier qu'il se recharge et se met à jour
quand on relance un `for … curl`.

## Pièges rencontrés (mêmes réflexes que le cours)

- **Champ `response`/`clientip` absent** : ils viennent du grok du chap. 4 et n'existent
  que sur les lignes nginx parsées. Vérifier dans Discover (`log_source : "nginx"`, cliquer
  un document). Pas de grok = pas de champs → revoir le pipeline chap. 4.
- **Agrégation Terms qui refuse le champ** : utiliser la version `.keyword`. Si absente,
  rafraîchir les champs de la data view (Stack Management > Data Views > logstash-* >
  Refresh).
- **Panneau vide** : fenêtre de temps trop étroite, ou `for` non exécuté → aucune ligne à
  agréger. Élargir le temps, régénérer du trafic.
