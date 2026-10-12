# Chapitre 1 — C'est quoi un homelab ? : script vidéo

> 🔄 Encart « vrai matériel » réaligné le 11/10/2026 sur le parc post-pivot VDP — référence : [`docs/infra-reelle-2026-10.md`](../../docs/infra-reelle-2026-10.md).

> Durée cible : ~15 min. **Chapitre narratif** : pas de demo.sh ni de TP (dérogation
> assumée au gabarit). Objectif : donner envie, montrer la destination, présenter le fil
> rouge et les deux chemins de lab. Les plans à filmer sur l'infra réelle sont détaillés
> dans [`plan-tournage-infra-reelle.md`](plan-tournage-infra-reelle.md).

---

## 1. Pourquoi un homelab ? (4 min)

**À dire** : « Un homelab, c'est ton laboratoire informatique à la maison : une ou
plusieurs machines qui n'appartiennent qu'à toi, où tu peux TOUT essayer. Pourquoi c'est
la meilleure école qui existe ? Trois raisons. »

1. **Apprendre en cassant, sans risque.** « Sur un vrai serveur d'entreprise, une erreur
   coûte cher — parfois un incident, parfois un job. Sur TON homelab, une erreur coûte…
   dix minutes pour tout recréer. Et c'est en cassant qu'on comprend vraiment comment ça
   marche. Personne n'a jamais appris le réseau en lisant un livre : on apprend le réseau
   le jour où plus rien ne ping et qu'il faut trouver pourquoi. »
2. **Héberger ses propres services.** « Ton cloud de fichiers, ton bloqueur de pubs, ton
   gestionnaire de mots de passe, ton média center… au lieu de louer des services à droite
   à gauche, tu les fais tourner chez toi. Tes données restent chez toi, et chaque service
   installé est une compétence gagnée. »
3. **Préparer un job devops / sysadmin.** « Tout ce qu'on va manipuler — virtualisation,
   réseau, pare-feu, supervision, automatisation — ce sont littéralement les lignes d'une
   fiche de poste devops ou sysadmin. Un homelab documenté sur un dépôt Git, en entretien,
   ça vaut plus qu'une liste de certifications : ça prouve que tu FAIS. »

**Transition** : « Mais un homelab, concrètement, ça ressemble à quoi ? Viens, je te
montre le mien. »

---

## 2. Tour filmé de l'infra réelle (4 min)

> Dérouler les plans 1 à 6 de `plan-tournage-infra-reelle.md`, dans l'ordre, avec la voix
> off indiquée. Résumé du parcours :

- **Le physique d'abord** : la tour Proxmox (« ce PC banal a d'abord fait tourner toute
  mon infra tout seul »), le switch et ses câbles (« cinq ports, ça suffit largement
  pour commencer »), les trois mini-PCs Lenovo (« trois hyperviseurs de plus : un cluster
  Proxmox de quatre nœuds tient sur une étagère »).
- **Puis les écrans** : la vue Datacenter du cluster, ses 4 nœuds et leurs VMs (« chaque
  ligne verte est un faux PC dans le vrai »), le tableau de bord Kibana « Homelab — Vue
  d'ensemble » (« tout ce qui se passe sur le lab est enregistré et visualisé ici »), la
  GUI OPNsense avec les alertes Suricata (« et voilà le pare-feu qui monte la garde — il
  détecte même les tentatives d'intrusion »).

**À dire en conclusion du tour** : « Retiens l'idée principale : tout ça, c'est UN PC
à 200 balles d'occasion, trois mini-PCs d'occasion et un switch à 15 euros. Pas un
datacenter. Et chaque brique que tu viens de voir, on va la construire ensemble, une par
une — en commençant par UN seul serveur, comme j'ai commencé. »

---

## 3. Le schéma — ce qu'on va construire (3 min)

**À montrer à l'écran** (schéma simplifié de l'infra, à afficher pendant qu'on le commente
de haut en bas) :

```
                        ┌──────────────┐
                        │   INTERNET   │
                        └──────┬───────┘
                               │ (box)
                        ┌──────┴───────┐
                        │    SWITCH    │  5 ports, non managé
                        └──────┬───────┘
                               │
        ┌──────────────────────────────────────────────────┐
        │   CLUSTER PROXMOX — 4 nœuds, une seule interface │
        │   tour 192.168.1.200  +  3 mini-PCs .50 .51 .52  │
        │                                                  │
        │  ┌──────────────┐    ┌─────────────────────────┐ │
        │  │  OPNsense    │    │ Rundeck + Vault         │ │  ← l'automate et les secrets
        │  │  le pare-feu │    │ GitLab                  │ │  ← le code
        │  ├──────────────┤    │ Artifactory             │ │  ← les livrables
        │  │  ELK         │    │ bastion                 │ │  ← la porte d'entrée SSH
        │  │  les logs,   │    └─────────────────────────┘ │
        │  │  derrière le │    ┌─────────────────────────┐ │
        │  │  pare-feu    │    │ PBS                     │ │  ← les sauvegardes
        │  └──────────────┘    └─────────────────────────┘ │
        └──────────────────────────────────────────────────┘
```

