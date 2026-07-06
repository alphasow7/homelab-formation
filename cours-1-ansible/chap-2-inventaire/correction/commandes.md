# Correction TP chapitre 2 — les commandes exactes

> À exécuter depuis `cours-1-ansible/ansible/`.

## Étape 1 — Redémarrer chrony sur tout le groupe lab

```bash
ansible lab -m ansible.builtin.service -a "name=chrony state=restarted" --become
```

`--become` est obligatoire : redémarrer un service demande les droits root
(sans lui : `Interactive authentication required` ou `Permission denied`).

**Sortie attendue** — 3 blocs `CHANGED` (l'ordre des hôtes peut varier) :

```
elastic-1 | CHANGED => {
    "changed": true,
    "name": "chrony",
    "state": "started",
    "status": {
        "ActiveState": "active",
        ...
    }
}
kibana-logstash | CHANGED => { ... }
dns-proxy | CHANGED => { ... }
```

`CHANGED` est normal et attendu : un restart modifie l'état du service, par
définition. Zéro `FAILED`, zéro `UNREACHABLE`.

> Note : selon la distribution, le service peut s'appeler `chronyd` (Rocky/RHEL)
> au lieu de `chrony` (Debian/Ubuntu). Sur notre lab Debian/Ubuntu : `chrony`.

## Étape 2 — Vérifier qu'il est actif partout

```bash
ansible lab -a "systemctl is-active chrony"
```

Pas de `-m` : module `command` implicite. Pas de `--become` : lire un état est
autorisé à tout le monde.

**Sortie attendue** — 3 fois `active` :

```
elastic-1 | CHANGED | rc=0 >>
active
kibana-logstash | CHANGED | rc=0 >>
active
dns-proxy | CHANGED | rc=0 >>
active
```

(`CHANGED` en orange même pour une simple lecture : Ansible ne peut pas savoir
qu'une commande brute n'a rien modifié — vu en démo. Ce qui compte : `rc=0` et
`active`.)

## Bonus — La RAM de chaque VM via les facts

```bash
ansible lab -m setup -a "filter=ansible_memtotal_mb"
```

`filter=` ne collecte/affiche que le fact demandé au lieu des centaines
habituels.

**Sortie attendue** — 3 blocs `SUCCESS` (les valeurs dépendent de tes VMs, ici
un exemple avec 4 Go pour elastic-1 et 2 Go pour les autres) :

```
elastic-1 | SUCCESS => {
    "ansible_facts": {
        "ansible_memtotal_mb": 3931
    },
    "changed": false
}
kibana-logstash | SUCCESS => {
    "ansible_facts": {
        "ansible_memtotal_mb": 1963
    },
    "changed": false
}
dns-proxy | SUCCESS => {
    "ansible_facts": {
        "ansible_memtotal_mb": 1963
    },
    "changed": false
}
```

(La valeur est légèrement inférieure au chiffre rond — 3931 pour « 4 Go » — :
une partie de la RAM est réservée par le noyau, c'est normal.)
