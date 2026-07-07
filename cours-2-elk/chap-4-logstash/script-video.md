# Chapitre 4 — Logstash : le centre de tri : script vidéo

> Durée cible : ~35 min. Prérequis : chap 2 (ES mono-nœud, mot de passe elastic vaulté
> sous `vault_elastic_password`) et chap 3 (TLS, CA dans `/etc/elasticsearch/certs/ca/`).
> Toutes les commandes montrées sont dans `demo.sh` et rejouées avant tournage.
> Le rôle complet est dans `../ansible-extraits/roles/logstash/` — l'élève le recopie
> dans SON arbre (`cours-1-ansible/ansible/roles/`). Logstash s'installe sur
> **kibana-logstash** (10.10.99.14), pas sur elastic-1.

## 1. Le concept (5 min)

**À dire** : « Elasticsearch sait ranger et chercher — mais il faut lui donner des fiches
propres. Entre tes machines qui crachent des logs bruts et ES, il manque un intermédiaire :
Logstash, **le centre de tri postal**. Tout colis qui entre passe par trois étages, dans
cet ordre :

- **input** : le quai de réception — d'où arrivent les événements (des Beats sur le port
  5044, du syslog réseau sur le 5514…) ;
- **filter** : la table de tri — on ouvre le colis, on le met en forme, on l'étiquette ;
- **output** : le quai d'expédition — vers où on envoie (ici : Elasticsearch, en HTTPS).

input → filter → output. Retiens ces trois mots, tu sais lire n'importe quel pipeline. »

**⚠️ LE mot du chapitre — grok** : « À la table de tri, l'outil vedette s'appelle **grok**.
Définition simple : *des expressions régulières avec des étiquettes nommées*. Une regex
classique dit "ici il y a une suite de chiffres" ; grok dit "ici il y a une suite de
chiffres, appelle-la `response`". »

**À montrer à l'écran (schéma)** — une ligne de log nginx brute :

```
192.168.1.10 - - [07/Jul/2026:10:00:00 +0000] "GET /index.html HTTP/1.1" 200 1234 "-" "curl/8"
```

« Pour ES aujourd'hui, c'est **un seul champ** : `message`, un gros bloc de texte. Grok
passe dessus et pose des étiquettes :

```
clientip = 192.168.1.10   verb = GET   request = /index.html   response = 200   bytes = 1234
```

Le même texte, mais **découpé en champs interrogeables**. C'est toute la magie du
chapitre : on va faire ça en direct. »

## 2. Démo guidée (16 min)

### 2.1 Déployer le rôle

**À montrer** : recopier le rôle depuis `ansible-extraits/`, copier le playbook
`logstash.yml`. Masquerade ON sur le nœud (réflexe cours 1 : Logstash pèse quelques
centaines de Mo). `ansible-playbook playbooks/logstash.yml`. Masquerade OFF.

**À expliquer pendant que ça télécharge** : le tour du rôle — on repose le dépôt Elastic
sur CETTE VM avec la méthode signed-by (le dépôt du chap 2 était sur elastic-1, machine
différente) ; le heap fixé à **512m** (« la VM n'a que 2 Go et elle hébergera Kibana au
prochain chapitre — on ne peut pas se permettre 2 Go comme pour ES ») ; le **slurp de la
CA** : on lit `ca.crt` SUR elastic-1 et on le ramène ici pour que Logstash fasse confiance
au HTTPS d'ES ; le pipeline `lab.conf`.

### 2.2 Un premier événement de test

**À montrer** (depuis le **bastion**, pas besoin de nginx pour commencer) :

```bash
echo "test $(date)" | nc 10.10.99.14 5514
```

« J'envoie une simple ligne de texte sur le port syslog 5514 de kibana-logstash. Logstash
la reçoit (input), la fait passer par le filtre — elle ne ressemble pas à du nginx, donc
elle prend juste le tag `non_nginx` — et l'expédie vers ES (output). »

