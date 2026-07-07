# Chapitre 1 — Menaces & périmètre : quiz

5 questions, 4 choix, 1 bonne réponse.

---

## Question 1 — Pourquoi ton homelab est-il une cible ?

Pourquoi un lab à la maison, sans données précieuses ni notoriété, se fait-il quand même
attaquer ?

- A. Parce que les attaquants savent qu'un débutant configure mal ses machines
- B. Parce qu'il est À PORTÉE : des bots scannent toutes les IP en continu, sans te
  choisir toi ✅
- C. Parce que les homelabs contiennent toujours des données bancaires
- D. Parce qu'un lab bien fait attire l'attention des hackers expérimentés

> **Explication** : « Tu es une cible parce que tu es à portée, pas parce que tu es
> intéressant. » Des programmes automatiques (des bots) balaient l'intégralité des adresses
> IP de la planète en boucle. Ils ne te cherchent pas TOI : ils testent ton IP parce
> qu'elle existe. Dès qu'un port est exposé, il est trouvé en quelques minutes — c'est de
> l'arithmétique, pas de la malchance.

---

## Question 2 — Qu'est-ce que la défense en profondeur ?

Quelle image décrit le mieux le principe de défense en profondeur ?

- A. Un seul mur, le plus haut et le plus épais possible
- B. Un oignon : plusieurs COUCHES, si l'attaquant en franchit une, il en trouve une
  autre derrière ✅
- C. Une caméra qui filme tout ce qui entre
- D. Un mot de passe très long et très compliqué

> **Explication** : La sécurité ne fonctionne pas comme un mur unique — un seul mur se
> contourne, et le jour où il tombe, tout tombe. Elle fonctionne par couches : périmètre
> (pare-feu), segmentation, moindre privilège, détection (IDS), secrets protégés (coffre).
> Chaque couche ralentit l'attaquant, le fatigue, et le fait remarquer.

---

## Question 3 — Une couche déjà posée aux cours précédents

Parmi les couches de défense en profondeur, laquelle as-tu DÉJÀ construite lors d'un
cours précédent, sans forcément savoir que c'était de la sécurité ?

- A. Le pare-feu OPNsense
- B. L'IDS Suricata
- C. La segmentation réseau — les segments 10.10.x du cours 0 ✅
- D. Le coffre-fort Vault

> **Explication** : Les segments isolés `10.10.x` créés au cours 0 sont exactement de la
> segmentation : découper le lab en zones qui ne se parlent pas librement. C'est la couche
> qui limite le mouvement latéral quand un service est compromis. Tu avais déjà posé une
> couche de défense en profondeur sans le savoir ; ce cours ajoute les autres.

---

## Question 4 — Que devient une alerte de sécurité ?

Quand ton pare-feu bloque une connexion ou que ton IDS détecte un scan, où atterrit
l'information ?

- A. Elle est affichée une fois puis perdue
- B. Elle reste uniquement sur la VM concernée, dans un fichier local
- C. Elle remonte dans ton SIEM (Kibana), à côté des logs du cours 2 ✅
- D. Elle est envoyée par e-mail à l'attaquant

> **Explication** : C'est LA boucle du cours. Chaque défense produit des logs, et ces logs
> vont là où tu as appris à les envoyer au cours 2 : ton SIEM. Un pare-feu qui bloque, un
> IDS qui alerte, ça arrive dans Kibana. Résultat : tu ne défends pas à l'aveugle, tu VOIS
> tes défenses travailler.

---

## Question 5 — Que fera le projet final ?

À quoi ressemble l'épreuve finale de ce cours (chapitre 8) ?

- A. Tu rédiges un rapport théorique sur les menaces des homelabs
- B. Tu lances un scan nmap sur ton pare-feu : il bloque, Suricata détecte, l'alerte tombe
  dans ton SIEM, et tu écris la règle qui bloque l'attaquant ✅
- C. Tu réinstalles toutes tes VMs depuis zéro
- D. Tu désactives le pare-feu pour tester la vitesse du réseau

> **Explication** : Le projet final te fait jouer l'attaquant contre ta propre forteresse.
> Depuis l'extérieur, un scan `nmap` — comme les bots du début. OPNsense le bloque,
> Suricata le détecte, l'alerte remonte dans Kibana, et tu écris la règle qui bloque
> définitivement l'attaquant. La boucle complète : attaque, défense, détection, réaction.
