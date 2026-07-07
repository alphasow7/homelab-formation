# Chapitre 2 — OPNsense : installation : script vidéo

> Durée cible : ~28 min. Prérequis : lab de départ vérifié (`../lab-depart.md` — surtout
> **le piège du subnet**). La VM se crée en `qm` côté Proxmox (voir `demo.sh`), mais
> l'installation elle-même se pilote **dans la console noVNC** — filme-la.
> Toutes les commandes `qm` montrées sont dans `demo.sh` et rejouées avant tournage.

## 1. Le concept (5 min)

**À dire** : « Jusqu'ici, ton lab et Internet vivaient collés l'un à l'autre. À partir
de ce chapitre, on installe entre les deux un **poste de douane** : le **pare-feu de
périmètre**. Tout ce qui entre et sort du lab passe devant lui, et il décide.

Un pare-feu de périmètre a deux côtés, et c'est LA chose à comprendre :

- le **WAN** (Wide Area Network) : le côté « monde », l'extérieur. Par défaut, le pare-feu
  est **méfiant** : il bloque tout ce qui vient de là. Personne n'entre sans invitation.
- le **LAN** (Local Area Network) : le côté « lab », ton réseau interne. C'est le côté
  **de confiance** : tes VMs peuvent sortir, et le pare-feu leur route Internet.

Retiens l'image : **WAN = la rue, LAN = la maison**. La porte laisse sortir les habitants,
mais ne laisse pas entrer n'importe qui.

Pourquoi une **VM dédiée** plutôt que le pare-feu intégré de Proxmox ? Trois raisons :

1. **Séparation des rôles** : Proxmox est ton hyperviseur, pas ton pare-feu. Mélanger les
   deux, c'est mettre le vigile et le coffre-fort dans la même pièce. Si l'un tombe,
   l'autre tombe.
2. **Un vrai OS de pare-feu** : OPNsense, c'est des règles fines, du NAT, du VPN, un IDS
   (détection d'intrusion)… Le filtre de Proxmox ne fait qu'une fraction de ça.
3. **Ça se transpose** : ce que tu apprends sur cette VM, tu le rejoues à l'identique sur
   un **boîtier physique** dédié le jour où tu veux du vrai matériel. Le savoir est
   portable.

Un mot de vocabulaire : **OPNsense**, c'est une **distribution pare-feu libre**, basée sur
**FreeBSD** (un cousin de Linux, très solide côté réseau). Gratuite, sérieuse, utilisée en
entreprise. C'est notre douanier. »

## 2. Préparation de la VM (4 min)

**À dire, en montrant `demo.sh`** : « La VM se crée côté Proxmox, en ligne de commande.
Trois points de vigilance :

**Deux cartes réseau**, et c'est ici que se joue tout le chapitre suivant :

- `net0` → le bridge **WAN**, celui qui a **Internet** (chez moi `vmbr0`, la box du foyer).
- `net1` → le bridge **LAN**, un **bridge ISOLÉ** (`vmbr5`, mon segment `192.168.99.0/24`),
  sans Internet, où ne vivent que le lab et le poste d'admin.

⚠️ **Rappel du piège du lab de départ** : le LAN par défaut d'OPNsense est `192.168.1.1`.
Si ton WAN est branché sur une box en `192.168.1.x` ET que le LAN reste en `192.168.1.1`,
tu as **deux réseaux avec le même adressage** → le pare-feu ne sait plus router, plus
d'Internet, GUI injoignable. On l'évite en mettant le LAN sur le bridge isolé
`192.168.99.0/24`. **Un subnet, un rôle.**

**L'ISO montée en CD** : on prend la version **DVD** d'OPNsense, PAS l'image "serial". On
verra dans un instant pourquoi ce choix n'est pas anodin — c'est la panne du chapitre.

**La console VGA (noVNC)** : on configure la VM en `--vga std`, pas en console série.
Pourquoi ? L'installeur d'OPNsense est en **ncurses** (une interface texte avec des menus,
des cases à cocher). Une interface ncurses **ne se pilote pas proprement en série** — les
flèches, la sélection, l'affichage se corrompent. On l'installe donc à la souris et au
clavier, dans le **noVNC** de Proxmox. »

## 3. Démo (12 min)

> Toute cette section se filme **dans la console noVNC** de la VM (bouton *Console* dans
> Proxmox). Les commandes `qm` de création, elles, sont déjà passées (section 2 / `demo.sh`).

### 3.1 Booter sur l'ISO

**À montrer** : `qm start 600`, puis ouvrir la **Console** (noVNC). OPNsense démarre depuis
l'ISO DVD. Il défile des lignes, puis propose un **login d'installation**.

```
login: installer
password: opnsense
```

**À dire** : « `installer` / `opnsense` — c'est le compte qui lance l'installeur, pas le
compte d'admin final. »

### 3.2 L'installeur ncurses — Install UFS SUR LE DISQUE

**À montrer**, écran par écran :

1. Clavier : accepte la disposition par défaut (*Continue with default keymap*).
2. Menu d'installation : choisis **`Install (UFS)`**.
   > **INSISTE ICI** : « UFS, c'est le système de fichiers **sur le disque**. On installe
   > OPNsense POUR DE BON sur le disque de la VM. On ne reste PAS sur le mode live de
   > l'ISO. Retiens ce mot : **on installe sur disque**. »
3. **Choisis le disque cible** (`da0` / le disque de la VM, ~8-20 Go) → *OK*.
4. Il prévient qu'il va **effacer le disque** → confirme (c'est un disque vierge de VM).
5. Il copie le système. Patiente.
6. **Mot de passe root** : il propose de le changer. Tu peux laisser `opnsense` pour le lab
   (on le changera au 1ᵉʳ login GUI) → *Continue / Complete Install*.

