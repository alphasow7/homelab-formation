# Quiz chapitre 2 — Elasticsearch

## Question 1 — Un index Elasticsearch, c'est…

- A. Le sommaire d'un document
- B. Un « classeur » qui regroupe des documents du même type ✅
- C. Une sauvegarde automatique
- D. Un utilisateur avec des droits réduits

**Explication** : l'index regroupe des documents JSON (les fiches) ; c'est l'unité qu'on
requête, dimensionne et supprime.

## Question 2 — Ton cluster mono-nœud est « yellow ». Que fais-tu ?

- A. Tu redémarres Elasticsearch jusqu'à ce qu'il passe green
- B. Tu ajoutes de la RAM
- C. Rien : les réplicas n'ont nulle part où aller, c'est l'état normal du mono-nœud ✅
- D. Tu supprimes les index pour repartir à zéro

**Explication** : yellow = données présentes, copies de secours impossibles faute de
2ᵉ nœud. Green mono-nœud n'existera pas ; red serait le vrai signal d'alarme.

## Question 3 — Un shard, c'est…

- A. Un fragment d'index — comme les tomes d'une encyclopédie ✅
- B. Un fichier de logs
- C. Un certificat de sécurité
- D. Une copie complète du cluster

**Explication** : l'index peut être découpé en shards répartissables entre nœuds ; les
réplicas sont les copies de ces tomes.

## Question 4 — Où obtiens-tu le mot de passe initial du compte `elastic` ?

- A. Il est affiché dans la GUI Proxmox
- B. C'est `changeme` par défaut
- C. Dans /etc/elasticsearch/passwords.txt
- D. Avec `elasticsearch-reset-password -u elastic` sur la VM ✅

**Explication** : l'outil officiel génère/réinitialise le mot de passe — qu'on range
aussitôt dans l'ansible-vault (réflexe du cours 1).

## Question 5 — `free -h` montre qu'ES « consomme » la moitié de la RAM de la VM. C'est…

- A. Une fuite mémoire, il faut redémarrer
- B. Le heap configuré : ES réserve sa mémoire au démarrage et la garde ✅
- C. Un bug de Debian
- D. Le cache du noyau, ça va se vider

**Explication** : le heap (2 Go ici) est fixé par notre fichier jvm.options.d — réservé
d'emblée pour la performance. Deuxième faux problème du chapitre, avec le yellow.

---

**Réponses : 1-B, 2-C, 3-A, 4-D, 5-B.**
