# Correction TP chapitre 5 — les runs et les curl attendus

> Tout se lance depuis `cours-1-ansible/ansible/` (là où vit `ansible.cfg`).
> Remplace `IP_DE_TON_BASTION` comme d'habitude. Les titres exacts sont libres :
> ce qui compte, c'est d'en voir TROIS DIFFÉRENTS, un par étage.

## Étape 1 — group_vars : ton titre personnel

Dans `inventory/group_vars/lab.yml`, remplacer la ligne du titre, par exemple :

```yaml
web_status_title: "Le lab d'Alpha — titre du groupe"
```

```bash
ansible-playbook playbooks/web-status-role.yml
```

Attendu : `changed=1` (la page est réécrite) + le handler nginx.

```bash
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12
```

Attendu :

```html
<h1>Le lab d'Alpha — titre du groupe</h1>
<p>Machine : dns-proxy — Debian 12.x</p>
```

## Étape 2 — host_vars : l'exception de la machine

```bash
mkdir -p inventory/host_vars
cp ../chap-5-variables/correction/host_vars-dns-proxy.yml \
   inventory/host_vars/dns-proxy.yml
ansible-playbook playbooks/web-status-role.yml
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12
```

Attendu :

```html
<h1>dns-proxy — l'exception de la machine (host_vars)</h1>
```

Le group_vars est TOUJOURS en place, mais host_vars est plus spécifique, donc
plus fort : c'est lui qui gagne pour `dns-proxy` (et seulement pour lui — les
autres machines du groupe garderaient le titre group_vars).

## Étape 3 — -e : l'ordre direct

```bash
ansible-playbook playbooks/web-status-role.yml -e 'web_status_title="Ordre direct : -e gagne sur tout"'
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12
```

Attendu :

```html
<h1>Ordre direct : -e gagne sur tout</h1>
```

`-e` écrase host_vars, group_vars et les defaults. Personne au-dessus de lui.

## Bonus — un run sans -e

```bash
ansible-playbook playbooks/web-status-role.yml
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12
```

Attendu : le titre **host_vars** revient. Le `-e` n'a rien écrit dans le repo :
c'était un ordre pour un run. Dès qu'il disparaît, l'étage le plus fort qui
reste — host_vars — reprend la main. C'est pour ça que la config permanente vit
dans des fichiers versionnés, jamais dans des `-e` qu'on oublie.

## Récapitulatif des trois curl (le critère de réussite)

| Run | Titre affiché | Étage qui a gagné |
|---|---|---|
| 1 | « Le lab d'Alpha — titre du groupe » | group_vars |
| 2 | « dns-proxy — l'exception de la machine (host_vars) » | host_vars |
| 3 | « Ordre direct : -e gagne sur tout » | `-e` |
