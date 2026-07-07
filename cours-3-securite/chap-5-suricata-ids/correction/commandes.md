# Correction TP chapitre 5 — Suricata IDS

Étapes complètes. Adapte l'IP WAN d'OPNsense (`192.168.1.36`), le relais syslog
(`192.168.1.200:514`) et le hostname (`OPNsense.internal`) à ton lab.

## 1. Ajouter un ruleset abuse.ch (GUI OPNsense)

```
Services > Intrusion Detection > Download
  [x] abuse.ch/URLhaus      (ou un autre abuse.ch que tu n'avais pas)
  -> Download & Update
```

## 2. Vérifier l'EFFET sur la console (SSH, shell tcsh -> sh -c)

```sh
# Suricata tourne ?
configctl ids status
# -> Suricata (pid ...) is running.

# Combien de règles RÉELLEMENT chargées ? (doit avoir augmenté)
sh -c "wc -l /usr/local/etc/suricata/rules/*.rules | tail -1"
# -> plusieurs dizaines de milliers de lignes
```

### Si le compte est à 0 (la panne du chapitre)

Le "Apply" du GUI n'a pas d'équivalent auto en console : il faut le template reload AVANT
l'update, sinon `rule-updater.config` reste vide et l'update ne fait rien malgré son "OK".

```sh
configctl template reload OPNsense/IDS   # = le Apply CLI ; remplit rule-updater.config
configctl ids update                     # télécharge + charge (a enfin la liste)
configctl ids start
sh -c "wc -l /usr/local/etc/suricata/rules/*.rules | tail -1"   # -> > 0 ✅
```

## 3. Déclencher l'alerte de test (depuis le POSTE)

```bash
sudo nmap -sS -T4 -p 1-1000 192.168.1.36    # IP WAN d'OPNsense
```

## 4. Retrouver l'alerte

### Dans OPNsense (GUI)

```
Services > Intrusion Detection > Alerts
```
Attendu : ligne(s) type `ET SCAN ...`, src = ton poste, dst = le WAN.

### Dans Kibana

```
Discover -> index "logstash-syslog-*" -> KQL :
  syslog_hostname : "OPNsense.internal" and message : "SCAN"
```
Attendu : les alertes Suricata, avec leur signature, timestamp récent.

### Variante — vérifier directement dans Elasticsearch (curl --cacert)

```bash
curl --cacert /etc/elasticsearch/certs/http_ca.crt \
  -u elastic:LE_MDP \
  "https://10.10.20.14:9200/logstash-syslog-*/_search?pretty" \
  -H 'Content-Type: application/json' \
  -d '{"query":{"bool":{"must":[
         {"match":{"syslog_hostname":"OPNsense.internal"}},
         {"match":{"message":"SCAN"}}
       ]}}, "size":3, "sort":[{"@timestamp":"desc"}]}'
# Attendu : hits.total.value > 0, documents Suricata frais.
```

## Diagnostic si rien n'arrive dans Kibana

1. L'onglet **Alerts** d'OPNsense montre-t-il l'alerte ? 
   - **Non** → problème Suricata (règles chargées ? scan bien dirigé vers le WAN ?).
   - **Oui, mais rien dans Kibana** → problème de **transport syslog** :
     `System > Settings > Logging` (destination = relais/Logstash), puis côté console
     `configctl syslog restart`. C'est le chaînon export du cours 2, chap 7.

## Leçon à retenir

Un "OK" n'est pas une preuve. Vérifie l'**effet** : compte les règles chargées et
déclenche une alerte de test. `template reload` **AVANT** `update`. Cousin de "l'import
Kibana qui réussit sans rien faire" (cours 2 chap 5) et de "Apply GUI ≠ CLI".
