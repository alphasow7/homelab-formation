# Correction TP chapitre 5 — Kibana

> Ce TP se fait dans l'UI (pas de commandes à figer). Voici les points d'étape et à quoi
> ressemble le résultat. Le NDJSON attendu est **une structure, pas une valeur exacte** :
> les ids que Kibana génère à la création via l'UI sont des UUID aléatoires — c'est normal
> que les tiens diffèrent. Ce qui compte, c'est la **cohérence des références**.

## 1. La visu "top 5 des machines par volume" (Lens)

- Ouvrir **Visualize/Lens > Create > Lens**, data view `logstash-*`.
- Type **Bar horizontal** (ou Pie).
- **Vertical axis / Size** : `Count of records`.
- **Horizontal axis / Slice by** : `Top values of machine.keyword`, **Number of values = 5**.
- Save, titre : `Top 5 machines par volume`, "Add to dashboard: Lab — Observabilité".

Si `machine.keyword` n'existe pas → utiliser `host.name` (dépend de ce que Logstash a
produit au chap. 4). Vérifier le nom réel dans **Discover** en dépliant un document.

## 2. Ajout au dashboard + sauvegarde

Le dashboard "Lab — Observabilité" contient alors **2 panneaux** : "volume de logs dans le
temps" (importé) + "top 5 machines par volume" (le tien). Save.

## 3. Ré-export

**Stack Management > Saved Objects** → cocher le dashboard → **Export** (inclure les
objets liés / "include related objects"). Fichier `.ndjson` téléchargé.

## 4. Comparaison au bundle fourni

Attendu dans le ré-export :

| type            | combien | rôle                                        |
|-----------------|---------|---------------------------------------------|
| `index-pattern` | 1       | la data view `logstash-*` (PARTAGÉE)        |
| `lens`          | 2       | volume-dans-le-temps + top-5-machines       |
| `dashboard`     | 1       | Lab — Observabilité (référence les 2 lens)  |
| (`exportedCount`) | 1 ligne | méta de fin, souvent ajoutée par Kibana   |

**Le point clé** : la data view apparaît **une seule fois** bien que deux visus s'en
servent — chaque lens la référence par le **même id** dans son bloc `references`. C'est
précisément ce qui évite la panne "missing references" vue en cours : un id partagé et
stable, pas un id par objet.

## Différences attendues avec `lab-observabilite.ndjson`

- **Les ids** diffèrent (UUID générés par l'UI vs nos ids lisibles `logstash-lab-dataview`,
  `volume-logs-temps`, `lab-observabilite`). Sans impact tant que les `references` pointent
  vers les bons ids **à l'intérieur du même fichier**.
- Ton bundle a **une visu de plus** (le top 5) et le `panelsJSON` du dashboard a 2 panneaux.
- Kibana peut ajouter des champs de version/migration : normal.

Un modèle de structure attendue est dans `dashboard-attendu.ndjson` (à titre indicatif —
tes ids seront différents).
