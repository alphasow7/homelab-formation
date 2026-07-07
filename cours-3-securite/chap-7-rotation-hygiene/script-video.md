# Chapitre 7 — Rotation & hygiène des secrets : script vidéo

> Durée cible : ~25 min. Prérequis : cours 0-2 finis, et les chapitres 1 à 6 de ce cours
> (OPNsense en place, Vault déployé, une CA interne ELK qui signe les certs, `ansible-vault`
> déjà utilisé depuis le cours 1). Toutes les commandes montrées sont dans `demo.sh`.
> Ce chapitre n'a **pas de rôle Ansible** : c'est un chapitre d'hygiène et de réflexes.

## 1. Le concept (6 min)

**À dire** : « On a passé six chapitres à construire des défenses : un pare-feu, des zones,
un IDS, un coffre-fort à secrets, du TLS. Aujourd'hui, aucun nouvel outil. On parle
d'**hygiène des secrets** — les trois gestes qui font qu'une infra bien construite ne
s'effondre pas sur une bêtise. Trois piliers.

**Pilier 1 — changer les mots de passe PAR DÉFAUT.** Chaque équipement, chaque service
arrive avec un identifiant d'usine : `admin/admin`, `root/opnsense`, `elastic/changeme`…
Ce ne sont **pas des secrets** : ils sont écrits dans la doc publique, sur le web, dans le
manuel PDF. Les bots qui scannent Internet les connaissent **tous** — c'est littéralement
la première chose qu'ils essaient. Une caméra, un NAS, un routeur laissé sur son mot de
passe d'usine, c'est une porte ouverte avec le code écrit sur la porte.

**Pilier 2 — la ROTATION.** Un secret a une **durée de vie**. On le change régulièrement,
et surtout on le change dès qu'on le soupçonne d'avoir fuité. Le mot magique :
**un secret qui a fuité mais qu'on a fait tourner ne vaut plus rien pour l'attaquant.**
La rotation, c'est ce qui transforme une fuite en non-événement. C'est aussi pour ça qu'on
range les secrets dans un **trousseau** (un *keystore*) : un endroit unique, chiffré, où on
sait les retrouver — et donc les remplacer — sans les chercher dans dix fichiers.

**Pilier 3 — la CA interne DANS le trousseau.** Au cours 2, on a créé notre propre autorité
de certification (CA) qui signe les certificats de nos services internes. Résultat : le
navigateur affiche « ⚠️ risque de sécurité » sur Kibana, Vault, OPNsense — parce qu'il ne
connaît pas notre CA. Le réflexe du débutant : cliquer « Accepter le risque » à chaque fois.
C'est **le pire réflexe** : à force de cliquer « accepter » dix fois par jour, on se
**désensibilise** — le jour où l'avertissement est un VRAI danger (un faux certificat, une
attaque), on clique par habitude sans lire. Le bon geste : importer **une fois** notre CA
dans le trousseau du navigateur. On dit "je fais confiance à cette autorité" → tous nos
services internes passent au vert d'un coup, et le prochain avertissement rouge redevient
un vrai signal d'alarme. »

