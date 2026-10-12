# Quiz chapitre 2 — OPNsense : installation

## Question 1 — À quoi sert un pare-feu de périmètre ?

- A. À stocker les logs de toutes les VMs
- B. À contrôler tout ce qui entre et sort du lab — le poste de douane entre le lab et le monde
- C. À accélérer la connexion Internet
- D. À remplacer l'hyperviseur Proxmox

---

## Question 2 — WAN et LAN, dans OPNsense, c'est…

- A. Deux marques de cartes réseau
- B. WAN = le côté « monde » méfiant (bloque l'entrant par défaut) ; LAN = le côté « lab » de confiance
- C. WAN = le sans-fil, LAN = le filaire
- D. Deux mots de passe différents

---

## Question 3 — Pourquoi une VM OPNsense dédiée plutôt que le pare-feu intégré de Proxmox ?

- A. Parce que Proxmox n'a aucun filtrage réseau
- B. Pour consommer moins de RAM
- C. Séparation des rôles, un vrai OS de pare-feu (règles/NAT/VPN/IDS), et ça se transpose sur un boîtier physique
- D. Parce que c'est obligatoire pour démarrer une VM

---

## Question 4 — `tmpfs`, et pourquoi le live-installer perd toute la config au reboot ?

- A. `tmpfs` est un disque chiffré ; il se verrouille au reboot
- B. `tmpfs` est un système de fichiers en RAM ; sur un live-system, tout (racine et config) y vit, donc tout est vidé à l'extinction
- C. `tmpfs` est un antivirus qui efface les fichiers suspects
- D. `tmpfs` est le nom du disque dur d'OPNsense

---

## Question 5 — Le bon réflexe AVANT d'investir des heures de config dans un système ?

- A. Configurer d'abord tout, rebooter seulement à la fin pour gagner du temps
- B. Faire un reboot de contrôle d'abord, et vérifier que la config a une mémoire (`mount | head -1`)
- C. Ne jamais rebooter tant que ça marche
- D. Sauvegarder la RAM sur une clé USB

---

## Corrigé

> Ne lis cette section qu'après avoir répondu aux 5 questions.

**Réponses : 1-B, 2-B, 3-C, 4-B, 5-B.**

### Question 1 — réponse B

le pare-feu de périmètre se place entre l'extérieur (WAN) et le réseau
interne (LAN) et décide de ce qui passe. C'est la porte, pas le coffre ni le SIEM.

### Question 2 — réponse B

WAN = la rue (on bloque les entrants non sollicités), LAN = la maison
(les habitants sortent). C'est la distinction fondamentale d'un pare-feu.

### Question 3 — réponse C

on ne mélange pas l'hyperviseur et le pare-feu. OPNsense (distribution
libre basée FreeBSD) offre un vrai arsenal réseau, et le savoir se rejoue à l'identique sur
du matériel dédié.

### Question 4 — réponse B

le live-system (quand on n'a pas lancé `Install`) tourne depuis la RAM :
racine sur un disque mémoire, config comprise. Toute config écrite disparaît au reboot. Le
fix : `Install (UFS)` sur disque, pour que la racine — et `/conf` avec — vive sur du dur.

### Question 5 — réponse B

un reboot de contrôle **avant** la config prouve que le système persiste.
Un système qui oublie est pire qu'un système cassé : il fait croire que ça marche jusqu'au
reboot qui efface tout. `mount | head -1` sans `/dev/gpt/rootfs` = alerte live-system.
