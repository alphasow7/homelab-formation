# Quiz chapitre 4 — Logstash

## Question 1 — Les trois étages d'un pipeline Logstash, dans l'ordre, sont…

- A. read → parse → write
- B. input → filter → output ✅
- C. source → grok → elasticsearch
- D. receive → tag → send

**Explication** : le centre de tri postal — réception (input), table de tri (filter),
expédition (output). Le filtre est facultatif, mais input et output sont obligatoires.

## Question 2 — Que fait `grok` ?

- A. Il chiffre les logs avant de les envoyer
- B. Il compresse les événements pour économiser de la place
- C. Il découpe un texte brut en champs nommés grâce à des expressions régulières étiquetées ✅
- D. Il crée les index dans Elasticsearch

**Explication** : grok = des regex avec des étiquettes. Une ligne nginx (un seul champ
`message`) devient `clientip`, `verb`, `response`, `bytes`… interrogeables séparément.

## Question 3 — Pourquoi un index par jour (`logstash-%{+YYYY.MM.dd}`) ?

- A. Parce qu'Elasticsearch refuse d'écrire deux jours dans le même index
- B. Pour purger/archiver facilement par tranche de temps et garder des index d'une taille raisonnable ✅
- C. Pour que la recherche plein texte fonctionne
- D. Parce que grok l'exige

**Explication** : segmenter par date permet de supprimer les vieux jours d'un coup
(`DELETE logstash-2026.06.*`) et évite l'index géant qui gonfle sans fin. Rien à voir
avec la capacité d'ES à écrire.

## Question 4 — Dans notre pipeline, quel port reçoit les Beats et quel port le syslog ?

- A. Beats sur 9200, syslog sur 9600
- B. Beats sur 5514, syslog sur 5044
- C. Beats sur 5044, syslog sur 5514 ✅
- D. Les deux sur 5044

**Explication** : 5044 = l'input `beats` (filebeat, metricbeat…) ; 5514 = l'input
`tcp`/`udp` de type syslog (nos tests `nc`, les équipements réseau). 9200 est ES, 9600
l'API de monitoring de Logstash.

## Question 5 — À quoi sert `curl localhost:9600/_node/stats/events` ?

- A. À redémarrer Logstash
- B. À voir les compteurs in / filtered / out pour diagnostiquer où bloque le flux ✅
- C. À afficher le mot de passe elastic
- D. À lister les index d'Elasticsearch

**Explication** : l'API de monitoring de Logstash. Si `in` monte mais pas `out`, le
problème est à la sortie (ES injoignable, CA, mot de passe) ; si `in` ne bouge pas,
l'événement n'arrive même pas (port/pare-feu).

---

**Réponses : 1-B, 2-C, 3-B, 4-C, 5-B.**
