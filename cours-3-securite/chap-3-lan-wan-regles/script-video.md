# Chapitre 3 — LAN, WAN & premières règles : script vidéo

> 🔄 Encart « vrai matériel » réaligné le 11/10/2026 sur le parc post-pivot VDP — référence : [`docs/infra-reelle-2026-10.md`](../../docs/infra-reelle-2026-10.md).

> Durée cible : ~30 min. Prérequis : le lab de départ du cours 3 (`../lab-depart.md`) — la
> VM OPNsense installée au chapitre 2, 2 NICs (WAN côté Internet, LAN sur bridge isolé),
> ELK qui tourne (segment `10.10.99.0/24`, Kibana en `10.10.99.14:5601`).
> Toutes les commandes de diagnostic montrées sont dans `demo.sh`. L'essentiel de la
> config se fait dans la **console** et le **GUI** OPNsense — pas d'Ansible ici.

## 1. Le concept (6 min)

**À dire** : « Un pare-feu, ce n'est pas une boîte magique : c'est un routeur avec un
videur à l'entrée. Pour le comprendre, trois mots de vocabulaire, une règle d'or, et une
phrase sur le NAT. »

**Les deux interfaces** — dessine deux pattes qui sortent de la boîte OPNsense :

- le **WAN** (*Wide Area Network*) : la **patte côté monde**. C'est par là qu'arrive
  Internet — chez toi, elle est branchée sur ta box FAI.
- le **LAN** (*Local Area Network*) : la **patte côté lab**. C'est ton réseau à toi, tes
  VMs, tes machines de confiance.

« OPNsense est **assis entre les deux**. Tout ce qui va du lab vers Internet, et
d'Internet vers le lab, passe par lui. »

**La règle d'or — le pare-feu par défaut d'OPNsense** :

