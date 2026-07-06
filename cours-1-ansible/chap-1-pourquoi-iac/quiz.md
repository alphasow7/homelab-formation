# Quiz — Chapitre 1 : Pourquoi l'Infrastructure as Code ?

> 5 questions, 4 choix, 1 seule bonne réponse. Les explications sont là pour ancrer,
> pas pour piéger.

---

### Question 1 — « Ansible est *agentless* » signifie que…

- A. Ansible fonctionne sans connexion réseau
- B. ✅ Il n'y a rien à installer sur les machines gérées : Ansible passe par SSH
- C. Ansible n'a pas besoin d'être installé sur ton poste
- D. Ansible ne peut gérer qu'une seule machine à la fois

**Explication** : agentless = pas de logiciel « agent » à installer sur les VMs ; Ansible
utilise simplement SSH, la connexion que tu utilises déjà depuis le cours 0.

---

### Question 2 — Quelle phrase illustre l'approche *déclarative* d'Ansible ?

- A. « Télécharge l'archive, décompresse-la, copie le binaire, redémarre le service »
- B. « Exécute ces 12 commandes dans cet ordre précis »
- C. ✅ « Je veux que le paquet nginx soit installé et que le service tourne »
- D. « Connecte-toi à la machine et tape les commandes toi-même »

**Explication** : déclaratif = on décrit l'ÉTAT voulu (le quoi) et Ansible calcule les
actions ; les propositions A, B et D décrivent des ACTIONS, c'est l'approche impérative.

---

### Question 3 — Grâce à l'*idempotence*, rejouer un playbook déjà appliqué donne…

- A. Des doublons dans les fichiers de configuration
- B. Une erreur, car la configuration existe déjà
- C. Une réinstallation complète de toutes les machines
- D. ✅ Zéro changement : Ansible constate que l'état voulu est déjà là et ne touche à rien

**Explication** : idempotent = rejouer ne change rien si l'état voulu est déjà atteint,
c'est ce qui rend le « dans le doute, rejoue » sans danger.

---

### Question 4 — Le « drift », c'est…

- A. ✅ L'écart qui se creuse entre l'état réel d'une machine et ce que décrit le code
- B. La vitesse d'exécution d'un playbook sur plusieurs machines
- C. Une fonctionnalité d'Ansible pour synchroniser deux serveurs
- D. Le délai entre deux exécutions d'un même playbook

**Explication** : le drift naît des modifications manuelles faites hors du code (comme la
zone DNS « alphahome ») et explose plus tard, quand le code écrase la réalité.

---

### Question 5 — Tu dois changer une configuration gérée par Ansible. Que fais-tu ?

- A. Tu te connectes en SSH et tu modifies le fichier à la main, c'est plus rapide
- B. ✅ Tu modifies le CODE (playbook/template), tu versionnes, puis tu rejoues le playbook
- C. Tu modifies le fichier à la main ET tu penses à mettre à jour le code plus tard
- D. Tu désactives Ansible sur cette machine pour éviter qu'il écrase ta modification

**Explication** : toute modification manuelle crée du drift — la règle d'or du chapitre :
on ne touche jamais à la main ce qu'Ansible gère, on change le code et on rejoue.
