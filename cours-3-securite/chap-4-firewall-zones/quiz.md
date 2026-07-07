# Chapitre 4 — Le firewall par zone : quiz

5 questions, 4 choix, 1 bonne réponse.

---

## Question 1 — Pourquoi durcir DANS le lab, pas juste au périmètre ?

Tu as déjà OPNsense en pare-feu de périmètre. Pourquoi ajouter en plus un firewall
par zone sur chaque VM ?

- A. Parce qu'OPNsense est trop lent pour tout filtrer seul
- B. Parce que si UNE VM est compromise, le périmètre ne l'arrête plus — il faut
  limiter ce que cette VM peut atteindre à l'intérieur ✅
- C. Parce que le firewall par zone remplace OPNsense, qui devient inutile
- D. Parce que Proxmox exige un fichier `.fw` pour démarrer les VMs

> **Explication** : Le périmètre, c'est la porte d'entrée de l'immeuble : il décide
> qui entre depuis le monde. Mais une fois l'attaquant dedans (VM compromise), il
> ne sert plus à rien. Les zones sont les serrures de chaque appartement : elles
> empêchent le mouvement latéral d'une VM vers les autres. C'est la défense en
> profondeur appliquée à l'intérieur du lab.

---

## Question 2 — Que signifie une policy DROP en entrée ?

Le fichier de zone commence par `policy_in: DROP`. Ça veut dire quoi ?

- A. On bloque uniquement les ports listés comme dangereux
- B. Par défaut on REFUSE tout le trafic entrant ; on ne rouvre ensuite QUE les
  ports explicitement autorisés ✅
- C. On coupe la VM du réseau, y compris son propre trafic sortant
- D. On journalise tout le trafic mais on laisse tout passer

> **Explication** : DROP inverse la logique. Au lieu de lister ce qu'on interdit
> (liste sans fin), on interdit tout, puis on autorise au compte-gouttes seulement
> le strict nécessaire. Tout ce qui n'a pas de règle `IN ACCEPT` explicite tombe.
> Note : `policy_in` ne concerne que l'ENTRÉE — le trafic sortant de la VM n'est
> pas touché ici.

---

## Question 3 — Un service devient injoignable juste après un changement firewall

Tu viens de modifier une règle de zone, et un service ne répond plus. Quel est le
BON premier réflexe ?

- A. Redémarrer le service et lire ses logs pour trouver l'erreur
- B. Redémarrer la VM entière, au cas où
- C. Lire les RÈGLES firewall réellement appliquées — la cause est là où tu viens
  de toucher ✅
- D. Désactiver complètement le firewall de la VM pour "voir si ça remarche"

> **Explication** : C'est LA panne du chapitre. Le faux réflexe est d'accuser le
> service : tu le redémarres, tu lis ses logs... et il va très bien, il n'a même
> pas vu la connexion (elle a été coupée avant de l'atteindre). **Un service
> injoignable juste après un changement de firewall : lis les RÈGLES d'abord, pas
> les logs du service.** Même famille que "lis le journal" (cours 1) et "lis la
> réponse" (cours 2) : regarde l'endroit que tu viens de modifier.

---

## Question 4 — Où lire les règles réellement actives ?

Le firewall par zone est écrit dans `/etc/pve/firewall/<vmid>.fw`. Où et comment
vérifies-tu les règles VRAIMENT appliquées ?

- A. Sur la VM elle-même, avec `systemctl status firewall`
- B. Sur le NŒUD Proxmox, avec `pve-firewall compile` (ou `iptables -L -n`) — c'est
  le nœud qui filtre au ras de la VM ✅
- C. Dans OPNsense, onglet Firewall → Rules
- D. Dans Kibana, en cherchant l'index `.fw`

> **Explication** : Le firewall par zone tourne sur l'HYPERVISEUR, pas dans la VM.
> C'est le nœud Proxmox qui lit les `.fw`, les compile en règles iptables et filtre
> le trafic au ras de la carte réseau de la VM. La VM ne sait même pas qu'elle est
> protégée. Donc tu diagnostiques sur le nœud : `pve-firewall compile` te montre les
> règles compilées, `iptables -L -n` les règles bas niveau.

---

## Question 5 — C'est quoi, le moindre privilège ?

Pour elastic-1, on autorise seulement le `9200` depuis Logstash et le `22` depuis
le bastion. Quel principe applique-t-on ?

- A. Le chiffrement de bout en bout
- B. Le moindre privilège : on n'accorde QUE les accès strictement nécessaires, à
  QUI en a besoin, et rien de plus ✅
- C. La haute disponibilité : dupliquer chaque service
- D. La rotation des secrets : changer les mots de passe régulièrement

> **Explication** : Le moindre privilège renverse la question. Tu ne demandes pas
> "qu'est-ce que je bloque ?" mais "qu'est-ce que j'autorise, et pour qui ?".
> elastic-1 n'a besoin de parler qu'à Logstash (9200) et d'être administré depuis le
> bastion (22) : on accorde ces deux accès, point. Tout le reste du segment tombe.
> Moins il y a de portes ouvertes, moins il y a de chemins pour un attaquant.
