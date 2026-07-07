#!/bin/sh
# Chapitre 3 — LAN, WAN & premières règles
#
# ATTENTION : ce chapitre se configure à 90 % dans la CONSOLE et le GUI d'OPNsense,
# PAS dans un shell classique. Ce fichier réunit :
#   - les commandes de DIAGNOSTIC à taper dans le shell OPNsense (option 8 de la console) ;
#   - les étapes GUI / console interactive, en COMMENTAIRES (elles n'ont pas d'équivalent
#     shell « rejouable » — c'est de la manip d'écran).
#
# Le shell root d'OPNsense est tcsh : pas de `2>/dev/null`. Si besoin : sh -c "..."

# ---------------------------------------------------------------------------
# 2.1  Assigner les interfaces  (CONSOLE OPNsense, menu au boot)
# ---------------------------------------------------------------------------
#   Option 1) Assign interfaces
#     - WAN  -> vtnet0   (NIC côté box / Internet)
#     - LAN  -> vtnet1   (NIC sur le bridge isolé, côté lab)
#
# Vérifier que les deux cartes sont montées :
ifconfig vtnet0        # WAN  — doit avoir une IP en 192.168.1.x (DHCP box)
ifconfig vtnet1        # LAN  — 192.168.99.1 une fois l'IP posée (2.2)
# ifconfig              # (vue complète de toutes les interfaces)

# ---------------------------------------------------------------------------
# 2.2  Donner au LAN une adresse sur un réseau À SOI  (CONSOLE, option 2)
# ---------------------------------------------------------------------------
#   Option 2) Set interface IP address  ->  choisir LAN
#     - IPv4 : statique
#     - IP   : 192.168.99.1
#     - masque : 24
#     - DHCP serveur sur le LAN : oui
#
#   /!\ OPNsense propose 192.168.1.1 par défaut : NE PAS le garder (voir la panne §3).
#       On prend 192.168.99.0/24, un réseau utilisé nulle part ailleurs.
#
# Vérifier la table de routage : deux réseaux DISTINCTS + une seule route par défaut
netstat -rn
#   Attendu :
#     default            192.168.1.1        ... vtnet0   (WAN, vers la box)
#     192.168.1.0/24     link#...           ... vtnet0   (WAN)
#     192.168.99.0/24    link#...           ... vtnet1   (LAN)

# ---------------------------------------------------------------------------
# 2.3  Une machine du LAN sort sur Internet via le NAT PAR DÉFAUT
# ---------------------------------------------------------------------------
# Depuis OPNsense (ou une VM du LAN) — le NAT LAN->WAN est automatique, rien à ouvrir :
ping -c 3 8.8.8.8
#   Attendu : 3 réponses. Le LAN emprunte l'adresse du WAN pour sortir.

# ---------------------------------------------------------------------------
# 2.4  Première règle explicite  (GUI : Firewall > Rules > LAN > Add)
# ---------------------------------------------------------------------------
#   Action       : Pass
#   Interface    : LAN     |  Direction : in
#   Source       : LAN net
#   Destination  : 10.10.99.14      Port : 5601 (Kibana)
#   Description  : LAN -> Kibana
#   -> puis APPLY CHANGES (rien n'est actif sans Apply).
#
# Test depuis une VM du LAN :  https://10.10.99.14:5601  -> Kibana répond.

# ---------------------------------------------------------------------------
# 3.  PANNE — conflit de subnet LAN = 192.168.1.1 = box  (à rejouer puis corriger)
# ---------------------------------------------------------------------------
#   Rejouer : CONSOLE option 2 -> LAN -> IP 192.168.1.1 / masque 24
#   Constater le réseau cassé, puis DIAGNOSTIQUER :
netstat -rn
#   Symptôme : 192.168.1.0/24 apparaît EN DOUBLE (WAN + LAN), route default ambiguë
#              -> OPNsense ne sait plus par quelle interface envoyer les paquets.
#
#   FIX : remettre le LAN sur un réseau dédié (CONSOLE option 2 -> LAN -> 192.168.99.1/24)
configctl interface reconfigure lan
netstat -rn                 # le doublon a disparu, deux lignes distinctes
ping -c 3 8.8.8.8           # Internet revient
#   GUI de nouveau joignable :  https://192.168.99.1
