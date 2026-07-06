# TP chapitre 4 — Enrichir le rôle DNS : un enregistrement A et des CNAME

> Durée : ~20 min. Tout se fait DEPUIS ton poste, dans le dossier
> `cours-1-ansible/ansible/`. Tu ne modifies QUE le rôle `roles/dns/`
> (tiroirs `defaults/` et `templates/`) — jamais les fichiers sur la VM.
> Prérequis : la démo est passée — `dig @10.10.99.12 elastic-1.lab.local +short`
> depuis le bastion répond `10.10.99.11`.

## Ta mission

Ton annuaire fonctionne, mais il lui manque deux choses : un nom pour le service
proxy, et les **CNAME** — les « surnoms » du DNS : un nom qui pointe vers un AUTRE
nom (pas vers une IP). Quand la machine change d'IP, tous ses surnoms suivent
automatiquement.

1. **Ajoute un enregistrement A `proxy` → `10.10.99.12`** dans les valeurs par
   défaut du rôle. Aucun template à toucher : la boucle existante fera le travail.
2. **Apprends les CNAME au rôle** :
   - dans `defaults/main.yml`, ajoute une variable `dns_cnames` : une liste
     d'éléments à deux clés, `name` et `target`, avec un premier surnom
     `www` → `dns-proxy` ;
   - dans `templates/zone.j2`, ajoute une boucle sur `dns_cnames` qui produit une
     ligne `{{ c.name }}    IN      CNAME   {{ c.target }}` par élément.
3. **Déploie** (`ansible-playbook playbooks/dns.yml`) et **prouve au dig**, depuis
   le bastion :
   - `dig @10.10.99.12 proxy.lab.local +short` → `10.10.99.12`
   - `dig @10.10.99.12 www.lab.local +short` → deux lignes : le CNAME
     (`dns-proxy.lab.local.`) PUIS l'IP (`10.10.99.12`) — dig suit le surnom
     jusqu'à l'enregistrement A.

## Indices

<details>
<summary>Indice 1 — à quoi ressemblent la variable et la boucle ?</summary>

`dns_cnames` a exactement la même forme que `dns_records`, avec `target` à la place
de `ip` :

```yaml
dns_cnames:
  - name: www
    target: dns-proxy
```

Et la boucle dans `zone.j2` est la jumelle de celle des enregistrements A :

```jinja
{% raw %}{% for c in dns_cnames %}
{{ c.name }}    IN      CNAME   {{ c.target }}
{% endfor %}{% endraw %}
```

Place-la APRÈS la boucle des enregistrements A (un CNAME doit pointer vers un nom
qui existe).
</details>

<details>
<summary>Indice 2 — le déploiement passe mais dig ne répond pas comme prévu ?</summary>

Trois vérifications, dans l'ordre :

1. **Le handler a-t-il tourné ?** Si `changed=0`, Ansible n'a rien redéployé : tu as
   probablement modifié le mauvais fichier (le rôle est dans
   `roles/dns/defaults/main.yml`, pas ailleurs).
2. **Le service est-il vivant ?** Réflexe du chapitre :
   `sudo journalctl -u named -n 20` sur la VM. Une faute de frappe dans le fichier
   de zone (tiret manquant, deux-points oublié) et named refuse la zone — le
   journal te donne la ligne exacte.
3. **La cible du CNAME existe-t-elle ?** `www` pointe vers `dns-proxy`, qui doit
   être un enregistrement A de la même zone. Vérifie l'orthographe.
</details>

## Critères de réussite (mesurables)

- [ ] `ansible-playbook playbooks/dns.yml` se termine **sans `failed`**, avec le
      handler `Reload bind9` déclenché.
- [ ] Depuis le bastion, `dig @10.10.99.12 proxy.lab.local +short` répond
      **`10.10.99.12`**.
- [ ] Depuis le bastion, `dig @10.10.99.12 www.lab.local +short` répond **deux
      lignes** : `dns-proxy.lab.local.` puis `10.10.99.12`.
- [ ] Tu n'as modifié **que deux fichiers**, tous les deux dans `roles/dns/` :
      `defaults/main.yml` et `templates/zone.j2`.

Bloqué plus de 5 minutes après les deux indices ? La correction est dans
`correction/` (les deux fichiers modifiés, complets).
