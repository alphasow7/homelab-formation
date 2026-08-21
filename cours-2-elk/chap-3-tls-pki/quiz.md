# Quiz chapitre 3 — TLS & PKI

## Question 1 — À quoi sert l'autorité de certification (CA) ?

- A. À chiffrer les mots de passe des utilisateurs
- B. À tamponner les certificats : elle atteste « cette machine est bien qui elle dit »
- C. À stocker les logs de sécurité
- D. À générer les mots de passe des services

---

## Question 2 — Quelle est la différence entre `curl -k` et `curl --cacert ca.crt` ?

- A. Aucune, ce sont deux façons d'écrire la même chose
- B. `-k` est plus sécurisé car plus court
- C. `-k` chiffre sans vérifier l'identité ; `--cacert` chiffre ET vérifie
- D. `--cacert` désactive le chiffrement

---

## Question 3 — Deux fichiers `ca.crt` ont la même empreinte SHA-256. Cela prouve que…

- A. Ils ont le même nom de fichier
- B. C'est exactement la même autorité — les certs qu'elle signe se font confiance
- C. Ils ont été créés le même jour
- D. Rien, l'empreinte est aléatoire

---

## Question 4 — Pourquoi faut-il UNE seule CA pour tout le cluster ?

- A. Pour économiser de l'espace disque
- B. Parce qu'Elasticsearch n'accepte qu'une CA
- C. Pour que tous les certificats chaînent vers la même racine et se fassent confiance
- D. Pour accélérer le chiffrement

---

## Question 5 — Dans la panne du chapitre, que signifiait la santé « 503 » du cluster ?

- A. Le disque était plein
- B. Les nœuds ne se faisaient pas confiance en TLS → pas de maître élu (master_not_discovered)
- C. Le mot de passe elastic était faux
- D. Kibana n'était pas installé

---

**Réponses : 1-B, 2-C, 3-B, 4-C, 5-B.**

---

## Corrigé

> Ne lis cette section qu'après avoir répondu aux 5 questions.

**Réponses : 1-B, 2-C, 3-B, 4-C, 5-B.**

### Question 1 — réponse B

la CA est le notaire ; quiconque connaît son tampon peut vérifier un
certificat sans la contacter.

### Question 2 — réponse C

`-k` est un aveu (« ne vérifie pas à qui je parle »), utile pour un test,
proscrit en vrai ; `--cacert` donne le tampon du notaire pour authentifier.

### Question 3 — réponse B

l'empreinte identifie le contenu réel de la CA ; identique = même
autorité, donc chaîne de confiance commune. Les noms de fichiers, eux, ne prouvent rien.

### Question 4 — réponse C

deux CA = deux mondes étrangers ; un cert signé par l'une n'est pas
reconnu par les machines qui ont l'autre → `CertPathValidatorException`.

### Question 5 — réponse B

chaque nœud avait sa propre CA ; le transport TLS inter-nœuds échouait,
aucun maître ne pouvait être élu, et ES répondait 503.
