# Chapitre 6 — HashiCorp Vault : le coffre-fort à secrets : script vidéo

> Durée cible : ~25 min. Prérequis : lab de départ (`../lab-depart.md`) + une VM pour
> héberger Vault (on réutilise `dns-proxy`, `10.10.99.12` sur le segment `10.10.99.0/24`).
> **Où tu travailles** : sur le segment interne `10.10.99.0/24` — Vault écoute en
> `https://10.10.99.12:8200`, rien à voir avec le LAN OPNsense `192.168.99.0/24`.
> Toutes les commandes montrées sont dans
> `demo.sh` et rejouées avant tournage. Le rôle complet est dans
> `../ansible-extraits/roles/vault/` — l'élève le recopie dans SON arbre
> (`cours-1-ansible/ansible/roles/`).

## 1. Le concept (6 min)

**À dire** : « On a DEUX outils qui s'appellent "vault", et ce sont des bêtes
complètement différentes. Il faut absolument les distinguer.

- **`ansible-vault`** (cours 1, chapitre 6) : ça chiffre des **FICHIERS** — ton
  `group_vars/lab/vault.yml` avec le mot de passe elastic dedans. C'est un cadenas sur un
  fichier, versionné dans Git, zéro serveur, zéro dépendance. **Parfait pour amorcer** :
  au premier `ansible-playbook`, les secrets doivent déjà être là. On appelle ça les
  secrets de **bootstrap**.

