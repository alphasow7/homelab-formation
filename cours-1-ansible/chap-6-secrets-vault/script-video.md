# Chapitre 6 — Les secrets avec ansible-vault : script vidéo

> Durée cible : ~27 min. Prérequis élève : chapitre 5 fait (le
> `group_vars/lab.yml` existe, `site.yml --limit dns-proxy` tourne, la page de
> statut répond). Toutes les commandes montrées sont dans `demo.sh` et doivent
> être rejouées sur le lab avant tournage. Les fichiers vedettes :
> `inventory/group_vars/lab/{vars.yml,vault.yml}` et `.vault_pass`.

---

## 1. Le concept (≤ 5 min)

**À l'écran :** un terminal, et un schéma simple : `repo Git` → deux fichiers,
`vars.yml` (en clair) et `vault.yml` (cadenas), plus une clé `.vault_pass`
DEHORS du rectangle « repo ».

**Le message d'ouverture :** « Un secret dans Git, c'est public pour toujours. »

- Même si tu le **supprimes** au commit suivant, l'historique n'oublie rien.
  Démonstration mentale : tu commits un mot de passe, tu paniques, tu le
  retires, tu re-commits. Un attaquant clone le repo, tape `git log -p`…
  et le mot de passe est là, noir sur blanc, dans le diff du premier commit.
  Supprimer un fichier de Git, ce n'est pas l'effacer : c'est ajouter une
  page « supprimé » à un livre dont toutes les pages précédentes restent
  lisibles.
