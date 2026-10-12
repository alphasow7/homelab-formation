# Chapitre 5 — Templates & cloud-init : script vidéo

> 🔄 Encart « vrai matériel » réaligné le 11/10/2026 sur le parc post-pivot VDP — référence : [`docs/infra-reelle-2026-10.md`](../../docs/infra-reelle-2026-10.md).

> Durée cible : ~30 min. Prérequis : chapitres 3-4 (VM 9001 cloud-init sur vmbr1).
> Chapitre volontairement court et jouissif : le « payoff » des efforts des chapitres
> précédents. Pas de « panne du vrai monde » dédiée (dérogation assumée) — remplacée par
> « l'astuce du vrai monde » en fin de démo.

## 1. Le concept (4 min)

**À dire** : « Au chapitre 3, créer une VM prenait 6 commandes. Pour un lab de 5 VMs, ça
fait 30 commandes… et 30 occasions de se tromper. La solution : le **template**. On
prépare UNE VM parfaite — le moule — puis on la fige. Ensuite, chaque nouvelle VM est un
**clone** du moule : une commande, dix secondes. C'est comme ça qu'on passe de
"bricoleur" à "industriel". »

**À montrer** : schéma simple — [image cloud] → VM 9001 configurée → `qm template` →
🔒 moule → clone, clone, clone.

**À dire** : « Attention, transformer une VM en template est **irréversible** : le moule
ne démarre plus jamais. Il sert uniquement à fabriquer. »

## 2. Démo guidée (15 min)

### 2.1 Figer le moule

**À montrer** : bloc 1 de `demo.sh`. Dans la GUI, l'icône de la VM 9001 change.

### 2.2 Trois VMs chrono en main

**À dire** : « Chrono à l'écran. Trois clones, trois IP, trois démarrages. » **À
montrer** : bloc 2 — la boucle `for`. Expliquer la lecture : `910$i` → 9101/9102/9103,
chaque clone reçoit SA propre config cloud-init (`ip=10.10.99.2$i`).

**Attendu** : bloc 3 — `qm list` montre les 3 clones `running`, et les 3 `ssh ... hostname`
répondent `clone-1`, `clone-2`, `clone-3`. Arrêter le chrono : « moins d'une minute pour
trois serveurs. »

### 2.3 💡 L'astuce du vrai monde (3 min)

**À dire** : « Pourquoi les 3 clones n'ont-ils pas la même adresse, le même nom, la même
identité ? Parce que **cloud-init régénère l'identité de chaque clone au premier boot** —
notamment la "machine-id". Si tu clones un jour une VM SANS cloud-init, tu auras 3
machines avec la même identité… et en DHCP, potentiellement la même IP : le chaos. Morale :
clone toujours depuis un template cloud-init. »

## 3. Encart vrai matériel (2 min)

**À filmer** : la GUI réelle — le template `901` (`template-debian12`) sur la tour
(vérifier qu'il existe encore : `qm list` sur la tour), et le dossier des images cloud
(`/var/lib/vz/template/iso/` : Debian 12, Rocky 9, Rocky 10, Ubuntu 24.04).

**À dire** : « Chez moi, le moule existe aussi — un template Debian 12, le jumeau du
tien. Mais regarde les images à côté : Rocky 9 pour la plateforme, Rocky 10 et Ubuntu
pour les labs. Un moule par famille d'OS. Et une subtilité apprise à mes dépens : sur ZFS,
les VMs de ma plateforme ne sont PAS clonées depuis un template mais importées directement
depuis l'image (`import-from`) — un `qm clone` d'image cloud y a produit des kernel
panic. Le principe reste le même : une image de référence, cloud-init, et jamais
d'installateur. Au cours 1, tu verras encore mieux : Ansible qui crée ET configure tout
seul. Le moule + le robot. »

## 4. Annonce du TP (2 min)

**À dire** : « À toi de fabriquer TON moule — le "template doré" id 9000, propre, à jour,
qui servira à TOUS les cours suivants. C'est un investissement : 20 minutes aujourd'hui,
des heures gagnées ensuite. »
