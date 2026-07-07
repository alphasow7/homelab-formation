# Quiz chapitre 5 — Suricata IDS

## Question 1 — Quelle est la différence entre un IDS et un IPS ?

- A. Un IDS chiffre le trafic, un IPS le déchiffre
- B. Un IDS **détecte et alerte** ; un IPS **détecte et bloque** ✅
- C. Un IDS surveille le LAN, un IPS surveille le WAN
- D. Aucune, ce sont deux noms pour la même chose

**Explication** : même moteur de détection (ici Suricata), mais l'IDS se contente de lever
une alerte (il ne touche pas au trafic), tandis que l'IPS coupe la connexion suspecte. On
démarre en IDS (détection) et on ne passe en IPS (blocage) qu'une fois les faux positifs
maîtrisés.

## Question 2 — Qu'est-ce qu'une "signature" et un "ruleset" dans Suricata ?

- A. Une signature est un certificat TLS ; un ruleset est une CA
- B. Une signature est le mot de passe de l'IDS ; un ruleset la liste des utilisateurs
- C. Une signature est le "portrait-robot" d'une attaque connue ; un ruleset est un paquet de signatures maintenu à jour (ET open, abuse.ch) ✅
- D. Une signature est une IP bloquée ; un ruleset la table de routage

**Explication** : une signature = une règle qui décrit le motif d'une attaque connue ("si
tu vois ce motif, c'est probablement telle attaque"). Un ruleset = un catalogue de
signatures maintenu par un fournisseur : **ET open** (Emerging Threats, familles
d'attaques) et **abuse.ch** (IP/domaines de malwares et de C2).

## Question 3 — Pourquoi active-t-on Suricata en mode DÉTECTION avant le mode blocage ?

- A. Parce que le mode blocage coûte une licence payante
- B. Parce qu'une signature peut lever un **faux positif** ; en détection il ne fait qu'alerter, alors qu'en blocage il couperait du trafic légitime ✅
- C. Parce que le mode détection est plus rapide que le blocage
- D. Parce qu'il faut un deuxième nœud pour bloquer

**Explication** : une règle imparfaite se déclenche parfois sur du trafic sain (faux
positif). En détection, ça ne coûte qu'une alerte de trop ; en IPS (blocage), ça
**casserait** ce trafic légitime. On observe et on affine d'abord, on bloque ensuite.

## Question 4 — Après un update de règles qui répond "OK", que faut-il vérifier ?

- A. Rien, "OK" garantit que les règles sont chargées
- B. La couleur du cluster Elasticsearch
- C. L'**effet** : que des règles sont réellement chargées (`wc -l` des `.rules` > 0) et qu'une alerte de test tombe — pas le message de succès ✅
- D. La version de Suricata

**Explication** : LA panne du chapitre. En console, `configctl ids update` peut répondre
"OK" tout en ne chargeant **0 règle** (le `template reload` — l'équivalent du Apply GUI —
n'avait pas rempli `rule-updater.config`). Un "OK" n'est pas une preuve : on compte les
règles chargées et on déclenche une alerte de test. Cousin de "l'import Kibana qui réussit
sans rien faire" et de "Apply GUI ≠ CLI".

## Question 5 — Où arrivent les alertes Suricata une fois l'export configuré ?

- A. Uniquement dans l'onglet Alerts d'OPNsense, elles n'en sortent jamais
- B. Dans le **SIEM** : via l'export syslog d'OPNsense vers l'input Logstash 5514, elles remontent dans Kibana (en plus de l'onglet Alerts) ✅
- C. Directement dans un e-mail à l'administrateur
- D. Dans les logs du navigateur

**Explication** : les alertes vivent d'abord dans l'onglet Alerts d'OPNsense, mais en
activant l'export syslog (System > Settings > Logging) vers l'input Logstash **5514** (mis
en place au cours 2, chap 7), elles montent dans **Kibana** (`logstash-syslog-*`, filtre
`syslog_hostname: "OPNsense.internal"`). Ton IDS et ton SIEM se parlent : tu détectes ET tu
gardes la trace.

---

**Réponses : 1-B, 2-C, 3-B, 4-C, 5-B.**
