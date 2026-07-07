# TP chapitre 6 — Fais lire les vrais logs nginx à Filebeat

**Temps cible : 20 min.** La panne du cours était le *négatif* (un fichier absent). Ici,
le *positif* : un input filestream sur des fichiers qui **existent** — les logs nginx de
`dns-proxy` (la page de statut du cours 1 tourne sous nginx). Tu les tagues, tu génères du
trafic, tu les retrouves dans Kibana.

## Énoncé

1. **Vérifie que les fichiers existent** (sur dns-proxy, ssh via bastion) :

```bash
ls -l /var/log/nginx/*.log        # access.log, error.log doivent être là
```

2. **Ajoute un input filestream** à Filebeat, ciblé sur `dns-proxy` uniquement, sur
   `/var/log/nginx/*.log`, avec un champ **`log_source: nginx`** (via `fields` +
   `fields_under_root`). Le rôle est déjà prévu pour ça : la variable
   `filebeat_log_inputs` (dans les defaults) est bouclée par le template. Tu la remplis
   donc en **host_vars/dns-proxy** — surtout PAS sur les 4 VMs (les autres n'ont pas de
   nginx : ce serait recréer la panne du cours !).
3. **Redéploie** Filebeat, puis **génère du trafic** pour écrire dans access.log :

```bash
for i in $(seq 1 10); do curl -s http://10.10.99.13/ >/dev/null; done
```

4. **Retrouve dans Kibana → Discover** les lignes taguées : filtre KQL
   `log_source : "nginx"`. Tu dois voir tes requêtes (méthode GET, code 200, l'IP…).

## Critères de réussite

- [ ] `filebeat_log_inputs` est défini en **host_vars/dns-proxy** (pas dans les defaults)
- [ ] Filebeat sur dns-proxy a un input filestream sur `/var/log/nginx/*.log`
- [ ] Dans Kibana, `log_source : "nginx"` renvoie tes requêtes curl (code 200)
- [ ] Les 3 autres VMs n'ont PAS cet input (elles n'ont pas de nginx)

## Indices

<details>
<summary>Indice 1 — la forme de la variable</summary>

Le template boucle sur `filebeat_log_inputs`, une liste de `{id, source, paths}`. Dans
`host_vars/dns-proxy.yml` (arbre du cours 1) :

```yaml
filebeat_log_inputs:
  - id: nginx-logs
    source: nginx
    paths:
      - /var/log/nginx/*.log
```

`source: nginx` devient le champ `log_source: nginx` (le template pose `fields_under_root`
+ `fields.log_source`). Redéploie ensuite : `ansible-playbook playbooks/filebeat.yml`.
</details>

<details>
<summary>Indice 2 — je ne vois rien dans Kibana</summary>

Ordre des vérifs (le réflexe du cours) : **qu'est-ce que Filebeat REGARDE ?**
`filebeat -e -c /etc/filebeat/filebeat.yml` sur dns-proxy doit lister l'input nginx sans
« no such file ». Vérifie aussi que le trafic a bien écrit : `tail /var/log/nginx/access.log`.
Enfin, `log_source` est un champ *mot-clé* : filtre exact `log_source : "nginx"`, et élargis
la fenêtre de temps (« Last 15 minutes ») en haut à droite de Discover.
</details>

Correction : [`correction/commandes.md`](correction/commandes.md).
