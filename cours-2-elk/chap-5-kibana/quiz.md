# Quiz chapitre 5 — Kibana

## Question 1 — À quoi sert une data view (ex-"index pattern") ?

- A. À sauvegarder automatiquement tes dashboards
- B. À dire à Kibana *quels index regarder* (ex. `logstash-*`) et *quel champ est le temps* ✅
- C. À créer un utilisateur pour Kibana
- D. À chiffrer la connexion entre Kibana et Elasticsearch

**Explication** : la data view mappe un motif d'index (`logstash-*`) et désigne le champ
temporel (`@timestamp`) — sans elle, ni Discover ni les courbes ne savent où chercher.

## Question 2 — Kibana écoute sur `10.10.99.14:5601`, un segment non routé. Comment y accèdes-tu depuis ton poste ?

- A. J'expose Kibana en NAT sur Internet
- B. C'est impossible sans reconfigurer tout le réseau
- C. Un tunnel SSH via le bastion (`ssh -L 5601:10.10.99.14:5601 -J alpha@bastion ...`) puis `https://localhost:5601` ✅
- D. Je copie les fichiers de Kibana en local

**Explication** : le tunnel SSH fait suivre `localhost:5601` jusqu'à Kibana à travers le
bastion — accès immédiat, sans exposer le service ni toucher au routage.

## Question 3 — En KQL, comment ne garder que les événements de la machine dns-proxy ?

- A. `SELECT * WHERE machine = 'dns-proxy'`
- B. `machine: "dns-proxy"` ✅
- C. `grep dns-proxy`
- D. `machine == dns-proxy;`

**Explication** : KQL utilise `champ: "valeur"`. On combine avec `and`/`or` et on emploie
`*` comme joker (`message: *timeout*`). Ni SQL, ni grep.

## Question 4 — Un import de saved objects renvoie HTTP 200. Que dois-tu vérifier ?

- A. Rien : 200 = c'est bon, on passe à la suite
- B. Le corps de la réponse : `"success": true/false` et le tableau `"errors"` ✅
- C. Que le fichier fait moins de 1 Mo
- D. La version de mon navigateur

**Explication** : un 200 dit juste que la requête a abouti, pas que l'opération a réussi.
Kibana peut renvoyer `"success": false` (data view au mauvais id, NDJSON mal formé…) dans
un corps en 200. **Un code HTTP 200 n'est pas un succès applicatif — lis le corps.**

## Question 5 — Avec quel compte Kibana se connecte-t-il à Elasticsearch ?

- A. `elastic`, le super-utilisateur
- B. `root`
- C. `admin`, créé à l'installation
- D. `kibana_system`, un compte de service dédié aux droits réduits ✅

**Explication** : `kibana_system` (mot de passe vaulté, réinitialisable via
`elasticsearch-reset-password -u kibana_system`) sert à Kibana pour parler à ES en
coulisses. `elastic`, lui, sert à TOI pour te connecter à l'UI — deux rôles distincts.

---

**Réponses : 1-B, 2-C, 3-B, 4-B, 5-D.**
