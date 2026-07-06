# Chapitre 4 — Les rôles : script vidéo

> Durée cible : ~30 min. Prérequis élève : chapitre 3 fait — le playbook
> `playbooks/web-status.yml` fonctionne (nginx + page de statut sur dns-proxy),
> `ansible lab -m ping` renvoie 3 pongs verts. Toutes les commandes se lancent
> depuis `cours-1-ansible/ansible/` sur le poste de l'élève.

---

## 1. Le concept (≤ 5 min) — « Un rôle = une compétence réutilisable »

### À dire (idées et phrases clés)
- « Ton playbook du chapitre 3 marche, mais regarde-le : les tâches, le contenu de la
  page, le handler… tout est en vrac dans UN fichier. Ajoute un serveur DNS, puis un
  proxy, puis une base de données, et ton playbook devient un roman illisible. La
  réponse d'Ansible s'appelle le **rôle** : une compétence complète — “savoir être un
  serveur web”, “savoir être un serveur DNS” — rangée dans des **tiroirs standards**. »
- Les 4 tiroirs (expliquer chacun) :
  - **`tasks/`** — le tiroir des actions : QUE FAIRE, dans l'ordre. C'est l'ancien
    contenu de ton playbook.
  - **`templates/`** — le tiroir des fichiers à trous : des fichiers de configuration
    où Ansible remplit les `{{ variables }}` avant de les poser sur la machine.
  - **`handlers/`** — le tiroir des réactions : « SI un fichier de conf a changé,
    ALORS redémarre le service ». Déclenchés par `notify`, jamais tout seuls.
  - **`defaults/`** — le tiroir des réglages d'usine : les valeurs par défaut des
    variables, que n'importe quel playbook peut surcharger SANS modifier le rôle.
- « Le nom des tiroirs n'est pas un choix : c'est une **convention**. Ansible sait que
  les tâches sont dans `tasks/main.yml`, les handlers dans `handlers/main.yml`… Tu ne
  déclares rien, tu ranges au bon endroit et ça marche. Et n'importe quel admin
  Ansible au monde s'y retrouve dans ton rôle en 10 secondes. »
- La phrase clé : « Grâce aux rôles, **le playbook devient une phrase** :
  “dns-proxy, tu es un serveur DNS.” Le COMMENT est dans le rôle, le playbook ne dit
  plus que le QUI et le QUOI. »

### À montrer à l'écran
- Schéma ASCII :

```
  AVANT (chap. 3)                    APRÈS (chap. 4)
  playbook = tout en vrac            playbook = une phrase
  ┌──────────────────────┐           ┌──────────────────────┐
  │ web-status.yml       │           │ dns.yml              │
  │  - hosts, become     │           │  hosts: dns-proxy    │
  │  - task apt          │           │  roles: [dns]  ◄─────┼── « tu es un DNS »
  │  - task page html    │           └──────────┬───────────┘
  │  - task service      │                      │
  │  - handler restart   │           roles/dns/ ▼  la compétence
  └──────────────────────┘           ├── tasks/      (que faire)
                                     ├── templates/  (fichiers à trous)
                                     ├── handlers/   (réactions)
                                     └── defaults/   (réglages d'usine)
```

---

## 2. Démo guidée (12 min)

> Toutes les commandes sont dans `demo.sh`, exécutées dans l'ordre depuis
> `cours-1-ansible/ansible/`. Rejouer sur le lab avant tournage.

### 2.1 — Le refactor : web-status devient un rôle (AVANT/APRÈS)

**À montrer** : écran splitté. À gauche, `playbooks/web-status.yml` du chapitre 3
(~30 lignes, tout en vrac). À droite, le résultat du rangement :

```
roles/web_status/
├── tasks/main.yml        ← les 3 tâches, telles quelles
├── templates/index.html.j2  ← la page (avant : inline dans copy)
├── handlers/main.yml     ← le handler Restart nginx
└── defaults/main.yml     ← web_status_title, le titre devient réglable
```

**À dire** : « Rien de nouveau n'a été écrit : on a DÉCOUPÉ. Les tâches vont dans
`tasks/`, le handler dans `handlers/`. Deux vraies améliorations au passage : la page
HTML, qui était collée en dur dans le module `copy`, devient un **template** dans
`templates/` — un vrai fichier, éditable, avec ses `{{ variables }}`. Et le titre de
la page devient une variable dans `defaults/` : demain, un autre playbook pourra
réutiliser ce rôle avec un autre titre sans toucher au rôle. »

