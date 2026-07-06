# Quiz chapitre 2 — L'inventaire

> 5 questions, 4 choix, 1 seule bonne réponse. Les explications sont sous chaque
> question.

## Question 1 — À quoi sert l'inventaire Ansible ?

- A. À installer Ansible sur les machines distantes
- B. ✅ À déclarer les machines du parc (noms, adresses, groupes, variables de connexion)
- C. À stocker les mots de passe des serveurs
- D. À sauvegarder l'historique des commandes exécutées

**Explication** : l'inventaire est l'annuaire du parc : il dit à Ansible QUI
commander et COMMENT s'y connecter (IP via `ansible_host`, utilisateur via
`ansible_user`, ProxyJump…). Ansible ne s'installe pas sur les machines distantes
(A) — il n'y a pas d'agent ; les secrets ont leur propre outil, qu'on verra plus
tard (Vault) (C) ; et il n'archive rien (D).

## Question 2 — À quoi sert un groupe dans l'inventaire ?

- A. À limiter les droits d'un utilisateur sur certaines machines
- B. À accélérer les connexions SSH vers les machines du groupe
- C. À isoler les machines sur des réseaux différents
- D. ✅ À cibler plusieurs machines d'un seul mot et leur donner des variables communes

**Explication** : un groupe est une étagère : `ansible lab -m ping` touche les 3
VMs d'un coup, et les `vars` posées sur le groupe (comme `ansible_user` ou le
ProxyJump) s'appliquent à tous ses membres. Ce n'est ni de la gestion de droits
(A), ni de la performance (B), ni du réseau (C) — l'isolement réseau, c'est le
travail des segments et du pare-feu, pas de l'inventaire.

## Question 3 — Que teste exactement `ansible lab -m ping` ?

- A. Que les machines répondent aux paquets ICMP, comme la commande `ping`
- B. Que le port 80 des machines est ouvert
- C. ✅ Que la connexion SSH fonctionne et qu'un Python utilisable répond sur chaque machine
- D. Que la latence réseau vers les machines est acceptable

**Explication** : piège classique — le module `ping` d'Ansible n'envoie AUCUN
paquet ICMP (A) et ne mesure rien (D). Il fait le trajet complet d'Ansible :
connexion SSH (à travers le bastion), exécution d'un mini-programme Python, retour
`pong`. Trois pongs verts = toute la chaîne SSH + Python est bonne. Le port 80 (B)
n'a rien à voir : Ansible passe par SSH (port 22).

## Question 4 — Que sont les « facts » ?

- A. Les résultats des dernières commandes ad-hoc, gardés en cache
- B. Les variables que tu déclares toi-même dans l'inventaire
- C. Les fichiers de log générés par Ansible sur le contrôleur
- D. ✅ Les informations qu'Ansible découvre automatiquement sur chaque machine (OS, IPs, RAM…)

**Explication** : les facts sont collectés par le module `setup` : architecture,
adresses IP, RAM (`ansible_memtotal_mb`), distribution… « Ansible SAIT tout des
machines », et on utilisera ces facts dans les playbooks pour prendre des
décisions. Ce ne sont ni des résultats mis en cache (A), ni tes variables
d'inventaire — celles-là, c'est toi qui les écris (B) —, ni des logs (C).

## Question 5 — Que fait l'option `--become` ?

- A. ✅ Elle fait exécuter l'action avec les droits super-utilisateur sur la machine cible (équivalent de sudo)
- B. Elle force Ansible à passer par le bastion
- C. Elle rend la commande permanente : elle sera rejouée à chaque redémarrage
- D. Elle exécute la commande sur le contrôleur au lieu des machines distantes

**Explication** : `become` = « devenir » (root, par défaut). C'est l'équivalent
d'un `sudo` côté machine cible : indispensable pour redémarrer un service, comme
dans le TP. Le passage par le bastion (B) est réglé par `ansible_ssh_common_args`
dans l'inventaire, pas par `--become` ; rien n'est « rejoué au redémarrage » (C) ;
et Ansible exécute toujours sur les cibles, pas sur le contrôleur (D).
