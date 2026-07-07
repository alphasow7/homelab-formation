# Quiz chapitre 7 — Rotation & hygiène des secrets

## Question 1 — Pourquoi faut-il changer les mots de passe par défaut ?

- A. Parce que les mots de passe d'usine sont trop courts à taper
- B. Parce qu'ils sont **publics** (dans la doc, le web, les manuels) et donc connus de tous
     les bots qui scannent Internet — un défaut, ce n'est pas un secret ✅
- C. Parce qu'ils expirent automatiquement au bout d'un mois
- D. Parce que le fabricant peut s'en servir pour espionner

**Explication** : `admin/admin`, `root/opnsense`… sont documentés partout. Un mot de passe
que le monde entier peut lire n'en est pas un. C'est la première chose qu'un attaquant essaie.

## Question 2 — Qu'est-ce que la rotation d'un secret ?

- A. Le fait de sauvegarder le secret à plusieurs endroits
- B. Le fait de chiffrer le secret avant de le stocker
- C. Le fait de **changer** le secret régulièrement et dès qu'on soupçonne une fuite — un
     secret roté ne vaut plus rien pour l'attaquant qui l'avait ✅
- D. Le fait de partager le secret entre plusieurs personnes

**Explication** : la rotation transforme une fuite en non-événement. Le secret qui a fuité
est périmé : l'attaquant tient une clé qui n'ouvre plus rien.

## Question 3 — Pourquoi importer sa CA interne dans le trousseau du navigateur ?

- A. Pour accélérer le chargement des pages internes
- B. Pour **faire confiance une fois** à son autorité → tous ses services internes passent
     au vert, au lieu de cliquer « Accepter le risque » et de se désensibiliser au vrai danger ✅
- C. Parce que sans ça les services internes ne démarrent pas
- D. Pour chiffrer le trafic, qui sinon serait en clair

**Explication** : cliquer « accepter » dix fois par jour anesthésie. Le jour où l'alerte est
un VRAI faux certificat, on clique par habitude. Un import propre garde l'alerte rouge
significative. (Le trafic, lui, est déjà chiffré par TLS — la question est la *confiance*.)

## Question 4 — Ton service vient de démarrer et « ça marche ». Quel est le premier geste ?

- A. Passer tout de suite à la configuration suivante, on reviendra au mot de passe plus tard
- B. Noter dans une liste de tâches « changer le mot de passe » pour le faire cette semaine
- C. **Changer le mot de passe par défaut immédiatement**, dans la même minute — en faire un
     réflexe, pas une tâche qu'on oublie ✅
- D. Redémarrer la machine pour vérifier que tout persiste

**Explication** : « je le noterai plus tard » a laissé un pare-feu réel en `root/opnsense`
pendant trois semaines. Une liste s'oublie ; un réflexe de la même minute, non.

## Question 5 — Pourquoi un changement de mot de passe doit-il PERSISTER au reboot ?

- A. Parce que sinon les autres utilisateurs ne pourront pas se connecter
- B. Parce qu'un système à mémoire (OPNsense) qui charge sa config depuis un cache réécrit
     un changement mal fait au boot — s'il ne passe pas par le système de config
     (`write_config`), il **disparaît** et le défaut revient (écho chap 2) ✅
- C. Parce que le reboot efface tous les mots de passe par sécurité
- D. Parce que la rotation impose un redémarrage à chaque changement

**Explication** : au chap 2, éditer `config.xml` à la main ne survivait pas — OPNsense
réécrit depuis son cache mémoire. Un changement bien fait (via `write_config()`) est gravé
sur disque et survit. Sur un système à mémoire, un changement mal fait n'a jamais eu lieu.

---

**Réponses : 1-B, 2-C, 3-B, 4-C, 5-B.**
