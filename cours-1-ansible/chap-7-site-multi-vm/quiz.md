# Quiz — Chapitre 7 : site.yml, tout le parc en une commande

> 5 questions, 4 choix, 1 seule bonne réponse. Les explications sont là pour ancrer,
> pas pour piéger.

---

### Question 1 — À quoi sert le playbook maître `site.yml` ?

- A. À sauvegarder l'état des machines avant chaque déploiement
- B. ✅ À décrire TOUT le parc dans un seul fichier : plusieurs plays, chacun cible un groupe, une seule commande met tout dans l'état voulu
- C. À générer automatiquement l'inventaire à partir des machines détectées sur le réseau
- D. À remplacer les rôles : dans site.yml, on réécrit toutes les tâches en un seul endroit

**Explication** : site.yml est la « partition de l'orchestre » : il ne contient
presque que des phrases — tel groupe reçoit tel(s) rôle(s) — enchaînées dans le bon
ordre (le socle d'abord). Les rôles gardent le COMMENT ; site.yml dit QUI et QUOI,
pour tout le parc, en une commande.

---

### Question 2 — Que fait l'option `--check` de `ansible-playbook` ?

- A. Elle vérifie la syntaxe YAML du playbook sans se connecter aux machines
- B. Elle exécute le playbook, puis vérifie que les services sont bien actifs
- C. ✅ Elle déroule le playbook en montrant ce qui serait modifié, sans RIEN changer sur les machines
- D. Elle compare l'inventaire avec les machines réellement allumées

**Explication** : `--check` est la répétition générale : Ansible se connecte,
compare l'état réel à l'état voulu et annonce ses `changed`… sans appliquer quoi
que ce soit. Combiné à `--diff` (les lignes -/+), c'est LE réflexe avant un
déploiement sensible : tu lis, TU décides.

---

### Question 3 — Tu as modifié une variable qui ne concerne que dns-proxy. Quelle option évite de rejouer tout le parc ?

- A. `--diff dns-proxy`
- B. `--check dns-proxy`
- C. `--tags dns-proxy`
- D. ✅ `--limit dns-proxy`

**Explication** : `--limit` restreint le run à un hôte ou un groupe de
l'inventaire : la partition ne se joue que pour ce pupitre. Grâce à
l'idempotence, rejouer tout le parc ne casserait rien — mais `--limit` fait
gagner du temps et réduit la surface de ce qui bouge.

---

### Question 4 — Pourquoi un service comme `named` peut-il « rater » le réseau au démarrage de la machine ?

- A. Parce que fail2ban bloque ses connexions tant que la machine n'est pas de confiance
- B. ✅ Parce qu'au boot les services démarrent en parallèle : s'il se lance avant que l'interface ait son IP, il ne voit que 127.0.0.1 et ne s'attache qu'à elle
- C. Parce que le DNS a besoin d'Internet pour démarrer, et le segment du lab est isolé
- D. Parce qu'Ansible arrête le réseau pendant qu'il déploie la configuration

**Explication** : c'est une course au boot entre le service et la configuration
réseau. Si le service perd — il liste les adresses disponibles alors que seule la
loopback existe —, il tourne, dit « active », a des logs propres… et reste sourd
depuis le réseau. Le fix durable : le drop-in systemd
`After/Wants=network-online.target`, posé par le rôle `common`.

---

### Question 5 — Que t'apprend le « reboot-test » qu'aucun autre test ne montre ?

- A. La vitesse de démarrage de la machine, pour dimensionner le matériel
- B. Que l'idempotence fonctionne : au reboot, Ansible rejoue le playbook tout seul
- C. Rien de plus : si le service est `active` après le déploiement, il le sera après un reboot
- D. ✅ Que la configuration survit à un redémarrage : services activés, ordre de démarrage correct — des défauts invisibles tant que la machine reste allumée

**Explication** : « un service qui marche n'est pas un service qui REdémarre ».
Un service non `enabled`, ou qui perd la course du réseau au boot, semble
parfaitement sain après le déploiement — et tombe au premier reboot (mise à jour,
coupure, migration). C'est le reboot qui dit la vérité : teste-le.
