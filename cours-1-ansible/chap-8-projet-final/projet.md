# Projet final du cours 1 — Le phénix

**Temps cible : 45 min.** C'est LE test ultime de l'Infrastructure as Code, et la
promesse du chapitre 1 : **si ton infra est vraiment du code, alors une VM n'est plus
précieuse.** Prouvons-le. Tu vas détruire `dns-proxy` — pour de vrai, disque effacé —
puis la faire renaître à l'identique en **moins de 5 minutes**, chronomètre en main.

Pas de nouvelles notions : template et cloud-init (cours 0), inventaire, rôles, vault et
`site.yml` (cours 1). Que de l'assemblage — et un peu de courage.

> Filet de sécurité : le snapshot `fin-cours-0` existe sur les autres VMs, et ton code
> est commité dans Git. Si ton dépôt `ansible/` n'est pas propre (`git status`), commence
> par là : le phénix ne ressuscite que ce qui est dans le code.

## Étape 1 — Photographier l'état (5 min)

Avant de détruire, on fige la preuve « avant ». Depuis ton poste, **garde ces sorties**
(copie-les dans un fichier `avant.txt`) :

```bash
# La page de statut (avec le secret vaulté du chap. 6)
curl -s http://10.10.99.12/        # via le bastion si besoin : ssh -J alpha@<bastion> ...
# Le DNS du lab
dig @10.10.99.12 elastic-1.lab.local +short    # attendu : 10.10.99.11
```

Sans photo « avant », pas de preuve « après ». C'est ton témoin.

## Étape 2 — La destruction (5 min)

Sur le **nœud Proxmox** (pas dans la VM — elle va cesser d'exister) :

```bash
qm stop 9203 && qm destroy 9203
```

`qm destroy` efface le disque. Pas de corbeille, pas de retour. Vérifie que c'est bien
mort : `dig @10.10.99.12 ...` → `connection timed out` ; le `curl` échoue. Ta seule VM
de service DNS/web vient de disparaître. Respire : regarde ton dépôt Git — tout est là.

## Étape 3 — La renaissance chronométrée (15 min)

**Objectif : < 5 minutes entre le `qm clone` et le `dig` qui répond.** Lance un chrono
(ou utilise le script de correction, qui affiche `t=…s` à chaque jalon).

1. **Sur le nœud** — cloner le template doré et réinjecter l'identité via cloud-init :

   ```bash
   qm clone 9000 9203 --name dns-proxy
   qm set 9203 --memory 1024 --ipconfig0 ip=10.10.99.12/24,gw=10.10.99.254
   # user alpha + ta clé : déjà dans le template ; sinon : qm set 9203 --ciuser alpha --sshkeys <fichier>
   qm start 9203
   ```

2. **Attendre SSH** (boucle depuis le nœud, ou depuis ton poste via le bastion) :

   ```bash
   until ssh -o ConnectTimeout=3 alpha@10.10.99.12 true 2>/dev/null; do sleep 5; done
   ```

   ⚠️ Si SSH répond `REMOTE HOST IDENTIFICATION HAS CHANGED` : normal — la VM renée a de
   nouvelles clés d'hôte. `ssh-keygen -R 10.10.99.12` sur ton poste et ça repart.

3. **Depuis ton poste** — la commande magique, celle du chapitre 1 :

   ```bash
   cd cours-1-ansible/ansible
   ansible-playbook playbooks/site.yml --limit dns-proxy
   ```

   common + dns + web_status se redéploient, secret vaulté compris. Arrête le chrono
   quand le `dig` de l'étape 4 répond.

## Étape 4 — Les preuves (10 min)

Rejoue **exactement** les commandes de l'étape 1 et compare avec `avant.txt` :

```bash
curl -s http://10.10.99.12/                       # même page, même secret
dig @10.10.99.12 elastic-1.lab.local +short       # 10.10.99.11
```

Puis la preuve reine — relance le playbook une seconde fois :

```bash
ansible-playbook playbooks/site.yml --limit dns-proxy    # attendu : changed=0
```

`changed=0` signifie : la VM est EXACTEMENT dans l'état décrit par le code. Pas « à peu
près » ressuscitée — conforme, au caractère près.

**L'interdit absolu** pendant tout le projet : **ni GUI Proxmox** (sauf en spectatrice),
**ni commande manuelle DANS la VM**. Si tu as dû te connecter pour « ajuster un truc à
la main », le phénix a échoué : reporte l'ajustement dans le code et recommence.

## Critères de réussite (mesurables)

- [ ] `qm destroy 9203` a bien été exécuté (la VM a disparu de `qm list`, dig → timeout)
- [ ] Renaissance en **moins de 300 s** entre `qm clone` et le premier `dig` OK
- [ ] `curl` et `dig` d'après = ceux d'avant (mêmes sorties que `avant.txt`, secret compris)
- [ ] Second run de `site.yml --limit dns-proxy` → **changed=0**
- [ ] Zéro action GUI, zéro commande manuelle dans la VM (parole d'IaC)

## Qu'est-ce qui a survécu ?

| Élément | Survécu ? | Pourquoi |
|---|---|---|
| Le disque de l'ancienne VM | ❌ | `qm destroy` — parti pour toujours |
| Les clés d'hôte SSH de la VM | ❌ | régénérées → d'où le HOST KEY CHANGED |
| Une modif faite à la main, non commitée | ❌ | elle n'existait que dans le disque… détruit |
| L'IP, l'utilisateur, la clé | ✅ | cloud-init les réinjecte au clone |
| DNS, page de statut, secret vaulté | ✅ | décrits dans les rôles + vault, rejoués par `site.yml` |
| **Le CODE** (inventaire, rôles, playbooks, vault) | ✅ | dans Git — c'est LUI, ton infrastructure |

**Pets vs cattle en 2 lignes** : un « pet » (animal de compagnie) est une machine unique,
soignée à la main, dont la mort est un drame ; du « cattle » (bétail) se remplace à
l'identique, en minutes, par du code. `dns-proxy` vient de prouver qu'elle était du bétail.

## Et après ?

Ton infra renaît en 5 minutes. Mais sais-tu ce qu'elle FAIT à chaque instant ? Au
**cours 2**, on branche les yeux : **ELK** — et `elastic-1` + `kibana-logstash` attendent
déjà sur le segment. À très vite.

Correction complète : [`correction/phenix.sh`](correction/phenix.sh) (à lancer sur le nœud).
