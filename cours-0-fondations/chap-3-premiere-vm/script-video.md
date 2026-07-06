# Chapitre 3 — Ta première VM : script vidéo

> Durée cible : ~30 min. Prérequis élève : Proxmox 9 post-installé (chapitre 2), dépôts
> no-subscription, système à jour. Chemin A : VirtualBox, réseau NAT 10.0.2.0/24, GUI via
> `https://localhost:8006`. Chemin B : PC dédié sur le LAN 192.168.1.0/24. Bridge par
> défaut : `vmbr0`.

---

## 1. Le concept (≤ 5 min) — « Deux façons de créer une VM »

### À dire (idées et phrases clés)
- « Ton Proxmox est prêt, mais son arbre est vide. Aujourd'hui, on y met la première VM.
  Et il y a deux façons de faire, très différentes. »
- **Façon 1 : l'ISO.** « L'ISO, c'est le DVD d'installation. Tu démarres la VM dessus, et
  l'installateur te pose 20 minutes de questions : la langue, le clavier, le fuseau
  horaire, le partitionnement, le mot de passe… Exactement comme installer Debian sur un
  vrai PC. C'est très bien pour comprendre, très mauvais pour aller vite. »
- **Façon 2 : l'image cloud + cloud-init.** « L'image cloud, c'est une VM PRÉ-INSTALLÉE :
  un Debian déjà installé par l'équipe Debian, empaqueté dans un fichier. Il ne manque que
  la personnalisation : quel utilisateur, quelle clé SSH, quelle IP. C'est le rôle de
  cloud-init : une étiquette de personnalisation collée à la VM, qu'elle lit à son premier
  démarrage. Résultat : 2 minutes au lieu de 20. »
- « C'est comme ça que fonctionnent AWS, Azure, tous les clouds : personne ne clique dans
  un installateur. On prend une image, on colle une étiquette, on démarre. »

### Vocabulaire (à l'écran, mots-clés en gros)
- **image qcow2** : le format de fichier disque des images cloud — un disque de VM déjà
  installé, dans un seul fichier.
- **cloud-init** : le programme, à l'intérieur de l'image, qui lit « l'étiquette » au
  premier démarrage et applique : utilisateur, clé SSH, IP.
- **ISO** : le DVD d'installation classique, avec ses 20 minutes de questions.

### À montrer à l'écran — schéma ASCII comparatif

```
        FAÇON 1 : ISO                        FAÇON 2 : IMAGE CLOUD + CLOUD-INIT
  ┌──────────────────────┐                 ┌──────────────────────┐
  │  ISO = DVD vierge    │                 │  qcow2 = Debian déjà │
  │  d'installation      │                 │  installé (fichier)  │
  └──────────┬───────────┘                 └──────────┬───────────┘
             │ boot                                   │ + étiquette cloud-init
             ▼                                        │   (user, clé SSH, IP)
  ┌──────────────────────┐                            ▼
  │ Installateur Debian  │                 ┌──────────────────────┐
  │ « Langue ? Clavier ? │                 │ 1er boot : cloud-init│
  │ Fuseau ? Disque ?    │                 │ lit l'étiquette et   │
  │ Mot de passe ?… »    │                 │ personnalise la VM   │
  │      ~20 minutes     │                 │      ~2 minutes      │
  └──────────┬───────────┘                 └──────────┬───────────┘
             ▼                                        ▼
        VM utilisable                            VM utilisable
```

- Phrase de transition : « On va faire les deux. La façon 1 juste pour la voir. La façon
  2 pour de vrai — c'est LA méthode de toute la formation. »

---

## 2. Démo guidée (15 min)

> Toutes les commandes CLI sont dans `demo.sh`, exécutées dans l'ordre, SUR le nœud, en
> root (GUI → nœud → Shell, ou SSH). Rejouer le script sur le lab avant tournage.

### 2.1 — La façon ISO, en GUI (rapide, ~4 min, on ne va PAS au bout)

**À dire** : « D'abord la méthode classique, pour que tu saches qu'elle existe et que tu
reconnaisses les écrans. »

**À montrer** (GUI uniquement, aucune commande) :
- Datacenter → nœud → local → ISO Images : montrer où on téléverse/télécharge une ISO
  Debian (bouton « Download from URL » — ne pas attendre la fin du téléchargement au
  montage).
- Bouton **Create VM** en haut à droite : dérouler les onglets en les commentant vite :
  - **General** : nom, VM ID — « chaque VM a un numéro unique » ;
  - **OS** : choisir l'ISO Debian ;
  - **Disks / CPU / Memory** : laisser les défauts, « on dimensionnera au chapitre
    suivant » ;
  - **Network** : `vmbr0` — « le bridge par défaut, on en reparle au chapitre 4 ».
- Démarrer la VM, ouvrir la Console : l'écran de l'installateur Debian apparaît.
- **STOP ici.** À dire : « Et là… langue, clavier, fuseau, partitionnement, mot de
  passe… 20 minutes de questions plus tard, tu aurais un Debian. On ne va pas se les
  infliger. On arrête cette VM, on la supprime, et on passe à la vraie méthode. »
