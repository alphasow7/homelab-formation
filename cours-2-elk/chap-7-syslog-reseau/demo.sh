#!/bin/bash
# Chapitre 7 — Syslog réseau : brancher ce qui n'a pas d'agent
# On configure rsyslog À LA MAIN (pas de rôle Ansible) pour forwarder le syslog du
# NŒUD PROXMOX vers l'input syslog de Logstash (tcp/udp 5514, en place depuis le chap 4).
set -euo pipefail

########## SUR LE NŒUD PROXMOX (root) ##########
# Le nœud a une patte dans notre segment (bridge vmbr1 = 10.10.99.254), il joint donc
# directement kibana-logstash (10.10.99.14) sans routage.

# 1. Déclarer le forward syslog. UNE seule ligne suffit.
#    *.*  = toutes les catégories (auth, kern, daemon…), tous les niveaux.
#    @    = UDP  (une seule arobase)  <-- "envoie et oublie", le syslog historique
#    @@   = TCP  (double arobase)     <-- fiable, accusé de réception (non utilisé ici)
#    Notre input Logstash écoute les DEUX. On prend UDP (@), le plus simple/répandu.
cat > /etc/rsyslog.d/90-forward-elk.conf <<'EOF'
*.* @10.10.99.14:5514
EOF

# 2. Recharger rsyslog pour prendre la conf.
systemctl restart rsyslog

# 3. Fabriquer une ligne de log de test, avec un tag UNIQUE pour la retrouver.
#    -p auth.warning = catégorie "auth", niveau "warning" (comme une vraie ligne sécurité).
logger -p auth.warning "TEST-SYSLOG-depuis-proxmox"

# (Astuce diagnostic — À FAIRE SUR kibana-logstash, PAS ici — vérifier que Logstash
#  écoute bien le 5514 en tcp ET udp. On doit voir deux lignes.)
# ss -tulnp | grep 5514


########## DEPUIS LE POSTE / DANS KIBANA ##########
# Kibana → Discover → vue d'index "logstash-*" → requête KQL :
#
#     message : "TEST-SYSLOG-depuis-proxmox"
#
# Attendu : 1 document, champ "host" = le nœud Proxmox, timestamp de tout à l'heure.
# Les logs de l'HYPERVISEUR arrivent maintenant dans le SIEM — sans aucun agent.
