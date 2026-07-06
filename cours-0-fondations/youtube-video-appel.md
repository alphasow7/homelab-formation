# Vidéo YouTube d'appel — « Transforme un vieux PC en datacenter »

**Durée cible : ~18 min.** Publication : ~2 semaines avant la sortie du cours Udemy.
**Miniature** : split-screen — à gauche un vieux PC poussiéreux, à droite la GUI Proxmox
avec 10 VMs vertes. Texte : « DATACENTER MAISON ».

## Déroulé

### Hook (0:00-0:30)

**À montrer** : la GUI de l'infra réelle — 10 VMs qui tournent, le dashboard Kibana avec
les logs qui défilent, une alerte Suricata.
**À dire** : « Tout ça — un cluster de recherche, un GitLab, un coffre-fort à secrets, un
détecteur d'intrusion — tourne dans mon salon, sur un PC qu'on m'aurait presque donné.
Aujourd'hui, je te montre comment démarrer le tien. Et tu n'as même pas besoin de PC en
plus : une machine avec 16 Go de RAM suffit pour tout faire en virtuel. »

### Pourquoi un homelab (0:30-2:30)

Les 3 raisons (apprendre en cassant sans risque / héberger ses services / préparer un job
devops-sysadmin), illustrées par des plans de l'infra réelle (plans 1-4 du
`chap-1/plan-tournage-infra-reelle.md` — réutiliser les rushes).

### Installation Proxmox en accéléré (2:30-10:30)

La version TIMELAPSE du chapitre 2 + labs :
- Téléchargement ISO, création de la VM VirtualBox (mention rapide du chemin « vieux PC ») ;
- Installation Proxmox (timelapse musical sur les écrans, arrêts sur les 3 valeurs qui
  comptent : IP, mot de passe, hostname) ;
- Premier login GUI — moment « wow » : « voilà, tu as un serveur de virtualisation » ;
- Post-install express (dépôts + update, SANS le détail deb822 — « la version pas-à-pas
  est dans le cours »).

### Première VM + le tour de magie (10:30-16:00)

- Créer une VM cloud-init en ~6 commandes (couper les temps morts) ; ssh → `demo-vm` ;
- LE moment spectaculaire : snapshot → on CASSE la VM en direct (`rm -rf /etc/ssh`) →
  rollback → elle revit. « Voilà pourquoi un homelab est le meilleur endroit pour
  apprendre : ici, casser n'a aucune conséquence. »
- Enchaîner : template + 3 clones chrono en main (< 1 min) — « et là tu comprends comment
  on passe de 1 VM à 10 ».

### Outro (16:00-18:00)

**À dire** : « Ce que tu viens de voir en 15 minutes, c'est le survol. La version
complète — pas à pas, avec les réseaux isolés comme les pros, les sauvegardes qu'on
PROUVE, un projet final avec bastion, les TPs corrigés et mes pannes réelles décortiquées
— c'est le cours en description. Et c'est le premier d'une série : Ansible pour tout
automatiser, ELK pour tout voir, OPNsense pour tout protéger. Abonne-toi pour la suite. »

**À montrer** : le programme de la série (4 vignettes), lien Udemy + repo GitHub à l'écran.

## Checklist tournage

- [ ] Rushes infra réelle (réutiliser ceux du chap-1)
- [ ] Timelapse installation (OBS, accéléré ×8)
- [ ] Chrono incrusté pour la séquence clones
- [ ] Casse/rollback répété à blanc avant tournage (snapshot de secours du snapshot !)
- [ ] Description : lien Udemy (code promo lancement), lien repo, chapitrage YouTube
