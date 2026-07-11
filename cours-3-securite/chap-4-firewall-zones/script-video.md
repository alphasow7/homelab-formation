# Chapitre 4 — Le firewall par zone : les serrures de chaque appartement : script vidéo

> Durée cible : ~25 min. Prérequis : ELK du cours 2 qui tourne (segment
> `10.10.99.0/24` — elastic-1 en `.11`, kibana-logstash en `.14`, dns-proxy en
> `.12`, bastion en `.2`) et le périmètre OPNsense des chapitres 2-3 en place.
> Toutes les commandes montrées sont dans `demo.sh` et rejouées avant tournage.
> Le rôle complet est dans `../ansible-extraits/roles/zone_firewall/` — l'élève le
> recopie dans SON arbre (`cours-1-ansible/ansible/roles/`).

## 1. Le concept (5 min)

**À dire** : « Aux chapitres 2 et 3, tu as posé OPNsense : le pare-feu de
**périmètre**. C'est la porte d'entrée de l'immeuble — il décide qui entre dans
le lab depuis le monde. Excellent. Mais pose-toi une question désagréable : et si
un attaquant est DÉJÀ dedans ? Si UNE de tes VMs est compromise — un service mal
patché, un mot de passe faible — le périmètre ne sert plus à rien : le cambrioleur
est dans le hall. À l'intérieur, si rien ne l'arrête, il ouvre TOUS les
appartements. Il saute d'elastic-1 à Kibana, de Kibana à ton bastion, et c'est
fini.

C'est ça, la défense en profondeur DANS le lab :

- **Le périmètre (OPNsense)**, c'est la porte d'entrée de l'immeuble.
- **Les zones**, ce sont les **serrures de chaque appartement**. Si un cambrioleur
  entre dans le hall, il ne doit pas pouvoir ouvrir tous les appartements.

Ces serrures, Proxmox sait les poser tout seul : c'est le **firewall par zone**
(`pve-firewall`). Chaque VM a un fichier de règles, `/etc/pve/firewall/<vmid>.fw`,
que le NŒUD Proxmox filtre au ras de la carte réseau de la VM. Deux ingrédients :

1. une **policy DROP en entrée** : par défaut, on **refuse tout** ;
2. quelques **autorisations au compte-gouttes** : on rouvre UNIQUEMENT les ports
   dont on a besoin, et seulement depuis les sources légitimes.

C'est le **moindre privilège** : tu ne demandes pas "qu'est-ce que je bloque ?",
tu demandes "qu'est-ce que j'autorise, et pour qui ?". Tout le reste tombe. »

**⚠️ À insister** : « Ce rôle s'applique sur le NŒUD Proxmox, pas sur les VMs.
C'est l'hyperviseur qui écrit les fichiers `.fw` et qui filtre — la VM, elle, ne
sait même pas qu'elle est protégée. »

## 2. Démo guidée (12 min)

### 2.1 Poser la serrure sur elastic-1

**À montrer** : recopier le rôle depuis `ansible-extraits/` vers l'arbre élève,
puis regarder le `defaults/main.yml` : la liste `zone_firewall_vms` avec elastic-1
(vmid 611) et ses deux seules autorisations —

- `9200` (Elasticsearch) **uniquement depuis Logstash** (`10.10.99.14`) ;
- `22` (SSH) **uniquement depuis le bastion** (`10.10.99.2`).

Le template ajoute tout seul une règle ICMP (le ping, pour diagnostiquer) et la
policy `DROP`. **Tout le reste du segment `10.10.99.0/24` est refusé.**

**Avant de lancer — déclarer le nœud** : le playbook fait `hosts: proxmox`, mais le
nœud n'est pas dans le groupe `lab` (ce sont les VMs, jointes via le bastion). On
ajoute un groupe `proxmox` dans `inventory/hosts.yml` pointant sur l'IP de management
du nœud, en `root`, **en direct** (pas via le ProxyJump du bastion). C'est le premier
groupe d'inventaire qu'on ajoute hors du `lab` ; le bloc YAML exact est dans l'en-tête
du playbook `zone-firewall.yml`.

```bash
ansible-playbook playbooks/zone-firewall.yml
```

**À expliquer pendant que ça tourne** : « Le playbook cible `proxmox`, pas les
VMs. Il écrit `/etc/pve/firewall/611.fw` sur le nœud. Note le `unsafe_writes:
true` dans le rôle : `/etc/pve` est un système de fichiers spécial, on ne peut pas
y écrire "proprement" — c'est normal, le rôle réel fait pareil. »

### 2.2 Vérifier que Logstash joint TOUJOURS Elasticsearch

**À montrer** — DEPUIS la VM kibana-logstash (`10.10.99.14`) :

```bash
nc -vz -w 3 10.10.99.11 9200
```

**Attendu** : `Connection to 10.10.99.11 9200 port [tcp/*] succeeded!` — « Logstash
est une source autorisée sur le 9200. La chaîne ELK continue de fonctionner : on a
durci sans rien casser de légitime. »

### 2.3 Vérifier qu'une AUTRE VM du segment est maintenant refusée

