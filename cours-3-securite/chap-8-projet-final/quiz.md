# Quiz — Projet final cours 3 (et de la formation) : la boucle complète

## Question 1 — Quel est l'ORDRE correct de la boucle de sécurité jouée dans ce projet ?

- A. Détection → attaque → réaction → défense → observation
- B. **Attaque → défense → détection → observation → réaction** ✅
- C. Réaction → détection → défense → observation → attaque
- D. Observation → attaque → défense → réaction → détection

**Explication** : on part de l'**attaque** (le scan depuis ton poste), le pare-feu
**défend** (drop), Suricata **détecte** (alerte), l'alerte remonte dans Kibana pour
l'**observation** (analyse SOC), et tu **réagis** (règle de blocage). C'est l'enchaînement
que tu as prouvé de bout en bout — chaque maillon dépend du précédent.

## Question 2 — Ton scan `nmap -sS -p-` renvoie « 65535 filtered ports ». Qu'est-ce que ça prouve ?

- A. Que Suricata est en panne
- B. Que ton poste n'a pas les droits root
- C. Que le **pare-feu bloque** : il avale les paquets sans répondre (drop silencieux), l'attaquant ne voit aucun port ouvert à exploiter ✅
- D. Que l'IP WAN d'OPNsense n'existe pas

**Explication** : `filtered` = le pare-feu a **droppé** les paquets sans répondre (ni
`open`, ni `closed` qui renverraient un signal). Du point de vue de l'attaquant : rien à
attaquer, que des timeouts. C'est la policy DROP par défaut du WAN (chap 3-4) qui fait son
travail — ta première victoire de la boucle.

## Question 3 — Où retrouves-tu l'alerte du scan pour l'analyser en analyste SOC ?

- A. Uniquement dans la sortie de nmap sur ton poste
- B. Dans l'onglet **Alerts** d'OPNsense (vue brute) ET dans **Kibana** `logstash-syslog-*` (vue SIEM, gardée et corrélable) ✅
- C. Dans les logs du navigateur
- D. Nulle part : un IDS ne garde pas de trace

**Explication** : deux endroits, deux usages. OPNsense (`Services > Intrusion Detection >
Alerts`) montre l'alerte brute en direct. Kibana la **conserve** et permet de la corréler
avec le reste des logs — c'est là que tu lis **qui** (`src_ip`), **quoi** (la signature) et
**quand** (`@timestamp`). L'export syslog (cours 2 chap 7) fait le pont entre les deux.

## Question 4 — Pour que Suricata BLOQUE le scan (et plus seulement l'alerte), que fais-tu ?

- A. Tu désinstalles Suricata
- B. Tu passes Suricata d'**IDS à IPS** (IPS mode ON) et l'action de la catégorie de **Alert** à **Drop** ✅
- C. Tu augmentes le nombre de rulesets
- D. Tu redémarres Kibana

**Explication** : même moteur de détection, mais l'**IDS** se contente d'alerter (il ne
touche pas au trafic) tandis que l'**IPS** **coupe** la connexion qui matche la signature.
Passer en IPS + action Drop, c'est faire réagir Suricata lui-même. Alternative (voie B du
projet) : une règle firewall OPNsense qui blackliste l'IP source — plus chirurgicale.

## Question 5 — Dans ce projet, qu'apporte CHAQUE cours à la boucle complète ?

- A. Les quatre cours font la même chose, c'est de la redondance
- B. **Proxmox** héberge la VM OPNsense · **Ansible** provisionne l'infra en code · **ELK** rend l'alerte visible et gardée · **Sécurité** détecte, bloque et réagit ✅
- C. Seul le cours 3 sert ; les autres sont décoratifs
- D. Proxmox détecte l'attaque, Ansible bloque, ELK réagit, la Sécurité observe

**Explication** : la boucle n'existe que parce que les quatre briques se parlent. **Sans
Proxmox** (cours 0), pas de VM OPNsense à faire tourner. **Sans Ansible** (cours 1), pas
d'infra reproductible pour l'héberger. **Sans ELK** (cours 2), l'alerte resterait invisible
dans un onglet. **Sans la Sécurité** (cours 3), pas de pare-feu ni d'IDS ni de réaction. Ce
ne sont pas quatre compétences séparées — c'est un métier.

---

**Réponses : 1-B, 2-C, 3-B, 4-B, 5-B.**
