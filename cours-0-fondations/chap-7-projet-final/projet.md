# Projet final du cours 0 — Le squelette de ton lab

**Temps cible : 45 min.** C'est l'examen de sortie : tu assembles TOUT ce que tu as appris
(cloud-init, template, segments, snapshots) pour déployer le squelette qui servira aux
cours 1, 2 et 3. Pas de nouvelles notions — que de l'assemblage.

## Cahier des charges

À partir de ton **template doré 9000**, déploie ces 4 VMs :

| id | Nom | RAM | Réseau(x) | IP |
|---|---|---|---|---|
| 9201 | `elastic-1` | 4096 Mo | vmbr1 | 10.10.99.11/24, gw .254 |
| 9202 | `kibana-logstash` | 2048 Mo | vmbr1 | 10.10.99.14/24, gw .254 |
| 9203 | `dns-proxy` | 1024 Mo | vmbr1 | 10.10.99.12/24, gw .254 |
| 9204 | `bastion` | 512 Mo | **vmbr0 ET vmbr1** | net0 : dhcp (ou statique LAN) ; net1 : 10.10.99.2/24 |

Le **bastion** est la porte d'entrée : c'est la seule VM qui a un pied dans les deux
mondes (ton réseau + le segment isolé). En vrai, on ne saute jamais directement dans un
segment interne — on passe par une machine de rebond.

Puis :

1. Ajuste la RAM de chaque clone (`qm set <id> --memory <mo>`).
2. Pour le bastion : ajoute une 2ᵉ carte réseau (`qm set 9204 --net1 virtio,bridge=vmbr1`
   puis `--ipconfig1 ip=10.10.99.2/24` — sans gw : la sortie par défaut reste net0).
3. **Snapshot `fin-cours-0`** sur chacune des 4 VMs : l'état de départ des cours suivants.

## Critères de réussite (mesurables)

- [ ] `qm list` : les 4 VMs `running`
- [ ] Depuis le nœud : les 4 IP du segment répondent au ping
- [ ] Depuis le **bastion** : `ssh alpha@10.10.99.11 hostname` → `elastic-1` (le bastion
      voit le segment)
- [ ] Depuis ton poste : SEUL le bastion est joignable (chemin B : ping des IP 10.10.99.x
      → échec ; chemin A : elles n'ont jamais été routées jusqu'à toi)
- [ ] `qm listsnapshot <id>` montre `fin-cours-0` sur les 4 VMs

## Et après ?

Éteins le lab proprement (`qm stop` sur les 4, ou laisse tourner si la machine reste
allumée). **Cours 1 (Ansible)** : on repart exactement d'ici — et la première chose qu'on
fera, c'est détruire `dns-proxy`… pour la faire renaître en une commande. À très vite.

Correction complète : [`correction/deploy-lab.sh`](correction/deploy-lab.sh).
