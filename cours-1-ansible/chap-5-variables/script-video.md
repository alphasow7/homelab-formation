# Chapitre 5 — Les variables : script vidéo

> Durée cible : ~28 min. Prérequis élève : chapitre 4 fait (les rôles `dns` et
> `web_status` existent dans `ansible/roles/`, `web-status-role.yml` et `dns.yml`
> tournent, `dig @10.10.99.12 elastic-1.lab.local` répond depuis le bastion).
> Toutes les commandes montrées sont dans `demo.sh` et doivent être rejouées sur
> le lab avant tournage. Le fichier vedette :
> `ansible/inventory/group_vars/lab.yml`.

---

## 1. Le concept (6 min) — « Où vivent les variables ? »

### À dire (idées et phrases clés)
- « Au chapitre 4, tu as vu que le rôle `web_status` a un dossier `defaults/`
  avec `web_status_title` dedans. Question toute bête : si le rôle contient déjà
  la valeur… comment je fais pour la CHANGER sans réécrire le rôle ? C'est tout
  le sujet du jour : où vivent les variables, et QUI GAGNE quand deux endroits
  donnent deux valeurs différentes. »
- Annoncer la simplification, À VOIX HAUTE : « Ansible a en réalité une liste de
  précédence à plus de vingt niveaux. On ne va PAS l'apprendre — personne ne la
  connaît par cœur, et tu n'en as pas besoin. On va retenir QUATRE étages, et ces
  quatre étages couvrent 95 % de ta vie avec Ansible. »
- Le schéma entonnoir, du plus FAIBLE au plus FORT :

```
        ┌──────────────────────────────────────────┐
  faible│  defaults/ du rôle                       │  « les réglages d'usine »
        │   → la valeur qui marche partout          │
        ├──────────────────────────────────────────┤
        │  group_vars/                              │  « la politique du groupe »
        │   → tous les hôtes d'un groupe            │
        ├──────────────────────────────────────────┤
        │  host_vars/                               │  « l'exception d'une machine »
        │   → un seul hôte, nommément               │
        ├──────────────────────────────────────────┤
   fort │  -e en ligne de commande                  │  « l'ordre direct,
        ▼   → ce run-là, et lui seul                │    qui gagne TOUJOURS »
        └──────────────────────────────────────────┘
```

- Dérouler chaque étage avec son image :
  - **`defaults/` du rôle** — « Les réglages d'usine. L'auteur du rôle dit :
    "si tu ne me dis rien, voilà ce que je fais". C'est fait pour être écrasé —
    c'est même leur raison d'exister. »
  - **`group_vars/`** — « La politique du groupe. "Chez nous, dans le groupe
    `lab`, le titre c'est ça et les forwarders c'est ça." Un fichier par groupe,
    dans l'inventaire, à côté de `hosts.yml`. »
  - **`host_vars/`** — « L'exception d'une machine. "Tout le groupe fait comme
    ça… SAUF dns-proxy." Un fichier par hôte, nommé comme l'hôte. »
  - **`-e` (extra vars)** — « L'ordre direct. Tapé sur la ligne de commande, il
    écrase TOUT, pour CE run seulement. Rien n'est écrit nulle part : au run
    suivant, tout redevient comme avant. »
- La règle mnémotechnique, à poser en gros à l'écran : **« Plus c'est
  SPÉCIFIQUE, plus c'est FORT. »** « Une valeur pour tout le monde perd contre
  une valeur pour un groupe, qui perd contre une valeur pour une machine, qui
  perd contre un ordre tapé à la main à l'instant T. C'est logique : plus tu
  vises précis, plus tu sais ce que tu fais. »

### À montrer à l'écran
- Le schéma entonnoir ci-dessus, étage par étage (surlignage progressif).
- L'arborescence cible :

```
ansible/
├── inventory/
│   ├── hosts.yml
│   ├── group_vars/
│   │   └── lab.yml          ← la politique du groupe lab
│   └── host_vars/
│       └── dns-proxy.yml    ← l'exception d'une machine (TP)
└── roles/
    └── web_status/
        └── defaults/main.yml ← les réglages d'usine
```

---

## 2. Démo guidée (10 min) — la même page, quatre étages

