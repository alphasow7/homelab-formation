# Vidéo YouTube d'appel — « J'ai installé un détecteur d'intrusion chez moi »

**Durée cible : ~16 min.** Publication : ~2 semaines avant la sortie du cours Udemy.
**Miniature** : un écran OPNsense/Kibana avec une alerte rouge « SCAN DETECTED » + texte
« IL M'ATTAQUE… ET JE LE VOIS ».

## Déroulé

### Hook (0:00-1:30) — l'attaque en direct

**À montrer** : deux écrans. À gauche, un terminal : `nmap -sS -p- 192.168.1.36` (le scan
de mon propre pare-feu). À droite, Kibana. Le scan démarre… et en quelques secondes, une
alerte Suricata tombe dans Kibana : « ET SCAN Potential SSH Scan », l'IP source, l'heure.
**À dire** : « Je viens d'attaquer mon propre réseau. Et mon lab l'a vu, l'a bloqué, et
m'a prévenu — en temps réel. Un pare-feu, un détecteur d'intrusion, un SIEM : les mêmes
outils qu'un vrai centre de sécurité, dans mon salon. Je te montre comment. »

### Le problème (1:30-3:30)

« Dès qu'une machine est en ligne, elle est scannée — pas parce qu'elle est intéressante,
parce qu'elle est à portée. La question n'est pas SI on te scanne, mais si tu le VOIS. »
La défense en profondeur : pas un mur, des couches.

### Les 3 couches en accéléré (3:30-11:00)

- **Le pare-feu (OPNsense)** : le poste de douane WAN/LAN, fermé par défaut, on ouvre au
  compte-gouttes. Montrer une règle. Le piège du subnet en 10 secondes (« ne mets jamais
  ton LAN sur le réseau de ta box »).
- **L'IDS (Suricata)** : les signatures d'attaques connues ; activer, télécharger les
  règles, mode détection. LE piège : « update OK » ne veut pas dire « règles chargées » —
  vérifie l'effet.
- **Le SIEM (ELK)** : les alertes du pare-feu remontent dans Kibana — « tu ne défends pas
  à l'aveugle, tu vois tes défenses ». Montrer le dashboard sécurité réel.
Bonus rapide : **Vault**, le coffre-fort à secrets (init/unseal, un secret rangé).

### La boucle complète (11:00-14:00)

Le projet final en condensé : scan → bloqué → détecté → vu dans Kibana → j'écris la règle
qui blackliste l'attaquant → 2ᵉ scan, mort. « Attaque, défense, détection, réaction. La
boucle d'un analyste SOC — chez toi. »

### Outro (14:00-16:00)

**À dire** : « C'est le DERNIER cours de la série. Si tu as suivi les quatre : tu es parti
d'un vieux PC vide, et tu as un datacenter miniature — virtualisé, automatisé, observé,
défendu. Proxmox, Ansible, ELK, sécurité : ce n'est pas un hobby, c'est un portfolio.
Le cours complet en description, avec mes vraies pannes — le pare-feu resté en mot de
passe par défaut trois semaines, les règles Suricata "téléchargées" mais jamais chargées,
le coffre-fort dont j'avais perdu les clés. On apprend autant de mes erreurs que de mes
réussites. Merci d'avoir construit tout ça avec moi. La suite — orchestration, CI/CD,
haute dispo — t'appartient. »

## Checklist tournage

- [ ] Le scan + l'alerte filmés en split-screen synchro (le cœur du hook)
- [ ] Chrono/horodatage visible pour prouver le temps réel
- [ ] La règle de blocage + le 2ᵉ scan mort (la réaction)
- [ ] Description : liens Udemy des 4 cours (bundle), repo, chapitrage
- [ ] Carte de fin : la série complète (4 vignettes)
