# Chapitre 2 — Installer Proxmox : script vidéo

> Durée cible : ~30 min. Prérequis élève : Proxmox fraîchement installé via un des deux
> guides labs/ (chemin A VirtualBox → `https://localhost:8006`, chemin B PC dédié →
> `https://192.168.1.240:8006`).

---

## 1. Le concept (≤ 5 min) — « C'est quoi un hyperviseur ? »

### À dire (idées et phrases clés)
- « Tu as installé Proxmox. Mais qu'est-ce que tu viens d'installer exactement ? Pas un
  logiciel qu'on lance : un système d'exploitation dont le seul métier est de faire tourner
  d'autres machines. Ça s'appelle un hyperviseur. »
- Il existe deux familles :
  - **Type 1 (bare-metal)** : l'hyperviseur EST le système. Il parle directement au
    matériel. Proxmox, ESXi, Hyper-V sont de cette famille. C'est ce qu'on utilise en
    entreprise et dans les datacenters.
  - **Type 2 (application)** : l'hyperviseur est un logiciel installé PAR-DESSUS ton OS
    habituel. VirtualBox, VMware Workstation. Pratique pour tester, moins performant.
- Clin d'œil chemin A : « Si tu as suivi le chemin VirtualBox, tu fais tourner un
  hyperviseur de type 1… dans un hyperviseur de type 2. C'est légal, et c'est exactement
  comme ça qu'on apprend sans casser sa machine. »
- Pourquoi Proxmox et pas un autre ?
  1. **Libre et gratuit** — pas de licence à payer pour apprendre ni pour ton homelab.
  2. **GUI web** — tout se pilote depuis un navigateur, pas besoin d'un client lourd.
  3. **Communauté énorme** — forums, wiki, Reddit : ton problème a déjà été résolu.
  4. **Utilisé en entreprise** — ce que tu apprends ici, tu le remets sur ton CV.

### À montrer à l'écran
- Schéma ASCII (slide ou terminal plein écran) :

```
        TYPE 1 (bare-metal)                  TYPE 2 (application)
  ┌──────┐ ┌──────┐ ┌──────┐             ┌──────┐ ┌──────┐
  │ VM 1 │ │ VM 2 │ │ VM 3 │             │ VM 1 │ │ VM 2 │
  └──────┘ └──────┘ └──────┘             └──────┘ └──────┘
  ┌────────────────────────┐             ┌────────────────────────┐
  │  HYPERVISEUR (Proxmox) │             │ HYPERVISEUR (VirtualBox)│
  ├────────────────────────┤             ├────────────────────────┤
  │        MATÉRIEL        │             │   OS (Windows/macOS)   │
  └────────────────────────┘             ├────────────────────────┤
                                         │        MATÉRIEL        │
                                         └────────────────────────┘
```

- Puis bascule sur la GUI Proxmox : tour rapide de l'interface (60-90 s max) :
  - Panneau de gauche = l'arborescence **Datacenter → nœud → VM**. « Datacenter, c'est
    l'ensemble ; le nœud, c'est TA machine physique ; en dessous viendront tes VMs — pour
    l'instant c'est vide, et c'est normal. »
  - Cliquer sur le nœud : montrer le résumé (CPU, RAM, disque) et l'onglet Shell.
  - « Retiens juste la logique de l'arbre. On explorera le reste au fil des chapitres. »

---

## 2. Démo guidée (15 min) — la post-installation

> Toutes les commandes sont dans `demo.sh`, exécutées dans l'ordre, SUR le nœud, en root
> (GUI → nœud → Shell, ou SSH). Rejouer le script sur le lab avant tournage.

### 2.1 — Le popup « No valid subscription » et les dépôts enterprise

**À dire** : « Première connexion à la GUI : un popup te dit que tu n'as pas d'abonnement.
Ce n'est PAS une erreur, Proxmox est 100 % fonctionnel sans abonnement. Mais par défaut,
Proxmox est configuré pour télécharger ses mises à jour depuis les dépôts *enterprise*,
réservés aux clients payants. Sans abonnement, `apt update` va donc échouer avec une
erreur 401 Unauthorized. La solution officielle : basculer sur le dépôt communautaire
*no-subscription* — mêmes paquets, testés un peu moins longtemps, parfaits pour un homelab. »

**À montrer** :
- D'abord la panne volontairement : `apt update` avec les dépôts enterprise encore en
  place → montrer l'erreur 401 sur `enterprise.proxmox.com`. « Regarde bien cette erreur,
  elle reviendra dans le quiz. »
- Puis les deux commandes de demo.sh :

```bash
cat > /etc/apt/sources.list.d/pve-no-subscription.list <<'EOF'
deb http://download.proxmox.com/debian/pve trixie pve-no-subscription
EOF
rm -f /etc/apt/sources.list.d/pve-enterprise.list /etc/apt/sources.list.d/ceph.list
```

**Résultat attendu** : aucune sortie (silence = succès). Expliquer : on écrit un nouveau
fichier de dépôt, on supprime les deux fichiers enterprise (PVE et Ceph). « `trixie`, c'est
le nom de la version Debian sur laquelle Proxmox est construit. »

### 2.2 — Mise à jour complète

```bash
apt update && apt -y full-upgrade
```

