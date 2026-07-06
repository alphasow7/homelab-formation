# Correction TP chapitre 7 — Piloter le parc avec site.yml

> Les deux fichiers host_vars corrigés sont dans ce dossier :
> - `host_vars-dns-proxy.yml` → à copier en `inventory/host_vars/dns-proxy.yml`
> - `host_vars-elastic-1.yml` → à copier en `inventory/host_vars/elastic-1.yml`
>
> (Le nom du fichier dans `inventory/host_vars/` doit être EXACTEMENT le nom de
> l'hôte tel qu'il apparaît dans l'inventaire.)

## Étape 1 — Drop-in réseau sur dns-proxy

```bash
# Depuis cours-1-ansible/ansible/ :
mkdir -p inventory/host_vars
# Créer inventory/host_vars/dns-proxy.yml (voir host_vars-dns-proxy.yml)

# Déployer SEULEMENT dns-proxy — inutile de rejouer tout le parc :
ansible-playbook playbooks/site.yml --limit dns-proxy
# Attendu : les 2 tâches "drop-in" en changed + le handler "Reload systemd".

# Vérifier SUR LA VM :
ssh -J alpha@IP_DE_TON_BASTION alpha@10.10.99.12 "systemctl cat named"
```

Attendu à la fin de la sortie :

```
# /etc/systemd/system/named.service.d/override.conf
[Unit]
After=network-online.target
Wants=network-online.target
```

## Étape 2 — fail2ban débrayé sur elastic-1 uniquement

```bash
# Créer inventory/host_vars/elastic-1.yml (voir host_vars-elastic-1.yml)

# Redéployer le socle (tout le parc, ou --limit elastic-1) :
ansible-playbook playbooks/site.yml
# Attendu : sur elastic-1, la tâche "Arrêter et désactiver fail2ban…" en changed.

# La preuve, en une commande ad-hoc :
ansible lab -m ansible.builtin.command -a "systemctl is-active fail2ban"
```

Attendu :

```
kibana-logstash | CHANGED | rc=0 >>
active
dns-proxy | CHANGED | rc=0 >>
active
elastic-1 | FAILED | rc=3 >>
inactive
```

Le `FAILED | rc=3` sur elastic-1 est NORMAL : `systemctl is-active` renvoie un
code non nul quand le service est inactif. La sortie `inactive` est la preuve
demandée — actif partout, sauf là où le host_vars l'a débrayé.

## Étape 3 — Le reboot-test

```bash
# SUR LE NŒUD PROXMOX :
qm list | grep dns-proxy      # → noter le VMID
qm reboot <VMID>

# Attendre ~30 s, puis DEPUIS LE BASTION :
dig @10.10.99.12 elastic-1.lab.local +short
```

Attendu : `10.10.99.11` — pas de timeout, même après plusieurs reboots. Grâce
au drop-in, named attend désormais que la VM ait son IP avant de choisir ses
adresses d'écoute : la course du boot est gagnée d'avance.