- il **bloque TOUT ce qui entre par le WAN** (personne d'Internet ne rentre sans qu'on
  l'ait explicitement autorisé) ;
- il **autorise ce qui sort du LAN** (tes machines peuvent aller sur Internet).

« C'est le **bon défaut** : *fermé par défaut côté monde, on ouvre au cas par cas*. À
l'inverse d'une box FAI grand public qui est plutôt permissive, OPNsense part fermé. Tu
n'ouvres que ce dont tu as besoin — retiens cette phrase, c'est toute la philosophie du
cours. »

**L'anatomie d'une règle** — une règle de pare-feu, c'est cinq cases à remplir :

| Case | Question | Exemple |
|---|---|---|
| **Action** | on laisse passer ou on bloque ? | `allow` / `block` |
| **Source** | ça vient d'où ? | `LAN net` (tout le LAN) |
| **Destination** | ça va où ? | `10.10.99.14` |
| **Port** | quel service ? | `5601` (Kibana) |
| **Direction** | sur quelle patte, dans quel sens ? | entrant sur `LAN` |

« Lis une règle comme une phrase : *"autorise (action) le LAN (source) à joindre
10.10.99.14 (destination) sur le port 5601 (port)"*. C'est tout. »

**Le NAT en une phrase** : « quand une VM du LAN sort sur Internet, elle **emprunte
l'adresse du WAN** pour se présenter au monde — le monde ne voit qu'une seule IP, celle
d'OPNsense. C'est le *masquerade* que tu connais déjà du cours 1, appliqué au périmètre.
OPNsense le fait tout seul par défaut du LAN vers le WAN. »

## 2. Démo guidée (12 min)

> Rappel : on est en console série / GUI d'OPNsense. Les commandes shell sont dans
> `demo.sh` ; les manips GUI sont décrites en commentaires.

### 2.1 Assigner les interfaces

**À montrer** (console OPNsense, option **1 — Assign interfaces**) :

- **WAN → `vtnet0`** (la NIC branchée sur le réseau qui a Internet, côté box) ;
- **LAN → `vtnet1`** (la NIC sur le bridge isolé côté lab).

« OPNsense te demande, pour chaque interface, quelle carte physique lui coller. On mappe
WAN sur la première carte (côté box) et LAN sur la seconde (côté lab). »

Vérifier avec `ifconfig` que `vtnet0` (WAN) et `vtnet1` (LAN) sont bien montées.

### 2.2 Donner au LAN une adresse sur un réseau À SOI

**À montrer** (console, option **2 — Set interface IP address**, interface LAN) :

- IPv4 **statique** : `192.168.99.1`, masque `/24` ;
- DHCP serveur sur le LAN : oui (pratique pour que les VMs du lab reçoivent une IP).

**⚠️ MOMENT CLÉ, à dire tout de suite** : « OPNsense propose par défaut `192.168.1.1`
pour le LAN. **Ne le laisse JAMAIS** si ta box est en `192.168.1.x` — on verra dans 5
minutes ce que ça casse. On prend `192.168.99.0/24`, un réseau **à nous**, qui n'est
utilisé nulle part ailleurs. »

Vérifier :

```
netstat -rn
```

**Attendu** : deux réseaux **distincts** dans la table de routage — `192.168.1.0/24` via
le WAN (`vtnet0`), `192.168.99.0/24` via le LAN (`vtnet1`), et **une seule** route par
défaut (`default`) qui pointe vers la box par le WAN. « Chaque réseau a sa ligne, la route
par défaut est claire : OPNsense sait exactement où envoyer chaque paquet. »

### 2.2 bis Un client derrière le pare-feu, et le chemin vers le segment ELK

**À montrer** (`demo.sh` § 2.2 bis) : sur le nœud, cloner `lan-test` (VM 9205, 512 Mo) sur
`vmbr5` en `192.168.99.10`, passerelle `192.168.99.1`. « Aucune de tes VMs ne vit derrière
le pare-feu : il nous faut un figurant. Voilà le poste de bureau du LAN protégé. » Puis les
deux lignes qui relient les mondes : `ip_forward` **persistant** sur le nœud (« au cours 0
on l'avait activé pour un TP ; cette fois c'est pour de bon : le nœud est le routeur entre
ses bridges »), et dans OPNsense une **route statique** `10.10.99.0/24` via le nœud.
« OPNsense ne connaît que ses deux pattes. Le segment ELK est derrière le nœud, pas
derrière la box : il faut le lui dire, sinon il enverra ces paquets à la box, qui les
jettera. » `netstat -rn | grep 10.10.99` sur OPNsense : la route est là.

### 2.3 Vérifier qu'une machine du LAN sort sur Internet (via le NAT par défaut)

**À montrer** : depuis `lan-test` (`ssh alpha@192.168.99.10` depuis le nœud) :

```
ping -c 3 8.8.8.8
```

**Attendu** : ça répond. « La VM du LAN sort sur Internet **sans qu'on ait rien ouvert** :
c'est la règle par défaut *allow LAN → any* + le NAT automatique qui lui prête l'adresse
du WAN. Le défaut fait déjà le travail. »

### 2.4 Écrire une première règle explicite et la tester

**À montrer** (GUI : **Firewall > Rules > LAN > Add**) : une règle lisible, juste pour
prendre le geste en main :

- Action : **Pass** ;
- Interface : **LAN**, Direction **in** ;
- Source : **LAN net** ;
- Destination : **10.10.99.14**, port **5601 (HTTPS/Kibana)** ;
- Description : `LAN -> Kibana`.

**Apply** (bouton en haut). « En GUI, rien n'est actif tant que tu n'as pas cliqué
**Apply changes**. »

**Tester** : depuis `lan-test`, `curl -k -o /dev/null -s -w '%{http_code}\n'
https://10.10.99.14:5601` → `200` (ou `302`) : Kibana répond à travers le pare-feu, le
nœud et le segment.
« Ta première règle explicite vit. Retiens la forme — action, source, destination, port —
on la réutilise au TP pour faire du *moindre privilège*. »

## 3. 💥 La panne du vrai monde — LAN = 192.168.1.1 = la box (7 min)

> Panne **réelle**, vécue sur l'infra (`docs/opnsense.md`). On la rejoue exprès pour la
> comprendre, puis on remet propre.

**Le symptôme** : « Je rebranche OPNsense, et d'un coup : plus d'Internet nulle part, le
GUI d'OPNsense est injoignable, et même les autres machines du foyer rament ou tombent. »

**La cause** : au premier boot, OPNsense assigne son LAN en **`192.168.1.1/24`**. Or ta
**box FAI est elle aussi dans `192.168.1.0/24`** (c'est le cas par défaut de presque
toutes les box). Le WAN d'OPNsense, branché sur la box, reçoit une IP `192.168.1.x`. Tu as
donc **DEUX réseaux avec le même adressage** : le WAN *et* le LAN prétendent tous les deux
être `192.168.1.0/24`.

**Rejouons-la** : remets temporairement le LAN dans `192.168.1.0/24` (console, option 2,
IP `192.168.1.1/24`). Constate : plus de route par défaut fiable, Internet cassé.

**Le diagnostic — la table de routage** :

```
netstat -rn
```

**Ce qu'on voit** : la ligne `192.168.1.0/24` apparaît **en double** (une pour le WAN, une
pour le LAN), et la route `default` ne sait plus par quelle interface partir. OPNsense
reçoit un paquet pour `192.168.1.50`, regarde sa table : deux interfaces correspondent. Il
ne **sait plus** laquelle choisir → les paquets partent au mauvais endroit, ou nulle part.
« Un routeur choisit son interface de sortie d'après le réseau de destination. Si deux
interfaces revendiquent le **même** réseau, ce choix devient impossible. C'est aussi bête
que ça. »

