# Quiz — Chapitre 3 : Le premier playbook

> 5 questions, 4 choix, 1 seule bonne réponse. Les explications sont là pour ancrer,
> pas pour piéger.

---

### Question 1 — Dans un playbook, à quoi sert un *handler* ?

- A. À gérer les erreurs : il s'exécute quand une task échoue
- B. À exécuter une task en premier, avant toutes les autres
- C. ✅ À exécuter une action (ex. redémarrer un service) seulement si une task l'a notifié parce qu'elle a changé quelque chose
- D. À exécuter une task sur toutes les machines de l'inventaire en même temps

**Explication** : un handler est une tâche « dormante » : il ne se réveille que si une
task portant un `notify` a réellement modifié la machine. Pas de changement, pas de
redémarrage — on ne secoue pas un service sans raison.

---

### Question 2 — Au PLAY RECAP, `changed=0` signifie que…

- A. Le playbook a échoué : aucune task n'a pu s'exécuter
- B. Ansible n'a pas réussi à se connecter à la machine
- C. Le playbook est vide, il n'y avait aucune task à exécuter
- D. ✅ L'état voulu était déjà en place : Ansible a tout vérifié et n'a rien eu à modifier

**Explication** : `changed=0` est une BONNE nouvelle : les tasks se sont exécutées
(regarde le `ok=`), Ansible a comparé l'état réel à l'état voulu, et tout était déjà
conforme. C'est l'idempotence en action — le rejeu est sans danger.

---

### Question 3 — Le `notify` d'une task déclenche le handler…

- A. À chaque exécution du playbook, systématiquement
- B. ✅ Seulement si cette task a le statut `changed` pendant ce run
- C. Seulement au premier run du playbook, jamais ensuite
- D. Seulement si la task échoue

**Explication** : `notify` ne « sonne » que si la task a réellement changé quelque
chose. Run 2 de la démo : la page était déjà la bonne, task en `ok`, handler muet.
Run 3 (après vandalisme) : page réécrite, task en `changed`, nginx redémarré.

---

### Question 4 — À quoi sert `become: true` en tête de play ?

- A. ✅ À exécuter les tasks avec les droits root (via sudo), nécessaire pour installer des paquets ou écrire dans /var/www
- B. À devenir le contrôleur Ansible de la machine cible
- C. À forcer Ansible à se reconnecter en SSH à chaque task
- D. À rendre le playbook idempotent

**Explication** : `become` = élévation de privilèges, l'équivalent du `sudo` que tu
tapes à la main. Installer nginx ou écrire dans `/var/www/html` demande root ;
l'idempotence, elle, vient des modules, pas de `become`.

---

### Question 5 — Quelqu'un a écrasé la page à la main (le « vandalisme »). Que montre le run suivant du playbook ?

- A. `failed=1` : Ansible refuse de toucher à un fichier modifié manuellement
- B. `changed=0` : Ansible ne détecte pas les modifications faites à la main
- C. ✅ `changed=1` sur la task de la page + le handler qui redémarre nginx : le drift est réparé par simple rejeu
- D. Une demande de confirmation : Ansible attend qu'un humain tranche

**Explication** : Ansible compare le contenu réel du fichier au contenu voulu, voit
l'écart (le drift), réécrit la page — d'où le `changed` — et le `notify` réveille le
handler. Pas de fouille, pas de stress : le code est la référence, la machine se
réaligne dessus.
