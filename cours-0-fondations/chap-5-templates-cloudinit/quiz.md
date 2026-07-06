# Quiz chapitre 5 — Templates & clones

## Question 1 — Que devient une VM après `qm template` ?

- A. Elle redémarre en mode lecture seule
- B. Elle devient un moule : elle ne démarrera plus jamais, elle sert à cloner ✅
- C. Elle est sauvegardée puis supprimée
- D. Elle est convertie en conteneur

**Explication** : l'opération est irréversible — le template n'existe que pour fabriquer
des clones.

## Question 2 — Pourquoi laisser le template en `ip=dhcp` ?

- A. Parce que le DHCP est plus rapide
- B. Parce qu'un template ne peut pas avoir d'IP statique
- C. Pour que le moule reste neutre : chaque clone recevra SA propre config ✅
- D. Pour économiser des adresses IP

**Explication** : si le moule portait une IP statique, tous les clones naîtraient avec la
même — c'est au clone qu'on donne son identité.

## Question 3 — Trois clones d'un template cloud-init n'ont pas la même identité machine. Pourquoi ?

- A. Proxmox modifie le disque de chaque clone à la main
- B. cloud-init régénère l'identité (machine-id, clés hôte SSH) au premier boot ✅
- C. C'est le DHCP qui change l'identité
- D. Faux : ils ont tous la même identité

**Explication** : c'est l'astuce du vrai monde — sans cloud-init, cloner une VM donne des
jumeaux parfaits, source de conflits (IP identiques en DHCP, clés SSH identiques…).

## Question 4 — Quelle est la bonne pratique pour un « template doré » ?

- A. Partir d'une VM qui a longtemps servi, elle est éprouvée
- B. Copier le disque d'une autre machine du réseau
- C. Installer le maximum de logiciels dedans
- D. Partir d'une image cloud fraîche, la mettre à jour, la figer ✅

**Explication** : un moule propre = image fraîche + mises à jour + rien d'autre ; les VMs
qui ont « vécu » embarquent leur historique dans chaque clone.

## Question 5 — Combien de temps prend la création d'une VM depuis un template ?

- A. Quelques secondes à une minute (clone + config cloud-init) ✅
- B. Environ 20 minutes (installation complète)
- C. Plusieurs heures (copie du disque)
- D. C'est instantané, aucune commande nécessaire

**Explication** : c'est tout l'intérêt : `qm clone` + `qm set --ipconfig0` + `qm start`,
et le chrono de la démo l'a prouvé.

---

**Réponses : 1-B, 2-C, 3-B, 4-D, 5-A.**
