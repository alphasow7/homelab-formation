# TP chapitre 7 — Piloter le parc avec site.yml

> Durée : ~20 min. Tout se fait depuis `cours-1-ansible/ansible/`, sauf les
> `qm reboot` (SUR LE NŒUD PROXMOX) et les vérifications (SUR LA VM / DEPUIS
> LE BASTION).
> Prérequis : la démo du chapitre rejouée — `ansible-playbook playbooks/site.yml`
> passe avec zéro `failed`. Si fail2ban n'est pas encore installé, pense au
> masquerade temporaire sur le nœud (bloc 0 de `demo.sh`).

## Ta mission

### Étape 1 — Poser le fix de la panne (drop-in réseau sur dns-proxy)

1. Crée le fichier `inventory/host_vars/dns-proxy.yml` contenant la variable
   `common_network_waits` avec `named` dans la liste.
2. Déploie (astuce : pas besoin de rejouer tout le parc…).
3. Vérifie SUR LA VM dns-proxy que le drop-in est en place :
   `systemctl cat named` doit afficher, après le fichier d'unité d'origine, un
   bloc `/etc/systemd/system/named.service.d/override.conf` avec
   `After=network-online.target`.

### Étape 2 — Débrayer fail2ban sur elastic-1 UNIQUEMENT

1. Crée `inventory/host_vars/elastic-1.yml` qui met `common_fail2ban_enabled`
   à `false`.
2. Redéploie le socle.
3. Prouve-le sans ouvrir de session SSH, avec une commande ad-hoc sur tout le
   groupe : `systemctl is-active fail2ban` doit répondre **`inactive` sur
   elastic-1** et **`active` sur les deux autres**.

### Étape 3 — Le juge de paix : le reboot-test

1. SUR LE NŒUD PROXMOX : `qm reboot <VMID de dns-proxy>` (VMID via `qm list`).
2. Attends le retour de la VM (~30 s), puis DEPUIS LE BASTION :
   `dig @10.10.99.12 elastic-1.lab.local +short`.
3. La réponse doit tomber : `10.10.99.11`. Refais un reboot pour être sûr :
   c'est le reboot qui dit la vérité.

## Indices

<details>
<summary>Indice 1 — host_vars, c'est quoi et ça va où ?</summary>

`inventory/host_vars/<nom-de-machine>.yml` : les variables qui ne valent que
pour CETTE machine (le nom du fichier doit être EXACTEMENT le nom de l'hôte
dans l'inventaire). Ansible les charge tout seul, rien à déclarer. Une liste
YAML s'écrit `ma_variable: [valeur]` ou sur plusieurs lignes avec des tirets.
Pour ne déployer qu'une machine : `--limit <nom>`.
</details>

<details>
<summary>Indice 2 — la commande ad-hoc de l'étape 2 affiche du rouge ?</summary>

C'est normal : `systemctl is-active` renvoie un code de sortie non nul quand le
service est inactif, donc Ansible marque elastic-1 en `FAILED (rc=3)` — mais
regarde la sortie : elle dit bien `inactive`, c'est TA preuve. Le squelette :

```
ansible lab -m ansible.builtin.command -a "systemctl is-active fail2ban"
```

Et si fail2ban est encore `active` sur elastic-1 après le déploiement, relis le
nom exact de la variable dans `roles/common/defaults/main.yml`.
</details>

## Critères de réussite (mesurables)

- [ ] Étape 1 : `systemctl cat named` sur dns-proxy affiche le drop-in
      `override.conf` avec `After=network-online.target` et
      `Wants=network-online.target`.
- [ ] Étape 2 : la commande ad-hoc renvoie `inactive` pour elastic-1 et
      `active` pour kibana-logstash et dns-proxy.
- [ ] Étape 3 : après `qm reboot`, le `dig` depuis le bastion répond
      `10.10.99.11` (et pas un timeout), y compris au deuxième reboot.
- [ ] Aucune modification faite à la main sur les VMs : uniquement des fichiers
      dans `inventory/host_vars/` et des runs de `site.yml`.

Bloqué plus de 5 minutes après les deux indices ? La correction est dans
`correction/`.
