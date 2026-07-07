#!/bin/bash
# Chapitre 5 — Suricata IDS sur OPNsense (WAN, mode détection) + alertes vers ELK
#
# PAS de rôle Ansible : Suricata se pilote dans le GUI OPNsense et sa console.
# Ce fichier est surtout des ÉTAPES GUI en commentaires + les commandes CONSOLE de
# diagnostic. Chaque bloc indique OÙ le jouer : POSTE / CONSOLE OPNSENSE / KIBANA.
#
# Rappel accès :
#   GUI OPNsense  : https://192.168.99.1 (root / mdp changé au 1er login)
#   Console/SSH   : shell root OPNsense = tcsh -> envelopper les redirections dans sh -c "..."
#   WAN OPNsense  : IP DHCP de la box, ex. 192.168.1.36 (adapte partout ci-dessous)

set -euo pipefail   # (n'a d'effet que si tu exécutes vraiment le fichier ; ici c'est un guide)


########## DANS LE GUI OPNSENSE — activer Suricata sur le WAN, en détection ##########
# Services > Intrusion Detection > Administration
#   [x] Enabled
#   Interfaces  : WAN            <-- on surveille ce qui vient du monde
#   IPS mode    : DÉCOCHÉ        <-- mode DÉTECTION (on alerte, on ne bloque pas)
#   Save, puis Apply.
#
# Services > Intrusion Detection > Download
#   Cocher des rulesets :
#     - ET open   : emerging-scan, emerging-exploit, emerging-malware  (familles d'attaques)
#     - abuse.ch  : abuse.ch/SSL Blacklist, abuse.ch/Feodo Tracker     (malwares / C2)
#   Cliquer "Download & Update".


########## SUR LA CONSOLE OPNSENSE (SSH) — vérifier l'ÉTAT et l'EFFET ##########
# 1. Suricata tourne-t-il ?
configctl ids status
#    Attendu : "Suricata (pid ...) is running."

# 2. LA vraie preuve : combien de règles sont RÉELLEMENT chargées ?
#    (tcsh -> on passe par sh -c pour le glob + le pipe)
sh -c "wc -l /usr/local/etc/suricata/rules/*.rules | tail -1"
#    Attendu : des DIZAINES DE MILLIERS de lignes (lab réel : ~69 500 pour 9 rulesets).
#    Si ça affiche 0 -> IDS aveugle -> voir la PANNE plus bas.


########## 💥 PANNE — "update OK" mais 0 règle chargée (l'équivalent du Apply GUI oublié) ##########
# Symptôme : l'update répond OK, Suricata "running", mais 0 règle -> ne détecte RIEN.
# Cause    : en console, le "Apply" du GUI est une commande SÉPARÉE. Sans elle, le fichier
#            rule-updater.config reste VIDE -> update n'a rien à télécharger/charger.
#
#   configctl ids update                                          # -> répond "OK"
#   sh -c "wc -l /usr/local/etc/suricata/rules/*.rules | tail -1" # -> 0   (le "OK" mentait)
#
# FIX : le template reload (= le Apply CLI) AVANT l'update, DANS CET ORDRE :
configctl template reload OPNsense/IDS   # régénère rule-updater.config depuis ta config
configctl ids update                     # MAINTENANT il a la liste -> télécharge + charge
configctl ids start
sh -c "wc -l /usr/local/etc/suricata/rules/*.rules | tail -1"   # -> dizaines de milliers ✅
#
# MORALE : un "OK" n'est pas une preuve. Vérifie l'EFFET (compte les règles, déclenche une
# alerte de test), pas le message de succès. Cousin de "l'import Kibana qui réussit sans
# rien faire" (cours 2 chap 5) et de la règle "Apply GUI ≠ CLI".


########## DEPUIS LE POSTE — déclencher une alerte de test (scan de ports vers le WAN) ##########
# Un scan SYN de 1000 ports : comportement de reconnaissance qu'une signature ET SCAN connaît.
sudo nmap -sS -T4 -p 1-1000 192.168.1.36    # <-- IP WAN d'OPNsense (adapte-la)


########## DANS LE GUI OPNSENSE — voir l'alerte ##########
# Services > Intrusion Detection > Alerts
#   Attendu : ligne(s) type "ET SCAN ...", src = ton poste, dst = le WAN.
#   L'IDS a ALERTÉ (pas bloqué) : c'est bien un IDS.


########## DANS LE GUI OPNSENSE — brancher les alertes vers ELK (input Logstash 5514) ##########
# System > Settings > Logging / targets > Add :
#   Transport    : UDP(4)
#   Applications : (tout, ou cibler suricata)
#   Hostname     : 192.168.1.200:514   <-- relais Proxmox qui pousse vers Logstash 5514
#   Save, Apply.
# (Côté console, si besoin de re-appliquer : configctl syslog restart)


########## DANS KIBANA — retrouver l'alerte dans le SIEM ##########
# Discover -> index "logstash-syslog-*" (ou "logstash-*") -> requête KQL :
#
#     syslog_hostname : "OPNsense.internal" and message : "SCAN"
#
# Attendu : les alertes Suricata, avec leur signature. Détecter ET garder la trace.

# --- Variante : vérifier directement dans Elasticsearch (curl --cacert, TLS du cours 2) ---
# À jouer depuis une machine qui joint ES (ex. le collecteur). Adapte l'URL/CA/index.
#   curl --cacert /etc/elasticsearch/certs/http_ca.crt \
#     -u elastic:LE_MDP \
#     "https://10.10.99.11:9200/logstash-syslog-*/_search?pretty" \
#     -H 'Content-Type: application/json' \
#     -d '{"query":{"bool":{"must":[
#            {"match":{"syslog_hostname":"OPNsense.internal"}},
#            {"match":{"message":"SCAN"}}
#          ]}}, "size":3, "sort":[{"@timestamp":"desc"}]}'
#   Attendu : "hits.total.value" > 0, des documents Suricata frais (@timestamp récent).
