#!/usr/bin/env bash
# Chapitre 7 — site.yml : la démo complète (parc entier + panne du boot).
#
# ATTENTION, trois machines différentes interviennent :
#   - TON POSTE (le contrôleur Ansible)  → ansible-playbook, ssh
#   - LE NŒUD PROXMOX                    → iptables (masquerade), qm reboot
#   - LA VM dns-proxy                    → le diagnostic (ss, systemctl)
# Les blocs sont étiquetés en majuscules : lis AVANT de copier-coller.
#
# Prérequis : chapitres précédents faits (rôles dns et web_status déployés,
# `ansible lab -m ping` → 3 pongs). Remplace IP_DE_TON_BASTION ci-dessous.
set -euo pipefail

# On se place dans le dossier ansible/ (là où vit ansible.cfg).
cd "$(dirname "$0")/../ansible"

# ============================================================================
# BLOC 0 — MASQUERADE ON — À EXÉCUTER SUR LE NŒUD PROXMOX (PAS SUR TON POSTE)
# ============================================================================
# Le segment 10.10.99.0/24 n'a pas d'Internet (voulu), mais apt doit
# télécharger fail2ban. On ouvre la sortie NAT LE TEMPS DU DÉPLOIEMENT.
# Adapter -o vmbr0 si ton interface de sortie a un autre nom (voir `ip route`).
#
#   iptables -t nat -A POSTROUTING -s 10.10.99.0/24 -o vmbr0 -j MASQUERADE

# ============================================================================
# DEPUIS TON POSTE — le playbook maître
# ============================================================================

# 1. Run 1 : TOUT le parc, une commande, chrono en main.
#    Attendu : 2 plays (socle sur les 3 VMs, puis DNS+web sur dns-proxy),
#    du changed partout (fail2ban, motd, sont nouveaux), zéro failed.
time ansible-playbook playbooks/site.yml

# 2. Run 2 : l'idempotence à l'échelle du parc.
#    Attendu : PLAY RECAP → changed=0 sur les 3 machines. Le rejeu complet
#    est un geste sans danger.
ansible-playbook playbooks/site.yml

# 3. La répétition générale : --check ne touche à RIEN, --diff montre tout.
#    On simule un changement de titre de la page de statut via une variable.
#    Attendu : la tâche du template en "changed" (jaune) + le diff -/+ du HTML…
ansible-playbook playbooks/site.yml --check --diff -e web_status_title="Lab v2"
#    …mais la vraie page n'a PAS bougé :
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12

# 4. Le clin d'œil du chapitre 1 : le motd à la connexion.
#    Attendu : la bannière « ⚙️ Machine gérée par Ansible… » s'affiche.
ssh -J alpha@IP_DE_TON_BASTION alpha@10.10.99.11 true

# ============================================================================
# 💥 LA PANNE : le service qui démarre avant le réseau
# ============================================================================

# 5. SUR LE NŒUD PROXMOX — trouver le VMID de dns-proxy, puis rebooter :
#
#   qm list | grep dns-proxy
#   qm reboot <VMID>
#
#    (Attendre ~30 s que la VM revienne.)

# 6. DEPUIS LE BASTION — le symptôme : DNS muet depuis le réseau.
#    Attendu : ";; connection timed out; no servers could be reached".
#    NOTE : la course ne se perd pas à CHAQUE boot — si le dig répond,
#    refaire un qm reboot ou deux. C'est ce qui rend cette panne traître.
ssh alpha@IP_DE_TON_BASTION "dig @10.10.99.12 elastic-1.lab.local +short"

# 7. SUR LA VM dns-proxy — le diagnostic :
#
#   ssh -J alpha@IP_DE_TON_BASTION alpha@10.10.99.12
#   systemctl is-active named        # → active (!!) le service "marche"
#   sudo ss -ulnp | grep 53          # → SEULEMENT 127.0.0.1:53, pas 10.10.99.12:53
#
#    named a démarré avant que la VM ait son IP : il ne s'est attaché
#    qu'à la loopback. Actif, logs propres… et sourd côté réseau.

# 8. LE FIX DURABLE — dans le code, pas sur la VM.
#    Fichier inventory/host_vars/dns-proxy.yml (créé au TP, montré ici) :
#      ---
#      common_network_waits: [named]
#    Le rôle common pose alors le drop-in systemd (After/Wants=network-online).
ansible-playbook playbooks/site.yml --limit dns-proxy

# 9. Vérifier le drop-in, puis re-rebooter et re-tester.
#    SUR LA VM :        systemctl cat named     → l'override.conf apparaît
#    SUR LE NŒUD :      qm reboot <VMID>        (attendre le retour)
#    DEPUIS LE BASTION — attendu : 10.10.99.11, à CHAQUE reboot désormais :
ssh alpha@IP_DE_TON_BASTION "dig @10.10.99.12 elastic-1.lab.local +short"

# ============================================================================
# BLOC FINAL — MASQUERADE OFF — À EXÉCUTER SUR LE NŒUD PROXMOX (PAS SUR TON POSTE)
# ============================================================================
# Un accès temporaire, ÇA SE REFERME. Le segment redevient étanche.
#
#   iptables -t nat -D POSTROUTING -s 10.10.99.0/24 -o vmbr0 -j MASQUERADE
