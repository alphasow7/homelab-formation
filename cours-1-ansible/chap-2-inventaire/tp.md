# TP chapitre 2 — Commander tout le lab avec des commandes ad-hoc

> Durée : ~15 min. Tout se fait DEPUIS ton poste, dans le dossier
> `cours-1-ansible/ansible/`. Interdiction d'ouvrir une session SSH à la main :
> uniquement des commandes ad-hoc `ansible`.
> Prérequis : `IP_DE_TON_BASTION` remplacée dans `inventory/hosts.yml`, et
> `ansible lab -m ping` qui renvoie 3 pongs verts (sinon, retourne à la démo).

## Ta mission

`chrony`, c'est le service qui garde l'heure des VMs synchronisée — indispensable
pour des logs cohérents (tu verras vite pourquoi dans la suite du cours).

1. **Redémarre `chrony` sur tout le groupe `lab`**, en une seule commande ad-hoc.
   Tu auras besoin du module `ansible.builtin.service` — et redémarrer un service,
   ça demande les droits administrateur.
2. **Vérifie qu'il est actif partout** : fais exécuter `systemctl is-active chrony`
   sur tout le groupe.
3. **Bonus** : trouve la RAM (en Mo) de chaque VM sans jamais t'y connecter.
   Piste : les facts vus en démo, et le module `setup` accepte un argument
   `filter=` pour n'afficher qu'un fact précis. Celui qui t'intéresse s'appelle
   `ansible_memtotal_mb`.

## Indices

<details>
<summary>Indice 1 — la structure d'une commande ad-hoc</summary>

Toute commande ad-hoc suit le même squelette :

```
ansible <cible> -m <module> -a "<arguments>"
```

- `<cible>` : un groupe (`lab`) ou un hôte (`dns-proxy`) de ton inventaire.
- `-m <module>` : la brique d'action (si tu l'omets, c'est `command`, la
  commande brute).
- `-a "..."` : les arguments du module. Pour le module `service`, ça ressemble à
  `"name=... state=..."` ; l'état qui redémarre s'appelle `restarted`.
</details>

<details>
<summary>Indice 2 — « Permission denied » ou « Interactive authentication required » ?</summary>

Redémarrer un service, c'est réservé à root. L'option `--become` dit à Ansible de
passer en super-utilisateur sur la machine cible (l'équivalent d'un `sudo`).
Ajoute-la à ta commande de l'étape 1. Les étapes 2 et 3 n'en ont pas besoin :
lire un état ou des facts, tout le monde a le droit.
</details>

## Critères de réussite (mesurables)

- [ ] Étape 1 : la commande renvoie **3 blocs `CHANGED`** (un par VM), avec
      `"state": "started"` et `"status": "active"` dans la sortie — zéro
      `FAILED`, zéro `UNREACHABLE`.
- [ ] Étape 2 : la commande renvoie **3 fois `active`** (une ligne par VM,
      `rc=0`).
- [ ] Bonus : tu obtiens **3 valeurs `ansible_memtotal_mb`** (une par VM) et tu
      sais dire laquelle a le plus de RAM.
- [ ] Tu n'as tapé **aucun `ssh`** pendant tout le TP.

Bloqué plus de 5 minutes après les deux indices ? La correction est dans
`correction/commandes.md`.