Puis `playbooks/web-status-role.yml` plein écran : « Et voilà le playbook : hosts,
become, roles. Quatre lignes utiles. La phrase. »

```bash
ansible-playbook playbooks/web-status-role.yml
```

**Résultat attendu** : `ok=4 changed=0` (ou `changed=1` si le template diffère de
l'ancienne page d'un octet — dans ce cas le handler redémarre nginx, c'est normal).
« Même résultat qu'au chapitre 3 : l'idempotence traverse le refactor. La page est
toujours là, le code est juste mieux rangé. »

### 2.2 — Un VRAI rôle : le serveur DNS du lab

**À dire** : « Maintenant qu'on sait ranger, on écrit une vraie compétence :
`roles/dns` transforme dns-proxy en serveur DNS avec **BIND9**, LE logiciel DNS
historique d'Internet. Jusqu'ici tu tapes des IPs : 10.10.99.11, .14… Après cette
démo, tes machines auront des NOMS. »

**À montrer** : visite guidée du rôle, tiroir par tiroir (1 min chacun) :
- `defaults/main.yml` : « le domaine `lab.local`, et surtout `dns_records` : la liste
  nom → IP des 4 machines. C'est ÇA, la donnée. Le reste n'est que mécanique. »
- `templates/zone.j2` : « le fichier de zone, l'annuaire au format DNS. La boucle
  `{% raw %}{% for record in dns_records %}{% endraw %}` fabrique une ligne
  `nom IN A ip` par machine. Le Serial utilise `ansible_date_time.epoch` : chaque
  déploiement produit un numéro de version croissant, comme le veut le protocole DNS. »
- `templates/named.conf.options.j2` : « la config du serveur : écoute partout
  (`any`), répond à tous (lab isolé, on assume), et **forwarders** : les questions
  qu'il ne connaît pas — google.com — sont transmises à 1.1.1.1. »
- `templates/named.conf.local.j2` : « la déclaration de la zone. Note le commentaire
  en tête : “Zones uniquement : le bloc options vit dans named.conf.options”.
  Retiens-le, on en reparle dans quelques minutes… »
- `tasks/main.yml` : « installer, créer le dossier, poser 3 templates, démarrer.
  Six tâches, aucune magie. »

```bash
ansible-playbook playbooks/dns.yml
```

**Résultat attendu** : `ok=8 changed=6` environ au premier passage (6 tâches +
2 handlers), zéro failed.

### 2.3 — LA preuve : dig depuis le bastion

```bash
# Depuis le bastion (il est sur le segment du lab) :
ssh alpha@IP_DE_TON_BASTION "dig @10.10.99.12 elastic-1.lab.local +short"
```

**Résultat attendu** :

```
10.10.99.11
```

**À dire** : « Décodons : `dig` pose une question DNS, `@10.10.99.12` désigne le
serveur à interroger — le nôtre, tout frais —, et `+short` ne garde que la réponse.
Question : “qui est elastic-1.lab.local ?” Réponse : `10.10.99.11`. C'est la bonne
IP, celle de tes defaults. **Ton lab a maintenant son propre annuaire.** Ce moment-là,
c'est le passage du bricolage à l'infrastructure. »

---

## 3. Encart vrai matériel (2 min)

**À dire** : « Voici le dossier `roles/` de mon infra réelle : **24 rôles**. Un rôle
par brique : elasticsearch, kibana, gitlab, vault, proxy, dns… Chaque compétence de
l'infra est un rôle, rangé dans les mêmes 4 tiroirs que les tiens. Et regarde
`roles/dns` : tasks, templates avec un zone.j2, handlers Restart/Reload — celui que tu
viens d'écrire est **le petit frère du vrai**. La seule différence : le mien gère
plusieurs zones et quelques cas de bord accumulés avec les pannes. La structure, elle,
est identique — c'est toute la force de la convention. »

**Plans à filmer sur l'infra réelle** :
1. `ls roles/` du repo réel : la liste des 24 rôles, scroll lent.
2. `tree roles/dns/` réel côte à côte avec le `tree roles/dns/` de l'élève :
   les mêmes tiroirs.
3. Un `dig @10.10.40.11 gitlab.lab +short` sur l'infra réelle : le DNS de prod répond.

---

## 4. 💥 La panne du vrai monde (7 min) — le doublon `options {}`

> Panne 100 % vécue sur l'infra du formateur, rejouée en direct sur le lab.

**Mise en situation — à dire** : « Celle-là, je l'ai vécue. Sur mon infra, mon
template écrivait un bloc `options { ... }` dans `named.conf.local`… alors que
`named.conf.options` en définissait déjà un. Résultat : au restart, named **mort**.
Et le message d'erreur est d'un cryptique délicieux : `loading configuration:
already exists`. Déjà existe ? QUOI déjà existe ? OÙ ? On va la rejouer ensemble,
parce que le réflexe de diagnostic vaut de l'or. »

**On la casse (à l'écran)** : éditer `roles/dns/templates/named.conf.local.j2` et
ajouter volontairement en bas :

```
options {
    recursion yes;
};
```

« Erreur plausible, hein ? “Je veux juste activer la récursion, je colle le bloc
ici.” Déployons. »

```bash
ansible-playbook playbooks/dns.yml
```

**Symptôme attendu** : la tâche de template passe (`changed`), puis le **handler
`Restart bind9` échoue** en rouge : `Unable to restart service named: Job for
named.service failed...`. Le DNS du lab est MORT — vérifiable :
`dig @10.10.99.12 elastic-1.lab.local +short` depuis le bastion → timeout.

**Diagnostic guidé — à dire** : « Ansible te dit que le restart a échoué, mais PAS
pourquoi : ce n'est pas son travail. Qui sait pourquoi ? Le service lui-même. Premier
réflexe, toujours : **le journal DU service, sur LA machine**. »

```bash
ssh alpha@IP_DE_TON_BASTION            # rebond
ssh alpha@10.10.99.12                  # la VM malade
sudo journalctl -u named -n 20
```

**À montrer** : dans les 20 lignes, trouver et surligner :

```
/etc/bind/named.conf.local:9: 'options' already exists
loading configuration: already exists
exited, code=exited, status=1/FAILURE
```

« Lis-la lentement : fichier `named.conf.local`, ligne 9, `'options' already
exists` — “options existe déjà”. Traduction : **défini deux fois**. BIND lit
`named.conf.options` (un bloc options), puis `named.conf.local` (un DEUXIÈME bloc
options) → interdit → il préfère ne pas démarrer du tout plutôt que de deviner.
Le message te disait tout : QUOI (`options` en double) et même OÙ (le fichier, la
ligne). Il fallait juste aller le lire. »

**Le fix** : « Et on corrige où ? PAS sur la VM — sur la VM, ton fix sera écrasé au
prochain déploiement. On corrige **le template**, la source de vérité. » Retirer le
bloc ajouté dans `named.conf.local.j2`, puis :

```bash
ansible-playbook playbooks/dns.yml
ssh alpha@IP_DE_TON_BASTION "dig @10.10.99.12 elastic-1.lab.local +short"
```

**Résultat attendu** : handler `Restart bind9` OK, et le dig répond `10.10.99.11`.

**Morale — à dire** : « Un service qui refuse de démarrer après un déploiement : lis
SON journal avant de toucher au code. `journalctl -u <service>`, vingt lignes. Le
message te dit presque toujours QUOI — à toi de trouver OÙ. Et c'est pour ça que le
commentaire “Zones uniquement” vit en tête du template : un commentaire de code, c'est
souvent la cicatrice d'une panne. »

---

## 5. Annonce du TP

**À dire** : « À toi. Le TP : tu enrichis TON annuaire. D'abord un alias d'IP
classique : un enregistrement `proxy` qui pointe sur 10.10.99.12. Ensuite, une vraie
extension du rôle : les **CNAME** — les surnoms du DNS, un nom qui pointe vers un
autre nom. Tu ajoutes une variable `dns_cnames`, tu boucles dessus dans le template de
zone, et tu prouves au dig que `www.lab.local` répond. Tu vas toucher aux deux tiroirs
qui comptent : `defaults/` et `templates/`. Compte 20 minutes, deux indices dans
`tp.md`, correction dans `correction/`. Au prochain chapitre : les variables en
profondeur — d'où elles viennent, qui gagne quand deux se contredisent. »
