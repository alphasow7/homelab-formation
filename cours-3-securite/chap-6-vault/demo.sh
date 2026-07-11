#!/bin/bash
# Chapitre 6 — HashiCorp Vault : déploiement, init/unseal, KV, PKI
set -euo pipefail

########## POSTE (contrôleur Ansible) ##########
cd "$(dirname "$0")/../../cours-1-ansible/ansible"

# 0. Recopier le rôle + les playbooks de référence dans TON arbre (une fois)
cp -r ../../cours-3-securite/ansible-extraits/roles/vault roles/
cp ../../cours-3-securite/ansible-extraits/playbooks/vault.yml playbooks/
cp ../../cours-3-securite/ansible-extraits/playbooks/vault-unseal.yml playbooks/

# 1. Déclarer le groupe `vault` dans l'inventaire YAML → la VM dns-proxy
#    (édite inventory/hosts.yml, sous all: children: — dns-proxy est déjà dans `lab`) :
#      vault:
#        hosts:
#          dns-proxy:

########## NŒUD PROXMOX (root) — masquerade ON (apt HashiCorp) ##########
# iptables -t nat -A POSTROUTING -s 10.10.99.0/24 -o vmbr0 -j MASQUERADE

########## POSTE ##########
ansible-playbook playbooks/vault.yml

########## NŒUD PROXMOX — masquerade OFF ##########
# iptables -t nat -D POSTROUTING -s 10.10.99.0/24 -o vmbr0 -j MASQUERADE

########## VM VAULT (ssh via bastion) — init & unseal ##########
# VAULT_ADDR est déjà exporté (/etc/profile.d/vault.sh)

# 2. INITIALISER le coffre — shamir 1 clé sur 1 (lab)
# vault operator init -key-shares=1 -key-threshold=1
#
#   ┌──────────────────────────────────────────────────────────────┐
#   │  >>> NOTE LES CLÉS MAINTENANT <<<                              │
#   │  Recopie "Unseal Key 1"  ET  "Initial Root Token".            │
#   │  Elles ne s'afficheront JAMAIS une deuxième fois.             │
#   │  Sans elles : coffre inouvrable = presse-papier.              │
#   └──────────────────────────────────────────────────────────────┘

# 3. DESCELLER (le coffre démarre scellé)
# vault operator unseal <UNSEAL_KEY_1>
#   → attendu : "Sealed  false"

# 4. Se connecter avec le root token
# vault login <ROOT_TOKEN>

# 5. Activer un moteur KV v2 et écrire/lire un secret
# vault secrets enable -path=secret kv-v2       # (souvent déjà activé)
# vault kv put secret/lab/demo password=s3cr3t-du-lab
# vault kv get secret/lab/demo                  # attendu : le password

# 6. Activer le moteur PKI (Vault devient une autorité de certification)
# vault secrets enable pki
# vault secrets tune -max-lease-ttl=8760h pki
# vault write pki/root/generate/internal common_name="lab" ttl=8760h
#   → attendu : un certificat racine (Vault peut désormais émettre des certs)

########## POSTE — descellage automatisé (après un reboot de la VM) ##########
# Range d'abord la clé dans l'ansible-vault (vault_unseal_key), puis :
# ansible-playbook playbooks/vault-unseal.yml
#   → attendu : "sealed=false"
