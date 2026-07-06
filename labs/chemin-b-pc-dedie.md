# Chemin B — Proxmox sur un vieux PC dédié

⏱️ **Temps cible : 45 minutes** (hors préparation de la clé USB).

Ici, pas de VirtualBox : Proxmox s'installe **directement sur le PC**, comme un vrai serveur. C'est le setup le plus proche de la réalité.

> 💡 C'est exactement le setup de l'infra du formateur : un i7 avec 31 Go de RAM qui fait tourner 10 VMs — tu verras cette machine dans les encarts « vrai matériel » de chaque chapitre.

⚠️ **Tout le disque du PC sera effacé.** Vérifie qu'il n'y a rien à sauver dessus avant de commencer.

**Prérequis :**
- Un PC libre : **8 Go de RAM minimum, 16 recommandé**, 64 bits, avec VT-x (Intel) ou AMD-V/SVM (AMD).
- Une **clé USB de 4 Go minimum** (elle sera effacée aussi).
- L'**ISO Proxmox VE 9.x** : télécharge-la sur [proxmox.com/downloads](https://www.proxmox.com/en/downloads) (dernière version 9.x).

---

## Étape 1 — Créer la clé USB bootable

L'ISO ne se copie pas comme un fichier normal : il faut l'« écrire » sur la clé pour qu'elle devienne démarrable.

### Windows / macOS : balenaEtcher

1. Télécharge [balenaEtcher](https://etcher.balena.io/) et installe-le.
2. Ouvre-le : **Flash from file** → choisis l'ISO Proxmox.
3. **Select target** → choisis ta clé USB (vérifie la taille pour ne pas te tromper).
4. **Flash!** — deux minutes plus tard, c'est prêt.

### Linux : la commande `dd`

```bash
sudo dd if=proxmox.iso of=/dev/sdX bs=4M status=progress
```

🛑 **Attention, `dd` ne pardonne pas.** Remplace `/dev/sdX` par le device de **ta clé USB**, pas de ton disque système. Pour l'identifier, lance `lsblk` avant et après avoir branché la clé : le nouveau venu (par exemple `/dev/sdb`), c'est elle. Utilise le device entier (`/dev/sdb`), **pas** une partition (`/dev/sdb1`). Si tu te trompes de device, tu effaces ton propre système. Vérifie deux fois.

---

## Étape 2 — Régler le BIOS du PC cible

Branche la clé sur le PC cible, allume-le, et entre dans le BIOS (touche `Suppr`, `F2`, `F10` ou `F12` au démarrage, selon la marque — c'est affiché brièvement à l'écran).

Deux choses à faire :

1. **Booter sur la clé USB** : soit via le menu de boot (souvent `F12`), soit en mettant l'USB en premier dans l'ordre de démarrage.
2. **Activer la virtualisation** : cherche « Intel VT-x », « Intel Virtualization Technology » ou « SVM Mode » (AMD) et mets sur **Enabled**. Sans ça, Proxmox ne pourra pas faire tourner de VMs.

Sauvegarde et redémarre : le menu d'installation Proxmox apparaît. Choisis **Install Proxmox VE (Graphical)**.

---

## Étape 3 — Installer Proxmox

Les écrans sont les mêmes que pour le chemin A, seul le réseau change :

1. **EULA** : **I agree**.
2. **Target Harddisk** : le disque interne du PC (il sera effacé). **Next**.
3. **Country / Keyboard** : **France**, clavier **French**.
4. **Password / Email** : choisis le mot de passe **root** et **note-le**. Email : le tien.
5. **Management Network Configuration** — ici, ton serveur rejoint le réseau de ta box :

| Champ | Exemple |
|---|---|
| Hostname (FQDN) | `pve.home.lab` |
| IP Address (CIDR) | `192.168.1.240/24` |
| Gateway | `192.168.1.1` (ta box) |
| DNS Server | `192.168.1.1` |

⚠️ **Choisis une IP LIBRE, hors de la plage DHCP de ta box.** La box distribue automatiquement des adresses (le DHCP) dans une certaine plage, souvent `192.168.1.100` à `192.168.1.199` (ça se vérifie dans l'interface de la box). Si tu prends une IP dans cette plage, la box risque un jour de la donner à un autre appareil → conflit, et ton serveur devient injoignable. Une IP haute comme `.240` est en général tranquille. Adapte aussi le préfixe si ta box n'est pas en `192.168.1.x` (certaines sont en `192.168.0.x`).

6. **Install**, café, redémarrage. Retire la clé USB quand le PC reboote.

---

## Étape 4 — Premier accès

Depuis **ton poste habituel** (pas le serveur), ouvre un navigateur :

```
https://192.168.1.240:8006
```

(Remplace par l'IP que tu as choisie. Le `https://` et le `:8006` sont obligatoires.)

Ton navigateur affiche un avertissement de sécurité : normal, Proxmox utilise un certificat auto-signé — c'est ton serveur, tu peux lui faire confiance. **Paramètres avancés → Continuer vers le site**.

Connexion :

- **User name** : `root`
- **Password** : celui que tu as noté
- **Realm** : **Linux PAM standard authentication**

Ferme la fenêtre « No valid subscription » (simple rappel commercial, tout fonctionne sans licence).

🎉 Ton serveur tourne. Débranche l'écran et le clavier si tu veux : à partir de maintenant, tout se passe depuis ton navigateur.

---

## Ça coince ?

- **Le PC ne boote pas sur la clé** : revérifie l'ordre de boot dans le BIOS, ou essaie le menu de boot direct (`F12`). Si la clé n'apparaît pas, re-flashe-la (étape 1).
- **Erreur KVM pendant l'installation** : VT-x / SVM n'est pas activé dans le BIOS (étape 2).
- **`https://192.168.1.240:8006` ne répond pas** : vérifie que ton poste est sur le même réseau que le serveur (même box, pas un réseau invité du Wi-Fi), que tu as bien tapé `https://` et `:8006`, et que l'IP correspond à celle saisie à l'installation (elle est affichée sur l'écran du serveur).

---

✅ **Terminé ?** Retourne sur [lab-cours-0.md](lab-cours-0.md) pour la vérification finale, puis file au chapitre 2.