**À dire** : « `apt update` rafraîchit la liste des paquets — cette fois sans erreur 401.
`full-upgrade` installe tout. Ça peut prendre plusieurs minutes juste après une
installation : c'est le bon moment pour un café. » (Couper/accélérer au montage.)

**Résultat attendu** : `apt update` liste les dépôts `download.proxmox.com` sans erreur ;
le full-upgrade se termine sur une invite propre. Si un nouveau noyau a été installé,
mentionner qu'un reboot est une bonne idée.

### 2.3 — Vérifications (expliquer chaque sortie)

```bash
pveversion
```
**Attendu** : une ligne du type `pve-manager/9.x.y/...`. « C'est TA version. Quand tu
demandes de l'aide sur un forum, c'est la première chose qu'on te demandera. »

```bash
ss -tlnp | grep 8006
```
**Attendu** : une ligne `LISTEN ... *:8006 ... pveproxy`. « Décodons : `ss` liste les
sockets, `-t` TCP, `-l` en écoute, `-n` ports en chiffres, `-p` le processus. On voit que
`pveproxy` — le serveur web de la GUI — écoute sur le port 8006. Garde cette commande en
tête, elle va nous resservir dans cinq minutes. »

```bash
df -h /
```
**Attendu** : la racine avec son pourcentage d'utilisation. « Un Proxmox frais utilise
quelques Go. Si `Use%` approche 90 %, tu auras des ennuis — on apprendra à surveiller ça. »

```bash
free -h
```
**Attendu** : lignes Mem/Swap. « `available`, c'est ce qui reste pour tes futures VMs.
C'est ton budget RAM : chaque VM va piocher dedans. »

---

## 3. Encart vrai matériel (3 min)

**À dire** : « Tout ce qu'on vient de faire, tu l'as fait sur un lab tout neuf. Voilà à
quoi ressemble le MÊME Proxmox après quelques mois de vie : le mien, bare-metal, un i7
avec 31 Go de RAM, qui fait tourner 10 VMs. Rien de magique : c'est exactement la même
interface, le même `pveversion`, le même port 8006. La seule différence, c'est le temps et
les chapitres qu'on va passer ensemble. On le verra grandir pendant toute la formation. »

**Plans à filmer sur l'infra réelle (192.168.1.200)** :
1. La GUI : arborescence Datacenter → nœud avec les 10 VMs dépliées (comparaison visuelle
   avec l'arbre vide de l'élève).
2. Le résumé du nœud : jauges CPU / RAM 31 Go / uptime.
3. Shell sur le nœud réel : `pveversion` puis `free -h` — « mêmes commandes, autre échelle ».
4. (Optionnel, plan B-roll) la machine physique elle-même, pour ancrer le « bare-metal ».

---

## 4. 💥 La panne du vrai monde (5 min) — « La GUI ne répond pas ! »

**Mise en scène** : « Situation vécue par TOUS les débutants. Tu reviens le lendemain, tu
veux te connecter à ta GUI, tu tapes l'adresse dans le navigateur… et rien. »

**Symptôme (à montrer)** : dans le navigateur, taper `https://192.168.1.240` (ou
`https://localhost` en chemin A) — **sans le port**. Résultat : « Impossible de se
connecter » / page inaccessible. Jouer la panique gentiment : « Le serveur est mort ?
J'ai tout cassé avec le full-upgrade ? »

**Diagnostic guidé (à dérouler à voix haute)** :
1. « Avant d'accuser le service, on va VÉRIFIER. Est-ce que la machine répond ? » — ouvrir
   la console du nœud (VirtualBox ou écran physique) : la machine est vivante, on peut se
   connecter en root. Donc pas un crash.
2. « Est-ce que le service web tourne ? » — sur le nœud :
   ```bash
   ss -tlnp | grep 8006
   ```
   → la ligne `pveproxy ... 8006` est bien là. **Le service écoute.** Il n'est pas mort.
3. Le déclic : « Le service écoute… mais sur le port **8006**. Ton navigateur, quand tu
   tapes `https://` sans rien préciser, va sur le port **443** — le port HTTPS par défaut.
   Et sur 443, chez toi, il n'y a personne. Un service web n'écoute pas forcément sur
   443 : chaque application choisit son port. »

**Fix (à montrer)** : retaper l'URL complète `https://IP:8006` → la page de login
apparaît. Soulagement.

**Morale (phrase clé, à l'écran en gros)** :
> « Avant d'accuser le service, vérifie sur quel port il écoute. »

`ss -tlnp` devient ton premier réflexe de diagnostic — il reviendra dans toute la formation.

---

## 5. Annonce du TP

**À dire** : « À toi de jouer. Le TP du chapitre : d'abord tu refais la post-installation
complète sur TON lab — dépôts no-subscription puis mise à jour. Ensuite, un vrai réflexe
d'admin : ne pas travailler en root tout le temps. Tu vas créer un utilisateur `eleve@pve`
en lecture seule avec le rôle PVEAuditor, te connecter avec, et constater par toi-même
qu'il voit tout mais ne peut rien casser — essaie de créer une VM, tu verras. Compte
20 minutes, les indices sont dans tp.md si tu bloques, la correction dans correction/.
Au prochain chapitre : on crée enfin ta première VM. »
