# Quiz chapitre 3 — Première VM

**5 questions, une seule bonne réponse par question.** Les réponses sont en bas.

## Question 1 — Quelle est la différence entre installer par ISO et par image cloud ?

- A. L'ISO est plus récente que l'image cloud
- B. L'image cloud est un système déjà installé qu'on personnalise au boot ; l'ISO lance un installateur interactif ✅
- C. L'image cloud ne fonctionne que chez les fournisseurs cloud (AWS, etc.)
- D. L'ISO ne fonctionne que pour Windows

**Explication** : l'image cloud (qcow2) contient un Debian déjà installé — cloud-init le
personnalise au premier démarrage ; l'ISO, c'est le « DVD » avec ses 20 minutes de questions.

## Question 2 — Que personnalise cloud-init au premier démarrage ?

- A. La version du noyau Linux
- B. Le matériel virtuel de la VM (RAM, CPU)
- C. L'utilisateur, la clé SSH et la configuration IP ✅
- D. Le mot de passe root de Proxmox

**Explication** : cloud-init lit son « étiquette » (utilisateur, clé publique, IP) et
l'applique dans la VM ; la RAM et le CPU, c'est `qm` qui les fixe côté hyperviseur.

## Question 3 — Dans `qm set 9001 --sshkeys ...`, quel fichier passes-tu ?

- A. Ta clé privée (`id_ed25519`)
- B. Ta clé publique (`id_ed25519.pub`) ✅
- C. Le fichier `known_hosts`
- D. N'importe lequel des deux, c'est pareil

**Explication** : la publique se dépose sur les serveurs (le cadenas) ; la privée ne
quitte JAMAIS ton poste (la clé). En passer une privée à `--sshkeys` = la divulguer.

## Question 4 — Tu changes la clé SSH cloud-init d'une VM qui tourne. Que faire pour l'appliquer ?

- A. Rien, c'est immédiat
- B. Un `reboot` dans la VM suffit
- C. Un **stop puis start** de la VM ✅
- D. Réinstaller la VM

**Explication** : c'est la panne du chapitre — l'ISO cloud-init n'est régénérée qu'au
démarrage de la VM par Proxmox ; un reboot interne ne la reconstruit pas, un stop/start si.

## Question 5 — À quoi sert `qm cloudinit dump 9001 user` ?

- A. À supprimer la configuration cloud-init de la VM
- B. À afficher ce que cloud-init va réellement appliquer (utilisateur, clé, etc.) ✅
- C. À exporter la VM vers un autre serveur
- D. À vider le cache de la VM

**Explication** : c'est l'outil de diagnostic de la panne du chapitre — il montre
l'« étiquette » telle que Proxmox la génère, donc l'ancienne clé qui traînait encore.

---

**Réponses : 1-B, 2-C, 3-B, 4-C, 5-B.**
