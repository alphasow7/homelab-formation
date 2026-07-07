#!/bin/bash
# Chapitre 7 — Rotation & hygiène : changer le mot de passe root OPNsense (qui PERSISTE),
#              le ranger dans l'ansible-vault, importer la CA interne dans le trousseau.
# Aucun rôle Ansible ici : que des gestes d'hygiène.
set -euo pipefail

########## CONSOLE OPNSENSE (root) — changer le mot de passe PROPREMENT ##########
# Deux chemins possibles. Les DEUX passent par le système de config (write_config)
# pour que le changement PERSISTE au reboot (écho chap 2 : un changement mal fait,
# édité à la main dans config.xml, est écrasé au boot depuis le cache mémoire).
#
# --- Chemin A (le plus simple) : le GUI ---
#   System ▸ Access ▸ Users ▸ éditer "root" ▸ nouveau mot de passe fort ▸ Save
#   Le "Save" du GUI appelle write_config() : c'est écrit sur disque, ça persiste.
#
# --- Chemin B : la console série (pas de GUI dispo) ---
#   Le shell root OPNsense est tcsh : pas de "2>/dev/null" → tout envelopper dans sh -c.
#   On écrit un petit script PHP qui change le hash via l'API de config, puis
#   write_config() grave le tout sur disque :
#
#   sh -c "cat > /tmp/rootpw.php" <<'PHP'
#   <?php
#   require_once("config.inc");
#   require_once("util.inc");
#   $new = "REMPLACE-PAR-UN-MDP-FORT";
#   foreach ($config['system']['user'] as $i => $u) {
#       if ($u['name'] === 'root') {
#           local_user_set_password($config['system']['user'][$i], $new);
#           local_user_set($config['system']['user'][$i]);
#       }
#   }
#   write_config("rotation mot de passe root");   # <-- LA ligne qui fait persister
#   echo "OK\n";
#   PHP
#   php /tmp/rootpw.php        # attendu : OK
#   rm /tmp/rootpw.php

########## CONSOLE PROXMOX — le reboot-test (la preuve que ça persiste) ##########
# qm reboot 600                # ~90 s
#   → se reconnecter : l'ancien "opnsense" ne marche PLUS, le nouveau OUI.
#   → si l'ancien marchait encore, le changement n'avait pas persisté (write_config oublié).

########## POSTE (contrôleur Ansible) — ranger le secret dans le trousseau ##########
cd "$(dirname "$0")/../../cours-1-ansible/ansible"

# Éditer (ou créer) le vault chiffré du groupe opnsense et y ajouter la variable.
# ansible-vault edit inventory/group_vars/opnsense/vault.yml
#   à l'intérieur :
#     vault_opnsense_root_password: "LE-NOUVEAU-MDP-FORT"
#   même convention que vault_elastic_password / vault_pbs_root_password (préfixe vault_).
#
# Vérifier (sans le mettre en clair ailleurs) :
# ansible-vault view inventory/group_vars/opnsense/vault.yml | grep vault_opnsense_root_password

########## POSTE — récupérer la CA interne (celle du cours 2) ##########
# La CA qui signe les certs ELK vit sur le nœud Elasticsearch :
# scp root@elastic-1:/etc/elasticsearch/certs/ca/ca.crt ~/homelab-ca.crt
#
# Vérifier qu'on tient bien un certificat de CA :
# openssl x509 -in ~/homelab-ca.crt -noout -subject -issuer
#   → subject == issuer (auto-signée = c'est bien une racine)

########## NAVIGATEUR — importer la CA dans le trousseau ##########
# --- Firefox (trousseau intégré au navigateur) ---
#   Paramètres ▸ Vie privée & sécurité ▸ Certificats ▸ Voir les certificats
#     ▸ onglet "Autorités" ▸ Importer ▸ ~/homelab-ca.crt
#     ▸ cocher "Confirmer cette AC pour identifier des sites web"
#
# --- macOS (trousseau système, utilisé par Chrome/Safari) ---
#   sudo security add-trusted-cert -d -r trustRoot \
#     -k /Library/Keychains/System.keychain ~/homelab-ca.crt
#
# --- Linux (Debian/Ubuntu, trousseau système) ---
#   sudo cp ~/homelab-ca.crt /usr/local/share/ca-certificates/homelab-ca.crt
#   sudo update-ca-certificates
#
# --- Windows ---
#   certutil -addstore -f "Root" homelab-ca.crt   # (PowerShell/cmd admin)

########## NAVIGATEUR — vérifier que ça passe au vert ##########
# Rafraîchir un service interne (redémarrer le navigateur si Firefox) :
#   https://localhost:5601   (Kibana, tunnel ssh)   → cadenas VERT, plus d'avertissement
#   https://10.10.30.12:8200 (Vault)                → cadenas VERT
#   https://localhost:8443   (OPNsense, tunnel ssh) → cadenas VERT
# Un seul import = confiance à TOUS les services signés par cette CA.
