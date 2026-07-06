# Quiz chapitre 4 — Le réseau Proxmox

## Question 1 — Qu'est-ce qu'un bridge Proxmox (vmbr0, vmbr1…) ?

- A. Un câble réseau virtuel entre deux VMs
- B. Un switch virtuel auquel on branche des VMs ✅
- C. Un pare-feu intégré à Proxmox
- D. Une carte réseau physique

**Explication** : le bridge est une « multiprise réseau » logicielle ; vmbr0 est en plus
relié à la carte physique, d'où son accès au monde réel.

## Question 2 — Que signifie `bridge-ports none` ?

- A. Le bridge est désactivé
- B. Le bridge refuse toutes les VMs
- C. Le bridge n'est relié à aucune carte physique : réseau isolé ✅
- D. Le bridge n'a pas d'adresse IP

**Explication** : sans port physique, ce switch virtuel ne mène nulle part — c'est
exactement ce qu'on veut pour un segment interne.

## Question 3 — Une VM d'un segment isolé ne peut pas pinger 8.8.8.8. C'est…

- A. Une panne du bridge, il faut le recréer
- B. Le comportement attendu : la segmentation, c'est de la sécurité ✅
- C. Un bug de cloud-init
- D. Un problème de DNS

**Explication** : la panne du chapitre — avant de dépanner, demande-toi si c'est un bug
ou un choix. Ici, c'est le but même du segment isolé.

## Question 4 — À quoi sert le masquerade (MASQUERADE) montré dans la démo ?

- A. À cacher la VM des scans réseau
- B. À permettre temporairement à un segment isolé de sortir via le nœud ✅
- C. À chiffrer le trafic de la VM
- D. À changer l'adresse MAC de la VM

**Explication** : le nœud « fait passer » les paquets du segment en les signant de sa
propre adresse (NAT) — et dans la démo, on referme aussitôt la parenthèse.

## Question 5 — Après `sysctl -w net.ipv4.ip_forward=1`, pourquoi les deux segments se parlent-ils ?

- A. Les bridges ont fusionné en un seul réseau
- B. Le nœud, passerelle des deux segments, accepte désormais de router entre eux ✅
- C. Les VMs ont changé d'adresse IP
- D. Proxmox a créé une règle de pare-feu automatique

**Explication** : chaque VM envoie à sa passerelle (.254 = le nœud) ce qui sort de son
réseau ; `ip_forward` autorise le nœud à transmettre d'un réseau à l'autre.

---

**Réponses : 1-B, 2-C, 3-B, 4-B, 5-B.**
