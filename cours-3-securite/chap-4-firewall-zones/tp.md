# TP Chapitre 4 — Poser une serrure sur le bastion

> Durée : ~20 min. Objectif : durcir la zone du **bastion** (`10.10.99.2`, vmid
> 602). Le SSH (22) ne doit être joignable QUE depuis ton poste (le réseau de
> management), et **tout le reste doit tomber** (policy DROP). Tu prouves ensuite
> que TOI tu joins toujours le bastion, mais qu'une VM du segment, non.

## Ce que tu dois faire

1. Recopie le rôle `zone_firewall` dans ton arbre (`cours-1-ansible/ansible/`) si
   ce n'est pas déjà fait au chapitre.
2. Dans `roles/zone_firewall/defaults/main.yml`, **ajoute une entrée** dans
   `zone_firewall_vms` pour le bastion :
   - `vmid: 602`, `name: bastion` ;
   - une seule règle : autoriser le `22` **uniquement depuis ton poste de
     management** (utilise `zone_firewall_management_source`).
3. Applique : `ansible-playbook playbooks/zone-firewall.yml` (il cible le NŒUD).
4. **Prouve que le bastion reste joignable depuis toi** :
   - `ssh alpha@10.10.99.2` depuis ton poste de management → tu entres.
5. **Prouve qu'une VM du segment ne peut plus toucher le SSH du bastion** :
   - depuis dns-proxy (`10.10.99.12`) : `nc -vz -w 3 10.10.99.2 22` → **timed out**.

## Le résultat attendu

- Depuis ton poste : SSH au bastion → **OK**.
- Depuis dns-proxy : `nc` sur le 22 du bastion → **timed out** (refusé).
- `ping 10.10.99.2` depuis dns-proxy → **répond** (la règle ICMP est laissée par
  le template : le ping reste autorisé pour le diagnostic).

---

<details>
<summary>💡 Indice 1 — quelle source mettre pour le "22" ?</summary>

Le réseau de management, c'est d'où TOI tu administres. Dans ce lab il est
représenté par la variable `zone_firewall_management_source` (le bastion / ton
poste). Réutilise-la telle quelle dans ta règle : ne réécris pas une IP en dur, la
variable existe déjà dans le `defaults`. Une seule ligne `IN ACCEPT ... -dport 22`.
</details>

<details>
<summary>💡 Indice 2 — mon test dns-proxy → 22 "succeeded" quand même !</summary>

Deux causes classiques :
1. Tu as ajouté l'entrée bastion mais **oublié de relancer le playbook** — le
   fichier `602.fw` n'existe pas encore sur le nœud.
2. Ne lis pas le service : **lis les règles** (le réflexe du chapitre !). SUR LE
   NŒUD Proxmox : `pve-firewall compile | grep -A20 'VM 602'`. Si tu ne vois pas
   ton `.fw` ou pas la policy DROP, c'est côté firewall que ça se joue, pas côté
   SSH.
</details>
