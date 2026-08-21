# Quiz chapitre 2 — Installer Proxmox

**5 questions, une seule bonne réponse par question.** Les réponses et les explications sont en bas.

## Question 1 — Proxmox est un hyperviseur de type…

- A. Type 2 : c'est une application qu'on installe sur Windows ou macOS
- B. Type 1 : il s'installe directement sur le matériel (bare-metal)
- C. Type 3 : il tourne dans le cloud uniquement
- D. Ce n'est pas un hyperviseur, c'est un conteneur

---

## Question 2 — La GUI web de Proxmox écoute sur le port…

- A. 443, comme tout site HTTPS
- B. 80
- C. 8006
- D. 22

---

## Question 3 — Un dépôt « no-subscription », c'est…

- A. Une version piratée de Proxmox
- B. Le dépôt communautaire officiel, gratuit, avec les mêmes paquets que l'enterprise mais testés moins longtemps
- C. Un dépôt qui désactive les mises à jour
- D. Un dépôt réservé aux clients payants

---

## Question 4 — Le rôle `PVEAuditor` donne le droit de…

- A. Tout administrer, comme root
- B. Créer des VMs mais pas les supprimer
- C. Tout voir en lecture seule, sans rien pouvoir modifier
- D. Gérer uniquement les utilisateurs

---

## Question 5 — `apt update` affiche une erreur 401 sur enterprise.proxmox.com. Que faire ?

- A. Acheter un abonnement, c'est obligatoire pour utiliser Proxmox
- B. Réinstaller Proxmox
- C. Ignorer l'erreur, elle est sans conséquence
- D. Désactiver les dépôts enterprise et basculer sur le dépôt pve-no-subscription

---

**Réponses : 1-B, 2-C, 3-B, 4-C, 5-D.**

---

## Corrigé

> Ne lis cette section qu'après avoir répondu aux 5 questions.

**Réponses : 1-B, 2-C, 3-B, 4-C, 5-D.**

### Question 1 — réponse B

Proxmox EST le système d'exploitation de la machine et parle directement
au matériel, ce qui définit un hyperviseur de type 1 (contrairement à VirtualBox, type 2).

### Question 2 — réponse C

`pveproxy` écoute sur le port 8006 (visible avec `ss -tlnp | grep 8006`),
d'où l'URL `https://IP:8006` — un service web n'écoute pas forcément sur 443.

### Question 3 — réponse B

c'est le dépôt officiel de Proxmox pour les utilisateurs sans abonnement,
parfaitement adapté à un homelab ; seul le dépôt enterprise exige un abonnement payant.

### Question 4 — réponse C

`PVEAuditor` est un rôle en lecture seule — l'utilisateur voit l'ensemble
de l'infrastructure mais toute action de modification (comme créer une VM) est refusée.

### Question 5 — réponse D

le 401 (Unauthorized) signifie que le dépôt enterprise refuse l'accès sans
abonnement ; la solution est de le désactiver (`Enabled: false`) et d'ajouter le dépôt
communautaire no-subscription, comme dans demo.sh.
