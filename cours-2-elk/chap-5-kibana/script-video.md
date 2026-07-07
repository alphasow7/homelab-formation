# Chapitre 5 — Kibana : la salle de lecture : script vidéo

> Durée cible : ~35 min. Prérequis : cluster ES en HTTPS (chap. 2-3) + Logstash qui
> alimente `logstash-*` (chap. 4). La VM `kibana-logstash` (10.10.99.14) héberge Kibana.
> Toutes les commandes montrées sont dans `demo.sh` et rejouées avant tournage.
> Le rôle complet est dans `../ansible-extraits/roles/kibana/` — l'élève le recopie dans
> SON arbre (`cours-1-ansible/ansible/roles/`).

## 1. Le concept (5 min)

**À dire** : « Elasticsearch, c'est la bibliothèque : les données y sont, indexées. Mais
personne ne lit une bibliothèque en tapant du `curl` toute la journée. Kibana, c'est la
**salle de lecture** : l'interface web pour chercher, filtrer, tracer des courbes,
construire des tableaux de bord. Trois idées et tu es opérationnel :

- **La data view** (ex-"index pattern") : elle répond à la question *"quels index je
  regarde ?"*. `logstash-*` = tous les index qui commencent par `logstash-`. Tu lui dis
  aussi *quel champ est le temps* — ici `@timestamp` — pour que les courbes marchent.
- **Discover** : la vue "grep visuel" — tes documents, en liste, filtrables.
- **KQL** (Kibana Query Language) : la barre de recherche. Syntaxe minimale :
  `machine: "dns-proxy"` (égalité), `machine: "dns-proxy" and niveau: "error"` (combinaison),
  `message: *timeout*` (joker). C'est tout pour commencer. »

**⚠️ MOMENT CLÉ — l'accès sur un segment isolé** : « Kibana écoute sur `10.10.99.14:5601`,
mais ce segment n'est pas routé depuis ton poste. On ne l'expose PAS. On passe par un
**tunnel SSH** via le bastion :

```bash
ssh -L 5601:10.10.99.14:5601 -J alpha@BASTION alpha@10.10.99.14
```

Traduction : "ouvre `localhost:5601` sur mon Mac, et fais suivre, à travers le bastion,
jusqu'à `10.10.99.14:5601`". Ensuite, dans le navigateur : **`https://localhost:5601`**.
HTTPS, pas HTTP — l'UI a son propre certificat (le cert `kibana-logstash` signé par notre
CA au chapitre 3). Le navigateur râlera (CA maison) : c'est attendu. »

## 2. Démo guidée (14 min)

### 2.1 Déployer le rôle

**À montrer** : recopier le rôle depuis `ansible-extraits/`, ajouter le playbook
`kibana.yml` (hosts `kibana-logstash`). Masquerade ON (Kibana pèse plusieurs centaines de
Mo — coupe le téléchargement au montage). `ansible-playbook playbooks/kibana.yml`.
Masquerade OFF.

**À expliquer pendant que ça télécharge** : le tour du rôle —
- il va **chercher** (slurp) la CA ET le cert serveur `kibana-logstash` sur elastic-1
  (là où la CA a tout signé au chap. 3), et les pose dans `/etc/kibana/certs` ;
- le template active `server.ssl.enabled: true` (UI en HTTPS) ET pointe
  `elasticsearch.ssl.certificateAuthorities` vers la CA (pour valider ES) ;
- **le point qui surprend tout le monde** : Kibana ne se connecte PAS avec `elastic`,
  mais avec un compte de service dédié, **`kibana_system`**. Son mot de passe est vaulté
  (`vault_kibana_system_password`) et se réinitialise avec
  `elasticsearch-reset-password -u kibana_system` sur elastic-1. `no_log` protège la clé
  et le mot de passe dans la sortie Ansible.

### 2.2 Premier login

**À montrer** : `https://localhost:5601` (via le tunnel). Page de login Kibana.

« Attention — piège pédagogique : le login de l'UI, c'est un compte **utilisateur**, pas
`kibana_system`. `kibana_system` sert à Kibana pour parler à ES en coulisses ; toi, tu te
connectes avec `elastic` (le super-utilisateur, mot de passe vaulté au chap. 2). »
→ login **`elastic`** / mot de passe elastic.

### 2.3 Créer la data view et Discover

**À montrer** :
1. **Stack Management > Data Views > Create data view** : nom `logstash-*`, index pattern
   `logstash-*`, champ temps `@timestamp`. Save.
