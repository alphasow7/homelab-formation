# Quiz — Chapitre 4 : Les rôles

> 5 questions, 4 choix, 1 seule bonne réponse. Les explications sont là pour ancrer,
> pas pour piéger.

---

### Question 1 — Les 4 « tiroirs » standards d'un rôle Ansible vus dans ce chapitre sont…

- A. `playbooks/`, `inventory/`, `group_vars/`, `host_vars/`
- B. ✅ `tasks/`, `templates/`, `handlers/`, `defaults/`
- C. `install/`, `config/`, `restart/`, `variables/`
- D. `src/`, `bin/`, `etc/`, `lib/`

**Explication** : un rôle range sa compétence dans des dossiers aux noms imposés par
la convention : `tasks/` (les actions), `templates/` (les fichiers à trous),
`handlers/` (les réactions au `notify`), `defaults/` (les réglages d'usine). C'est
grâce à ces noms qu'Ansible trouve tout sans déclaration — et qu'un autre admin s'y
retrouve en 10 secondes.

---

### Question 2 — À quoi sert `defaults/main.yml` dans un rôle ?

- A. À lister les machines sur lesquelles le rôle s'applique
- B. À stocker les mots de passe du rôle
- C. ✅ À donner des valeurs par défaut aux variables, qu'un playbook peut surcharger sans modifier le rôle
- D. À définir les tâches exécutées par défaut si `tasks/main.yml` est absent

**Explication** : `defaults/` = les réglages d'usine. Le rôle fonctionne tel quel avec
ces valeurs (`dns_domain: lab.local`…), et chaque playbook qui l'utilise peut les
remplacer par les siennes — c'est ce qui rend un rôle réutilisable. Les machines
cibles, c'est l'affaire du playbook et de l'inventaire, jamais du rôle.

---

### Question 3 — Pourquoi sépare-t-on le bloc `options {}` (dans `named.conf.options`) des zones (dans `named.conf.local`) ?

- A. Parce que BIND lit uniquement le fichier `named.conf.local`
- B. Pour que le fichier de zone soit rechargeable sans redémarrer le service
- C. Parce que les zones doivent être dans un fichier appartenant à root
- D. ✅ Parce qu'un deuxième bloc `options` serait un doublon : BIND répond « already exists » et refuse de démarrer

**Explication** : BIND n'accepte qu'UN bloc `options` dans toute sa configuration. S'il
en trouve un dans `named.conf.options` ET un dans `named.conf.local`, il échoue au
démarrage avec le message cryptique `loading configuration: already exists` — la panne
rejouée dans ce chapitre. D'où le commentaire « Zones uniquement » en tête du template.

---

### Question 4 — Après un déploiement, le handler `Restart bind9` échoue : le service refuse de démarrer. Ton PREMIER réflexe ?

- A. Relancer `ansible-playbook` une deuxième fois, au cas où
- B. Modifier le fichier de configuration directement sur la VM jusqu'à ce que ça reparte
- C. ✅ Lire le journal du service sur la machine : `journalctl -u named -n 20`
- D. Réinstaller le paquet bind9 pour repartir de zéro

**Explication** : Ansible sait QUE le restart a échoué, pas POURQUOI — seul le service
le sait, et il l'a écrit dans son journal (`journalctl -u <service>`). Le message dit
presque toujours QUOI (et souvent OÙ : fichier + ligne). Relancer ne change rien à une
conf cassée, et corriger sur la VM sera écrasé au prochain déploiement : on corrige le
template, la source de vérité.

---

### Question 5 — Que fait un enregistrement CNAME ?

- A. Il associe un nom directement à une adresse IP
- B. Il déclare quel serveur fait autorité sur la zone
- C. ✅ Il fait pointer un nom vers un AUTRE nom — un « surnom » qui suit la cible si son IP change
- D. Il transmet les requêtes inconnues vers un DNS public (1.1.1.1)

**Explication** : `www IN CNAME dns-proxy` dit « www est un surnom de dns-proxy ».
Pour trouver l'IP, le client suit le CNAME jusqu'à l'enregistrement A de la cible —
c'est pour ça que `dig www.lab.local` renvoie deux lignes. Nom → IP, c'est le A ;
l'autorité, c'est le NS ; le renvoi vers 1.1.1.1, ce sont les forwarders.