**À montrer** — DEPUIS la VM dns-proxy (`10.10.99.12`), une VM du même segment mais
qui n'a AUCUNE raison de parler à Elasticsearch :

```bash
nc -vz -w 3 10.10.99.11 9200
```

**Attendu** : ça **bloque** puis `timed out` (au bout des 3 secondes). « Même
segment, même sous-réseau — et pourtant, refusé. Avant, dns-proxy pouvait toquer à
la porte 9200 d'elastic-1. Plus maintenant. Si dns-proxy est compromis demain,
l'attaquant ne peut plus rebondir sur ta base de logs. Voilà la serrure de
l'appartement. »

## 3. 💥 La panne du vrai monde — le service joignable de nulle part

> Panne RÉELLE, rejouée. Sur l'infra, après un durcissement de zone, un service
> est devenu injoignable — et le premier réflexe a été d'**accuser le service**.

**Mise en situation** : « Tu ajoutes une VM à durcir, ou tu ajustes une règle
existante, et — mauvaise manip classique — tu oublies d'autoriser le port. Par
exemple, tu retires par erreur la ligne du `9200` dans les règles d'elastic-1.
Tu relances le playbook. Et là : **Logstash ne parle plus à Elasticsearch**. Les
logs n'arrivent plus dans Kibana. »

**Le symptôme** : depuis kibana-logstash, `nc -vz 10.10.99.11 9200` → `timed
out`. Kibana est vide. Panique.

**💥 LE FAUX RÉFLEXE** (à jouer à l'écran, exprès) :

```bash
# "C'est sûrement Elasticsearch qui est planté !"
ssh alpha@10.10.99.11 'systemctl restart elasticsearch'   # ne change RIEN
ssh alpha@10.10.99.11 'journalctl -u elasticsearch -n 50' # tout va bien côté service !
```

« Tu redémarres le service. Tu lis ses logs. Et le service te répond : "je vais
très bien, je suis à l'écoute sur 9200, aucune erreur". Tu perds 20 minutes à
soupçonner un innocent. Le service N'EST PAS le problème — la preuve, il n'a même
pas vu passer la connexion : elle a été **coupée avant** d'arriver jusqu'à lui. »

**✅ LE BON DIAGNOSTIC** : lis les **RÈGLES** actives, PAS les logs du service.
Et lis-les **sur le NŒUD Proxmox**, là où le filtrage a lieu :

```bash
# SUR LE NŒUD Proxmox — compiler/afficher les règles réellement appliquées
pve-firewall compile | grep -A20 'VM 611'   # la 9200 a disparu de la liste !
# ou, plus bas niveau, les règles iptables générées pour la VM :
iptables -L -n | grep 9200                  # (aucune ligne = port non autorisé)
```

« En dix secondes tu VOIS que le `9200` n'est plus dans les règles. Le port était
simplement bloqué. Tu remets la ligne, tu relances le playbook, Logstash reparle,
Kibana se remplit. »

> **Morale (à graver) : un service injoignable juste après un changement de
> firewall — lis les RÈGLES d'abord, pas les logs du service. La cause est presque
> toujours là où tu viens de toucher.**

**À dire** : « C'est la même famille de pannes qu'aux cours précédents. Au cours 1,
"lis le journal" (`journalctl`) avant d'accuser Ansible. Au cours 2, "lis la
réponse" d'Elasticsearch avant d'accuser le réseau. Ici c'est "lis les règles"
avant d'accuser le service. Même méthode : **regarde l'endroit que tu viens de
modifier, pas l'endroit qui se plaint.** »

## 4. Encart vrai matériel (2 min)

**À filmer** : sur le vrai nœud, `ls /etc/pve/firewall/` et l'ouverture d'un vrai
`.fw`, puis un `pve-firewall compile`.

**À dire** : « Sur l'infra réelle, le rôle `proxmox_firewall` gère plusieurs zones
d'un coup, chacune avec sa policy `DROP` et ses ports :

- la zone **management** (le contrôleur Ansible) ;
- la zone **elk** (les nœuds Elasticsearch, Logstash, Kibana) — 9200/9300 entre
  eux, 5601 pour Kibana, 5044 pour Filebeat, et rien d'autre ;
- la zone **devsecops** (GitLab, Vault) — 443, 8200, et même un filtrage de
  SORTIE (`policy_out: DROP`) pour limiter l'exfiltration.

Chaque VM ne reçoit QUE les ports de son rôle. Notre `zone_firewall` de la
formation, c'est exactement cette idée, réduite à une VM et deux règles pour que
tu voies le mécanisme à nu. »

## 5. Annonce du TP (1 min)

**À dire** : « À toi de poser une serrure. Objectif : durcir la zone du **bastion**
(`10.10.99.2`). Le bastion, c'est ta porte d'entrée SSH — il ne doit accepter le
`22` QUE depuis ton poste (le réseau de management), et **DROP** tout le reste. Tu
prouveras que tu joins toujours le bastion depuis chez toi, mais qu'une VM du
segment, elle, ne peut plus toucher son SSH. 20 minutes. Au prochain chapitre :
on rallume l'œil — Suricata, l'IDS qui repère l'intrus quand il essaie quand
même. »
