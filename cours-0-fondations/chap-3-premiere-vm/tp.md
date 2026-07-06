# TP chapitre 3 — Ta deuxième VM, en IP statique

**Temps cible : 25 min.** Tout se fait sur le nœud Proxmox (shell root) + ton poste pour
la vérification finale.

## Objectif

Créer une **deuxième VM cloud-init** (`demo-vm2`, id **9002**) avec une **IP statique**
— parce qu'un serveur dont l'adresse change tous les matins, ce n'est pas un serveur —
puis prouver qu'elle marche avec une connexion SSH par clé.

## Énoncé

1. Reprends la méthode du chapitre (image cloud déjà téléchargée : pas besoin de refaire
   le `wget`) pour créer la VM **9002**, nommée `demo-vm2`, 1 Go de RAM, 1 vCPU, sur
   `vmbr0`.
2. Configure cloud-init : utilisateur `alpha`, ta clé publique, et l'**IP statique** selon
   ton chemin :
   - **Chemin A (VirtualBox)** : `--ipconfig0 ip=10.0.2.50/24,gw=10.0.2.2`
   - **Chemin B (PC dédié)** : `--ipconfig0 ip=192.168.1.245/24,gw=192.168.1.1`
     (vérifie que cette IP est libre et hors plage DHCP de ta box)
3. Démarre la VM.
4. **Preuve finale** depuis le nœud (ou ton poste pour le chemin B) :

```bash
ssh alpha@10.0.2.50 hostname      # chemin A (192.168.1.245 pour le chemin B)
```

**Attendu** : la commande répond `demo-vm2` **sans demander de mot de passe**.

## Critères de réussite

- [ ] `qm list` montre `9002 demo-vm2 running`
- [ ] `ssh alpha@<ip> hostname` → `demo-vm2`, sans mot de passe
- [ ] Dans la GUI : VM 9002 > **Cloud-Init** montre bien l'utilisateur, la clé et l'IP

## Indices

<details>
<summary>Indice 1 — la liste des commandes à adapter</summary>

Ce sont exactement celles de `demo.sh`, blocs 2 à 4, en remplaçant : `9001` → `9002`,
`demo-vm` → `demo-vm2`, et `ip=dhcp` → ton `ip=...,gw=...`. Le disque importé s'appellera
`vm-9002-disk-0`.
</details>

<details>
<summary>Indice 2 — ça ne répond pas ?</summary>

Le piège classique : le **gw** oublié ou faux dans `--ipconfig0` (sans passerelle, la VM
ne répond qu'aux machines de son propre réseau). Vérifie ta config dans la GUI :
**VM 9002 > Cloud-Init** — c'est là que tu vois ce que cloud-init appliquera. Si tu
corriges quelque chose : **stop puis start** (pas reboot !), comme vu dans la panne du
chapitre.
</details>

Correction complète : [`correction/tp.sh`](correction/tp.sh).
