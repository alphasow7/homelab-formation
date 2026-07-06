# Quiz — Chapitre 5 : Les variables

> 5 questions, 4 choix, 1 seule bonne réponse. Les explications sont là pour ancrer,
> pas pour piéger.

---

### Question 1 — `web_status_title` est défini dans les `defaults/` du rôle ET dans `group_vars/lab.yml`, avec deux valeurs différentes. Laquelle s'applique ?

- A. Celle des defaults du rôle : le rôle est prioritaire sur l'inventaire
- B. ✅ Celle de group_vars : plus spécifique que les defaults, donc plus forte
- C. Aucune : Ansible s'arrête en erreur quand une variable est définie deux fois
- D. Les deux, fusionnées en une liste

**Explication** : « plus c'est spécifique, plus c'est fort ». Les defaults d'un rôle
sont l'étage le plus FAIBLE de l'entonnoir — ils sont faits pour être écrasés.
Définir deux fois une variable n'est pas une erreur : c'est le mécanisme normal de
surcharge.

---

### Question 2 — À quoi servent les `defaults/` d'un rôle ?

- A. À stocker les valeurs obligatoires que personne n'a le droit de modifier
- B. À définir des variables visibles uniquement à l'intérieur des tasks du rôle
- C. ✅ À fournir des « réglages d'usine » qui marchent partout, conçus pour être surchargés par la config locale (group_vars, host_vars, -e)
- D. À sauvegarder les valeurs du dernier run pour les réutiliser au suivant

**Explication** : les defaults disent « si tu ne me dis rien, voilà ce que je
fais ». C'est ce qui rend un rôle GÉNÉRIQUE : le même rôle sert dix groupes avec
dix configs, sans une ligne modifiée dedans — le rôle est générique, la config est
locale.

---

### Question 3 — `inventory/host_vars/dns-proxy.yml` sert à…

- A. Lister les hôtes du groupe dns-proxy
- B. ✅ Définir des variables pour la machine dns-proxy uniquement — « l'exception d'une machine », plus forte que group_vars
- C. Stocker les facts collectés sur dns-proxy pour aller plus vite
- D. Définir des variables par défaut pour tout l'inventaire

**Explication** : host_vars, c'est le sur-mesure d'UNE machine, identifiée par le
nom du fichier (= le nom de l'hôte dans l'inventaire). « Tout le groupe fait comme
ça… sauf dns-proxy. » Étant plus spécifique que group_vars, il gagne — mais perd
encore face au `-e`.

---

### Question 4 — Que fait `-e 'web_status_title="Test"'` sur la ligne de commande ?

- A. Modifie le fichier group_vars pour y écrire la nouvelle valeur
- B. Définit la valeur seulement si la variable n'existe encore nulle part
- C. Exporte la variable dans l'environnement du shell pour tous les runs suivants
- D. ✅ Impose cette valeur pour CE run, en écrasant defaults, group_vars et host_vars — sans rien écrire dans les fichiers

**Explication** : `-e` (extra vars), c'est « l'ordre direct, qui gagne toujours » —
le sommet de l'entonnoir. Mais il ne persiste pas : au run suivant sans `-e`, les
fichiers reprennent la main. Parfait pour un test, jamais pour de la config
permanente.

---

### Question 5 — La panne du chapitre : `dns_listen: "0.0.0.0"` a rendu le DNS muet, alors que le playbook était vert. Quelle est la leçon ?

- A. Il ne faut jamais mettre d'adresse IP dans une variable Ansible
- B. Ansible aurait dû détecter l'erreur : c'est un bug d'Ansible
- C. `0.0.0.0` est une valeur invalide qui casse tous les services réseau
- D. ✅ Une valeur n'a pas le même sens pour tous les logiciels : pour BIND, `listen-on { 0.0.0.0; }` = « nulle part » — après un changement de valeur, il faut re-tester le SERVICE, pas juste le playbook

**Explication** : pour nginx ou sshd, `0.0.0.0` veut dire « toutes les
interfaces » ; pour BIND, `listen-on` attend une liste d'adresses à matcher, et
l'adresse littérale 0.0.0.0 n'existe sur aucune interface → named n'écoute nulle
part. Ansible a déployé fidèlement une valeur qui n'avait pas de sens pour le
logiciel destinataire : un PLAY RECAP vert prouve que la config est déployée, pas
qu'elle fonctionne. D'où le réflexe `ss -ulnp` / `dig` après chaque changement.
