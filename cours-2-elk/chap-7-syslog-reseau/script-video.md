# Chapitre 7 — Syslog réseau : brancher ce qui n'a pas d'agent : script vidéo

> 🔄 Encart « vrai matériel » réaligné le 11/10/2026 sur le parc post-pivot VDP — référence : [`docs/infra-reelle-2026-10.md`](../../docs/infra-reelle-2026-10.md).

> Durée cible : ~25 min. Prérequis : l'input syslog de Logstash (tcp/udp **5514**) est en
> place depuis le chap 4, Kibana répond, le lab tourne (elastic-1 / kibana-logstash /
> dns-proxy / bastion sur `10.10.99.0/24`).
> Toutes les commandes montrées sont dans `demo.sh` et rejouées avant tournage.
> **Ce chapitre ne crée AUCUN rôle Ansible** : on configure `rsyslog` à la main, sur le
> nœud puis (au TP) sur le bastion. Pas d'agent, juste du forwarding syslog — et UN bloc
> ajouté au pipeline du rôle `logstash` pour que le collecteur sache *lire* ce qu'il reçoit.

## 1. Le concept (5 min)

**À dire** : « Au chapitre 6, on a vu Filebeat : un agent qu'on installe sur une machine
pour lire ses fichiers et les pousser dans ELK. Super. Mais pose-toi la question : ta box
Internet, ton switch managé, ton pare-feu, ton NAS, ton imprimante réseau… tu comptes y
installer Filebeat ? Tu ne peux même pas : ce sont des boîtes fermées. Et pourtant elles
ont toutes des logs, souvent les plus intéressants pour la sécurité.

La solution existe depuis 40 ans et elle est universelle : **syslog**. C'est LE protocole
des logs réseau. N'importe quel équipement sérieux sait faire une chose : *"envoie tous
tes logs vers cette IP, ce port"*. Il ne stocke rien, il ne parse rien : il **forwarde**.
Et de l'autre côté, un collecteur écoute — et c'est LUI qui lit. Ce collecteur, tu l'as
déjà : c'est l'input syslog de Logstash sur le port **5514**, monté au chapitre 4, en tcp
ET en udp. Il attend.