> Toutes les commandes sont dans `demo.sh`, à lancer depuis le poste de l'élève
> (les `curl` passent par le bastion, comme d'habitude). Rejouer l'intégralité
> avant tournage.

### 2.1 — Le réglage d'usine

```bash
cat roles/web_status/defaults/main.yml
```

**À dire** : « Voilà l'étage 1, le réglage d'usine : `web_status_title: "Lab de
{{ ansible_user }} — géré par Ansible"`. C'est la valeur qu'on voit sur la page
depuis le chapitre 4. Maintenant, on va la changer SANS OUVRIR ce fichier. »

### 2.2 — La politique du groupe : `group_vars/lab.yml`

Créer (ou montrer) `inventory/group_vars/lab.yml` :

```yaml
---
# Variables communes au groupe lab — surchargent les defaults des rôles
web_status_title: "Lab du groupe LAB — géré par Ansible (group_vars)"
dns_forwarders:
  - 1.1.1.1
  - 8.8.8.8
```

**À dire** : « Regarde bien OÙ ce fichier vit : `inventory/group_vars/lab.yml`.
`lab`, c'est le nom du GROUPE dans `hosts.yml` — le nom du fichier DOIT
correspondre au nom du groupe, c'est comme ça qu'Ansible fait le lien. Aucune
ligne de code en plus : Ansible le charge tout seul. »

```bash
ansible-playbook playbooks/web-status-role.yml
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12
```

**Résultat attendu** : `changed` sur la task de la page, puis le HTML affiche
**« Lab du groupe LAB — géré par Ansible (group_vars) »**.

**À dire, la phrase clé du chapitre** : « La page a changé et je n'ai PAS touché
au rôle. Ni au playbook. **Le rôle est générique, la config est locale — c'est
ÇA la réutilisabilité.** Le même rôle `web_status` peut servir dix groupes avec
dix titres, sans une ligne modifiée dedans. »

### 2.3 — L'ordre direct : `-e`

```bash
ansible-playbook playbooks/web-status-role.yml -e 'web_status_title="Ordre direct"'
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12
```

**Attendu** : la page affiche **« Ordre direct »**.

**À dire** : « Le `-e` a écrasé le group_vars, qui écrasait déjà le default :
l'étage du haut gagne toujours. Mais attention au piège : c'est un ordre pour CE
run. Rien n'a été écrit dans le repo — si je rejoue sans `-e`, le group_vars
reprend la main. » (Le montrer : rejouer sans `-e`, re-curl → le titre group_vars
revient.) « Usage typique du `-e` : un test rapide, un déploiement
exceptionnel — jamais de la config permanente. La config permanente vit dans des
FICHIERS, versionnés. »

### 2.4 — Pas que du cosmétique : `dns_forwarders`

**À dire** : « Le titre d'une page, c'est mignon, mais la même mécanique pilote
de la vraie config. Relis `group_vars/lab.yml` : j'y ai aussi mis
`dns_forwarders` avec DEUX serveurs — le default du rôle `dns` n'en avait
qu'un. »

```bash
ansible-playbook playbooks/dns.yml
ssh -J alpha@IP_DE_TON_BASTION alpha@10.10.99.12 \
  "grep -A3 forwarders /etc/bind/named.conf.options"
```

**Attendu** : le bloc `forwarders` contient `1.1.1.1;` ET `8.8.8.8;`, et le
handler a rechargé BIND.

**À dire** : « Même principe, vraie conséquence : le groupe `lab` a maintenant
un forwarder de secours. Le rôle `dns` n'a pas bougé d'une virgule. »

---

## 3. Encart vrai matériel (2 min)

**À filmer** : l'arborescence `inventory/group_vars/` du repo réel du
formateur : les dossiers `all/`, `elk/`, `devsecops/`, `backup/`, et un
`tree` + un `cat` rapide de `elk/vars.yml` (version d'Elasticsearch, heap size,
nom de cluster…).

**À dire** : « Voilà le group_vars de mon infra réelle. Un dossier par groupe :
`elk` a SES variables — version d'Elasticsearch, taille de heap — `devsecops` a
les siennes, `backup` aussi. **Chaque segment a sa politique**, et les rôles
en dessous sont les mêmes pour tout le monde. Tu remarqueras aussi des fichiers
`vault.yml` chiffrés à côté : les secrets suivent la même logique de groupes —
on en reparle dans un chapitre dédié. C'est exactement ta structure, avec plus
d'étages. »

---

## 4. 💥 La panne du vrai monde (8 min) — « 0.0.0.0, la valeur qui ment »

> Cette panne est RÉELLE : elle est arrivée sur l'infra du formateur, sur la
> config BIND. À raconter comme telle.

### Mise en situation

**À dire** : « Histoire vraie. Sur mon infra, la variable qui pilote l'écoute de
BIND valait `"0.0.0.0"`. Réflexe classique : pour nginx, pour sshd, pour à peu
près tout le monde, `0.0.0.0` veut dire "écoute sur toutes les interfaces".
Sauf que pour BIND… non. Dans `listen-on { ... };`, BIND attend une **liste
d'adresses à matcher** : `listen-on { 0.0.0.0; };` veut dire "écoute sur
l'adresse littérale 0.0.0.0" — une adresse qui n'existe sur aucune interface.
Autrement dit : **n'écoute NULLE PART**. DNS muet, config valide, service
démarré, zéro message d'erreur. »

### On la rejoue sur le lab

**À dire** : « On va simuler ce que ferait un rôle dont le template lit une
variable `dns_listen`. Notre template du chapitre 4 a `any` en dur — je le bascule
temporairement sur la variable, le temps de la démo (la commande exacte est dans
`demo.sh`), et je pose la valeur piégée dans group_vars. » Ajouter dans
`group_vars/lab.yml` :

```yaml
dns_listen: "0.0.0.0"    # « toutes les interfaces »… croit-on
```

```bash
ansible-playbook playbooks/dns.yml
```

**Attendu** : run vert, `changed` sur le template + handler. « Regarde bien :
**Ansible est parfaitement content.** `failed=0`, handler passé, BIND rechargé.
Le playbook ne teste pas le SENS de ta valeur. »

### Le symptôme

```bash
ssh alpha@IP_DE_TON_BASTION dig @10.10.99.12 elastic-1.lab.local +time=2 +tries=1
```

**Attendu** : `connection timed out; no servers could be reached`. « Le DNS qui
répondait il y a deux minutes est muet. »

### Diagnostic guidé

**À dire** : « Réflexe chapitre par chapitre : le service tourne-t-il ? Oui,
`systemctl status named` est vert. Alors : sur quoi ÉCOUTE-t-il ? La commande
qui répond à ça, c'est `ss -ulnp` — les sockets UDP en écoute. »

```bash
ssh -J alpha@IP_DE_TON_BASTION alpha@10.10.99.12 "sudo ss -ulnp | grep 53"
```

**Attendu** : RIEN sur `10.10.99.12:53` — au mieux `127.0.0.1:53` (le loopback),
au pire aucune ligne named. « Et voilà la preuve : named tourne mais n'écoute
sur rien d'utile. La machine dit la vérité que le playbook ne voyait pas. »

### Comprendre, puis réparer

**À dire** : « Le cœur du problème : **`0.0.0.0` n'a pas le même SENS pour tous
les logiciels.** Pour nginx, c'est "partout". Pour BIND, c'est une adresse
littérale introuvable, donc "nulle part". La variable a transporté la valeur
sans broncher — c'est le logiciel au bout qui décide de ce qu'elle veut dire. »

Le fix, dans `group_vars/lab.yml` :

```yaml
dns_listen: "any"    # le mot-clé de BIND pour « toutes les interfaces »
```

```bash
ansible-playbook playbooks/dns.yml
ssh -J alpha@IP_DE_TON_BASTION alpha@10.10.99.12 "sudo ss -ulnp | grep 53"
ssh alpha@IP_DE_TON_BASTION dig @10.10.99.12 elastic-1.lab.local +time=2 +tries=1
```

**Attendu** : named écoute sur `0.0.0.0:53` (oui, ironie : c'est ss qui affiche
0.0.0.0 pour dire « partout » !), et le `dig` répond `10.10.99.11`. Puis on
remet le template d'origine (bloc RÉPARER de `demo.sh`).

**Morale, à poser en gros** : « **Une variable n'est pas magique : sa valeur
doit avoir un SENS pour le logiciel qui la lira.** Et le corollaire : après tout
changement de valeur, **re-teste le SERVICE, pas juste le playbook**. Un PLAY
RECAP vert prouve que la config est déployée — pas qu'elle fonctionne. »

---

## 5. Annonce du TP

**À dire** : « À toi de jouer, 20 minutes : tu vas prouver l'entonnoir de
précédence toi-même, sur la page de statut. Trois étapes : ton titre personnel
en `group_vars`, puis un `host_vars/dns-proxy.yml` qui fait exception pour cette
machine, puis un `-e` qui écrase tout. Le critère : **trois `curl`, trois titres
différents**, un par étage. Deux indices dans `tp.md` si tu bloques sur
l'emplacement de host_vars ou sur l'ordre, la correction dans `correction/`. Et garde
le réflexe de la panne : à chaque nouvelle valeur, re-teste le service. »
