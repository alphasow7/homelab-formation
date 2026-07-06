#!/usr/bin/env bash
# Chapitre 5 — Les variables : la démo complète (4 étages de précédence + la panne 0.0.0.0).
#
# Tout se lance DEPUIS TON POSTE (le contrôleur Ansible). Les curl et dig passent
# par le bastion, comme d'habitude. Remplace IP_DE_TON_BASTION avant de lancer.
#
# Prérequis : chapitre 4 fait (les rôles dns et web_status existent, bind9 et
# nginx sont déjà installés sur dns-proxy → AUCUN masquerade nécessaire ici,
# rien ne se télécharge).
set -euo pipefail

# On se place dans le dossier ansible/ (là où vit ansible.cfg).
cd "$(dirname "$0")/../ansible"

# ============================================================================
# ÉTAGE 1 — les réglages d'usine : les defaults du rôle
# ============================================================================

# 1. Le réglage d'usine de web_status : la valeur si personne ne dit rien.
cat roles/web_status/defaults/main.yml

# ============================================================================
# ÉTAGE 2 — la politique du groupe : group_vars/lab.yml
# ============================================================================

# 2. Le fichier group_vars du groupe lab (le nom du fichier = le nom du groupe
#    dans hosts.yml — c'est comme ça qu'Ansible fait le lien, tout seul).
cat inventory/group_vars/lab.yml

# 3. On rejoue le rôle : le titre du group_vars écrase le default.
#    Attendu : changed sur la task de la page.
ansible-playbook playbooks/web-status-role.yml

# 4. La preuve (depuis le bastion) :
#    Attendu : "Lab du groupe LAB — géré par Ansible (group_vars)".
#    On a changé la page SANS toucher au rôle : rôle générique, config locale.
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12

# ============================================================================
# ÉTAGE 4 — l'ordre direct : -e écrase TOUT (pour ce run seulement)
# ============================================================================

# 5. Extra var en ligne de commande : gagne sur group_vars ET sur les defaults.
ansible-playbook playbooks/web-status-role.yml -e 'web_status_title="Ordre direct"'

# 6. Attendu : la page dit "Ordre direct".
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12

# 7. Mais le -e n'écrit RIEN dans le repo : un run sans -e, et le group_vars
#    reprend la main. Attendu : le titre "Lab du groupe LAB…" est revenu.
ansible-playbook playbooks/web-status-role.yml
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12

# ============================================================================
# Pas que du cosmétique — dns_forwarders surchargé en group_vars
# ============================================================================

# 8. group_vars/lab.yml donne DEUX forwarders (le default du rôle n'en a qu'un).
#    On rejoue le rôle dns puis on vérifie la config générée sur la VM.
#    Attendu : le bloc forwarders contient 1.1.1.1; ET 8.8.8.8;
ansible-playbook playbooks/dns.yml
ssh -J alpha@IP_DE_TON_BASTION alpha@10.10.99.12 \
  "grep -A3 forwarders /etc/bind/named.conf.options"

# ============================================================================
# 💥 LA PANNE DU VRAI MONDE — la variable 0.0.0.0 qui ment (panne réelle)
# ============================================================================

# --- CASSER --------------------------------------------------------------
# On simule un rôle dont le template lit une variable dns_listen : on bascule
# temporairement le "any" en dur du chapitre 4 sur la variable (sauvegarde .bak),
# puis on pose la valeur piégée dans group_vars.
sed -i.bak 's/listen-on { any; };/listen-on { {{ dns_listen }}; };/' \
  roles/dns/templates/named.conf.options.j2
echo 'dns_listen: "0.0.0.0"' >> inventory/group_vars/lab.yml

# On déploie : Ansible est PARFAITEMENT CONTENT (failed=0, handler passé).
# Le playbook ne teste pas le SENS de ta valeur.
ansible-playbook playbooks/dns.yml

# --- OBSERVER ------------------------------------------------------------
# Le symptôme : le DNS qui répondait il y a deux minutes est muet.
# Attendu : "connection timed out; no servers could be reached".
ssh alpha@IP_DE_TON_BASTION dig @10.10.99.12 elastic-1.lab.local +time=2 +tries=1 || true

# Le diagnostic : sur quoi named écoute-t-il VRAIMENT ?
# Attendu : RIEN sur 10.10.99.12:53 (au mieux 127.0.0.1:53). Pour BIND,
# listen-on { 0.0.0.0; }; est une LISTE D'ADRESSES : il ne matche que
# l'adresse littérale 0.0.0.0 → il n'écoute NULLE PART. La même valeur est
# pourtant correcte pour nginx ou sshd : le sens dépend du logiciel.
ssh -J alpha@IP_DE_TON_BASTION alpha@10.10.99.12 "sudo ss -ulnp | grep 53" || true

# --- RÉPARER -------------------------------------------------------------
# Le fix : la valeur qui a un sens pour BIND, c'est le mot-clé "any".
sed -i.fix 's/^dns_listen: "0.0.0.0"$/dns_listen: "any"/' inventory/group_vars/lab.yml
ansible-playbook playbooks/dns.yml

# Vérification SERVICE (pas juste playbook) : named écoute partout, dig répond.
# Attendu : une ligne 0.0.0.0:53 dans ss (ironie : ss dit "0.0.0.0" pour
# "partout"…) et dig renvoie 10.10.99.11.
ssh -J alpha@IP_DE_TON_BASTION alpha@10.10.99.12 "sudo ss -ulnp | grep 53"
ssh alpha@IP_DE_TON_BASTION dig @10.10.99.12 elastic-1.lab.local +time=2 +tries=1

# Nettoyage : on restaure le template du chapitre 4 et on retire dns_listen
# du group_vars (la simulation est finie).
mv roles/dns/templates/named.conf.options.j2.bak roles/dns/templates/named.conf.options.j2
sed -i.fix '/^dns_listen: "any"$/d' inventory/group_vars/lab.yml
rm -f inventory/group_vars/lab.yml.fix
ansible-playbook playbooks/dns.yml
