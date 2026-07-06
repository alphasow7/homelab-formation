# Vidéo YouTube d'appel — « Je détruis et reconstruis mon infra en 1 commande »

**Durée cible : ~15 min.** Publication : ~2 semaines avant la sortie du cours Udemy.
**Miniature** : une VM barrée d'une croix rouge + un chrono « 4:32 » + texte « DÉTRUITE
PUIS RECONSTRUITE ».

## Déroulé

### Hook (0:00-0:45)

**À montrer** : plein écran, sans intro : `qm destroy 9203` — la VM disparaît de la GUI.
Le serveur DNS du lab est MORT (dig → timeout, page web → morte).
**À dire** : « Je viens de détruire un serveur. Volontairement. Pas un snapshot, pas une
sauvegarde : détruit. Et dans moins de 5 minutes — chrono en bas de l'écran — il sera de
retour, configuré au poil, sans que je touche à quoi que ce soit à la main. Voilà ce que
change l'Infrastructure as Code. »

### Le problème (0:45-3:00)

Le serveur artisanal : configuré à la main, indocumenté, irremplaçable (« le serveur
flocon de neige — unique et fragile »). La question qui fâche : « ton serveur, là — tu
saurais le refaire à l'identique ? » Transition : et si la config était du CODE ?

### Ansible en 5 minutes (3:00-8:00)

- L'inventaire (l'annuaire du parc) et le ping des 3 VMs ;
- Un playbook qui se LIT (montrer web-status.yml : « même sans connaître Ansible, tu
  comprends ») ;
- LA démo d'idempotence : run → changed, re-run → `changed=0` ;
- Le vandalisme réparé : casser la page à la main, rejouer, réparé. « Le code est la
  vérité ; la machine s'y conforme. »

### Le phénix chronométré (8:00-13:00)

La séquence du hook, complète et honnête : destruction → clone du template → cloud-init →
`site.yml --limit dns-proxy` → dig OK, page OK avec son mot de passe. Chrono incrusté du
début à la fin. Arrêt du chrono à l'écran (< 5:00). « La VM n'était pas précieuse. Le
CODE est précieux. C'est toute la différence entre un animal de compagnie et du bétail —
pets versus cattle, comme disent les gens sérieux. »

### Outro (13:00-15:00)

**À dire** : « Ce que tu as vu, c'est le résultat du cours complet en description :
l'inventaire et le bastion comme les pros, les rôles réutilisables, les variables, les
secrets chiffrés dans Git — et mes VRAIES pannes décortiquées, celle du DNS fantôme,
celle de la variable piégée. Prérequis : mon cours Fondations (lien), ou n'importe quel
Proxmox avec 3 VMs. Prochaine étape de la série : ELK — brancher des yeux sur tout ça. »

## Checklist tournage

- [ ] Le phénix répété à blanc ×2 (le chrono doit passer SOUS 5 min sans triche)
- [ ] Chrono incrusté en continu sur la séquence phénix (crédibilité)
- [ ] Rushes GUI : la VM qui disparaît puis réapparaît dans l'arborescence
- [ ] Description : lien Udemy cours 1 + cours 0, repo GitHub, chapitrage
