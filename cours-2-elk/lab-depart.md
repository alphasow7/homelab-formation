# Lab du cours 2 — d'où on part

## Prérequis

Le lab **fin de cours 1** : les 4 VMs (elastic-1, kibana-logstash, dns-proxy, bastion) et
l'arbre `ansible/` complet (rôles common/dns/web_status, `site.yml` qui passe en
`changed=0`). Rattrapage : clone le repo, `git checkout c1-fin`, et déroule
[`cours-1-ansible/lab-depart.md`](../cours-1-ansible/lab-depart.md) puis le projet phénix.

## ⚠️ La RAM — lis ce paragraphe

**Elasticsearch est gourmand.** Le cours est calibré pour : ES avec 2 Go de heap sur
elastic-1 (4 Go), Logstash 512 Mo + Kibana sur kibana-logstash (2 Go). Avant de commencer :

- **Chemin A (VirtualBox)** : monte la VM Proxmox à **10-12 Go de RAM** si ton PC le
  permet (VM éteinte → Configuration → Système). Sinon, libère de la place : arrête les
  clones du cours 0 s'ils tournent encore (`qm stop 9101 9102 9103`).
- **Chemin B** : 8 Go sur le PC dédié passent, 16 Go sont confortables.

Vérification : `ansible elastic-1 -m ansible.builtin.shell -a "free -h"` → ≥ 3,5 Go
au total sur la VM.

## Où vit le code de ce cours ?

**On continue dans le MÊME arbre** `cours-1-ansible/ansible/` — c'est le réalisme : une
infra, un repo, qui grandit. Les nouveaux rôles (elasticsearch, elk_certs, logstash,
kibana, filebeat) s'y ajoutent chapitre après chapitre.

Le dossier [`ansible-extraits/`](ansible-extraits/) de ce cours contient la **copie de
référence** de chaque fichier ajouté — pour lire le code final sans dépendre de l'état de
ton lab, et pour te comparer en cas de doute (les tags `c2-chap*-fin` figent aussi chaque
étape).

## ✅ Vérifications avant le chapitre 1

```bash
cd cours-1-ansible/ansible
ansible lab -m ping                          # 3 pongs
ansible-playbook playbooks/site.yml          # changed=0 (ton lab est sain)
```
