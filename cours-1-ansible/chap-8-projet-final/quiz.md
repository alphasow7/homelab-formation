# Quiz chapitre 8 — Projet final : le phénix

## Question 1 — Que signifie « pets vs cattle » (animaux de compagnie vs bétail) ?

- A. Les VMs de prod sont des pets, celles de test du cattle
- B. Un pet se soigne à la main et son nom compte ; du cattle se remplace à l'identique sans regret ✅
- C. Les pets sont des VMs, le cattle des conteneurs
- D. C'est une classification des tailles de VM chez les hébergeurs

**Explication** : une machine « pet » est unique, bichonnée à la main, irremplaçable ; une
machine « cattle » est produite par du code — si elle meurt, on en refait une identique en
minutes. Le phénix prouve que `dns-proxy` est du cattle.

## Question 2 — Après la renaissance, SSH refuse la connexion avec `WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!`. Pourquoi ?

- A. Quelqu'un intercepte réellement ta connexion
- B. La nouvelle VM a généré de nouvelles clés d'hôte SSH — même IP, nouvelle identité ✅
- C. Ansible a écrasé la configuration SSH de la VM
- D. Le bastion bloque la connexion après une destruction

**Explication** : chaque installation génère ses propres clés d'hôte. Ton `known_hosts`
garde l'ancienne empreinte de 10.10.99.12 ; la VM renée en a une nouvelle. Ici c'est
NORMAL et attendu : `ssh-keygen -R 10.10.99.12` et on repart. (En prod, ce même message
sans destruction connue = alerte sérieuse.)

## Question 3 — Que faut-il pour qu'une VM soit vraiment « du bétail », destructible sans peur ?

- A. Un snapshot récent
- B. Beaucoup de RAM et un disque rapide
- C. Toute sa configuration en code (playbooks versionnés) et ses données persistantes stockées ailleurs ✅
- D. Être clonée depuis un template

**Explication** : le clone ne suffit pas — il donne une VM vierge. C'est le code (Ansible,
versionné dans Git) qui recrée la configuration, et les données qui comptent doivent vivre
hors de la VM (dépôt, stockage externe). Alors, et seulement alors, la VM devient jetable.

## Question 4 — Pourquoi relancer le playbook APRÈS la renaissance et vérifier `changed=0` ?

- A. Pour forcer Ansible à redémarrer les services
- B. Pour mettre à jour l'inventaire avec la nouvelle VM
- C. Ça prouve que la VM est EXACTEMENT dans l'état décrit par le code — rien ne manque, rien ne dépasse ✅
- D. C'est obligatoire, sinon Ansible garde un verrou sur l'hôte

**Explication** : l'idempotence comme instrument de mesure : si le second run ne change
rien, l'état réel = l'état déclaré. La renaissance n'est pas « à peu près » réussie, elle
est prouvée conforme au code, au caractère près.

## Question 5 — Qu'est-ce qui n'aurait PAS survécu au phénix ?

- A. L'enregistrement DNS de elastic-1
- B. La page web de statut et son secret vaulté
- C. Une modification faite à la main dans la VM, jamais reportée dans le code ✅
- D. L'utilisateur alpha et sa clé SSH

**Explication** : tout ce qui est dans le code (rôles, templates, vault) ou dans
cloud-init renaît à l'identique. Un `vim /etc/...` fait directement dans la VM et non
commité a disparu avec le disque — c'est LA leçon : toute modif passe par le code, sinon
elle n'existe pas.

---

**Réponses : 1-B, 2-B, 3-C, 4-C, 5-C.**