2. **Discover** : on retrouve les événements des chapitres précédents (ce que Logstash a
   poussé au chap. 4). Régler la fenêtre de temps (en haut à droite) sur "Last 7 days".
3. **Une requête KQL** dans la barre :

   ```
   machine: "dns-proxy"
   ```

   → seuls les événements de dns-proxy restent. « Voilà ton `grep`, mais visuel,
   filtrable, et sur des millions de lignes. »

### 2.4 Importer un tableau de bord tout prêt

**À montrer** : **Stack Management > Saved Objects > Import** → le fichier
`../ansible-extraits/dashboards/lab-observabilite.ndjson`. Cocher "overwrite". Import.

**Attendu** : bandeau vert "1 dashboard, 1 lens, 1 data view imported". Puis
**Dashboard > Lab — Observabilité** : la visualisation "volume de logs dans le temps"
s'affiche.

« Ce fichier NDJSON, c'est ton dashboard **versionnable** : un objet JSON par ligne
(la data view, la visu, le dashboard). On peut le rejouer sur n'importe quel Kibana. »

## 3. Encart vrai matériel (3 min)

**À filmer** : sur l'infra réelle, la liste des dashboards Kibana — **un tableau de bord
par service** (DNS, reverse-proxy, pare-feu OPNsense/Suricata, K3S…). Montrer le dashboard
DNS : requêtes/s, top domaines, clients bloqués.

**À dire** : « Le NDJSON du lab, c'est la graine. En vrai, ces dashboards vivent dans un
rôle Ansible (`kibana_dashboards`) et s'importent de façon **idempotente** au déploiement.
Ton tableau de bord n'est pas un clic perdu dans une UI : c'est du code, dans Git. »

## 4. 💥 La panne du vrai monde (5 min) — l'import qui « réussit » sans rien faire

**Mise en situation** : « Tu importes ton NDJSON. Kibana ne montre pas d'erreur rouge.
Tu vas dans Dashboard… **rien**. Ou pire : tu automatises l'import via l'API dans un
playbook, la tâche est **verte**, et pourtant aucun dashboard n'apparaît. »

**Le vrai vécu, généralisé** : sur l'infra, un import de configuration renvoyait
**HTTP 200** — donc "OK" pour le playbook — mais le **corps** de la réponse disait
`"success": false`. La requête a abouti ; l'opération, non. Deux mondes différents.

**Ici, les causes classiques du silence** :
- la data view référencée par le dashboard a un **id différent** de celle du fichier
  (le dashboard pointe dans le vide → `missingReferences`) ;
- le NDJSON est **mal formé** (une virgule en trop, un objet sur deux lignes) → l'objet
  est rejeté sans planter le reste.

**Diagnostic guidé** : ne te fie **jamais** au "ça a l'air passé". **Lis la réponse.**
- Dans l'UI : ouvre le détail du bandeau d'import — il liste les objets en erreur.
- Via l'API (ce que fait `demo.sh`) :

  ```bash
  curl -sk -u elastic:LE_MDP \
    -H "kbn-xsrf: true" \
    "https://localhost:5601/api/saved_objects/_import?overwrite=true" \
    -F file=@lab-observabilite.ndjson
  ```

  Et tu **lis le JSON** renvoyé :
  - `"success": true, "successCount": 3` → bon.
  - `"success": false` + `"errors": [ ... ]` → **pas** bon, même en HTTP 200. Le tableau
    `errors` te dit exactement quel objet et pourquoi (`missing_references`,
    `conflict`, etc.).

**Fix** : id de data view stable et **cohérent** entre la visu et le dashboard (c'est
pourquoi notre bundle fixe `id: logstash-lab-dataview` partout), NDJSON validé (un objet
JSON par ligne).

**Morale, à marteler** : « **Un code HTTP 200 n'est pas un succès applicatif.** Le
transport a réussi — ça ne dit rien de l'opération. Lis TOUJOURS le corps de la réponse.
C'est vrai pour Kibana, pour toute API, et ça t'évitera des heures de "mais ça marchait !". »

## 5. Annonce du TP (1 min)

**À dire** : « À toi : dans Kibana, construis une 2ᵉ visualisation en Lens — le *top 5 des
machines par volume* — ajoute-la au dashboard, puis **ré-exporte** le dashboard en NDJSON
et compare-le à mon bundle. Tu verras comment Kibana sérialise ton travail — et tu sauras
le remettre dans Git. 25 minutes. Au prochain chapitre : Filebeat, pour arrêter de pousser
les logs à la main. »