**Le fix** : on remet le LAN sur un réseau **dédié** (console, option 2, LAN =
`192.168.99.1/24`), puis :

```
configctl interface reconfigure lan
netstat -rn
```

**Attendu** : le doublon disparaît, `192.168.99.0/24` (LAN) et `192.168.1.0/24` (WAN) sont
deux lignes distinctes, la route par défaut se réinstalle vers la box. `ping 8.8.8.8` → OK.
GUI de nouveau joignable en `https://192.168.99.1`.

**La morale** : **« deux réseaux avec le même adressage = un routeur qui ne sait plus où
envoyer les paquets. Un subnet, un rôle. C'est la règle que tu liras dans lab-depart, la
voilà en action. »**

## 4. Encart vrai matériel (2 min)

**À filmer / à dire** : « Sur l'infra réelle, ce piège est déjà désamorcé. Le **LAN
d'OPNsense est en `192.168.99.1`** (sur son bridge isolé `vmbr5`), et le **WAN prend une
IP de la box en `192.168.1.x`** (DHCP, ex. `192.168.1.36`). Les deux mondes sont séparés
proprement : un réseau côté lab, un réseau côté box, aucun chevauchement. Un `netstat -rn`
sur la vraie VM montre les lignes distinctes qu'on veut voir — plus une troisième depuis
septembre : `10.10.20.0/24`, le segment où vit ma stack de logs, dont OPNsense est la
passerelle (`10.10.20.254`). Le parc la joint par une **adresse virtuelle** sur le WAN
(`192.168.1.61`) traduite en **NAT 1:1** vers `10.10.20.61` — aucun client n'a changé
d'adresse, c'est tout l'intérêt par rapport à une renumérotation. C'est précisément la
config qu'on vient de reconstruire, avec un étage de plus. »

**💥 Quatre pièges de NAT et de règles, vécus le jour de cette bascule** (en choisir
deux pour la vidéo, garder les autres pour la FAQ) :
- **`blockpriv` sur le WAN** bloquait tout le parc : « bloquer les réseaux privés » est
  juste face à Internet, absurde quand ton "WAN" donne sur un LAN privé. La règle `block
  quick` tranche AVANT tes règles `pass`.
- **`reply-to`**, ajouté d'office aux règles d'une interface WAN, renvoie les réponses à
  la passerelle — la box. Quand le demandeur est sur le MÊME segment, la connexion
  s'établit puis meurt (« timed out during banner exchange »). À désactiver.
- **Le retour en épingle** : un service qui vit DERRIÈRE le pare-feu et s'interroge
  lui-même par son adresse publique sort vers OPNsense pour revenir sur lui-même. Depuis
  l'intérieur : `localhost`. Depuis l'extérieur : l'adresse d'accès. La segmentation
  impose cette distinction.
- **VIP et NAT 1:1 ne s'écrivent pas à la main** dans `config.xml` : sans les identifiants
  que son framework génère, OPNsense a posé un alias `127.0.0.1` sur le WAN. Pour ces deux
  objets, l'interface — ou l'API —, pas l'éditeur.

## 5. Annonce du TP (1 min)

**À dire** : « À toi de passer du "ça marche" au **moindre privilège**. Tu vas écrire une
règle qui autorise **uniquement** le port 5601 (Kibana) depuis ton LAN vers
`10.10.99.14`, et qui **bloque le reste** du segment ELK depuis le LAN. Le lab n'a pas
besoin d'atteindre Elasticsearch ou Logstash directement — alors on ferme. Attention à
**l'ordre des règles** : OPNsense évalue de haut en bas et s'arrête à la première qui
matche. 25 minutes. Au chapitre suivant : les **zones** et un vrai découpage réseau. »