**Vocabulaire à retenir** :
- **rotation** : changer un secret périodiquement / après une fuite suspectée ;
- **trousseau / keystore** : le magasin chiffré où l'on range et retrouve ses secrets et
  ses autorités de confiance (l'ansible-vault, Vault, ou le trousseau du navigateur/OS).

## 2. Démo guidée (12 min)

### 2.1 Changer le mot de passe root d'OPNsense — PROPREMENT

**À dire d'abord** : « OPNsense est notre pare-feu — la pièce censée protéger tout le reste.
Il est encore en `root/opnsense`, le défaut public. On le change. Mais **attention à la
façon** : au chapitre 2, un changement mal fait ne survivait pas au reboot (la config vivait
en tmpfs). Leçon retenue : on passe par le **système de config** d'OPNsense, pas par une
édition à la main de `config.xml` — sinon OPNsense réécrit le fichier depuis son cache
mémoire au boot et notre changement disparaît. »

**À montrer — le chemin simple (GUI)** : `System ▸ Access ▸ Users`, éditer `root`, saisir
un mot de passe fort, **Save**. Le Save du GUI appelle `write_config()` : la config est
écrite sur disque, elle **persiste**.

**À montrer — le chemin console (si pas de GUI)** : dans `demo.sh`, un petit script PHP qui
change le hash via l'API de config (`config.inc` + `util.inc`) puis appelle `write_config()`.
« Le point clé n'est pas le PHP, c'est le `write_config()` : c'est LUI qui grave le changement
sur un système à mémoire. Un changement bien fait, sur un système qui persiste, survit au
reboot. »

**Reboot-test** (le geste qui prouve) :

```bash
# depuis Proxmox
qm reboot 600
# se reconnecter : l'ancien mot de passe "opnsense" ne marche PLUS → c'est gagné
```

### 2.2 Ranger le nouveau secret dans l'ansible-vault

**À montrer** (depuis `cours-1-ansible/ansible/`) :

```bash
ansible-vault edit inventory/group_vars/opnsense/vault.yml
# à l'intérieur, ajouter :
#   vault_opnsense_root_password: "LE-NOUVEAU-MDP-FORT"
```

**À dire** : « Le mot de passe n'existe plus nulle part en clair : ni dans un post-it, ni
dans un fichier, ni dans ma tête pour trois semaines. Il est **chiffré et versionné**, à
UN endroit connu. C'est ça, un trousseau : quand il faudra le faire tourner, je sais où il
est. `vault_opnsense_root_password` — même convention que `vault_elastic_password`,
`vault_pbs_root_password` : préfixe `vault_`, dans le `vault.yml` du groupe. »

### 2.3 Importer la CA interne dans le trousseau du navigateur

**À montrer** — récupérer le certificat de la CA (celle du cours 2) :

```bash
# depuis le poste : copier ca.crt depuis le nœud ELK
scp root@elastic-1:/etc/elasticsearch/certs/ca/ca.crt ~/homelab-ca.crt
```

**À montrer** — l'importer dans le trousseau :
- **Firefox** : `Paramètres ▸ Vie privée & sécurité ▸ Certificats ▸ Autorités ▸ Importer`
  → cocher « Confirmer cette AC pour identifier des sites web » ;
- **Chrome / OS** : import dans le trousseau système (Keychain macOS / magasin « Autorités
  de certification racines de confiance » Windows / `/usr/local/share/ca-certificates/` +
  `update-ca-certificates` Linux).

**Attendu** : rafraîchir Kibana (`https://localhost:5601`), Vault (`:8200`), OPNsense — le
cadenas passe au **vert**, plus aucun « Accepter le risque ». « Un seul import a rendu
confiance à **tous** mes services internes d'un coup. Et le jour où un avertissement rouge
réapparaît, ce sera un vrai. »

## 3. 💥 La panne du vrai monde — le mot de passe par défaut oublié 3 semaines (RÉELLE)

**À raconter** : « Histoire vraie, et pas glorieuse. J'ai installé OPNsense. Ça marchait :
WAN OK, LAN OK, GUI joignable, IDS actif. J'étais content, je suis passé à la suite —
Suricata, les zones, l'export des logs vers ELK. Pendant **trois semaines**, OPNsense est
resté en `root/opnsense`. Le défaut. Le mot de passe **public**, documenté partout, écrit
dans le manuel, connu de tous les bots de la planète.

Réalise ce que ça veut dire : **un pare-feu, la pièce censée protéger tout le reste, avec
le mot de passe que le monde entier connaît.** La serrure de la porte blindée, avec la clé
scotchée dessus. Toute l'infra derrière — Proxmox, ELK, Vault, mes VMs — protégée par une
porte dont n'importe qui a la clé. Et je ne l'ai même pas oublié par ignorance : je *savais*.
La doc disait "à changer à la 1ʳᵉ connexion". Je me suis dit "je le ferai plus tard". »

**Le fix** : exactement la démo — changer via le système de config (pour que ça persiste),
puis ranger dans `vault_opnsense_root_password`.

**Morale (à dire lentement, à l'écran en gras)** :
> **Le PREMIER geste après "ça marche", c'est "je change le mot de passe par défaut" —
> pas "je le noterai plus tard". Fais-en un réflexe de la même minute, pas une tâche sur
> une liste qu'on oublie.**

« "Plus tard" a duré trois semaines. Une liste de tâches, ça s'oublie. Un réflexe de la
même minute, non. Dès que ça marche, avant de savourer : tu changes le défaut. »

## 4. Encart vrai matériel (2 min)

**À filmer** : `ansible-vault view` sur les vaults réels de l'infra — sans montrer les
valeurs, montrer les **noms** des variables rotées :

- `vault_pbs_root_password` — le `root@pam` du serveur de sauvegarde (PBS) ;
- `vault_opnsense_root_password` — le pare-feu, enfin roté après ses trois semaines ;
- `vault_unseal_key` — la clé d'unseal de Vault (cours 1, chap 6) ;
- `vault_elastic_password`, `vault_kibana_system_password`, `vault_gitlab_root_password`…

**À dire** : « Voilà le trousseau réel. **Chaque secret sensible : chiffré et versionné.**
Un seul fichier `.vault_pass` (jamais committé, dans `.gitignore`) ouvre l'ensemble. Le jour
où l'un fuite, je sais exactement où il est et je le fais tourner en une commande :
`ansible-vault edit`, puis je rejoue le playbook. La rotation devient une routine, pas une
crise. »

## 5. Annonce du TP (1 min)

**À dire** : « À toi de faire l'audit d'hygiène de TON lab. Tu vas lister les services encore
en identifiants par défaut, en changer **un** proprement et le ranger dans l'ansible-vault,
et importer ta CA interne dans ton navigateur pour vérifier qu'un service passe au vert.
20 minutes. Et à la fin, une checklist d'hygiène en 10 points que tu garderas pour toutes
tes futures machines. Au prochain chapitre : le projet final, où tout ce cours se recolle. »