- La réponse d'Ansible : **ansible-vault**. C'est le fichier chiffré **DANS**
  le repo. Le contrat est simple :
  - le fichier **chiffré** se pousse (Git le versionne comme n'importe quoi) ;
  - la **clé** (`.vault_pass`) ne se pousse **JAMAIS** — elle vit sur ton
    poste, et uniquement là.
- La convention pro (celle du repo réel du homelab) : deux fichiers par
  groupe :
  - `vars.yml` — lisible, il **référence** les secrets :
    `web_status_users_password: "{{ vault_web_status_password }}"` ;
  - `vault.yml` — chiffré, il ne contient **QUE** des variables préfixées
    `vault_*`.

  **Pourquoi ce détour ?** Parce qu'en lisant `vars.yml` en clair, on voit
  QUELLES variables existent (donc quels secrets le projet utilise) sans
  jamais voir leurs valeurs. `grep web_status_users_password` fonctionne ;
  le mot de passe, lui, reste dans le coffre.

## 2. Démo guidée (12 min)

> Toutes les commandes sont dans `demo.sh`, rejouées sur le lab
> (dns-proxy 10.10.99.12 via le bastion).

1. **Migration de group_vars.** On part du `lab.yml` du chapitre 5 et on le
   transforme en dossier : `inventory/group_vars/lab/` avec `vars.yml` et
   `vault.yml`. Ansible lit indifféremment `lab.yml` ou `lab/*.yml` — le
   dossier nous permet d'avoir deux fichiers, un lisible et un chiffré.
   - `cp vault.yml.example` → `vault.yml` (le `.example` est le modèle
     versionné ; le vrai `vault.yml` est dans `.gitignore`).
   - Montrer `vars.yml` : la nouvelle ligne
     `web_status_users_password: "{{ vault_web_status_password }}"`.
2. **Chiffrement.**
   - `ansible-vault encrypt inventory/group_vars/lab/vault.yml` — saisir la
     passphrase deux fois.
   - `cat vault.yml` : à l'écran, du charabia qui commence par
     `$ANSIBLE_VAULT;1.1;AES256`. « Voilà ce que Git verra. »
   - `ansible-vault view vault.yml` : le clair revient (avec la passphrase).
   - `ansible-vault edit vault.yml` : édition à chaud, re-chiffré à la
     sortie.
3. **Ne plus taper la passphrase : `.vault_pass`.**
   - `echo 'ma-passphrase-de-demo' > .vault_pass && chmod 600 .vault_pass`
     « La clé du coffre. Elle vit sur ton poste, en 600, et c'est la SEULE
     chose qui ne partira jamais dans Git. »
   - L'enregistrer dans `ansible.cfg`, en direct. **À dire :** « Le réflexe,
     c'est `echo 'vault_password_file = .vault_pass' >> ansible.cfg`. Mais
     attention au piège : `>>` ajoute EN FIN de fichier, et notre
     `ansible.cfg` finit par la section `[ssh_connection]` — la ligne y
     serait ignorée. Elle doit vivre sous `[defaults]`. » Montrer alors
     l'insertion au bon endroit (la commande `sed` exacte est dans
     `demo.sh` ; à l'écran, ouvrir le fichier suffit), puis
     `grep -A1 '^\[defaults\]' ansible.cfg` pour prouver le placement.
   - La preuve : `ansible-vault view vault.yml` ne demande plus rien.
4. **PROUVER que Git ignore les fichiers sensibles.**
   - `git check-ignore -v .vault_pass` → la règle du `.gitignore` s'affiche.
   - `git check-ignore -v inventory/group_vars/lab/vault.yml` → idem.
   - « Si ces deux commandes ne répondent rien, ARRÊTE-TOI : tu es à un
     `git add .` de publier ta clé. »
5. **Déploiement.**
   - `ansible-playbook playbooks/site.yml --limit dns-proxy`
   - `ssh alpha@IP_DE_TON_BASTION "curl -s -o /dev/null -w '%{http_code}\n' http://10.10.99.12/"`
     → **401** : la page demande maintenant un mot de passe.
   - `ssh alpha@IP_DE_TON_BASTION "curl -s -u admin:change-moi-Formation2026 http://10.10.99.12/"`
     → **200**, la page de statut s'affiche.
   - Faire remarquer le `no_log: true` de la task htpasswd : même en `-vvv`,
     le mot de passe n'apparaît pas dans la sortie d'Ansible.

## 3. Encart vrai matériel (2 min)

**Quoi filmer :** le repo réel du homelab, ouvrir le `vault.yml` chiffré
(`inventory/group_vars/.../vault.yml`). Plein écran sur les lignes
`$ANSIBLE_VAULT;1.1;AES256` suivies des blocs hexadécimaux.

**Phrase clé :** « Ce repo est cloné sur GitHub et GitLab. Voilà TOUT ce
qu'un attaquant qui le clone verra. Sans la clé — qui n'a jamais quitté mon
poste — ces lignes ne valent rien. »

## 4. 💥 La panne du vrai monde (6 min)

**D'abord, une précision qui évite 90 % de la confusion :** il existe DEUX
« Vault », et ce sont des homonymes.
- **ansible-vault** : ce qu'on vient d'apprendre — un *fichier* chiffré dans
  le repo.
- **HashiCorp Vault** : un *serveur* de secrets, un service qui tourne et
  distribue les secrets à la demande. On le verra au cours 3.

La panne concerne le second — mais la morale s'applique aux deux.

**Le récit (véridique, sur l'infra de cette formation) :**
- Un serveur HashiCorp Vault avait été installé et **initialisé** des
  semaines plus tôt. À l'initialisation, Vault génère des **clés d'unseal**
  (de descellement) : sans elles, le coffre est physiquement inouvrable —
  c'est le principe même du produit.
- **Symptôme :** des semaines après, on veut s'en servir. Le coffre est
  scellé (`sealed: true`). Normal, il se scelle à chaque redémarrage.
- **Diagnostic guidé :** « OK, il faut les clés d'unseal. Elles sont où ?
  Dans le repo ? Non. Dans un gestionnaire de mots de passe ? Non. Sur la
  VM ? Non. » Elles avaient été affichées **une fois** dans un terminal…
  qui a été fermé.
- **Verdict :** coffre définitivement inouvrable. **Fix :** réinitialisation
  complète du serveur. Par chance, il était encore vide — trois semaines plus
  tard, ç'aurait été la perte de tous les secrets de l'infra.
- **Depuis :** la clé est chiffrée dans l'ansible-vault du repo, dans la
  **même minute** que sa génération.

**La morale, à faire répéter :** « Un secret qui n'existe que dans un
terminal fermé N'EXISTE PAS. Le réflexe : **généré → chiffré → versionné**,
dans la même minute. »

## 5. Annonce du TP

« À toi : tu vas changer le mot de passe de la page — sans jamais le voir
passer en clair dans Git — redéployer, et PROUVER deux choses : que l'ancien
mot de passe ne marche plus, et que ton repo est propre (`git log` ne montre
rien, `git check-ignore` répond). 20 minutes, tout est dans tp.md. »