- Supprimer la VM de test (clic droit → Remove). « Détruire une VM ratée, c'est gratuit.
  C'est toute la beauté de la virtualisation. »

### 2.2 — LA méthode du cours : cloud-init en CLI (~11 min)

**À dire** : « Maintenant la façon 2. Ouvre le Shell du nœud. Cinq blocs de commandes, et
à la fin tu as une VM qui tourne. » (Tout est dans `demo.sh`.)

#### Étape 1 — Télécharger l'image cloud (~350 Mo)

```bash
wget -nc https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-generic-amd64.qcow2 \
  -O /var/lib/vz/template/iso/debian-12-cloud.qcow2
```

**À dire** : « On télécharge le Debian pré-installé, au format qcow2, depuis le site
officiel de Debian. `-nc` = *no clobber* : si le fichier est déjà là, on ne le
retélécharge pas. » **Résultat attendu** : barre de progression wget, ~350 Mo, puis
`'/var/lib/vz/template/iso/debian-12-cloud.qcow2' saved`. (Accélérer au montage.)

#### Étape 2 — Créer la VM et lui donner ce disque

```bash
qm create 9001 --name demo-vm --memory 1024 --cores 1 --net0 virtio,bridge=vmbr0
qm importdisk 9001 /var/lib/vz/template/iso/debian-12-cloud.qcow2 local-lvm
qm set 9001 --scsihw virtio-scsi-pci --scsi0 local-lvm:vm-9001-disk-0
```

**À dire** : « `qm`, c'est l'outil en ligne de commande de Proxmox pour les VMs — tout ce
que fait la GUI, `qm` le fait aussi. Trois temps : on CRÉE une coquille de VM (id 9001,
1 Go de RAM, 1 cœur, carte réseau sur `vmbr0` — le bridge par défaut) ; on IMPORTE le
qcow2 comme disque dans le stockage `local-lvm` ; on ATTACHE ce disque au contrôleur de
la VM. » **Résultat attendu** : `qm importdisk` affiche une progression de transfert puis
`Successfully imported disk as 'unused0:local-lvm:vm-9001-disk-0'` ; les `qm set` sont
avares en sortie — montrer dans la GUI (VM 9001 → Hardware) que le disque `scsi0` est
apparu.

#### Étape 3 — Brancher cloud-init

```bash
qm set 9001 --ide2 local-lvm:cloudinit --boot order=scsi0 --serial0 socket
qm set 9001 --ciuser alpha --sshkeys ~/.ssh/id_ed25519.pub --ipconfig0 ip=dhcp
```

**À dire** : « Le cœur du chapitre. Première ligne : on ajoute un mini-lecteur CD spécial
(`ide2`) — c'est le support physique de l'étiquette cloud-init, que Proxmox regénère à
chaque démarrage de la VM. Deuxième ligne : on écrit l'étiquette elle-même :
`--ciuser alpha` crée l'utilisateur, `--sshkeys` colle ta clé SSH, `--ipconfig0 ip=dhcp`
demande une IP automatique. »

**⚠️ Insister lourdement (zoom écran)** : « `--sshkeys` prend le **chemin du fichier de
clé PUBLIQUE** — celui qui finit en `.pub`. Pas le contenu de la clé, et surtout PAS la
clé privée : la privée ne quitte JAMAIS ton poste. Si tu n'as pas de clé sur le nœud,
`ssh-keygen -t ed25519` t'en fait une (chapitre 0). »

**Résultat attendu** : pas de sortie (silence = succès). Montrer dans la GUI : VM 9001 a
maintenant un onglet **Cloud-Init** qui affiche user `alpha`, la clé, `ip=dhcp`. « Cet
onglet, c'est l'étiquette vue depuis la GUI — retiens où il est, il resservira. »

#### Étape 4 — Démarrer et trouver l'IP

```bash
qm start 9001
sleep 20
qm guest cmd 9001 network-get-interfaces 2>/dev/null \
  || echo "agent pas encore prêt — l'IP est visible dans la GUI (VM 9001 > Summary)"
```

**À dire** : « On démarre. Cloud-init lit son étiquette pendant ce premier boot : il crée
l'utilisateur `alpha`, installe ta clé, demande une IP au DHCP. On attend 20 secondes,
puis on demande son IP à l'agent invité. » **Résultat attendu** : soit un JSON avec les
interfaces et l'adresse IP, soit — très probable au premier boot, l'agent n'est pas
encore prêt — le message de repli : l'IP se lit alors dans la GUI (VM 9001 → Summary) ou
dans la Console (`ip a` après login). Ne pas paniquer à l'écran : « les deux chemins
mènent à l'IP ».

#### Vérification finale — la connexion SSH

**À montrer** : depuis le poste (chemin B) ou le nœud (chemin A, réseau NAT) :

```bash
ssh alpha@<IP-de-la-VM>
```

