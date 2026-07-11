# Lab du cours 3 — d'où on part

## Prérequis

Le lab **fin de cours 2** : ELK fonctionnel (Elasticsearch, Logstash, Kibana, Filebeat sur
les 4 VMs), les logs qui affluent dans Kibana. C'est important : dans ce cours, **tes
défenses vont produire des alertes, et elles boucleront vers ce SIEM**. Rattrapage :
`git checkout c2-fin` et déroule les cours 0 → 2.

## Nouveau matériel de ce cours

- **Une VM OPNsense** (le pare-feu de périmètre) : 2 vCPU, 1 Go de RAM, disque 8 Go, et
  surtout **2 cartes réseau** — une côté « monde » (WAN), une côté « lab » (LAN). Sur
  l'infra réelle elle a 4 Go ; 1 Go suffit pour ce cours.
- **L'ISO OPNsense** (version DVD, pas la serial) — on la télécharge au chapitre 2.
- **HashiCorp Vault** (chapitre 6) : réutilise une VM existante ou une petite VM de 512 Mo.

## ⚠️ LE piège à connaître AVANT de commencer

**Le LAN par défaut d'OPNsense est `192.168.1.1`.** Si ta box FAI est elle aussi en
`192.168.1.x` (c'est le cas de la plupart des box), et que le WAN d'OPNsense est branché
sur ce même réseau, tu obtiens **deux réseaux avec le même adressage** → le pare-feu ne
sait plus où router, plus d'Internet, GUI injoignable. C'est la panne du chapitre 3, et
on l'évite dès le départ : **le LAN d'OPNsense vivra sur un bridge isolé** (`192.168.99.0/24`,
comme sur l'infra réelle), le WAN sur le réseau qui a Internet.

Retiens la règle : **un subnet, un rôle**. Jamais deux réseaux avec le même adressage.

## Le plan d'adressage — trois réseaux à ne pas confondre

À partir de ce cours, ton lab a **trois** réseaux distincts. Garde ce tableau sous les yeux :

| Réseau | Rôle | Qui y vit |
|---|---|---|
| `192.168.1.0/24` | Ton LAN domestique (la box FAI) | Ton poste, le WAN d'OPNsense (IP DHCP de la box) |
| `192.168.99.0/24` | Le LAN d'OPNsense (côté « lab protégé ») | OPNsense en `.1` — futur réseau de bureau derrière le pare-feu |
| `10.10.99.0/24` | Le segment interne Proxmox (des cours 0-2) | elastic-1 `.11`, kibana-logstash `.14`, dns-proxy `.12`, bastion `.2` |

**Le pont entre eux** : OPNsense a le pied sur le LAN domestique par son WAN. Pour que ses
alertes Suricata rejoignent ton SIEM (Logstash sur `10.10.99.14:5514`), on s'appuie sur le
relais syslog déjà en place au **chapitre 7 du cours 2** : OPNsense envoie son syslog au
nœud Proxmox, qui a une patte sur le segment `10.10.99.0/24` et fait suivre à Logstash.
Autrement dit : **tu ne reconstruis rien** — le pipeline de logs existe déjà, on ne fait
que brancher une nouvelle source (OPNsense) dessus. La seule couture à ajouter (chapitre 5) :
comme le relais du cours 2 ne forwardait que le syslog *du nœud lui-même*, on lui apprend à
**écouter** les messages entrants d'OPNsense — une ligne dans sa conf rsyslog. Chaque
chapitre te rappelle sur quel réseau tu travailles.

## ✅ Vérifications avant le chapitre 1

```bash
# Kibana répond (le SIEM où atterriront tes alertes)
ssh -L 5601:10.10.99.14:5601 -J alpha@IP_DE_TON_BASTION alpha@10.10.99.14
#   puis https://localhost:5601

cd cours-1-ansible/ansible && ansible lab -m ping    # 3 pongs
```
