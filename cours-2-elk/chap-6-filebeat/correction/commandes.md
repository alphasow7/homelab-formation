# Correction TP chapitre 6

## 1. L'input filestream, en host_vars (pas dans les defaults !)

Fichier `cours-1-ansible/ansible/host_vars/dns-proxy.yml` (créer/compléter) :

```yaml
filebeat_log_inputs:
  - id: nginx-logs
    source: nginx
    paths:
      - /var/log/nginx/*.log
```

Ce qui, une fois rendu par `templates/filebeat.yml.j2`, ajoute ce bloc au
`/etc/filebeat/filebeat.yml` de **dns-proxy seulement** :

```yaml
  - type: filestream
    id: nginx-logs
    paths:
      - /var/log/nginx/*.log
    fields_under_root: true
    fields:
      log_source: nginx
```

L'input `journald` reste en place à côté : on AJOUTE les logs nginx, on ne remplace rien.

## 2. Redéployer + générer du trafic

```bash
# contrôleur
cd cours-1-ansible/ansible
ansible-playbook playbooks/filebeat.yml        # ne change que dns-proxy

# sur dns-proxy (ou depuis le bastion) : écrire dans access.log
for i in $(seq 1 10); do curl -s http://10.10.99.13/ >/dev/null; done
```

## 3. Retrouver les lignes dans Kibana

Kibana → Discover, data view `logstash-*`, fenêtre « Last 15 minutes », barre KQL :

```
log_source : "nginx"
```

→ tes 10 requêtes, avec la ligne d'access log nginx (GET / HTTP/1.1" 200 …).

## Vérif en ligne de commande (facultatif, sur elastic-1)

```bash
curl --cacert /etc/elasticsearch/certs/ca/ca.crt -u elastic:MDP \
  "https://localhost:9200/logstash-*/_count?pretty" \
  -H 'Content-Type: application/json' \
  -d '{"query":{"match":{"log_source":"nginx"}}}'      # count > 0
```

**La leçon (en positif)** : un input filestream ne pose problème que si les fichiers
n'existent pas. Ici ils existent → Filebeat les récolte immédiatement. Et le champ
`log_source` te permet, côté Kibana, de séparer d'un clic les logs applicatifs (nginx) du
bruit système (journald). Un input par machine qui en a besoin — jamais partout par défaut.