Donc la règle du chapitre : **tout ce qui parle syslog peut alimenter ELK sans agent.**
Aujourd'hui on le prouve avec deux machines qu'on a sous la main — le nœud Proxmox
lui-même (l'hyperviseur !) et le bastion (au TP) — mais c'est exactement pareil pour un
switch ou un pare-feu. »

**Schéma à afficher** :

```
  [ nœud Proxmox ]  ─┐
  [ bastion ]        ├── syslog  udp 5514 ──▶ [ Logstash ]  ──▶ [ Elasticsearch ]
  [ futur switch /   │                        (kibana-logstash        (elastic-1)
    pare-feu / NAS ]─┘                          10.10.99.14)
```

**À insister** : « Regarde bien : aucun agent dans ce schéma. Juste des équipements qui
crachent leur syslog, et un collecteur qui écoute. C'est ça la beauté du truc. »

## 2. Démo guidée (12 min)

On configure le **NŒUD PROXMOX** (l'hyperviseur) pour forwarder son syslog vers Logstash.

### 2.1 Pourquoi le nœud peut joindre Logstash

**À dire** : « Le nœud Proxmox a un pied dans notre segment : le bridge `vmbr1` porte
l'adresse `10.10.99.254`. Donc il est sur le même réseau que kibana-logstash
(`10.10.99.14`) et peut lui parler directement, sans routage. C'est *par cette IP de
segment* qu'il va joindre le collecteur. »

### 2.2 La conf rsyslog (une seule ligne)

**À montrer** (sur le nœud, en root) — créer `/etc/rsyslog.d/90-forward-elk.conf` :

```
*.* @10.10.99.14:5514
```

**À expliquer, LE point du chapitre — `@` vs `@@`** : « Cette ligne se lit :
*"tous les logs (`*.*` = toutes les catégories, tous les niveaux), envoie-les à
10.10.99.14 sur le port 5514"*. Et l'arobase :

- **`@`** (une seule) = **UDP**. Léger, "envoie et oublie". C'est le syslog historique.
- **`@@`** (double) = **TCP**. Fiable, avec accusé de réception, mieux si le réseau perd
  des paquets.

Notre input Logstash écoute les DEUX. On prend `@` (UDP), le plus simple, le plus courant
sur les équipements réseau. Un seul `@` = UDP, retiens ça, c'est LA question piège. »

### 2.3 Redémarrer et générer un log de test

**À montrer** :

```bash
systemctl restart rsyslog
logger -p auth.warning "TEST-SYSLOG-depuis-proxmox"
```

**À dire** : « `logger` fabrique une ligne de log à la demande. `-p auth.warning` la
range dans la catégorie *auth*, niveau *warning* — comme le ferait une vraie tentative de
connexion. Le message porte un tag unique, `TEST-SYSLOG-depuis-proxmox`, pour le retrouver
facilement. À l'instant où j'appuie sur Entrée, rsyslog l'envoie en UDP vers Logstash. »

### 2.4 Le retrouver dans Kibana

**À montrer** : Kibana → **Discover**, vue des index `logstash-*`, requête **KQL** :

```
message : "TEST-SYSLOG-depuis-proxmox"
```

**Attendu** : un document apparaît, avec le message, un champ `host.ip` à `10.10.99.254`,
un timestamp de tout à l'heure. « Voilà. Les logs de l'**hyperviseur** — la machine qui
fait tourner tout ton lab — arrivent maintenant dans ton SIEM. Zéro agent. Une ligne de
conf et un restart. C'est ça, syslog. »

**Puis, le doigt sur le document — à dire** : « Maintenant regarde-le vraiment. `message`,
c'est TOUTE la ligne syslog, brute : `<36>Oct 11 05:22:01 pve root: TEST-…`. Et `host.ip`,
c'est l'adresse de **qui a envoyé le paquet**. Aujourd'hui c'est le nœud lui-même, donc ça
tombe juste. Mais pose-toi la question pour le cours 3 : mon pare-feu OPNsense n'aura pas
de route vers ce segment, il passera par ce nœud, qui *relaiera*. Et là, `host.ip` dira…
le nœud. L'équipement d'origine ? Nulle part — sauf dans le texte. Il est pourtant là,
sous nos yeux : `pve`, dans l'en-tête syslog. Il faut apprendre à Logstash à le **lire**. »

### 2.5 Apprendre à Logstash à lire le syslog (grok + index dédié)

**À montrer** (sur le poste, dans `roles/logstash/templates/pipeline.conf.j2`) : le bloc à
ajouter dans `filter`, après le grok nginx du chapitre 4 — le lire ligne à ligne :

```
if [type] == "syslog" {
  grok {
    match => { "message" => "(?:<%{POSINT:syslog_pri}>)?(?:1 )?(?:%{SYSLOGTIMESTAMP:syslog_timestamp}|%{TIMESTAMP_ISO8601:syslog_timestamp8601}) %{SYSLOGHOST:syslog_hostname} %{DATA:syslog_program}(?:\[%{POSINT:syslog_pid}\])?:? %{GREEDYDATA:syslog_message}" }
    tag_on_failure => ["_syslogparsefailure"]
  }
}
```

**À dire** : « Même outil qu'au chapitre 4, grok, autre motif. On lit l'en-tête syslog
morceau par morceau : la priorité entre chevrons — optionnelle, un test à la main avec
`nc` n'en met pas —, l'horodatage, en format classique OU ISO parce que les émetteurs
varient, puis **le hostname** — c'est lui qu'on veut, `syslog_hostname` —, le programme
avec son pid entre crochets s'il y en a un, et le message nettoyé. Et le filet de
sécurité : si une ligne ne colle pas, elle est quand même indexée, avec un tag
`_syslogparsefailure` qui te dit d'aller voir. »

**À montrer** : dans `output`, le `if [type] == "syslog"` qui route vers
`logstash-syslog-%{+YYYY.MM.dd}`, le reste restant dans `logstash-%{+YYYY.MM.dd}`.
« Souviens-toi de l'encart du chapitre 4 : *un index par famille de source*. Le syslog
réseau est une famille à part — mapping différent, rétention différente demain. On lui
donne son index. La data view `logstash-*` de Kibana voit les deux, rien à refaire. »

Puis `ansible-playbook playbooks/logstash.yml` → `changed=1`, Logstash redémarre.
« C'est le rôle du cours 1 qui travaille : on a changé UN template, Ansible rend, dépose,
redémarre. »

### 2.6 Rejouer, et comparer

**À montrer** : sur le nœud, `logger -p auth.warning "TEST-SYSLOG-depuis-proxmox-2"`. Dans
Kibana, rafraîchir les champs de la data view (Stack Management → Data Views →
`logstash-*` → *Refresh field list*), puis Discover :

```
syslog_hostname : "pve" and message : "TEST-SYSLOG-depuis-proxmox-2"
```

**Attendu / à commenter, AVANT vs APRÈS** (comme au chapitre 4) : le même log, mais
maintenant `syslog_hostname = pve`, `syslog_program = root`, `syslog_message` propre, dans
l'index `logstash-syslog-<date>`. « Le blob est devenu des champs. Je peux demander *tout
ce qu'a dit le bastion*, *toutes les lignes de sshd*, *tout ce qui vient d'OPNsense* — par
le nom que l'équipement a lui-même écrit dans l'en-tête, quel que soit le chemin pris par
le paquet. C'est exactement ce dont le cours 3 aura besoin. »

## 3. Encart vrai matériel (3 min)

**À dire** : « Sur mon infra réelle, ce que tu viens de voir tourne pour de bon, et c'est
un rôle Ansible (`syslog_relay`) qui pose le relais sur la tour. Le **pare-feu OPNsense**
n'aura JAMAIS Filebeat, c'est une appliance fermée. Mais il forwarde son syslog — les
règles déclenchées, les blocages, les alertes de son IDS Suricata — vers le relais, qui
le pousse sur le port syslog de Logstash. Dans Kibana, ça atterrit dans `vortex-logs-*`
avec `application: opnsense`.

Et le switch ? Le mien aujourd'hui est un **TP-Link LS1005G**, un modèle *non-managé* : il
ne sait rien faire d'autre que commuter des trames, pas de syslog — pas même d'adresse IP.
Mais l'ancien, un **T2600G managé**, savait forwarder son syslog exactement comme le nœud.
Dès que tu montes en gamme sur un switch, cette fonction est là. »

**💥 La panne du relais, vécue en septembre** : « Mon relais a forwardé **dans le vide
pendant un mois**. Sa destination était écrite en dur : l'adresse d'une VM Logstash que
j'avais décommissionnée. Et un relais syslog qui n'a personne au bout ne produit AUCUNE
erreur — c'est de l'UDP, ni OPNsense ni rsyslog ne s'en plaignent. La destination est
désormais lue dans l'inventaire. Règle : une adresse codée en dur dans une conf, c'est une
panne silencieuse qui attend son heure. »

**💡 Deux pièges de plus, vécus sur ce relais** : chez moi aussi, `host` disait le
relais et pas l'équipement — exactement pourquoi on a sorti `syslog_hostname` de l'en-tête
en 2.5 ; et un `logger` récent émet du RFC 5424, que notre motif accepte mais range moins
finement — d'où le tag `_syslogparsefailure` à surveiller quand tu branches un nouvel
émetteur.

**Teaser cours 3** : « Retiens bien les logs du pare-feu OPNsense qui arrivent ici. Pour
l'instant ce ne sont que des lignes dans Kibana. **Au cours 3, ces mêmes logs de pare-feu
deviennent des alertes de sécurité** : une connexion refusée répétée, un scan de ports, et
ELK te préviendra. Aujourd'hui on branche le tuyau ; au cours 3 on met l'alarme dessus. »

## 4. 💡 L'astuce du vrai monde (3 min)

> Dérogation assumée : pas de panne dédiée ce chapitre — une astuce de diagnostic à la place.

**À dire** : « Un jour tu forwardes un syslog et… rien n'arrive dans Kibana. Panique zéro.
La bonne méthode, c'est de **tracer le chemin de bout en bout** avec `logger` et un tag
unique, puis de vérifier les trois maillons **dans cet ordre** :

1. **Le pare-feu / le réseau.** Le port 5514 est-il ouvert entre l'émetteur et
   kibana-logstash ? Nos segments internes sont cloisonnés. Un `logger` qui part mais
   n'arrive pas = souvent un port bloqué. Teste la route.
2. **L'écoute de Logstash.** Sur kibana-logstash : `ss -tulnp | grep 5514`. Tu dois voir
   Logstash à l'écoute en **tcp ET udp**. S'il n'écoute pas, c'est Logstash le problème
   (pipeline planté, service down), pas ton émetteur.
3. **Le format.** Notre grok attend du **RFC 3164 ou 5424** — le format syslog standard.
   Bonne nouvelle : rsyslog l'émet dans ce format **par défaut**. Donc si tu utilises
   rsyslog comme nous, ce maillon est bon d'office. C'est surtout à surveiller si un
   équipement exotique envoie du texte non standard : le document arrive quand même, mais
   avec le tag `_syslogparsefailure` et sans `syslog_hostname` — cherche ce tag dans
   Kibana, c'est ton détecteur de format.

Un tag unique + ces trois vérifs dans l'ordre, et tu trouves la panne en deux minutes. »

## 5. Annonce du TP (1 min)

**À dire** : « À toi de rejouer ça, mais sur le **bastion** : forwarde son syslog vers
Logstash, provoque une **tentative SSH ratée** — une vraie ligne de sécurité — et
retrouve-la dans Kibana filtrée par `syslog_hostname`. Attention à une subtilité qu'on connaît bien
depuis le chapitre 6 : ces Debian minimales n'ont **pas rsyslog** installé par défaut… À
toi de voir. 20 minutes. Au prochain chapitre : les **dashboards** — on transforme tous
ces logs en tableaux de bord qui parlent. »
