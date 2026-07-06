# Chemin A — Proxmox dans VirtualBox

⏱️ **Temps cible : 45 minutes.**

Tu vas installer Proxmox **dans une machine virtuelle** sur ton PC. Oui, c'est un hyperviseur dans un hyperviseur — on appelle ça de la virtualisation « imbriquée » (*nested*). C'est parfait pour apprendre : si tu casses quelque chose, tu supprimes la VM et tu recommences.

**Prérequis :**
- Un PC avec **16 Go de RAM minimum** (on va en donner 8 à Proxmox).
- Environ **20 Go d'espace disque libre** (le disque de 100 Go est alloué dynamiquement : il ne prend que la place réellement utilisée).
- La virtualisation activée dans le BIOS (VT-x chez Intel, AMD-V chez AMD). On y revient plus bas.

---

## Étape 1 — Télécharger les deux outils

1. **VirtualBox 7.x** : va sur [virtualbox.org](https://www.virtualbox.org/wiki/Downloads) et télécharge la version pour ton système (Windows, macOS ou Linux). Installe-le comme n'importe quel logiciel.
2. **L'ISO Proxmox VE** : va sur [proxmox.com/downloads](https://www.proxmox.com/en/downloads) et télécharge le **Proxmox VE 9.x ISO Installer** (prends la dernière version 9.x). C'est un fichier d'environ 1,5 Go. Une ISO, c'est l'image d'un DVD d'installation — sauf qu'ici, pas besoin de DVD.

---

## Étape 2 — Créer la machine virtuelle

Ouvre VirtualBox et clique sur **Nouvelle** (ou « New »). Renseigne :

| Champ | Valeur |
|---|---|
| Nom | `proxmox-lab` |
| Type | Linux |
| Version | Debian (64-bit) |
| Mémoire (RAM) | **8192 Mo** |
| Processeurs | **2 vCPU** |
| Disque dur | VDI, **100 Go**, **alloué dynamiquement** |

Pourquoi Debian ? Parce que Proxmox est construit sur Debian. VirtualBox n'a pas de profil « Proxmox », donc on lui dit « Debian » et tout va bien.

Si l'assistant te propose de choisir l'ISO tout de suite, sélectionne l'ISO Proxmox téléchargée à l'étape 1. Sinon, tu pourras l'attacher dans **Configuration → Stockage → lecteur optique**.

⚠️ **Ne démarre pas encore la VM.** Il reste deux réglages cruciaux.

---

## Étape 3 — Activer la virtualisation imbriquée (CRUCIAL)

Proxmox est lui-même un hyperviseur : son métier, c'est de créer des VMs. Mais là, il tourne déjà dans une VM. Sans ce réglage, Proxmox ne pourra **pas créer de VMs à l'intérieur** — et tout le cours repose là-dessus.

Ferme VirtualBox... non, laisse-le ouvert mais ouvre un **terminal** et tape :

```bash
VBoxManage modifyvm "proxmox-lab" --nested-hw-virt on
```

- **Windows** : lance la commande depuis l'invite de commandes, dans le dossier d'installation de VirtualBox (`C:\Program Files\Oracle\VirtualBox`), ou ajoute ce dossier au PATH.
- **macOS / Linux** : la commande marche directement dans le terminal.

Pas de message ? C'est bon signe : la commande réussit en silence.

**Prérequis côté BIOS** : la virtualisation matérielle (**VT-x** chez Intel, **AMD-V/SVM** chez AMD) doit être activée sur ton PC hôte. Sur la plupart des PC récents, elle l'est déjà. Si Proxmox affiche une erreur KVM au démarrage, c'est le suspect n°1 — voir la section « Ça coince ? ».

---

## Étape 4 — Configurer le réseau

Va dans **Configuration → Réseau** de la VM `proxmox-lab` :

1. **Adaptateur 1** : mode **« Réseau NAT »** (NAT tout court dans VirtualBox suffit ici). Ta VM vivra dans un petit réseau privé `10.0.2.0/24` que VirtualBox fabrique pour elle.
2. Clique sur **Avancé → Redirection de ports** et ajoute deux règles :

| Nom | Port hôte | Port invité | Pourquoi |
|---|---|---|---|
| gui | 8006 | 8006 | L'interface web de Proxmox |
| ssh | 2222 | 22 | L'accès SSH (utile plus tard) |

**À quoi ça sert ?** Ta VM est enfermée dans son réseau privé : ton PC ne peut pas la joindre directement. La redirection de port fait le pont : quand tu tapes `localhost:8006` sur ton PC, VirtualBox transmet à la VM sur son port 8006. Sans ces règles, l'interface Proxmox restera inaccessible.

---

## Étape 5 — Installer Proxmox, écran par écran

Démarre la VM. Elle boote sur l'ISO et affiche le menu Proxmox. Choisis **Install Proxmox VE (Graphical)**.

1. **EULA** : la licence. Lis-la si tu veux, puis **I agree**.
2. **Target Harddisk** : le disque cible. Il n'y en a qu'un — ton VDI de 100 Go. Laisse tel quel, **Next**.
3. **Country / Time zone / Keyboard** : **France**, fuseau Europe/Paris, clavier **French**. Sinon ton mot de passe sera tapé en QWERTY sans que tu le saches...
4. **Password / Email** :
   - Mot de passe **root** : choisis-le, et **note-le quelque part**. Sérieusement. C'est LA clé de ton serveur.
   - Email : le tien (Proxmox s'en sert pour des alertes ; en lab, peu importe).
5. **Management Network Configuration** — recopie exactement :

| Champ | Valeur |
|---|---|
| Hostname (FQDN) | `pve-lab.home.lab` |
| IP Address (CIDR) | `10.0.2.15/24` |
| Gateway | `10.0.2.2` |
| DNS Server | `10.0.2.3` |

Ces valeurs ne sortent pas d'un chapeau : `10.0.2.2` et `10.0.2.3` sont la passerelle et le DNS que VirtualBox fournit dans son réseau NAT, et `10.0.2.15` est l'adresse qu'il réserve à ta VM.

6. **Summary** : vérifie, puis **Install**. Va boire un café, ça prend 5-10 minutes.
7. À la fin, la VM redémarre. Si elle reboote sur l'installateur, éjecte l'ISO (**Périphériques → Lecteurs optiques → Éjecter**) et redémarre.

Quand tu vois un écran texte avec une invite de connexion et une URL en `https://...:8006`, c'est gagné.

---

## Étape 6 — Premier accès à l'interface web

Sur ton PC (pas dans la VM !), ouvre un navigateur et va sur :

```
https://localhost:8006
```

Grâce à la redirection de port de l'étape 4, `localhost:8006` arrive directement sur ta VM.

😱 **« Votre connexion n'est pas privée » ?** C'est normal. Proxmox utilise un certificat **auto-signé** : le chiffrement fonctionne, mais personne n'a « garanti » l'identité du serveur auprès de ton navigateur. Comme ce serveur, c'est toi, aucun risque ici. Clique sur **Paramètres avancés → Continuer vers le site**.

Écran de connexion :

- **User name** : `root`
- **Password** : celui que tu as noté (tu l'as noté, hein ?)
- **Realm** : **Linux PAM standard authentication**

Clique sur **Login**. Une fenêtre te dit que tu n'as pas de licence (« No valid subscription ») : ferme-la, c'est juste un rappel commercial, tout fonctionne sans.

🎉 Tu es dans Proxmox. Ton hyperviseur tourne.

---

## Ça coince ?

**1. Erreur KVM au démarrage de Proxmox (ou plus tard, impossible de démarrer une VM dans Proxmox)**
Message du genre `KVM virtualisation not available` ou erreur mentionnant `kvm`. Deux causes possibles :
- Tu as sauté l'étape 3 → lance la commande `VBoxManage modifyvm "proxmox-lab" --nested-hw-virt on` (VM éteinte), puis redémarre-la.
- **VT-x / AMD-V est désactivé dans le BIOS de ton PC.** Redémarre le PC, entre dans le BIOS (souvent touche `Suppr`, `F2` ou `F10` au démarrage), cherche « Intel VT-x », « Intel Virtualization Technology » ou « SVM Mode », mets sur **Enabled**, sauvegarde.

**2. `https://localhost:8006` ne répond pas**
Tu as oublié la redirection de port (étape 4). Vérifie **Configuration → Réseau → Avancé → Redirection de ports** : il faut la règle hôte **8006** → invité **8006**. Vérifie aussi que la VM est bien démarrée et que l'installation est terminée.

**3. La page ne charge pas alors que tout semble bon**
Deux oublis classiques dans l'URL :
- Tu as tapé `http://` au lieu de **`https://`** (le « s » est obligatoire, Proxmox refuse le http).
- Tu as oublié le **`:8006`** à la fin. Proxmox n'écoute pas sur le port standard du web.
L'URL complète, c'est bien : `https://localhost:8006`.

---

✅ **Terminé ?** Retourne sur [lab-cours-0.md](lab-cours-0.md) pour la vérification finale, puis file au chapitre 2.
