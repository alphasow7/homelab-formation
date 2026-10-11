# Chapitre 4 — Le réseau Proxmox : script vidéo

> 🔄 Encart « vrai matériel » réaligné le 11/10/2026 sur le parc post-pivot VDP — référence : [`docs/infra-reelle-2026-10.md`](../../docs/infra-reelle-2026-10.md).

> Durée cible : ~40 min. Prérequis : chapitres 2-3 (Proxmox post-installé, VM 9001
> existante). Toutes les commandes montrées sont dans `demo.sh` et doivent être rejouées
> sur le lab avant tournage. Schémas à l'écran : `schema-bridges.md`.

## 1. Le concept (5 min)

**À dire** : « Depuis deux chapitres, on tape `bridge=vmbr0` sans savoir ce que c'est.
Aujourd'hui, on ouvre le capot. Un **bridge**, c'est un **switch virtuel** : une multiprise
réseau dans ton serveur. `vmbr0` est branché sur ta vraie carte réseau — les VMs qui y
sont connectées voient le monde. Mais on peut créer d'autres switchs virtuels, **sans
aucun câble** : des réseaux qui n'existent que dans le serveur. »

**À montrer** : le premier schéma de `schema-bridges.md` (vmbr0 relié au monde, vmbr1
isolé).

**À dire** : « Pourquoi isoler des VMs ? Un mot : **sécurité**. Si ta base de données
n'a pas accès à Internet, un attaquant qui la compromet ne peut rien exfiltrer facilement,
et elle ne peut pas télécharger n'importe quoi. C'est la **segmentation** : chaque groupe
de services dans sa bulle. Les pros appellent ça la défense en profondeur. »

## 2. Démo guidée (18 min)

### 2.1 Créer un bridge isolé

**À montrer** : bloc 1 de `demo.sh` — on ajoute `vmbr1` dans `/etc/network/interfaces`.

**À dire** : « `bridge-ports none` : ce switch n'a AUCUN câble vers le monde réel. Et le
nœud lui-même prend l'adresse `10.10.99.254` — il a un pied dans ce réseau, ce qui nous
servira. `ifreload -a` applique sans redémarrer. » **Attendu** : `ip -4 addr show vmbr1`
montre `10.10.99.254/24`.

(Note GUI : montrer aussi que le bridge apparaît dans Datacenter > pve > Network.)

### 2.2 Déplacer une VM dans le segment isolé

**À montrer** : bloc 2 — `qm set 9001 --net0 virtio,bridge=vmbr1` + la nouvelle
`--ipconfig0` (IP statique du segment, gw = le nœud). Stop/start (réflexe du chapitre 3 !).

**À dire** : « On débranche virtuellement la VM du switch public et on la branche sur le
switch isolé. Nouvelle prise = nouvelle adresse : `10.10.99.10`, passerelle
`10.10.99.254` — le nœud. »

### 2.3 Prouver l'isolement

**À montrer** : blocs 3-4. Le ping du nœud vers la VM passe ; depuis la VM,
`ping 8.8.8.8` échoue.

**À dire** : « Le nœud la joint car il a un pied dans le réseau. Mais elle, elle ne sort
pas. » **Attendu** : `PAS D'INTERNET — normal, segment isolé !`.

## 3. 💥 La panne du vrai monde (7 min)

**Mise en scène** : « Panique classique du débutant : "ma VM n'a pas Internet, mon réseau
est CASSÉ !" Sauf que… regarde bien : rien n'est cassé. **C'est exactement ce qu'on a
construit.** » (plot twist assumé)

**Diagnostic guidé** : `ip route` dans la VM (une seule route, pas de sortie), le schéma
à l'écran, et la question à se poser AVANT de dépanner : « est-ce un bug ou un choix ? »

**À dire** : « Sur l'infra réelle de ce cours, les segments internes de la tour n'ont PAS
d'Internet, par choix — la stack ELK vit sur l'un d'eux, derrière le pare-feu, et mes
labs d'entraînement sur d'autres. Alors comment ces machines font leurs mises à jour ??
Voilà LA bonne question. Réponse courte aujourd'hui : le nœud peut jouer les passeurs —
chez moi, c'est un rôle Ansible qui pose le masquerade le temps d'installer des paquets,
puis le **retire**, exactement comme on va le faire. Réponse complète au cours 1 : un
proxy apt dédié sur le nœud. »

**À montrer** : bloc 5 — le masquerade NAT temporaire : on ouvre (`iptables -t nat -A
POSTROUTING ... MASQUERADE`), la VM sort (`INTERNET OK`), et surtout **on referme**
(`-D`) et on re-prouve l'isolement.

**Morale** : « Un accès temporaire, ça se referme. Et "pas d'Internet" n'est pas toujours
une panne — parfois c'est une décision de sécurité. Apprends à distinguer les deux. »

## 4. Encart vrai matériel (3 min)

**À filmer** : la GUI de l'infra réelle, Datacenter > `pve` (la tour) > Network : les
bridges `vmbr0` à `vmbr8`. Puis la même page sur `pve01` : **un seul** bridge, `vmbr0`.
Enfin un schéma : le LAN `192.168.1.0/24` (où vivent les 4 nœuds et la plateforme), le
segment ELK `10.10.20.0/24` derrière OPNsense, les segments de labs `10.10.99.0/24` et
`10.10.98.0/24`.

**À dire** : « Sur la tour : le LAN, quatre segments internes historiques, deux bridges
pour le pare-feu, deux pour mes labs d'entraînement — neuf bridges, tous virtuels sauf le
premier. Sur les mini-PCs : un seul, le LAN. Pourquoi ? Un bridge sans port physique
n'existe QUE sur son nœud : une VM posée dessus y est clouée. C'est un choix assumé chez
moi — et une vraie question d'architecture que tu rencontreras. Et ELK ? Il vit sur le
segment `10.10.20.x`, derrière le pare-feu : le reste du parc le joint par UNE adresse
sur le LAN, traduite par OPNsense, et seuls cinq ports passent. Il n'a jamais vu Internet
de sa vie — et il indexe pourtant les logs de tout le lab. Tu construiras cette mécanique
complète dans les cours 1 à 3. »

## 5. Annonce du TP (2 min)

**À dire** : « À toi : un DEUXIÈME segment isolé, `vmbr2`. Tu y déplaces ta VM 9002, tu
prouves que les deux segments ne se voient PAS… puis tu fais du nœud un routeur pour
qu'ils se parlent. Oui : tu vas configurer ton premier routeur. 30 minutes, indices dans
tp.md. Au prochain chapitre, on arrête de créer les VMs une par une : les templates. »
