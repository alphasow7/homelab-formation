# Chapitre 2 — Elasticsearch : la bibliothèque : script vidéo

> Durée cible : ~40 min. Prérequis : lab de départ vérifié (`../lab-depart.md` — la RAM !).
> Toutes les commandes montrées sont dans `demo.sh` et rejouées avant tournage.
> Le rôle complet est dans `../ansible-extraits/roles/elasticsearch/` — l'élève le
> recopie dans SON arbre (`cours-1-ansible/ansible/roles/`).

## 1. Le concept (6 min)

**À dire** : « Elasticsearch, c'est une bibliothèque avec un index intégral : chaque mot
de chaque document est répertorié. Chercher dans des millions de lignes prend des
millisecondes. Trois mots de vocabulaire et tu sais parler ES :

- l'**index** : un classeur par type de documents (un pour les logs, un pour ton journal…) ;
- le **document** : une fiche du classeur — du JSON, tout simplement ;
- le **shard** : les tomes d'une encyclopédie — un index peut être découpé en morceaux
  pour être porté par plusieurs nœuds. Même en mono-nœud, le concept existe. »

**⚠️ MOMENT CLÉ, à dire AVANT la démo** : « Ton cluster sera **YELLOW** et c'est
**NORMAL**. Green = données + copies de secours en place ; yellow = les données sont là,
mais les copies (réplicas) n'ont **nulle part où aller** — tu n'as qu'un nœud ! Red =
données manquantes, là il faut s'inquiéter. Ne passe pas deux heures à "réparer" du
yellow mono-nœud : il n'y a rien à réparer. »

## 2. Démo guidée (14 min)

### 2.1 Déployer le rôle

**À montrer** : recopier le rôle depuis `ansible-extraits/`, l'ajouter à un nouveau
playbook `elk.yml`. Masquerade ON sur le nœud (réflexe du cours 1 : ES pèse ~600 Mo,
prévoir 5-10 min de téléchargement — coupe au montage). `ansible-playbook playbooks/elk.yml`.
Masquerade OFF.

**À expliquer pendant que ça télécharge** : le tour du rôle — la méthode GPG moderne
(signed-by, « apt-key est mort »), le template avec `discovery.type: single-node`, le
heap fixé à 2 Go.

### 2.2 Premier contact

**À montrer** (sur la VM, via ssh) :

```bash
/usr/share/elasticsearch/bin/elasticsearch-reset-password -u elastic
```

« Le mot de passe du super-utilisateur `elastic` — note-le, on le vaultera au TP. »

```bash
curl -u elastic:LE_MDP http://localhost:9200
```

**Attendu** : le JSON de bienvenue avec `"tagline" : "You Know, for Search"`. « Si tu
vois la tagline, ta bibliothèque est ouverte. »

```bash
curl -u elastic:LE_MDP "http://localhost:9200/_cluster/health?pretty"
```

**Attendu** : `"status" : "yellow"` — « comme annoncé. Encadre-le mentalement en vert. »

### 2.3 Indexer et chercher

**À montrer** :

```bash
# Créer une fiche dans le classeur « journal » (l'index naît tout seul)
curl -u elastic:LE_MDP -X POST "http://localhost:9200/journal/_doc" \
  -H 'Content-Type: application/json' \
  -d '{"date": "2026-07-07T10:00:00", "machine": "elastic-1", "evenement": "premier document indexé"}'

# Une deuxième fiche
curl -u elastic:LE_MDP -X POST "http://localhost:9200/journal/_doc" \
  -H 'Content-Type: application/json' \
  -d '{"date": "2026-07-07T10:05:00", "machine": "dns-proxy", "evenement": "rien à signaler"}'

# Chercher
curl -u elastic:LE_MDP "http://localhost:9200/journal/_search?q=evenement:premier&pretty"
```

**Attendu** : `"hits" : { "total" : { "value" : 1 } }` et le bon document. « Tu viens de
faire ta première recherche indexée. Retiens la forme : un index, des documents JSON, une
recherche. Tout le reste du cours, c'est industrialiser ça. »

## 3. Encart vrai matériel (2 min)

**À filmer** : `_cluster/health` du cluster réel : `"status": "green", "number_of_nodes": 2,
"active_shards": 150`.

**À dire** : « Deux nœuds : les réplicas ont un deuxième nœud où vivre — d'où le green.
Si un nœud meurt, l'autre a tout, et le cluster continue. C'est exactement ce que ton
yellow t'explique en creux. »

## 4. 💡 L'astuce du vrai monde (2 min)

> Dérogation assumée : pas de panne dédiée ce chapitre — une astuce à la place.

**À dire** : « Premier réflexe de tout le monde : `free -h` → "ES me bouffe la moitié de
la RAM !!". Oui. C'est **configuré** (notre fichier heap : 2 Go) et c'est **voulu** : ES
réserve sa mémoire au démarrage et la garde — c'est sa façon d'être rapide. Ne "répare"
pas ça non plus. Deux faux problèmes évités en un chapitre : le yellow, et le heap. »

## 5. Annonce du TP (1 min)

**À dire** : « À toi : ton journal de bord du lab — 5 entrées, des recherches plein
texte, une recherche par date, un comptage. Et vaulte le mot de passe elastic (réflexe
cours 1). 25 minutes. Au prochain chapitre : la porte blindée — TLS et ta propre autorité
de certification. »
