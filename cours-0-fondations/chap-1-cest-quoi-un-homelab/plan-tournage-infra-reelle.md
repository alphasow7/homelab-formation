# Chapitre 1 — Plan de tournage : tour de l'infra réelle

> Section 2 du script vidéo (~4 min au montage). Six plans, dans l'ordre. Pour chaque
> plan : durée cible et phrase de voix off. Filmer large puis resserrer ; les plans écran
> se font en capture (pas de caméra sur l'écran).

1. **Le boîtier du serveur Proxmox** — *10-15 s*, plan fixe puis léger travelling.
   Voix off : « Voilà la star : un PC d'occasion tout à fait banal. Pas de rack, pas de
   salle serveur — et pourtant, tout ce que tu vas voir dans cette série tourne
   là-dedans. »

2. **Le switch TP-Link LS1005G et les câbles** — *5-10 s*, gros plan sur les ports et les
   LEDs qui clignotent.
   Voix off : « La multiprise réseau du lab : un switch cinq ports à quinze euros. Chaque
   câble relie une machine — c'est lui qui permet à tout ce petit monde de se parler. »

3. **Les 2 Lenovo ThinkCentre (cluster K3S)** — *5-10 s*, plan fixe sur les deux mini-PCs
   côte à côte.
   Voix off : « Et ces deux mini-PCs, c'est un cluster Kubernetes. Oui, un cluster tient
   sur une étagère. On les garde pour beaucoup plus tard — retiens juste qu'ils
   existent. »

4. **Écran : la GUI Proxmox avec les 10 VMs running** — *10-15 s*, capture d'écran, dérouler
   lentement l'arborescence Datacenter → nœud → VMs (toutes vertes).
   Voix off : « L'intérieur du serveur : dix machines virtuelles, chacune avec son métier.
   Chaque ligne verte est un faux PC qui tourne dans le vrai — c'est exactement ce que tu
   sauras faire à la fin de ce cours. »

5. **Écran : un dashboard Kibana avec les logs qui défilent** — *8-12 s*, capture, choisir
   un dashboard vivant (graphes + flux de logs en temps réel).
   Voix off : « Tout ce qui se passe sur le lab — chaque connexion, chaque erreur — est
   collecté et visualisé ici. Un serveur qu'on ne surveille pas, c'est un serveur qu'on
   découvre en panne. »

6. **Écran : la GUI OPNsense avec les alertes Suricata** — *8-12 s*, capture, montrer la
   liste d'alertes IDS puis zoomer sur une alerte.
   Voix off : « Et voilà le garde du corps : le pare-feu OPNsense, avec sa détection
   d'intrusion. Il filtre qui entre, qui sort, et lève une alerte quand quelque chose
   sent mauvais. Ça aussi, on le construira ensemble. »

---

**Check-list avant tournage** :
- [ ] Les 10 VMs sont bien toutes *running* (vert) dans la GUI Proxmox.
- [ ] Le dashboard Kibana choisi reçoit des logs en direct (sinon générer du trafic avant).
- [ ] Suricata a des alertes récentes à montrer (sinon en déclencher une de test).
- [ ] Aucune information sensible visible à l'écran (mots de passe, IPs publiques, tokens).