### 3.3 Retirer l'ISO et rebooter sur le disque

**À montrer** :

1. L'installeur propose **`Reboot`** — mais AVANT, **retire l'ISO**. Deux façons :
   - dans Proxmox : VM 600 → *Hardware* → le lecteur CD/DVD → *Edit* → **Do not use any
     media** (ou détacher le `ide2`) ;
   - et t'assurer que le **boot order** pointe sur le disque (`scsi0`/`scsi1`) et plus sur
     le CD.
2. **Reboot**. La VM redémarre — cette fois **depuis le disque**.

**Attendu** : au boot, tu dois voir `Root file system: /dev/gpt/rootfs` (ou `da0`), PAS un
montage depuis le CD. Puis le menu console d'OPNsense avec l'assignation WAN/LAN.

**À dire** : « Voilà. OPNsense est installé sur disque. On a un vrai système, avec une
mémoire. On configurera le réseau au TP — pour l'instant, on a fait le plus important :
poser les fondations sur du **dur**, pas sur du sable. »

## 4. 💥 La panne du vrai monde — la config qui ne survit pas au reboot (7 min)

> **C'est la panne fondatrice de ce chapitre. Elle m'est réellement arrivée sur cette
> infra.** Prends ton temps pour la raconter — c'est la leçon la plus importante du cours.

**À raconter** : « Je vais te raconter comment j'ai perdu une soirée entière. Au tout
début, l'image d'OPNsense que j'avais déployée n'était pas l'ISO DVD : c'était l'image
**"serial"** — et cette image, une fois bootée, est un **LIVE-installer**. Un système qui
tourne **entièrement en mémoire**, comme une clé USB "live" que tu bootes sans rien
installer.

Sauf que je ne le savais pas. Alors j'ai travaillé. J'ai configuré le LAN en
`192.168.99.1`. J'ai branché l'export des logs vers mon SIEM ELK. J'ai activé Suricata,
l'IDS. **Tout marchait.** Le GUI répondait, les logs arrivaient dans Kibana, les alertes
tombaient. J'étais content.

Puis j'ai fait un truc parfaitement banal : **j'ai redémarré la VM.**

Et là… **TOUT avait disparu.** Le LAN était revenu à `192.168.1.1` — donc conflit de
subnet, plus d'Internet, GUI injoignable. L'export des logs : évanoui. Les règles
Suricata : le dossier était **vide**. Des heures de travail, effacées par un simple
reboot. »

**À expliquer (le diagnostic)** : « Voici pourquoi. Sur ce live-installer :

- la racine du système (`/`) est montée en **lecture seule** — tu ne peux rien y écrire de
  durable ;
- et surtout, le dossier de config `/conf` est monté sur **`tmpfs`**.

**`tmpfs`, c'est un système de fichiers qui vit dans la RAM.** Rapide, pratique… et
**totalement volatil** : à l'extinction, la RAM se vide, et tout ce qui était dans `tmpfs`
**part avec**. OPNsense écrivait bien ma config — dans `/conf` — mais `/conf` était de la
RAM déguisée en dossier. Au reboot : page blanche.

**Le diagnostic tient en une commande.** Sur le système, tu tapes :

```
mount | grep conf
```

Si tu vois `/conf` monté sur **`tmpfs`** → **ALERTE ROUGE** : tu es sur un live-system, ta
config ne survivra PAS. Si tu vois `/conf` sur un vrai disque (`/dev/da0…`, UFS) → tu es
tranquille, ça persiste.

**Le fix**, c'est exactement ce qu'on vient de faire ensemble : **installer sur disque**
(`Install UFS`). Une fois installé, `/conf` vit sur le disque, et la config **survit au
reboot**. »

**La morale (à dire lentement, à l'écran)** :

> **Avant d'investir des heures de configuration dans un système, assure-toi qu'il a une
> MÉMOIRE.** Fais un **reboot de contrôle AVANT la config, pas après**. Un système qui
> oublie est **pire** qu'un système cassé : le cassé, tu le vois tout de suite. Celui qui
> oublie, lui, **te fait croire que ça marche** — jusqu'au reboot qui efface ta soirée.

**À dire pour conclure** : « C'est pour ça qu'on a pris l'ISO DVD et qu'on a fait
`Install UFS` dès le départ. Et c'est pour ça qu'au TP, la toute première chose qu'on
validera après la config, c'est : **est-ce que ça survit au reboot ?** »

## 5. Annonce du TP (1 min)

**À dire** : « À toi. Trois missions : (1) refais l'**installation sur disque** de bout en
bout dans le noVNC ; (2) le **reboot-test de persistance** — tu configures le LAN en
`192.168.99.1`, tu redémarres, et tu vérifies qu'il a **SURVÉCU** ; (3) tu ouvres le **GUI**
en https. 30 minutes. Au prochain chapitre : on donne des ordres au douanier — les
**règles LAN / WAN**, et on répare pour de bon le piège du subnet. »
