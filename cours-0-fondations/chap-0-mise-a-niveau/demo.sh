#!/bin/bash
# Chapitre 0 — commandes de la démo, dans l'ordre du script vidéo.
# Aucune commande destructive. À rejouer sur le lab avant tournage.
#
# ⚠️ PLACEHOLDERS : remplace UTILISATEUR@IP_DE_TA_MACHINE par un vrai
#    utilisateur et une vraie IP (ex. alpha@192.168.1.240) avant de jouer
#    le bloc SSH.

### ────────────────────────────────────────────────
### Bloc 1 — Terminal & SSH
### ────────────────────────────────────────────────

# 1.1 Se déplacer
pwd                          # OÙ suis-je ? (print working directory)
ls                           # QU'y a-t-il ici ? (list)
ls -l                        # pareil, avec les détails (taille, date, permissions)
cd /tmp                      # aller ailleurs (change directory)
pwd                          # vérifier : on est bien dans /tmp
cd                           # cd tout seul = retour à la maison

# 1.2 Lire et éditer
cat /etc/hostname            # afficher tout un (petit) fichier
less /etc/services           # lire page par page — 'q' pour quitter !
nano /tmp/test.txt           # éditer : Ctrl+O = enregistrer, Ctrl+X = quitter
cat /tmp/test.txt            # vérifier ce qu'on vient d'écrire

# 1.3 sudo — le passe-droit
cat /etc/shadow | head -1        # ATTENDU : Permission denied (c'est voulu !)
sudo cat /etc/shadow | head -1   # avec sudo : ça passe (mot de passe demandé)

# 1.4 SSH — piloter une machine à distance
# ⚠️ Remplacer le placeholder ci-dessous par un vrai utilisateur@ip.
ssh UTILISATEUR@IP_DE_TA_MACHINE       # 1ère fois : fingerprint (yes) + mot de passe
# ... sur la machine distante : hostname, puis exit pour revenir.

ssh-keygen -t ed25519                  # générer la paire de clés (Entrée aux questions)
ls ~/.ssh/                             # montrer id_ed25519 (privée) et id_ed25519.pub (publique)
ssh-copy-id UTILISATEUR@IP_DE_TA_MACHINE   # poser le "cadenas" (dernier mot de passe !)
ssh UTILISATEUR@IP_DE_TA_MACHINE       # connexion SANS mot de passe 🎉

### ────────────────────────────────────────────────
### Bloc 2 — Réseau minimal
### ────────────────────────────────────────────────

ip a                         # QUELLE est mon adresse ? (chercher inet 192.168.1.x/24)
ip route                     # OÙ est la sortie ? (default via 192.168.1.1 = passerelle)
dig +short example.com       # l'annuaire DNS : nom → adresse IP
ping -c 3 192.168.1.1        # ma passerelle répond ? (-c 3 = trois essais puis stop)
ping -c 3 example.com        # Internet répond ? (DNS + ping combinés)

### ────────────────────────────────────────────────
### Bloc 3 — C'est quoi une VM ?
### ────────────────────────────────────────────────
# Pas de commande dans ce bloc : schéma hyperviseur à l'écran (voir script-video.md).
