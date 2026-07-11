# Chapitre 9 — Projet final : script vidéo

> Durée cible : ~18 min de vidéo (le gros du chapitre, c'est l'examen de l'élève : < 10 min
> chrono en main). Format projet, comme les finals du cours 0 et du cours 1 : pas de
> nouvelle notion — on cadre, on montre la méthode, on célèbre. Dérogation au gabarit
> assumée.

## 1. Le brief — la règle du jeu (5 min)

**À dire** : « Tout ce cours, on a branché des yeux : Elasticsearch, Logstash, Filebeat,
Kibana, les logs de tes VMs et de l'hyperviseur, tes dashboards. Aujourd'hui, on s'en
sert pour de vrai. Je vais cacher un incident quelque part sur ton lab — un vrai, discret,
et TU ne sauras pas lequel. Ta mission : trouver QUOI il s'est passé, OÙ (quelle machine),
et QUAND. En moins de dix minutes.

Et voici la règle sacrée : **tu n'as PAS le droit de te connecter aux machines.** Pas de
ssh, pas de qm, pas de GUI Proxmox. UNIQUEMENT Kibana. Parce que c'est ça, la promesse du
SIEM : diagnostiquer à distance, depuis une seule console, sans mettre les mains dans le
serveur. Le jour où tu as trente machines, tu ne peux pas te connecter à chacune pour
"voir". Tu regardes tes logs centralisés, et tu SAIS. Si tu ssh sur la VM pour vérifier,
tu n'as pas raté l'exercice — tu as raté le métier. »

**À montrer** : le lancement à l'aveugle — `./correction/generateur-incident.sh` sur le
poste. « Regarde : il ne me dit rien. Il choisit un scénario au hasard, l'exécute via
ansible sur une VM, et range la solution dans un fichier que je m'interdis d'ouvrir. À
partir de là, mon seul informateur, c'est Kibana. »

## 2. La méthode d'un bon analyste — large → étroit (5 min)

**À dire** : « L'erreur du débutant : foncer dans Discover et scroller au hasard dans dix
mille lignes. Tu vas te noyer. La méthode pro, c'est l'entonnoir, et l'ordre compte :

**D'abord le TEMPS — QUAND.** Ouvre ton dashboard "Santé du lab". Fenêtre "Last 30
minutes". Tu ne cherches pas encore le coupable : tu cherches le MOMENT où quelque chose
sort de l'ordinaire. Un pic de volume ? Le camembert de sévérité qui vire au rouge ? Une
couleur qui disparaît d'un coup ? Le temps te donne ta fenêtre d'enquête. Sans ça, tu
cherches une aiguille dans toute la botte ; avec ça, tu sais dans quelle poignée de foin
regarder.

**Ensuite le LIEU — OÙ.** Ton panneau volume par `host.name` te dit sur quelle machine ça
se passe. Un filtre `host.name` et tu as divisé le problème par quatre.

**Enfin la NATURE — QUOI.** Là seulement tu descends dans Discover, avec ta fenêtre de
temps et ta machine. Tu regardes `journald.unit`, `process.name`, le `message`. Tu LIS.
C'est là que l'incident se nomme.

Temps, lieu, nature. Chaque étape est un filtre KQL — et ces filtres, tu les gardes : ce
sont ta preuve que tu as trouvé, pas deviné. »

## 3. La démo du formateur — un scénario (le brute-force) (6 min)

**À montrer** : dérouler la méthode sur le scénario 2, le brute-force SSH, chrono à
l'écran.

1. **QUAND** : le dashboard "Santé du lab", "Last 30 minutes". « Regarde ce **pic de
   volume** net, il y a trois minutes. Et le camembert de sévérité qui gonfle du côté
   warning au même instant. Voilà ma fenêtre. » Noter l'heure.
2. **OÙ** : le panneau volume par host. « Le pic est tout entier sur **le bastion**. Les
   trois autres machines n'ont pas bougé. » Poser le filtre `host.name : "bastion"`.
3. **QUOI** : passer dans Discover, garder l'heure + la machine, ajouter
   `process.name : "sshd"`. « Et là, l'aiguille : une RAFALE de `Failed password for
   invalid user baduser`, vingt lignes en quelques secondes. Sur le bastion, à telle
   heure, quelqu'un a martelé SSH. C'est un brute-force. »
4. **Conclure** : QUOI = brute-force SSH, OÙ = bastion, QUAND = l'heure du pic. « Trois
   filtres, deux minutes, zéro connexion à la machine. Voilà le métier. »

**À montrer (vérification)** : `cat /tmp/solution-NEPASREGARDER.txt` — le scénario et
l'heure confirment. « On ouvre le juge SEULEMENT maintenant. »

## 4. Célébration et suite (2 min)

**À dire** : « Prends dix secondes. Tu viens de diagnostiquer une panne sur une machine
sans jamais t'y connecter — juste en lisant tes logs centralisés. Reviens au début du
cours : tu SUBISSAIS tes serveurs, tu apprenais leur état en te connectant, un par un,
trop tard. Aujourd'hui, tu VOIS tout, d'une seule console, en temps réel. Ce n'est pas un
gadget : c'est un vrai métier, ça s'appelle l'analyse SOC — Security Operations Center — et
c'est exactement ce que tu viens de faire.

Mais voir, ce n'est que la moitié du travail. Tu sais VOIR ; au **cours 3**, tu vas
apprendre à DÉFENDRE : un pare-feu qui bloque, un système de détection d'intrusion qui
repère les attaques, un coffre-fort à secrets. Et le plus beau : toutes ces alertes de
sécurité viendront atterrir ICI, dans le SIEM que tu viens de bâtir. Les yeux d'abord, les
boucliers ensuite. À très vite. »

**À filmer (encart final)** : sur l'infra réelle, une alerte de sécurité (une détection
Suricata, un accès refusé au pare-feu) qui apparaît dans Kibana — « voilà ce qu'on branche
au cours 3, et où ça arrive : chez toi, dans ton SIEM. »