→ prompt `alpha@demo-vm:~$` **sans mot de passe** — c'est la clé qui authentifie.
« Deux minutes chrono depuis le `qm create`. Aucune question, aucun installateur. Voilà
pourquoi c'est LA méthode. »

---

## 3. Encart vrai matériel (3 min)

**À dire** : « Tu te demandes peut-être si cette méthode cloud-init, c'est un truc de
formation. Réponse : sur mon infra réelle, les 10 VMs que tu as vues au chapitre 2 sont
TOUTES nées exactement comme ça — image cloud + cloud-init, orchestrées par un outil
d'automatisation qui s'appelle Ansible (on le croisera plus tard). Personne, jamais, n'a
cliqué dans un installateur Debian sur cette machine. La méthode que tu viens d'apprendre,
c'est la méthode de production. »

**Plans à filmer sur l'infra réelle (192.168.1.200)** :
1. GUI : cliquer sur 2-3 VMs différentes → onglet **Cloud-Init** : montrer que chacune a
   son user, sa clé, son ipconfig — « même étiquette, valeurs différentes ».
2. Shell du nœud réel : `qm cloudinit dump <vmid> user` sur une vraie VM — « la même
   commande que celle qu'on va utiliser dans deux minutes pour diagnostiquer une panne ».
3. (Optionnel, B-roll) faire défiler la liste des 10 VMs : « dix étiquettes, zéro clic
   d'installateur ».

---

## 4. 💥 La panne du vrai monde (5 min) — « Permission denied (publickey) »

> Incident réellement vécu sur le chantier de l'infra du formateur — on le rejoue tel quel.

**Mise en scène** : « Situation : tu changes de poste — nouveau PC, ou tu as regénéré ta
clé SSH avec `ssh-keygen`. Ta VM 9001 tourne toujours, tu veux t'y connecter… »

**Symptôme (à montrer)** :

```bash
ssh alpha@<IP-de-la-VM>
```

→ `alpha@<IP>: Permission denied (publickey).`

Jouer la panique gentiment : « La VM est morte ? Cloud-init est cassé ? J'ai perdu ma
VM ? »

**Diagnostic guidé (à dérouler à voix haute)** :
1. « Avant d'accuser la VM, on VÉRIFIE — réflexe du chapitre 2. La VM répond au ping,
   la GUI la montre *running* : elle est vivante. Le problème est ailleurs. »
2. « `publickey`, ça pointe vers la clé. Quelle clé la VM connaît-elle ? Cloud-init a une
   commande pour relire l'étiquette : »
   ```bash
   qm cloudinit dump 9001 user
   ```
   → dans la sortie YAML, section `ssh_authorized_keys` : c'est **l'ANCIENNE clé**.
   Comparer à l'écran avec `cat ~/.ssh/id_ed25519.pub` (la nouvelle) : elles diffèrent.
3. Le déclic : « Mais attends — je peux juste mettre à jour l'étiquette, non ? Oui, MAIS :
   cloud-init n'applique son étiquette **qu'au démarrage** de la VM. Changer l'étiquette
   d'une VM qui tourne ne change rien en vol. »

**Fix (à montrer)** :

```bash
qm set 9001 --sshkeys ~/.ssh/id_ed25519.pub     # la NOUVELLE clé publique
qm stop 9001 && qm start 9001                   # stop/start, PAS reboot !
```

**⚠️ Le piège dans le piège (zoom écran)** : « Pourquoi stop/start et pas un simple
reboot ? Parce qu'un reboot À L'INTÉRIEUR de la VM ne demande pas à Proxmox de regénérer
le mini-CD cloud-init : la VM redémarrerait avec la VIEILLE étiquette. C'est le
stop/start côté Proxmox qui reconstruit le lecteur `ide2` avec la nouvelle config. »
(Incident vécu : c'est exactement là que le formateur a perdu une heure.)

Puis : `ssh alpha@<IP>` → connexion OK. Soulagement.

**Morale (phrase clé, à l'écran en gros)** :
> « Cloud-init lit son étiquette au démarrage, pas en vol. Nouvelle étiquette ⇒
> stop/start. »

Et le réflexe à retenir : `qm cloudinit dump <vmid> user` — « pour voir ce que la VM
croit, pas ce que tu crois ».

---

## 5. Annonce du TP

**À dire** : « À toi de jouer. Le TP : tu crées une DEUXIÈME VM, id 9002, nommée
`demo-vm2`, avec exactement la même méthode — mais cette fois avec une **IP statique** au
lieu du DHCP, parce qu'un serveur dont l'adresse change tous les matins, ce n'est pas un
serveur. Puis tu prouves que ça marche : une connexion SSH par clé qui te répond
`demo-vm2`. Compte 25 minutes, les indices sont dans tp.md, la correction dans
correction/. Au prochain chapitre : on ouvre le capot du réseau — ce fameux `vmbr0` qu'on
tape depuis deux chapitres sans savoir ce que c'est. »
