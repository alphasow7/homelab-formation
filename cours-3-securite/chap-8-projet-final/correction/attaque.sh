#!/bin/bash
# CORRECTION — Projet final cours 3 (et de la formation) : la boucle complète.
# Joue attaque -> vérif détection -> (tu poses la règle) -> 2e passe.
# Prérequis : nmap installé sur CE poste (brew install nmap / apt install nmap).
# Adapte les variables ci-dessous à TON lab.
set -euo pipefail

IP_WAN_OPNSENSE="192.168.1.36"          # <-- l'IP WAN de TON OPNsense (DHCP box)
ES_HOST="https://10.10.99.11:9200"      # elastic-1 : l'API Elasticsearch (SIEM cours 2)
ES_CA="/etc/elasticsearch/certs/http_ca.crt"   # CA du cluster, sur l'hôte où tu lances la requête
ES_USER="elastic"                       # user ES ; le mot de passe est demandé au clavier
SYSLOG_HOST="OPNsense.internal"         # champ hostname des docs OPNsense dans Kibana

# --- Un scan qui exige root ; fallback sans privilège ---------------------------
# -sS (SYN scan) nécessite root ; sinon nmap bascule en -sT (connect scan).
if [ "$(id -u)" -eq 0 ]; then SCAN="-sS"; else echo "[i] pas root -> -sT"; SCAN="-sT"; fi

# --- Petite fonction : chercher l'alerte de scan dans Elasticsearch --------------
# ⚠️ OÙ LANCER CETTE VÉRIF : depuis kibana-logstash (10.10.99.14). Après le
# durcissement du chapitre 4, le 9200 d'elastic-1 n'accepte QUE Logstash — et ton
# poste (192.168.1.x) ne route même pas vers le segment 10.10.99.x. La vérif du
# projet se fait dans Kibana (Discover, index logstash-syslog-*) ; ce curl est le
# même contrôle en ligne de commande, à lancer depuis kibana-logstash.
chercher_alerte() {   # $1 = libellé de la passe
  echo "== [$1] recherche de l'alerte scan dans le SIEM =="
  curl -s --cacert "$ES_CA" -u "$ES_USER" \
    "$ES_HOST/logstash-syslog-*/_search?pretty" \
    -H 'Content-Type: application/json' \
    -d "{\"query\":{\"bool\":{\"must\":[
           {\"match\":{\"syslog_hostname\":\"$SYSLOG_HOST\"}},
           {\"match\":{\"message\":\"SCAN\"}}
         ]}},\"size\":3,\"sort\":[{\"@timestamp\":\"desc\"}]}"
  # Attendu : hits.total.value > 0 ; regarde src_ip (ton poste), signature, @timestamp.
}

# --- ÉTAPE 1 : la reconnaissance (l'attaque) ------------------------------------
echo "== ATTAQUE 1 — $(date) =="        # note l'heure : clé pour retrouver l'alerte
sudo nmap $SCAN -p- "$IP_WAN_OPNSENSE"  # scan complet ; attendu : ports 'filtered'

# --- ÉTAPE 3 : détection + observation (1re passe) ------------------------------
echo "[i] laisse ~1 min aux logs pour remonter (syslog -> Logstash 5514 -> ES)"
chercher_alerte "avant blocage"

# --- ÉTAPE 4 : la réaction (À FAIRE DANS LE GUI OPNsense, puis reviens) ----------
echo "== RÉACTION — pose ta règle de blocage puis appuie sur Entrée =="
echo "   Voie A (IPS)      : Intrusion Detection > IPS mode ON + action Drop sur la catégorie scan"
echo "   Voie B (firewall) : Firewall > Rules > WAN > Block, source = l'IP de ce poste"
read -r _

# --- ÉTAPE 5 : la preuve (2e passe) ---------------------------------------------
echo "== ATTAQUE 2 — $(date) =="        # le scan doit être bloqué plus tôt / IP blacklistée
sudo nmap $SCAN -p- "$IP_WAN_OPNSENSE"
chercher_alerte "apres blocage"         # IPS -> action 'drop' ; firewall -> IP droppée en amont

echo "== Boucle complète : attaque -> defense -> detection -> observation -> reaction =="
