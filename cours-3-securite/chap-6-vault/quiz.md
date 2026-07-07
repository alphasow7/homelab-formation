# Quiz chapitre 6 — HashiCorp Vault

## Question 1 — Quelle est la différence entre `ansible-vault` et HashiCorp Vault ?

- A. Aucune, ce sont deux noms du même outil
- B. `ansible-vault` chiffre des FICHIERS versionnés dans Git (bootstrap) ; HashiCorp Vault
     est un SERVEUR de secrets avec API, TTL, révocation, audit (runtime) ✅
- C. `ansible-vault` est payant, HashiCorp Vault est gratuit
- D. HashiCorp Vault chiffre des fichiers, `ansible-vault` est un serveur

**Explication** : même mot, deux bêtes. Un cadenas sur un fichier d'un côté (parfait pour
amorcer un playbook), un service de secrets dynamiques de l'autre.

## Question 2 — Le principe des clés de Shamir, c'est…

- A. Chaque secret est chiffré avec une clé différente
- B. La clé maîtresse est découpée en morceaux ; le coffre ne s'ouvre qu'avec un QUORUM de
     morceaux (ex. 3 sur 5 en prod, 1 sur 1 en lab) ✅
- C. Une clé qui change automatiquement toutes les heures
- D. Un algorithme de chiffrement des mots de passe

**Explication** : personne ne détient seul la clé complète en prod — il faut réunir le
quorum. En lab on simplifie à 1 clé sur 1.

## Question 3 — Après un reboot de la VM, Vault est « Sealed: true ». Que fais-tu ?

- A. Tu réinstalles Vault, il est corrompu
- B. Tu paniques, les données sont perdues
- C. Rien d'anormal : c'est le design (la clé n'est jamais sur le disque). Tu le descelles,
     ici via `ansible-playbook vault-unseal.yml` ✅
- D. Tu changes le mot de passe root

**Explication** : Vault redémarre TOUJOURS scellé, par conception. Le descellage fait
partie de l'exploitation quotidienne — d'où le playbook dédié.

## Question 4 — Tu as perdu la clé d'unseal (jamais sauvegardée). Que se passe-t-il ?

- A. Une commande `vault recover` régénère la clé
- B. Le support HashiCorp peut la retrouver
- C. Le root token permet quand même d'ouvrir le coffre
- D. Le coffre est définitivement inouvrable — il faut tout réinitialiser, données perdues.
     C'est un presse-papier ✅

**Explication** : c'est arrivé sur l'infra réelle (06/07). Aucune récupération possible,
c'est le principe même. D'où la règle : généré → sauvegardé chiffré → testé, dans la minute.

## Question 5 — À quoi sert le moteur KV de Vault ?

- A. À gérer les utilisateurs et leurs droits
- B. À stocker et relire des secrets (clé → valeur) derrière l'API, comme un dictionnaire
     chiffré ✅
- C. À émettre des certificats TLS
- D. À sauvegarder la configuration de Vault

**Explication** : KV = Key-Value, le moteur le plus simple (`vault kv put` / `vault kv get`).
L'émission de certificats, elle, c'est le moteur PKI.

---

**Réponses : 1-B, 2-B, 3-C, 4-D, 5-B.**
