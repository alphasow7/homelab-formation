# Chapitre 3 — Le premier playbook : script vidéo

> Durée cible : ~25 min. Prérequis élève : chapitre 2 fait (inventaire en place,
> `ansible lab -m ping` renvoie 3 pongs verts, placeholder `IP_DE_TON_BASTION`
> remplacé). Toutes les commandes montrées sont dans `demo.sh` et doivent être
> rejouées sur le lab avant tournage. Le playbook vedette :
> `ansible/playbooks/web-status.yml`.

---

## 1. Le concept (5 min) — « L'anatomie d'un playbook »

### À dire (idées et phrases clés)
- « Au chapitre 2, tu as tapé des commandes ad-hoc : pratiques, mais jetables. Un
  **playbook**, c'est le contraire : un fichier YAML qui décrit l'**état voulu** de
  tes machines, versionnable, rejouable, partageable. Aujourd'hui tu écris le tien. »
- Ouvrir `playbooks/web-status.yml` plein écran et le disséquer de haut en bas :
  - **`hosts: dns-proxy`** — « À QUI on s'adresse. Un hôte de l'inventaire, ou un
    groupe entier : la syntaxe ne change pas. »
  - **`become: true`** — « AVEC SUDO. Installer un paquet ou toucher à
    `/var/www`, ça demande les droits root : `become` dit à Ansible de passer
    par sudo, exactement comme quand tu tapes `sudo apt install` toi-même. »
  - **`tasks:`** — « L'ÉTAT VOULU, étape par étape. Chaque task = un **module**
    (la brique d'action du chapitre 2 : `apt`, `copy`, `service`…) + des
    **paramètres** (quel paquet, quel fichier, quel état). Et chaque task a un
    `name` en français : c'est ce qui s'affichera à l'exécution. »
  - **`handlers:`** — « Les tâches DORMANTES. Un handler ne s'exécute que si une
    task qui porte un `notify` a réellement CHANGÉ quelque chose. Ici : on ne
    redémarre nginx que si la page a été modifiée. Pas de changement, pas de
    redémarrage — pourquoi secouer un service qui n'a aucune raison de l'être ? »
- Les `{{ ... }}` dans la page : « Ce sont les **facts** du chapitre 2, injectés
  dans le contenu. Ansible SAIT le hostname et la version de Debian — autant s'en
  servir. »
- Phrase clé à poser : « Un playbook se **LIT** : c'est sa force — montre-le à un
  collègue qui n'a jamais fait d'Ansible, il comprend. "Installer nginx. Déployer
  la page. Nginx démarré et activé." C'est de la documentation qui s'exécute. »

### À montrer à l'écran
- Le playbook plein écran, avec surlignage successif : `hosts` → `become` →
  chaque task → le couple `notify` / `handlers`.
- Un mini-schéma :

```
  PLAY (hosts: dns-proxy, become: true)
  ├── task 1 : apt      → nginx présent
  ├── task 2 : copy     → la page en place ──notify──┐
  ├── task 3 : service  → nginx démarré + activé     │
  └── handler : restart nginx  ◄── seulement si CHANGÉ
```

---

## 2. ⚠️ Préambule réseau (2 min) — « apt sans Internet ? »

### À dire
- « STOP avant de lancer quoi que ce soit. Souviens-toi du cours 0, chapitre 4 :
  ton segment `10.10.99.0/24` n'a **PAS d'Internet** — et c'est VOULU, c'est de la
  segmentation. Or la première task fait `apt: name=nginx` : apt doit
  **télécharger** nginx quelque part. Ça va coincer. »
- « Solution provisoire, ASSUMÉE pour ce cours : le **masquerade temporaire** que
  tu as appris au cours 0 — on ouvre la sortie NAT sur le nœud Proxmox le temps du
  playbook, et on **referme** juste après. Les commandes exactes, ON et OFF, sont
  dans `demo.sh`, bien étiquetées : celles-là se tapent sur le NŒUD, pas sur ton
  poste. »
- Teaser : « La vraie solution pro, c'est un **proxy apt interne** : une machine du
  segment qui sert de dépôt relais, et plus personne n'a besoin de sortir. C'est
  exactement ce que fait l'infra réelle du formateur — hors périmètre de ce
  chapitre, mais garde l'idée en tête. »

### À montrer
- Le bloc « MASQUERADE ON » de `demo.sh` surligné, avec la mention « SUR LE NŒUD
  PROXMOX ».

---

## 3. Démo guidée (12 min) — trois runs, une leçon

> Toutes les commandes sont dans `demo.sh`. Les commandes Ansible et curl se
> lancent DEPUIS le poste de l'élève ; le masquerade se manipule SUR le nœud
> Proxmox. Rejouer l'intégralité avant tournage.

### 3.1 — Run 1 : la construction

```bash
ansible-playbook playbooks/web-status.yml
```

**À dire** : « Regarde le déroulé : chaque task s'affiche avec son `name` en
français — c'est notre playbook qui se lit tout seul. Et le récap final, le
**PLAY RECAP**, c'est LA ligne à savoir lire. »

**Résultat attendu** :

```
PLAY RECAP *********************************************************
dns-proxy : ok=4  changed=3  unreachable=0  failed=0  ...
```

**À dire** : « Décodons : `ok` = les tasks qui se sont bien passées (y compris la
collecte des facts, d'où le 4). `changed=3` = trois tasks ont réellement MODIFIÉ
la machine : nginx installé, page déposée, service activé — normal, on part de
zéro. `failed=0` = rien n'a cassé. Le jour où tu vois `failed` différent de zéro,
tu t'arrêtes et tu lis le message rouge au-dessus. »

### 3.2 — La preuve par curl

```bash
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12
```

**À dire** : « On demande au bastion — lui a un pied dans le segment — d'aller
chercher la page. » **Attendu** : le HTML avec « Lab de alpha — géré par
Ansible » et « Machine : dns-proxy — Debian 12.x ». « Les facts ont rempli les
trous : Ansible savait le hostname et la version, il les a écrits dans la page. »

### 3.3 — Run 2 : l'idempotence en direct

```bash
ansible-playbook playbooks/web-status.yml
```

**Résultat attendu** :

```
PLAY RECAP *********************************************************
dns-proxy : ok=4  changed=0  unreachable=0  failed=0  ...
```

**À dire** : « Même playbook, dix secondes plus tard : **`changed=0`**. Ansible
constate que l'état voulu est déjà là. RIEN n'a été refait : nginx est déjà
installé, la page est déjà la bonne, le service tourne déjà. C'est
l'**idempotence**, et c'est ce qui rend le rejeu **sans danger**. Tu peux lancer
ce playbook cent fois par jour : tant que rien n'a bougé, il ne touche à rien.
Et remarque : le handler n'a pas bronché — pas de changement, pas de notify, pas
de redémarrage. »

### 3.4 — 💥 La panne du vrai monde : le vandalisme (intégrée à la démo)

**Mise en scène** : « Maintenant, jouons le collègue pressé — ou toi-même, un soir
de fatigue. Quelqu'un se connecte à la machine et écrase la page à la main. »

```bash
ssh -J alpha@IP_DE_TON_BASTION alpha@10.10.99.12 \
  "echo VANDALISME | sudo tee /var/www/html/index.html"
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12
```

**Attendu** : la page ne dit plus que `VANDALISME`. « Voilà le **drift** du
chapitre 1, en chair et en os : la machine ne correspond plus au code. Symptôme
classique : "la page de statut est cassée, qui a touché à quoi ?" »

**Diagnostic guidé** : « Réflexe du vieux monde : se connecter, fouiller,
réécrire le fichier à la main. Réflexe Ansible : la vérité est dans le CODE.
Rejoue. »

**Run 3** :

```bash
ansible-playbook playbooks/web-status.yml
```

**Résultat attendu** :

```
TASK [Déployer la page de statut] **********************************
changed: [dns-proxy]

RUNNING HANDLER [Restart nginx] ************************************
changed: [dns-proxy]

PLAY RECAP *********************************************************
dns-proxy : ok=5  changed=2  unreachable=0  failed=0  ...
```

Puis re-curl : la vraie page est revenue.

**À dire** : « Regarde ce qui s'est passé : Ansible a comparé la page réelle au
contenu voulu, vu la différence, réécrit le fichier — `changed` sur cette task,
et SEULEMENT celle-ci — et le `notify` a réveillé le handler : nginx redémarré.
Le drift du chapitre 1 ? **Réparé par simple rejeu.** Pas de fouille, pas de
stress : le code EST la référence, la machine se réaligne dessus. »

**Morale** : « Retiens le triptyque : run 1 construit, run 2 ne touche à rien,
run 3 répare. Un seul et même fichier pour les trois. »

### 3.5 — On referme le masquerade

**À montrer** : le bloc « MASQUERADE OFF » de `demo.sh`, sur le nœud. **À
dire** : « Réflexe du cours 0 : un accès temporaire, ça se referme. Le segment
redevient étanche — et note que les runs 2 et 3 n'avaient même pas besoin
d'Internet : nginx était déjà installé, apt n'a rien retéléchargé. »

---

## 4. Encart vrai matériel (2 min)

**À filmer** : le terminal du formateur, la fin d'un run du `site.yml` de l'infra
réelle : le défilé de dizaines de tasks (ELK, GitLab, Vault, DNS…) puis le PLAY
RECAP avec plusieurs machines et `changed=0` partout.

**À dire** : « Ton playbook a 3 tasks sur 1 machine. Voilà le mien : des dizaines
de tasks, toutes les VMs de l'infra — et regarde le récap : `changed=0` sur toute
la ligne. Ce que tu vois, c'est **une infra entière vérifiée en 2 minutes** : je
viens de prouver que chaque machine est exactement dans l'état que décrit le
code. C'est le même mécanisme que ton `web-status.yml`, juste avec plus
d'étages. Rien de magique : des plays, des tasks, des handlers. »

---

## 5. Annonce du TP

**À dire** : « À toi de jouer : tu vas ENRICHIR la page de statut. Objectif :
afficher l'IP de la machine et son uptime, et installer `htop` au passage —
trois modifications de playbook. Deux pièges t'attendent, ils sont documentés
dans `tp.md` : les facts de ces VMs n'ont PAS de `default_ipv4` — segment sans
passerelle par défaut oblige — et l'uptime demandera un `register`. Le critère de
réussite est non négociable : après ta modification, un **deuxième run doit
afficher `changed=0`**. Si ça re-change à chaque run, ce n'est pas idempotent,
et ce n'est pas fini. Compte 25 minutes, deux indices dans `tp.md`, la correction
dans `correction/`. Au prochain chapitre : les variables et les templates — on
arrête d'écrire le HTML en dur dans le playbook. »
