# Correction TP chapitre 2

> Remplace `LE_MDP` par ton mot de passe elastic. Toutes les commandes se lancent sur
> elastic-1 (ou depuis le bastion en remplaçant localhost par 10.10.99.11 — en http pour
> l'instant, le TLS arrive au chapitre 3).

## 1. Les 5 entrées (exemple)

```bash
for i in 1 2 3 4 5; do
  case $i in
    1) J='{"date":"2026-07-06T09:00:00","machine":"elastic-1","evenement":"installation elasticsearch"}' ;;
    2) J='{"date":"2026-07-06T14:30:00","machine":"dns-proxy","evenement":"rotation des logs nginx"}' ;;
    3) J='{"date":"2026-07-07T08:15:00","machine":"bastion","evenement":"connexion ssh admin"}' ;;
    4) J='{"date":"2026-07-07T10:00:00","machine":"kibana-logstash","evenement":"preparation logstash"}' ;;
    5) J='{"date":"2026-07-07T11:45:00","machine":"elastic-1","evenement":"tp chapitre 2 termine"}' ;;
  esac
  curl -s -u elastic:LE_MDP -X POST "http://localhost:9200/journal/_doc" \
    -H 'Content-Type: application/json' -d "$J"
  echo
done
```

## 2. Plein texte

```bash
curl -s -u elastic:LE_MDP "http://localhost:9200/journal/_search?q=evenement:logs&pretty"
```

**Attendu** : `total.value: 1` (la rotation des logs nginx).

## 3. Par date (range)

```bash
curl -s -u elastic:LE_MDP "http://localhost:9200/journal/_search?pretty" \
  -H 'Content-Type: application/json' \
  -d '{ "query": { "range": { "date": { "gte": "2026-07-07T00:00:00" } } } }'
```

**Attendu** : `total.value: 3` (les entrées du 7).

## 4. Compter

```bash
curl -s -u elastic:LE_MDP "http://localhost:9200/journal/_count?pretty"
```

**Attendu** : `"count" : 5` (+2 si tu as gardé les documents de la démo — c'est bien
aussi : tu sais l'expliquer).

## 5. Bonus vault

```bash
cd cours-1-ansible/ansible
ansible-vault edit inventory/group_vars/lab/vault.yml
# ajouter : vault_elastic_password: "LE_MDP"
ansible-vault view inventory/group_vars/lab/vault.yml | grep -c vault_elastic_password  # → 1
```
