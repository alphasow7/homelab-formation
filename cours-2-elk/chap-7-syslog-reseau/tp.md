# TP chapitre 7 — Le syslog du bastion dans ELK

**Temps cible : 20 min.** Tu refais la démo, mais sur le **bastion** : tu forwardes son
syslog vers Logstash, tu provoques une **tentative de connexion SSH ratée** (une vraie
ligne de sécurité), et tu la retrouves dans Kibana, filtrée par `host`.

Rappel : pas de rôle Ansible ici, tout se fait **à la main** sur le bastion (en root).

## Énoncé

1. **Configure rsyslog sur le bastion** pour forwarder **tout** son syslog vers Logstash
   (`10.10.99.14`, port `5514`, en **UDP**). Le fichier va dans `/etc/rsyslog.d/`, exactement
   comme sur le nœud à la démo. Recharge le service.

2. **Provoque un log d'authentification** : depuis le bastion, tente une connexion SSH qui
   va forcément échouer, avec un utilisateur bidon :

   ```bash
   ssh mauvaisuser@localhost
   ```

   Tape n'importe quoi comme mot de passe (ou `Ctrl-C`) : l'important est que le SSH
   **refuse**. Ça écrit une ligne dans les logs *auth* — la matière première d'un SIEM.

3. **Retrouve-la dans Kibana** → Discover → index `logstash-*`. Filtre par l'hôte bastion
   et cherche l'échec d'authentification, par exemple :

   ```
   host : "bastion" and message : "mauvaisuser"
   ```

   (adapte `"bastion"` à ce que rapporte réellement le champ `host` de tes documents.)

## Critères de réussite

- [ ] Un document du **bastion** remonte dans `logstash-*` (champ `host` = le bastion)
- [ ] Il contient la trace de l'échec SSH (`mauvaisuser`, ou `Failed`/`invalid user`)
- [ ] Tu sais dire si tu as envoyé en **UDP** (`@`) ou **TCP** (`@@`)

## Indices

<details>
<summary>Indice 1 — le fichier rsyslog (le même qu'à la démo)</summary>

Crée `/etc/rsyslog.d/90-forward-elk.conf` avec **une ligne** :

```
*.* @10.10.99.14:5514
```

Puis `systemctl restart rsyslog`. Le simple `@` = UDP (mets `@@` si tu voulais du TCP).
`*.*` = toutes les catégories, tous les niveaux — donc *auth* est inclus.
</details>

<details>
<summary>Indice 2 — LA subtilité : rsyslog n'est peut-être pas installé</summary>

Ces VMs sont des **Debian minimales** : comme on l'a découvert au chapitre 6 (la panne
Filebeat « 0 document »), **rsyslog n'y est pas installé par défaut** ! Si
`systemctl restart rsyslog` répond *"Unit rsyslog.service not found"*, c'est ça.

Installe-le d'abord (masquerade temporaire sur le nœud si le segment n'a pas Internet —
réflexe du cours 1) :

```bash
apt update && apt install -y rsyslog
```

Ensuite seulement, dépose ton fichier de forward et redémarre.

Pour **voir** les logs d'auth côté bastion et vérifier que l'échec s'écrit bien :
`journalctl -u ssh` (ou `journalctl -u sshd`) montre le refus SSH. Mais retiens : ce qui
part vers Logstash, ce sont les logs pris en charge par **rsyslog** une fois installé — pas
journald directement. Pas de rsyslog → rien ne part. C'est toute la leçon.
</details>

Correction : [`correction/commandes.md`](correction/commandes.md).