**À montrer** (sur elastic-1, ou depuis le bastion avec la CA) :

```bash
curl --cacert /etc/elasticsearch/certs/ca/ca.crt -u elastic:LE_MDP \
  "https://10.10.99.11:9200/logstash-*/_search?q=message:test&pretty"
```

**Attendu** : un `hits` avec notre ligne, dans un index `logstash-2026.07.07`. « L'index
est né tout seul, daté du jour. Le pipeline fonctionne de bout en bout. »

### 2.3 LE moment : grok sur une vraie ligne nginx

**À montrer** — envoyer une vraie ligne de log nginx :

```bash
echo '192.168.1.10 - - [07/Jul/2026:10:00:00 +0000] "GET /index.html HTTP/1.1" 200 1234 "-" "curl/8"' \
  | nc 10.10.99.14 5514
```

**Puis la chercher et bien montrer le document** :

```bash
curl --cacert /etc/elasticsearch/certs/ca/ca.crt -u elastic:LE_MDP \
  "https://10.10.99.11:9200/logstash-*/_search?q=response:200&pretty"
```

**Attendu / à commenter à l'écran — AVANT vs APRÈS :**

- **AVANT** (l'événement test de 2.2) : un seul champ utile, `message`, un blob de texte.
  On ne peut chercher que du plein texte dedans.
- **APRÈS** (la ligne nginx) : le document contient maintenant `clientip`, `verb`,
  `request`, **`response`**, `bytes`… « Je peux demander à ES *toutes les requêtes qui ont
  répondu 200*, ou *tout ce qui vient de 192.168.1.10*. Le texte brut est devenu une
  base de données interrogeable. C'est ça, grok. C'est ça, tout l'intérêt de Logstash. »

## 3. Encart vrai matériel (3 min)

**À filmer** : sur le Logstash réel, le `conf.d/` avec le vrai pipeline, et la liste des
index dans ES :

```bash
curl -s -u elastic:*** "https://ELASTIC:9200/_cat/indices/logstash-*?v"
```

**À dire** : « En vrai on ne mélange pas tout dans un seul `logstash-*`. On route par type
de source : `logstash-filebeat-*`, `logstash-metricbeat-*`, `logstash-syslog-*`… un index
par famille de Beat. Pourquoi ? Pour éviter les conflits de *mapping* (deux sources qui
appellent un champ pareil avec des types différents) et pour pouvoir purger/dimensionner
chaque type indépendamment. Notre `logstash-%{+YYYY.MM.dd}` du lab est la version simple
de cette idée : **un index par jour** — on verra tout de suite pourquoi. »

## 4. 💡 L'astuce du vrai monde (2 min)

> Dérogation assumée : pas de panne dédiée ce chapitre — une astuce à la place.

**À dire** : « "Mes logs n'arrivent pas dans ES." Avant de tout casser, demande à Logstash
combien d'événements il a vu passer. Il a une petite API de monitoring sur le port 9600 :

```bash
curl -s localhost:9600/_node/stats/events?pretty
```

Tu obtiens des compteurs : `in` (reçus par les inputs), `filtered` (passés dans les
filtres), `out` (expédiés). **Renvoie une ligne avec `nc` et regarde `in` monter d'une
unité en direct.** Si `in` bouge mais pas `out` → le problème est à la sortie (ES
injoignable, CA, mot de passe). Si `in` ne bouge pas → l'événement n'arrive même pas
(mauvais port, pare-feu). En 5 secondes tu sais de quel côté chercher. »

## 5. Annonce du TP (1 min)

**À dire** : « À toi de jouer avec le filtre. Aujourd'hui grok extrait le code HTTP dans le
champ `response`. Tu vas ajouter une règle : si `response` est ≥ 400 — donc une erreur —
Logstash colle le tag `http_error`. Puis tu le prouves : tu envoies une ligne nginx en 404
et tu la retrouves dans ES avec son tag. 20 minutes. Au prochain chapitre : Kibana, enfin
des écrans pour voir tout ça. »