- **HashiCorp Vault** : ça, c'est un **SERVEUR** de secrets. Une API sur `https://…:8200`,
  une interface web, et surtout des super-pouvoirs qu'un fichier chiffré n'aura jamais :
  des **secrets dynamiques** (générés à la demande, avec une durée de vie — un TTL), de la
  **révocation** (couper un secret d'un coup), de l'**audit** (qui a lu quoi, quand). C'est
  pour les secrets **runtime** : ceux dont tes applications ont besoin en marchant.

Même mot, deux rôles. Un fichier d'un côté, un service de l'autre. Quand je dis "vaulte
ce mot de passe", je parle du fichier ansible-vault. Quand je dis "le Vault est scellé",
je parle du serveur HashiCorp. Garde les deux bien séparés dans ta tête. »

**Le sceau et les clés de Shamir** : « Vault stocke tout **chiffré sur le disque**. La clé
qui déchiffre, elle, n'est **jamais** écrite sur le disque — sinon quel intérêt. Au
démarrage, Vault est donc **scellé** (`sealed`) : il a les données, mais pas de quoi les
lire. Pour l'ouvrir il faut lui **redonner la clé** : c'est le **descellage** (unseal).

Et cette clé maîtresse est découpée en morceaux — c'est l'astuce de **Shamir** : le coffre
ne s'ouvre qu'avec un **quorum** de morceaux. En prod on fait 3 clés sur 5 (il faut que 3
personnes sur 5 se réunissent — aucune ne peut ouvrir seule). En **lab on fait 1 sur 1** :
une seule clé, plus simple. »

**Deux moteurs qu'on verra** :
- **KV** (Key-Value) : le plus simple — tu ranges un secret, tu le relis. Comme un
  dictionnaire chiffré derrière une API.
- **PKI** : Vault sait être une **autorité de certification** — comme ta CA du cours 2,
  mais **dynamique** : il émet des certs à la demande, avec un TTL, et sait les révoquer.

## 2. Démo guidée (12 min)

### 2.1 Déployer le rôle

**À montrer** : recopier `roles/vault` et les 2 playbooks depuis `ansible-extraits/`,
déclarer le groupe `vault` dans l'inventaire YAML `hosts.yml` (→ `dns-proxy`). **Masquerade ON** sur le
nœud (apt HashiCorp à télécharger). `ansible-playbook playbooks/vault.yml`. Masquerade OFF.

**À expliquer pendant que ça installe** : le tour du rôle — dépôt HashiCorp en `signed-by`
(même méthode moderne que le rôle elasticsearch), le **cert TLS auto-signé** généré par le
rôle (Vault refuse le HTTP en clair ; en lab un cert auto-signé suffit, sur l'infra réelle
c'est la CA ELK du cours 2), et le `vault.hcl` : storage file, listener TLS 8200, UI activée.

**⚠️ À dire** : « Le rôle installe et démarre Vault, mais il **n'initialise pas** le
coffre. L'init produit des secrets critiques — on le fait à la main, à l'écran, pour bien
voir le moment. »

### 2.2 Initialiser — LE moment critique

**À montrer** (sur la VM, ssh via bastion) :

```bash
vault operator init -key-shares=1 -key-threshold=1
```

**Attendu** : `Unseal Key 1: ...` et `Initial Root Token: ...`.

**À dire, très solennel** : « **STOP. Recopie ces deux lignes MAINTENANT.** La clé
d'unseal et le root token ne s'afficheront **jamais** une deuxième fois. Vault ne les
stocke nulle part exprès. Si tu fermes ce terminal sans les noter, ton coffre est
**définitivement inouvrable**. On y revient dans deux minutes avec une histoire vraie. »

### 2.3 Desceller et se connecter

```bash
vault operator unseal <UNSEAL_KEY_1>   # → "Sealed  false"
vault login <ROOT_TOKEN>
```

**Attendu** : `Sealed  false`, puis `Success! You are now authenticated`.

### 2.4 KV — ranger et relire un secret

```bash
vault kv put secret/lab/demo password=s3cr3t-du-lab
vault kv get secret/lab/demo
```

**Attendu** : `password  s3cr3t-du-lab`. « Voilà le moteur KV : je range, je relis. Une
API, pas un fichier. »

### 2.5 PKI — Vault devient une autorité de certification

```bash
vault secrets enable pki
vault secrets tune -max-lease-ttl=8760h pki
vault write pki/root/generate/internal common_name="lab" ttl=8760h
```

**Attendu** : un certificat racine s'affiche. « Vault peut maintenant émettre des certs à
la demande — la même idée que ta CA du cours 2, mais pilotée par API et révocable. »

## 3. 💥 La panne du vrai monde — DOUBLE panne

> Histoire vraie, tirée de `docs/secrets.md` de l'infra réelle.

### (a) « Vault redémarre scellé » — et c'est SAIN

**À montrer** : rebooter la VM Vault, puis :

```bash
vault status   # → "Sealed  true"
```

**À dire** : « Après CHAQUE reboot, Vault revient **scellé**. Ce n'est **pas un bug**,
c'est le **design** : la clé de déchiffrement n'est jamais sur le disque, donc au
redémarrage Vault ne peut pas s'ouvrir tout seul. Le descellage fait partie de
l'**exploitation quotidienne** — c'est pour ça qu'on a un playbook dédié : »

```bash
ansible-playbook playbooks/vault-unseal.yml   # → sealed=false
```

« Il lit la clé dans l'ansible-vault et la soumet à l'API. Coffre rouvert. »

### (b) L'histoire des clés jamais sauvegardées — le paiement de la promesse du cours 1

**À dire** : « Tu te souviens, au **cours 1 chapitre 6**, je t'avais raconté une panne
en te disant "on la verra pour de vrai au cours 3" ? On y est — et maintenant tu as un
Vault sous les doigts, ça va parler autrement. Rappel express : sur l'infra réelle, ce
Vault avait été initialisé des **semaines** plus tôt, les clés d'unseal notées **NULLE
PART**. Au moment de s'en servir : coffre **inouvrable**. Aucune commande, aucune magie
ne récupère ça — c'est le principe même. Il a fallu **tout réinitialiser** : données
perdues. Par chance le coffre était encore vide (il était scellé depuis le début,
justement...), sinon c'était la catastrophe.

Rejoue-le mentalement : imagine que tu n'aies pas noté la clé tout à l'heure au `init`.
Reboot → scellé → et là... rien. **Game over.** »

> **Morale** : **un coffre scellé au reboot, c'est normal et SAIN** — les clés ne dorment
> pas dans le coffre. **Un coffre dont tu as perdu les clés, c'est un presse-papier.** Et
> la règle est exactement la même qu'au cours 1 — sauf qu'ici elle a des dents : **généré
> → sauvegardé chiffré (dans ton ansible-vault) → testé, dans la même minute.** Pas « je
> note ça plus tard ». Plus tard n'existe pas.

## 4. Encart vrai matériel (2 min)

**À filmer** : sur l'infra réelle, le `docs/secrets.md` (section Vault) et le vrai
`playbooks/vault-unseal.yml`.

**À dire** : « Sur l'infra, exactement le même playbook `vault-unseal.yml`. La clé et le
root token sont rangés dans le vault Ansible **devsecops** (`vault_unseal_key`,
`vault_root_token`) — chiffrés, versionnés, jamais en clair. Après le fiasco du 06/07, le
Vault a été réinitialisé **proprement** : shamir 1/1, clés sauvegardées dans la même minute.
Le SEUL changement entre le lab et la prod : le cert TLS est signé par la CA ELK au lieu
d'être auto-signé, et le PKI/KV sont provisionnés par Ansible plutôt qu'à la main. Le
principe, lui, est identique. »

## 5. Annonce du TP (1 min)

**À dire** : « À toi : range le mot de passe `elastic` dans le KV de Vault et relis-le ;
puis rebote la VM, constate le sceau, et desèle-la avec le playbook. Bonus : range la clé
d'unseal dans ton ansible-vault (`vault_unseal_key`) — pour que le descellage devienne un
seul `ansible-playbook`. 25 minutes. Au prochain chapitre : la rotation et l'hygiène des
secrets. »
