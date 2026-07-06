# Lab du cours 1 — d'où on part

## Ce qu'il te faut

Le **squelette du cours 0** (projet final, chapitre 7) :

| id | Nom | RAM | IP (segment vmbr1) |
|---|---|---|---|
| 9201 | `elastic-1` | 4096 Mo | 10.10.99.11 |
| 9202 | `kibana-logstash` | 2048 Mo | 10.10.99.14 |
| 9203 | `dns-proxy` | 1024 Mo | 10.10.99.12 |
| 9204 | `bastion` | 512 Mo | 10.10.99.2 (+ une patte sur ton réseau) |

Si tu as suivi le cours 0 : démarre les 4 VMs — au besoin, reviens à l'état propre avec
le snapshot : `qm rollback <id> fin-cours-0` puis `qm start <id>`.

## Tu n'as pas fait le cours 0 ?

Rattrapage express (~1 h 30) :
1. Installe Proxmox en suivant [`labs/lab-cours-0.md`](../labs/lab-cours-0.md) (chemin A ou B).
2. Fais les chapitres 3 à 5 du cours 0 en accéléré, ou directement : crée le template doré
   (`cours-0-fondations/chap-5-templates-cloudinit/correction/tp.sh`), le bridge vmbr1
   (`chap-4-reseau-proxmox/demo.sh`, bloc 1), puis déroule
   [`cours-0-fondations/chap-7-projet-final/correction/deploy-lab.sh`](../cours-0-fondations/chap-7-projet-final/correction/deploy-lab.sh).

Tu rateras le POURQUOI de chaque brique — le cours 0 reste le vrai chemin.

## Installer Ansible sur TON poste

Ton poste devient le **contrôleur** : c'est lui qui pilote les VMs (Ansible n'installe
rien sur les machines gérées — juste SSH).

- **macOS** : `brew install ansible`
- **Debian/Ubuntu** : `sudo apt install ansible`
- **Windows** : Ansible ne pilote pas depuis Windows natif → **WSL obligatoire**
  (`wsl --install`, puis dans Ubuntu : `sudo apt install ansible`). Ta clé SSH doit être
  DANS le WSL (`ssh-keygen` dedans + recopier la clé publique sur les VMs, chapitre 0 du
  cours 0).

## ✅ Vérifications avant le chapitre 1

```bash
ansible --version        # ≥ 2.15
ssh alpha@IP_DE_TON_BASTION hostname    # → bastion, sans mot de passe
```

`IP_DE_TON_BASTION` : chemin A = l'IP de la patte vmbr0 du bastion (visible GUI > VM 9204
> Summary) ; chemin B = son IP sur ton LAN. Note-la — on s'en sert dès le chapitre 2.
