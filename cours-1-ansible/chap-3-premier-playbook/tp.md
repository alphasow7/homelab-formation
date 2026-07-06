# TP — Chapitre 3 : Enrichir la page de statut (≈ 25 min)

## Objectif

Partir de `ansible/playbooks/web-status.yml` (copie-le ou modifie-le directement)
et enrichir la page de statut de `dns-proxy` pour qu'elle affiche en plus :

1. **L'adresse IP de la machine** — via les facts.
2. **Son uptime** — au format lisible de `uptime -p` (« up 3 days, 2 hours »).

Et ajouter :

3. **Une task qui installe `htop`** (le moniteur système — toujours utile sur un
   serveur).

## ⚠️ Les deux pièges (lis AVANT de commencer)

- **L'IP** : sur ces VMs, `ansible_facts['default_ipv4']` **n'existe PAS** — pas
  de passerelle par défaut sur un segment isolé, donc pas d'« IPv4 par défaut ».
  Si tu l'utilises, le playbook plantera. Utilise plutôt
  `ansible_facts['all_ipv4_addresses'][0]` : la liste de toutes les IPv4 de la
  machine (tu l'as vue au chapitre 2 avec le module `setup`), dont on prend la
  première.
- **L'uptime** : il n'y a pas de fact tout prêt et fiable pour un uptime lisible.
  La méthode : exécuter la commande `uptime -p` avec le module
  `ansible.builtin.command`, capturer sa sortie avec `register`, puis l'injecter
  dans la page. Attention : une task `command` n'est PAS idempotente par nature —
  Ansible ne sait pas si elle a changé quelque chose. Pour garder le critère
  `changed=0`, dis-lui explicitement avec `changed_when: false` (c'est une
  LECTURE, elle ne modifie rien).

## Critère de réussite (non négociable)

- Run 1 après ta modification : la page (vue par `curl` depuis le bastion)
  affiche IP + uptime, et `htop` est installé.
- **Run 2 immédiat : `changed=0` au PLAY RECAP.** Si une task re-change à chaque
  run, ce n'est pas idempotent — corrige avant de regarder la correction.
  (Note : l'uptime affiché ne se met à jour que si la page est réécrite ; c'est
  accepté pour ce TP — une page 100 % dynamique, c'est pour plus tard.)

## Indices

<details>
<summary>Indice 1 — capturer l'uptime avec register</summary>

Une task de lecture, placée AVANT la task de déploiement de la page :

```yaml
- name: Lire l'uptime
  ansible.builtin.command: uptime -p
  register: uptime_result
  changed_when: false
```

La sortie de la commande est ensuite disponible dans
`{{ uptime_result.stdout }}`. Le `changed_when: false` dit à Ansible : « cette
task ne modifie rien, ne la compte jamais en changed » — indispensable pour ton
`changed=0`.
</details>

<details>
<summary>Indice 2 — la page enrichie et htop</summary>

Dans le `content` de la task `copy`, ajoute deux lignes :

```yaml
<p>IP : {{ ansible_facts['all_ipv4_addresses'][0] }}</p>
<p>Uptime : {{ uptime_result.stdout }}</p>
```

Pour `htop`, la task ressemble comme deux gouttes d'eau à celle de nginx :
module `ansible.builtin.apt`, `name: htop`, `state: present`. (Le paquet doit se
télécharger : le masquerade doit être ouvert pour ce run-là, comme dans la démo.)
</details>

## Vérification

```bash
ansible-playbook playbooks/web-status.yml          # run 1 : changed > 0
ssh alpha@IP_DE_TON_BASTION curl -s http://10.10.99.12   # IP + uptime visibles
ansible-playbook playbooks/web-status.yml          # run 2 : changed=0 ✔
ansible dns-proxy -a "htop --version"              # htop répond
```

Correction complète : `correction/tp.yml` (vérifie-la avec
`ansible-playbook --syntax-check correction/tp.yml`).
