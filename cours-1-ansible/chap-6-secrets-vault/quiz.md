# Quiz — Chapitre 6 : Les secrets avec ansible-vault

> 5 questions, 4 choix, 1 seule bonne réponse. Les explications sont là pour ancrer,
> pas pour piéger.

---

### Question 1 — Tu as commité un mot de passe par erreur, puis tu l'as supprimé au commit suivant et poussé. Le secret est-il en sécurité ?

- A. Oui : le fichier n'existe plus dans le repo, donc le secret non plus
- B. Oui, à condition que le repo soit privé au moment de la suppression
- C. ✅ Non : l'historique Git conserve tous les commits — `git log -p` montre encore le secret dans le diff du premier commit
- D. Non, mais un simple `git commit --amend` suffit à l'effacer partout

**Explication** : supprimer un fichier de Git, c'est ajouter une page « supprimé »
à un livre dont toutes les pages précédentes restent lisibles. Quiconque clone le
repo remonte l'historique et retrouve le secret. Un secret commité doit être
considéré comme compromis : on le RÉVOQUE (on en génère un nouveau), on ne se
contente pas de le supprimer.

---

### Question 2 — Dans la convention pro vue au chapitre, que contient `vault.yml` ?

- A. Toutes les variables du groupe, secrètes ou non, pour tout centraliser
- B. ✅ Uniquement des variables préfixées `vault_*`, chiffrées ; `vars.yml` (lisible) les référence via `{{ vault_... }}`
- C. La passphrase de chiffrement, pour qu'Ansible la retrouve tout seul
- D. Une copie de secours de `vars.yml`, au cas où

**Explication** : le duo `vars.yml` (clair) + `vault.yml` (chiffré, que du
`vault_*`) permet de voir QUELLES variables existent — un `grep` sur le nom
fonctionne — sans jamais voir leurs valeurs. Et surtout : la passphrase ne vit
JAMAIS dans le repo, même chiffrée.

---

### Question 3 — Où doit vivre le fichier `.vault_pass` ?

- A. Dans le repo, chiffré avec ansible-vault pour faire bonne mesure
- B. Dans le repo en clair : sans lui, Ansible ne peut pas déchiffrer
- C. Sur la machine cible (dns-proxy), pour que le playbook le trouve
- D. ✅ Sur le poste du contrôleur uniquement, hors Git (listé dans `.gitignore`), déclaré via `vault_password_file` dans `ansible.cfg`

**Explication** : c'est LE contrat d'ansible-vault : le fichier chiffré se pousse,
la clé ne se pousse jamais. Pousser `.vault_pass` à côté du vault chiffré
reviendrait à scotcher la clé sur le coffre. `git check-ignore -v .vault_pass`
doit toujours répondre.

---

### Question 4 — Quelle est la différence entre ansible-vault et HashiCorp Vault ?

- A. Aucune : HashiCorp Vault est le nouveau nom d'ansible-vault
- B. ansible-vault est la version payante, HashiCorp Vault la version libre
- C. ✅ Ce sont des homonymes : ansible-vault chiffre un FICHIER versionné dans le repo ; HashiCorp Vault est un SERVEUR de secrets qui les distribue à la demande
- D. ansible-vault chiffre les playbooks, HashiCorp Vault chiffre les inventaires

**Explication** : deux outils sans lien, qui partagent juste un nom.
ansible-vault : un fichier chiffré, statique, qui vit dans Git. HashiCorp
Vault : un service qui tourne, avec ses clés d'unseal, ses tokens, ses accès
dynamiques — on le verra au cours 3. La panne du chapitre concernait le second…
et c'est le premier qui l'a résolue.

---

### Question 5 — Tu viens de générer une clé importante dans ton terminal. Quel est LE bon réflexe ?

- A. La noter dans un fichier TODO.txt du repo, en attendant de faire mieux
- B. La laisser affichée dans le terminal : l'historique du shell la garde
- C. La mémoriser : une clé écrite quelque part est une clé compromise
- D. ✅ La chiffrer dans le vault et la versionner immédiatement : généré → chiffré → versionné, dans la même minute

**Explication** : la panne du chapitre — des clés d'unseal affichées une fois
dans un terminal fermé, coffre définitivement inouvrable, réinstallation
complète. « Un secret qui n'existe que dans un terminal fermé N'EXISTE PAS. »
Le TODO.txt en clair est l'erreur inverse — exposer le secret plutôt que le perdre
(même famille que la Q1 : un secret en clair dans le repo). Le seul chemin sûr, et
il prend trente secondes : `ansible-vault edit`, coller, commiter.
