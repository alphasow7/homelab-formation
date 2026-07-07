# TP chapitre 4 — Étiqueter les erreurs HTTP

**Temps cible : 20 min.** Tu modifies le pipeline dans TON arbre ansible (le rôle
`logstash` recopié), tu redéploies, puis tu envoies une ligne nginx en erreur depuis le
bastion et tu la retrouves taguée dans Elasticsearch.

## Énoncé

Aujourd'hui, grok extrait le code HTTP de nginx dans le champ `response`. Ton but :

1. **Ajoute une règle au filtre** : si `response` est **≥ 400** (une erreur HTTP), ajoute
   le tag `http_error` à l'événement. La règle vient APRÈS le grok (il faut que `response`
   existe déjà) et seulement sur les lignes nginx (celles qui n'ont pas le tag `non_nginx`).
2. **Redéploie** : `ansible-playbook playbooks/logstash.yml` (masquerade inutile ici, rien
   à télécharger — juste le template qui change et un restart).
3. **Prouve-le** : envoie une ligne nginx en **404** depuis le bastion :

```bash
echo '10.0.0.9 - - [07/Jul/2026:11:00:00 +0000] "GET /perdu HTTP/1.1" 404 153 "-" "curl/8"' \
  | nc 10.10.99.14 5514
```

4. **Retrouve-la avec son tag** dans ES :

```bash
curl --cacert /etc/elasticsearch/certs/ca/ca.crt -u elastic:LE_MDP \
  "https://10.10.99.11:9200/logstash-*/_search?q=tags:http_error&pretty"
```

## Critères de réussite

- [ ] Le document en 404 remonte sur `?q=tags:http_error`
- [ ] Il contient bien `"response" : "404"` et le tag `http_error`
- [ ] Une ligne nginx en **200** (le `curl` de la démo) n'a PAS le tag `http_error`

## Indices

<details>
<summary>Indice 1 — comparer un champ grok à un nombre</summary>

`response` sort de grok en **texte**. Pour le comparer à 400, convertis-le en entier
d'abord, ou compare la version numérique. Le plus simple : dans un bloc `if`, teste
`[response]` avec l'opérateur `>=`. Logstash convertit tout seul si tu écris
`if [response] and [response] >= 400`. Pour ajouter le tag : `mutate { add_tag => [...] }`.
</details>

<details>
<summary>Indice 2 — où placer le bloc</summary>

Dans `filter { ... }`, APRÈS le `if [message] =~ ... { grok ... }` — sinon `response`
n'existe pas encore. Structure :

```
if [response] and [response] >= 400 {
  mutate { add_tag => ["http_error"] }
}
```
</details>

Correction : [`correction/pipeline.conf`](correction/pipeline.conf).
