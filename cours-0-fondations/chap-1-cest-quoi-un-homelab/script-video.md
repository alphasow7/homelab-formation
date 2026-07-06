# Chapitre 1 — C'est quoi un homelab ? : script vidéo

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

- **Le physique d'abord** : le boîtier du serveur Proxmox (« ce PC banal fait tourner
  toute mon infra »), le switch TP-Link et ses câbles (« cinq ports, ça suffit largement
  pour commencer »), les deux mini-PCs Lenovo (« un cluster Kubernetes tient sur une
  étagère »).
- **Puis les écrans** : la GUI Proxmox avec les 10 VMs qui tournent (« chaque ligne verte
  est un faux PC dans le vrai »), un dashboard Kibana avec les logs qui défilent (« tout
  ce qui se passe sur le lab est enregistré et visualisé ici »), la GUI OPNsense avec les
  alertes Suricata (« et voilà le pare-feu qui monte la garde — il détecte même les
  tentatives d'intrusion »).

**À dire en conclusion du tour** : « Retiens l'idée principale : tout ça, c'est UN serveur
à 200 balles d'occasion, deux mini-PCs et un switch à 15 euros. Pas un datacenter. Et
chaque brique que tu viens de voir, on va la construire ensemble, une par une. »

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
                        │    SWITCH    │  TP-Link 5 ports
                        └──┬───────┬───┘
                           │       │
           ┌───────────────┴──┐   ┌┴──────────────────┐
           │     PROXMOX      │   │   2 mini-PCs      │
           │  192.168.1.200   │   │   Lenovo (K3S)    │
           │                  │   │ cluster Kubernetes│
           │  VMs internes    │   └───────────────────┘
           │  (réseaux 10.10.x)
           │  ┌────────────┐  │
           │  │  OPNsense  │  │  ← pare-feu, la porte d'entrée des VMs
           │  ├────────────┤  │
           │  │ ELK        │  │  ← les logs de tout le monde
           │  │ GitLab     │  │  ← le code et l'automatisation
           │  │ Vault      │  │  ← les secrets (mots de passe, clés)
           │  │ DNS        │  │  ← l'annuaire interne
           │  │ proxy      │  │  ← la porte d'entrée web des services
           │  └────────────┘  │
           └──────────────────┘
```

**À dire, en pointant le schéma** :
- « En haut, Internet, qui arrive par la box. En dessous, le switch — la multiprise
  réseau — qui relie tout le monde. »
- « À gauche, la star : le serveur **Proxmox**, en `192.168.1.200`. C'est un hyperviseur —
  souviens-toi du chapitre 0 : le logiciel qui découpe un vrai PC en plusieurs faux. À
  l'intérieur, chaque service est une VM. »
- « Détail qui a son importance : les VMs ne sont PAS sur le réseau de la maison. Elles
  vivent sur des réseaux internes en `10.10.x` — des rues privées, à l'intérieur du
  serveur — et c'est **OPNsense**, le pare-feu, qui contrôle qui entre et qui sort.
  Pourquoi séparer ? Pour la même raison qu'on ne met pas la porte du labo directement
  dans le salon : si une VM se fait compromettre, elle reste enfermée dans sa rue. Ça
  s'appelle la **segmentation**, et on y reviendra tout au long de la série. »
- « À droite, les deux mini-PCs : un cluster **K3S**, du Kubernetes léger. Ça, c'est pour
  bien plus tard — sache juste qu'ils existent. »
- Passer une ligne sur chaque VM avec sa phrase : ELK « les logs », GitLab « le code »,
  Vault « les secrets », DNS « l'annuaire interne », proxy « la porte d'entrée web ».

---

## 4. Le fil rouge de la série (2 min)

**À dire (phrase clé à l'écran)** :
> « À la fin de la série, tu auras construit ÇA — version allégée. »

- « C'est le contrat entre toi et moi. Pas une copie exacte — tu n'as pas besoin de
  10 VMs ni de deux mini-PCs — mais la même architecture : un hyperviseur, des VMs, des
  réseaux séparés, un pare-feu, des services qui tournent et des logs qu'on regarde. »
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
2. **Cours 1 — Réseau et sécurité** : OPNsense, la segmentation, le pare-feu, le VPN.
   Ton lab devient une vraie infrastructure défendue.
3. **Cours 2 — Services et supervision** : DNS, proxy, ELK — héberger des services et
   VOIR ce qui se passe dessus.
4. **Cours 3 — Automatisation** : Ansible, GitLab, Vault — tout reconstruire en une
   commande, comme les pros.

Rendez-vous au chapitre 2 : on installe Proxmox. D'ici là, choisis ton chemin de lab —
et fais le quiz, il est court. »
