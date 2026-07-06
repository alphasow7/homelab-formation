#!/usr/bin/env bash
# Chapitre 6 — Les secrets avec ansible-vault : la démo complète.
#
# Tout se lance DEPUIS TON POSTE (le contrôleur Ansible). Les curl passent par
# le bastion, comme d'habitude. Remplace IP_DE_TON_BASTION avant de lancer.
#
# Prérequis : chapitre 5 fait (group_vars du groupe lab en place, site.yml
# fonctionne). nginx est déjà sur dns-proxy ; apache2-utils s'installe via
# apt interne → si le paquet manque, masquerade temporaire (cf. lab-depart.md).
set -euo pipefail

# On se place dans le dossier ansible/ (là où vit ansible.cfg).
cd "$(dirname "$0")/../ansible"

# ============================================================================
# 1 — Migration group_vars : lab.yml → lab/{vars.yml, vault.yml}
# ============================================================================

# Le dossier lab/ remplace le fichier lab.yml : Ansible charge les deux formes
# tout seul. Ça nous donne DEUX fichiers : vars.yml (lisible) + vault.yml
# (chiffré). Dans ce repo, vars.yml et le modèle vault.yml.example existent
# déjà — il ne reste qu'à créer TON vault.yml à partir du modèle.
cat inventory/group_vars/lab/vars.yml          # lisible : référence {{ vault_* }}
cp inventory/group_vars/lab/vault.yml.example inventory/group_vars/lab/vault.yml
cat inventory/group_vars/lab/vault.yml         # en clair... pour dix secondes

# ============================================================================
# 2 — Chiffrement : le fichier chiffré se pousse, la clé jamais
# ============================================================================

# Saisir la passphrase deux fois. À partir de là, Git ne verra QUE du chiffré.
ansible-vault encrypt inventory/group_vars/lab/vault.yml

# Attendu : $ANSIBLE_VAULT;1.1;AES256 puis des blocs hexadécimaux illisibles.
cat inventory/group_vars/lab/vault.yml

# Le clair revient — avec la passphrase.
ansible-vault view inventory/group_vars/lab/vault.yml

# Édition à chaud : déchiffre dans l'éditeur, re-chiffre à la sortie.
# ansible-vault edit inventory/group_vars/lab/vault.yml

# ============================================================================
# 3 — .vault_pass : ne plus taper la passphrase à chaque run
# ============================================================================

# La clé vit sur TON POSTE, en 600, et JAMAIS dans Git (elle est .gitignore).
echo 'ma-passphrase-de-demo' > .vault_pass
chmod 600 .vault_pass

# On la déclare dans ansible.cfg. Le réflexe serait :
#   echo 'vault_password_file = .vault_pass' >> ansible.cfg
# ⚠️ MAIS le >> ajoute EN FIN de fichier — chez nous la dernière section est
# [ssh_connection], et la ligne y serait ignorée. Elle doit vivre sous
# [defaults] : on l'insère donc juste après ce titre de section.
grep -q '^vault_password_file' ansible.cfg || sed -i.bak '/^\[defaults\]$/a\
vault_password_file = .vault_pass' ansible.cfg
rm -f ansible.cfg.bak
grep -A1 '^\[defaults\]' ansible.cfg

# Preuve que ça marche : plus aucune passphrase demandée.
ansible-vault view inventory/group_vars/lab/vault.yml

# ============================================================================
# 4 — PROUVER que Git ignore les fichiers sensibles
# ============================================================================

# Attendu : chaque commande affiche la règle du .gitignore qui attrape le
# fichier. Si l'une des deux ne répond RIEN : STOP — tu es à un `git add .`
# de publier ta clé.
git check-ignore -v .vault_pass
git check-ignore -v inventory/group_vars/lab/vault.yml

# ============================================================================
# 5 — Déploiement : la page de statut est maintenant protégée
# ============================================================================

# Le rôle web_status installe apache2-utils, génère /etc/nginx/.htpasswd
# (no_log : le mot de passe n'apparaît jamais dans la sortie, même en -vvv)
# et déploie la conf nginx avec auth_basic.
ansible-playbook playbooks/site.yml --limit dns-proxy

# Sans mot de passe : la porte est fermée. Attendu : 401.
ssh alpha@IP_DE_TON_BASTION "curl -s -o /dev/null -w '%{http_code}\n' http://10.10.99.12/"

# Avec le mot de passe du vault : la page s'affiche. Attendu : 200 + le HTML.
ssh alpha@IP_DE_TON_BASTION "curl -s -u admin:change-moi-Formation2026 http://10.10.99.12/"
