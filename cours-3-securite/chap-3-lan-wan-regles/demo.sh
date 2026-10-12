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
# 2.2 bis  Un CLIENT du LAN pour tester : la VM lan-test  (SUR LE NŒUD PROXMOX, root)
# ---------------------------------------------------------------------------
# Aucune de tes VMs ne vit derrière OPNsense : on en clone une petite, depuis le
# template doré, sur vmbr5. Elle joue « le poste de bureau derrière le pare-feu ».
#   qm clone 9000 9205 --name lan-test
#   qm set 9205 --memory 512 --net0 virtio,bridge=vmbr5 \
#     --ipconfig0 ip=192.168.99.10/24,gw=192.168.99.1 --nameserver 192.168.99.1
#   qm start 9205
# Le nœud la joint directement (il est sur vmbr5, et sa clé est dans le trousseau) :
#   ssh alpha@192.168.99.10 hostname        # attendu : lan-test
#
# Et pour que ce LAN atteigne le segment ELK (10.10.99.0/24), qui vit DERRIÈRE le
# nœud et non derrière la box, deux choses, une fois pour toutes :
#   a) le nœud route entre ses bridges, de façon PERSISTANTE (cours 0 chap. 4, en dur) :
#        echo 'net.ipv4.ip_forward = 1' > /etc/sysctl.d/99-lab-routeur.conf
#        sysctl --system | grep ip_forward
#   b) OPNsense connaît la route (GUI, par le tunnel) :
#        System > Gateways > Configuration > Add : nom NOEUD, interface WAN,
#          IP = l'IP du nœud côté WAN (chemin B 192.168.1.240 ; chemin A 10.0.2.15)
#        System > Routes > Configuration > Add : réseau 10.10.99.0/24, passerelle NOEUD
#      Vérif, shell OPNsense :  netstat -rn | grep 10.10.99

# ---------------------------------------------------------------------------
# 2.3  Une machine du LAN sort sur Internet via le NAT PAR DÉFAUT
# ---------------------------------------------------------------------------
# Depuis lan-test (ssh alpha@192.168.99.10, depuis le nœud) — le NAT LAN->WAN est
# automatique, rien à ouvrir :
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
# Test depuis lan-test (ssh alpha@192.168.99.10) :
#   curl -k -o /dev/null -s -w '%{http_code}\n' https://10.10.99.14:5601   -> 200/302 : Kibana répond.

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
