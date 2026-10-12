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

## Le masquerade temporaire (tu t'en serviras à chaque installation de paquet)

Le segment `10.10.99.0/24` n'a **pas d'Internet** — c'est un choix (cours 0, chapitre 4).
Chaque fois qu'un playbook doit installer un paquet, on ouvre une sortie NAT **sur le
nœud**, le temps du playbook, puis on la referme. Deux verrous à chaque fois : le routage
et la réécriture d'adresse.

```bash
# SUR LE NŒUD PROXMOX, en root — ON (avant le playbook)
WAN_IF="$(ip route | awk '/default/{print $5;exit}')"
sysctl -w net.ipv4.ip_forward=1
iptables -t nat -A POSTROUTING -s 10.10.99.0/24 -o "$WAN_IF" -j MASQUERADE

# OFF (après le playbook) — un accès temporaire, ÇA SE REFERME
iptables -t nat -D POSTROUTING -s 10.10.99.0/24 -o "$WAN_IF" -j MASQUERADE
```

Le verrou vers Internet, c'est la **règle NAT** : c'est elle qu'on ouvre et qu'on referme.
Le routage (`ip_forward`) reste à 1 — sans lui, rien ne traverse le nœud, et le cours 3 en
aura besoin en permanence (il le rendra persistant).

Les `demo.sh` qui en ont besoin le signalent par un bloc « MASQUERADE ON/OFF ». La
réponse propre — un proxy apt sur le nœud — est évoquée dans les encarts ; elle n'est
pas au programme de ce cours.

## Installer Ansible sur TON poste

Ton poste devient le **contrôleur** : c'est lui qui pilote les VMs (Ansible n'installe
rien sur les machines gérées — juste SSH).

- **macOS** : `brew install ansible`
- **Debian/Ubuntu** : `sudo apt install ansible`
- **Windows** : Ansible ne pilote pas depuis Windows natif → **WSL obligatoire**
  (`wsl --install`, puis dans Ubuntu : `sudo apt install ansible`). Ta clé SSH doit être
  DANS le WSL : si tu as fait le cours 0 depuis PowerShell, refais depuis WSL l'étape D du
  chapitre 2 (`ssh-keygen` + `ssh-copy-id` vers le nœud + trousseau), puis redonne le
  trousseau aux 4 VMs : `qm set <id> --sshkeys /root/.ssh/lab-keys.pub` et stop/start.

## ✅ Vérifications avant le chapitre 1

```bash
ansible --version        # ≥ 2.16 (ansible-core 2.15 n'est plus maintenu)
ssh alpha@IP_DE_TON_BASTION hostname                       # → bastion, sans mot de passe
ssh -J alpha@IP_DE_TON_BASTION alpha@10.10.99.11 hostname  # → elastic-1, à travers le bastion
```

`IP_DE_TON_BASTION` : **chemin B** = l'IP de la patte `net0` du bastion sur ton LAN ;
**chemin A** = `localhost`, port `2223` (la règle de redirection VirtualBox « bastion » →
`10.0.2.20:22`, voir `labs/chemin-a-virtualbox.md`), ce qui s'écrit `alpha@localhost:2223`
dans un `-J` et, dans l'inventaire du chapitre 2, `ansible_host: localhost` +
`ansible_port: 2223`. Note-la — on s'en sert dès le chapitre 2.
