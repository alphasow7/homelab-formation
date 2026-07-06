# Quiz chapitre 7 — Projet final (révision générale)

## Question 1 — À quoi sert le bastion dans ton lab ?

- A. À sauvegarder les autres VMs
- B. À servir de point d'entrée contrôlé vers le segment isolé ✅
- C. À fournir Internet aux VMs du segment
- D. À héberger la GUI Proxmox

**Explication** : machine de rebond à cheval sur les deux réseaux — on n'expose jamais un
segment interne directement.

## Question 2 — Pourquoi la 2ᵉ carte réseau du bastion n'a-t-elle PAS de passerelle ?

- A. Le segment isolé n'a pas de passerelle du tout
- B. C'est un oubli du cahier des charges
- C. Une seule route par défaut : la sortie reste par net0, net1 ne sert qu'à joindre le segment ✅
- D. cloud-init ne sait pas configurer deux passerelles

**Explication** : deux passerelles par défaut = conflit de routage ; la machine doit avoir
UNE sortie principale, et une simple patte locale sur le segment.

## Question 3 — Pourquoi déployer les VMs une par une plutôt que les 4 d'un coup ?

- A. Proxmox ne peut cloner qu'une VM à la fois
- B. Pour vérifier chaque étape et isoler immédiatement un problème ✅
- C. Pour économiser la RAM
- D. Parce que le template se verrouille après chaque clone

**Explication** : méthode de travail : petite étape → vérification → étape suivante. Un
problème détecté tôt est un problème facile.

## Question 4 — Que fige le snapshot `fin-cours-0` ?

- A. La configuration du nœud Proxmox
- B. L'état exact de chaque VM à la fin du cours — le point de départ des cours 1-3 ✅
- C. Une sauvegarde complète externe au disque
- D. Le template doré

**Explication** : les cours suivants disent « partez du snapshot fin-cours-0 » — n'importe
quelle bêtise future se rattrape par un rollback.

## Question 5 — Ton poste ne peut pas pinger 10.10.99.11 mais le bastion si. C'est…

- A. Un problème de DNS
- B. Une panne du bridge vmbr1
- C. Le comportement voulu : le segment est isolé, seul le bastion y a un pied ✅
- D. Un pare-feu Proxmox mal configuré

**Explication** : la boucle est bouclée — même logique que la « panne » du chapitre 4 :
c'est un choix d'architecture, pas un bug.

---

**Réponses : 1-B, 2-C, 3-B, 4-B, 5-C.**
