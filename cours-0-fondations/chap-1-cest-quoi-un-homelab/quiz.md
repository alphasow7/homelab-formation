# Quiz chapitre 1 — C'est quoi un homelab ?

**5 questions, une seule bonne réponse par question.** Les réponses sont en bas.

## Question 1 — À quoi sert un homelab, avant tout ?

- A. À remplacer un datacenter d'entreprise
- B. À apprendre en expérimentant chez soi, sans risque, et à héberger ses propres services ✅
- C. À miner des cryptomonnaies
- D. À obligatoirement obtenir une certification

**Explication** : le homelab est un laboratoire personnel où l'erreur ne coûte rien —
on casse, on recommence — tout en pouvant héberger ses services et préparer un job
devops/sysadmin.

## Question 2 — Un hyperviseur, c'est…

- A. Un antivirus pour serveurs
- B. Un câble spécial qui relie plusieurs PCs
- C. Le logiciel qui découpe un vrai PC en plusieurs machines virtuelles ✅
- D. Un écran de supervision

**Explication** : l'hyperviseur (comme Proxmox) partage le matériel d'une vraie machine
entre plusieurs VMs, chacune se croyant un PC complet.

## Question 3 — Pourquoi mettre les VMs sur des réseaux séparés (segmentation) ?

- A. Pour que les VMs aillent plus vite
- B. Pour économiser des adresses IP
- C. Parce que les VMs ne peuvent techniquement pas partager un réseau
- D. Pour qu'une VM compromise reste enfermée dans son réseau au lieu d'atteindre tout le reste ✅

**Explication** : la segmentation cloisonne l'infrastructure en « rues » séparées : un
problème (piratage, erreur) reste confiné à son segment au lieu de se propager partout.

## Question 4 — Que fait un pare-feu comme OPNsense ?

- A. Il contrôle le trafic réseau : qui a le droit d'entrer, qui a le droit de sortir ✅
- B. Il sauvegarde les VMs chaque nuit
- C. Il refroidit le serveur en cas de surchauffe
- D. Il attribue les adresses IP à toutes les machines

**Explication** : le pare-feu filtre le trafic entre les réseaux selon des règles — c'est
la porte d'entrée gardée des VMs (et avec Suricata, il détecte en plus les intrusions).

## Question 5 — Qu'auras-tu construit à la fin du cours 0 ?

- A. Une copie exacte de l'infra du formateur, avec 10 VMs et un cluster K3S
- B. Un mini-homelab : Proxmox installé, des VMs, du réseau, des snapshots et des sauvegardes ✅
- C. Uniquement de la théorie, la pratique commence au cours 1
- D. Un site web hébergé chez un fournisseur cloud

**Explication** : le fil rouge, c'est l'infra du formateur « version allégée » — le cours 0
pose les fondations : hyperviseur, premières VMs, réseau, snapshots et sauvegardes.

---

**Réponses : 1-B, 2-C, 3-D, 4-A, 5-B.**