**À dire, en pointant le schéma** :
- « En haut, Internet, qui arrive par la box. En dessous, le switch — la multiprise
  réseau — qui relie tout le monde. »
- « Puis la star : **Proxmox**. Chez moi aujourd'hui c'est un cluster de quatre nœuds —
  la tour en `192.168.1.200` et trois mini-PCs — mais c'est UNE seule interface, et tout
  ce que je te montre dans ce cours se fait sur UN nœud. Un hyperviseur — souviens-toi
  du chapitre 0 : le logiciel qui découpe un vrai PC en plusieurs faux. À l'intérieur,
  chaque service est une VM. »
- « Détail qui a son importance : la VM la plus exposée — la stack de logs, ELK — n'est
  PAS sur le réseau de la maison. Elle vit sur un réseau interne en `10.10.x`, une rue
  privée à l'intérieur du serveur, et c'est **OPNsense**, le pare-feu, qui contrôle qui
  entre et qui sort : cinq ports autorisés, rien d'autre. Pourquoi séparer ? Pour la même
  raison qu'on ne met pas la porte du labo directement dans le salon : si une VM se fait
  compromettre, elle reste enfermée dans sa rue. Ça s'appelle la **segmentation**, et on
  y reviendra tout au long de la série. »
- « Le reste, ce sont les outils du métier : **Vault** pour les secrets, **GitLab** pour
  le code, **Artifactory** pour les livrables, **Rundeck** l'automate qui, en un clic,
  reconstruit la stack ELK de zéro. Et un **bastion** : la seule porte d'entrée SSH quand
  je ne suis pas à la maison. Tu auras le tien dès la fin de ce cours. »
- « Et **PBS**, le serveur de sauvegarde : chaque VM est sauvegardée toutes les nuits, et
  la restauration a été testée — on en reparle au chapitre 6. »

---

## 4. Le fil rouge de la série (2 min)

**À dire (phrase clé à l'écran)** :
> « À la fin de la série, tu auras construit ÇA — version allégée. »

- « C'est le contrat entre toi et moi. Pas une copie exacte — tu n'as pas besoin d'un
  cluster de quatre nœuds ni de trois mini-PCs — mais la même architecture : un
  hyperviseur, des VMs, des réseaux séparés, un pare-feu, des services qui tournent et
  des logs qu'on regarde. »
- « Et surtout : chaque chapitre te fait construire une brique DE ce schéma. À chaque fois
  qu'on ajoute quelque chose, je remontrerai ce schéma avec la brique qui s'allume. Tu
  sauras toujours où tu en es. »

---

## 5. Les deux chemins de lab (1 min)

**À dire** : « Pour suivre, il te faut un lab. Deux chemins, mêmes TPs, même destination :
- **Chemin A** : Proxmox dans VirtualBox, sur ton PC actuel. Rien à acheter, rien à
  casser. C'est le chemin de la majorité.
- **Chemin B** : un vieux PC qui traîne devient ton serveur. C'est exactement mon setup.

Tout est expliqué pas à pas dans le guide du lab — le lien est dans la description :
[`labs/lab-cours-0.md`](../../labs/lab-cours-0.md). Il y a même un tableau pour choisir,
et une mise en garde pour les Mac à puce Apple. Installe ton lab AVANT le chapitre 2 :
c'est là qu'on commence à s'en servir. »

---

## 6. Teaser des 4 cours (1 min)

**À dire (slide avec les 4 titres)** : « Cette formation est une série de quatre cours :
1. **Cours 0 — Fondations** : celui-ci. Proxmox, tes premières VMs, le réseau, les
   snapshots et sauvegardes. À la fin : un mini-homelab qui tourne.
2. **Cours 1 — Ansible** : automatiser — inventaire, playbooks, rôles, secrets. Détruire
   une VM et la faire renaître en une commande, comme les pros.
3. **Cours 2 — ELK** : Elasticsearch, Logstash, Kibana, Filebeat — VOIR tout ce qui se
   passe sur ton lab. Ton propre SIEM.
4. **Cours 3 — Sécurité** : OPNsense, le pare-feu par zone, l'IDS Suricata, Vault — ton
   lab devient une vraie infrastructure défendue.

Rendez-vous au chapitre 2 : on installe Proxmox. D'ici là, choisis ton chemin de lab —
et fais le quiz, il est court. »
