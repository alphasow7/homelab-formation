# Chapitre 1 — Plan de tournage : tour de l'infra réelle

> Section 2 du script vidéo (~4 min au montage). Six plans, dans l'ordre. Pour chaque
> plan : durée cible et phrase de voix off. Filmer large puis resserrer ; les plans écran
> se font en capture (pas de caméra sur l'écran).
>
> 🔄 **Réaligné le 11/10/2026** sur le parc post-pivot VDP (cluster Proxmox de 4 nœuds,
> plateforme en VMs, ELK derrière le pare-feu). L'état de référence est dans
> [`docs/infra-reelle-2026-10.md`](../../docs/infra-reelle-2026-10.md) — le relire la
> veille du tournage, le parc bouge.

1. **La tour Proxmox** — *10-15 s*, plan fixe puis léger travelling.
   Voix off : « Voilà la star : un PC d'occasion tout à fait banal — un i7 et 31 Go de
   RAM. Pas de rack, pas de salle serveur — et pourtant, tout ce que tu vas voir dans
   cette série a d'abord tourné là-dedans. »

2. **Le switch et les câbles** — *5-10 s*, gros plan sur les ports et les LEDs.
   Voix off : « La multiprise réseau du lab : un switch cinq ports à quinze euros, non
   managé. Chaque câble relie une machine — la box, la tour, et les trois mini-PCs.
   C'est lui qui permet à tout ce petit monde de se parler. »

3. **Les 3 Lenovo ThinkCentre (nœuds du cluster Proxmox)** — *5-10 s*, plan fixe sur les
   trois mini-PCs côte à côte.
   Voix off : « Et ces trois mini-PCs, 16 Go de RAM chacun, sont trois hyperviseurs de
   plus. Avec la tour, ça fait un **cluster Proxmox de quatre nœuds** — oui, un cluster
   tient sur une étagère. Ce que tu vas apprendre sur UN serveur, c'est exactement ce
   qui tourne sur ces quatre-là. »

4. **Écran : la GUI Proxmox, vue Datacenter du cluster** — *10-15 s*, capture, dérouler
   lentement Datacenter → `vortex-cluster` → les 4 nœuds → leurs VMs (toutes vertes).
   Voix off : « L'intérieur : quatre nœuds, et sur chacun des machines virtuelles avec
   leur métier — une plateforme de déploiement, une stack de logs, un pare-feu, un
   serveur de sauvegarde, un bastion. Chaque ligne verte est un faux PC qui tourne dans
   le vrai — c'est exactement ce que tu sauras faire à la fin de ce cours. »

5. **Écran : le tableau de bord Kibana « Homelab — Vue d'ensemble »** — *8-12 s*,
   capture : les jauges CPU/RAM/disque des 4 nœuds, la table up/down des sondes, le
   volume de logs qui défile.
   Voix off : « Tout ce qui se passe sur le lab — chaque machine, chaque connexion,
   chaque erreur — est collecté et visualisé ici. Un serveur qu'on ne surveille pas,
   c'est un serveur qu'on découvre en panne. »

6. **Écran : la GUI OPNsense avec les alertes Suricata** — *8-12 s*, capture, la liste
   d'alertes IDS puis zoom sur une alerte.
   Voix off : « Et voilà le garde du corps : le pare-feu OPNsense, avec sa détection
   d'intrusion. Il filtre qui entre, qui sort, et lève une alerte quand quelque chose
   sent mauvais. Ça aussi, on le construira ensemble. »

---

**Check-list avant tournage** :
- [ ] Les 4 nœuds sont verts dans la vue Datacenter, et toutes les VMs permanentes
      *running* (plateforme 210-212, cible ELK 300, bastion 220, OPNsense 600, PBS 500).
      Les VMs de labs de certification (91xx), si elles existent, sont **arrêtées** ou
      hors champ : elles brouillent le message « chaque VM a son métier ».
- [ ] Le tableau de bord « Homelab — Vue d'ensemble » est alimenté (sondes vertes,
      métriques < 1 min) — sinon rejouer `monitoring.yml` avant.
- [ ] Suricata a des alertes récentes à montrer (sinon en déclencher une de test).
- [ ] Aucune information sensible visible à l'écran (mots de passe, IPs publiques,
      tokens, l'adresse Tailscale du bastion).
