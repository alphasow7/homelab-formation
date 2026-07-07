# Chapitre 6 — Filebeat : le facteur de chaque machine : script vidéo

> Durée cible : ~35 min. Prérequis : Logstash écoute les beats sur
> `kibana-logstash:5044` (chap 4), Kibana est joignable (chap 5).
> Toutes les commandes montrées sont dans `demo.sh` et rejouées avant tournage.
> Le rôle complet est dans `../ansible-extraits/roles/filebeat/` — l'élève le
> recopie dans SON arbre (`cours-1-ansible/ansible/roles/`).

## 1. Le concept (5 min)

**À dire** : « Jusqu'ici on a construit la destination : Elasticsearch qui range,
Logstash qui trie, Kibana qui montre. Mais les logs, eux, naissent sur CHAQUE machine.
Il faut quelqu'un qui aille les chercher là où ils vivent et les poste à Logstash.
Ce quelqu'un, c'est **Filebeat**.

Filebeat, c'est **un facteur par machine** : il ramasse le courrier local et il le poste,
point. Il ne l'ouvre pas, ne le trie pas, ne réfléchit pas — c'est le travail de Logstash,
au centre de tri. Un agent volontairement bête : léger, discret, un par serveur. »

**⚠️ MOMENT CLÉ, à dire AVANT la démo — journald vs fichiers plats** : « Où sont les logs
sur nos VMs ? Réflexe classique : `/var/log/syslog`, `/var/log/auth.log`. **Sauf que sur
ces Debian minimales, ces fichiers n'existent pas** : il n'y a pas de `rsyslog` installé.
Alors où sont les logs ? Dans **journald** — le journal binaire de systemd, qui centralise
déjà TOUT (démarrages, services, ssh, kernel). Il est là, toujours, sur toute machine
systemd. Donc on ne fait PAS lire des fichiers à Filebeat : on lui fait lire **journald
directement**. Retiens ce couple : *pas de rsyslog → input journald*. C'est toute la
leçon du chapitre, et la panne de tout à l'heure en découle. »

## 2. Démo guidée (12 min)

### 2.1 Déployer sur les 4 VMs en un coup

**À montrer** : recopier le rôle depuis `ansible-extraits/`, l'ajouter au play `elk.yml`
(en `hosts: lab`, ou lancer le playbook autonome `filebeat.yml`). Masquerade ON (apt tire
le paquet filebeat sur des VMs sans Internet), puis :

```bash
ansible-playbook playbooks/filebeat.yml
```

**À expliquer pendant le déploiement** : le tour du rôle — la méthode GPG moderne
(`signed-by`, comme au chap 2), l'installation sur les 4 machines, et surtout le template :
`filebeat.inputs: - type: journald` et `output.logstash` vers `10.10.99.14:5044`.
« Remarque : **aucun `output.elasticsearch`**. Filebeat ne parle jamais à ES en direct —
tout transite par Logstash. » Masquerade OFF.

### 2.2 Les hostnames apparaissent dans Kibana

**À montrer** : ouvrir **Kibana → Discover** (data view `logstash-*`, celui du chap 4).
En quelques secondes, des documents arrivent. Dans la liste des champs, cliquer sur
`host.name` (ou `agent.hostname`) : les **4 noms** sont là — `elastic-1`,
`kibana-logstash`, `dns-proxy`, `bastion`.

« Chaque VM s'est présentée toute seule. Filtre par host : clique sur `dns-proxy` → tu ne
vois plus que ses logs. Quatre facteurs, un seul centre de tri, une seule vue. »

**À montrer (filtre)** : dans la barre KQL de Discover : `host.name : "dns-proxy"`.

## 3. Encart vrai matériel (2 min)

**À dire** : « Sur mon vrai cluster, les VMs et le Proxmox ont exactement ce rôle Filebeat.
Mais les **conteneurs** du cluster K3S, eux, ne sont pas des machines : on n'y met pas un
facteur par pod. On déploie Filebeat **et Metricbeat en DaemonSet** — un agent par NŒUD
Kubernetes, qui lit les logs de tous les conteneurs de ce nœud. Même idée (un agent proche
de la source), autre emballage. C'est hors périmètre du cours, mais sache que le concept ne
change pas d'un iota entre ta VM et un cluster de prod. »

## 4. 💥 La panne du vrai monde — « 0 documents » (10 min)

**Le récit (vécu)** : « Ça m'est arrivé pour de vrai, et ça a coûté une soirée. J'avais
déployé Filebeat partout, `systemctl status filebeat` **vert** sur toutes les machines,
Ansible en `changed=0`, tous les services au beau fixe. Et dans Kibana… mes dashboards
étaient **VIDES**. Zéro document. Aucune erreur nulle part. »

**Le diagnostic de l'époque** : « La config d'origine pointait des **chemins de fichiers** :
`/var/log/syslog`, `/var/log/auth.log`. Or — tu vois où je veux en venir — sur ces Debian
minimales, **ces fichiers n'existent pas** : pas de rsyslog, personne ne les écrit. Et
voici le piège, le vrai enseignement : **Filebeat ne considère PAS un fichier absent comme
une erreur.** Il ne plante pas, il ne crie pas. Il *attend*, en silence, qu'un fichier qui
n'apparaîtra jamais finisse par apparaître. Service vert. Zéro donnée. Pour l'éternité. »

**Le fix réel** : « La correction a été de basculer sur l'input **journald** — le journal
systemd, lui, existe toujours. C'est exactement le template que tu viens de déployer. »

**ON LA REJOUE (à filmer, tout est dans `demo.sh`)** :

1. **CASSER** — dans le template, remplacer temporairement l'input journald par un
   filestream sur un chemin bidon :
   ```yaml
   filebeat.inputs:
     - type: filestream
       id: casse
       paths:
         - /var/log/rien.log
   ```
   Redéployer (`ansible-playbook playbooks/filebeat.yml`).
2. **OBSERVER le silence** — sur la VM : `systemctl status filebeat` → **active (running),
   vert**. Dans Kibana Discover, plus rien de neuf pour cet host. Tout va « bien » et rien
   n'arrive. « Voilà le piège grandeur nature. »
3. **OBSERVER le POURQUOI** — le réflexe qui sauve : arrêter le service et lancer Filebeat
   **en avant-plan** pour le VOIR travailler :
   ```bash
   systemctl stop filebeat
   filebeat -e -c /etc/filebeat/filebeat.yml
   ```
   Attendu à l'écran : des lignes du type *« Harvester could not be started… no such file »*
   / *« Filestream input… no paths were found »* — **il te DIT qu'il attend des fichiers
   absents.** `Ctrl-C` pour sortir.
4. **RÉPARER** — remettre l'input `journald` dans le template, redéployer, relancer le
   service. Dans Kibana, les documents de la VM repartent en quelques secondes.

**Morale (à dire lentement, à l'écran)** : **« Un agent vert qui n'envoie rien : demande-toi
ce qu'il REGARDE. Pour Filebeat, un fichier absent n'est pas une erreur — c'est une attente
éternelle et silencieuse. Le service au vert ne prouve qu'une chose : que le processus
tourne. Pas qu'il a quelque chose à lire. »**

## 5. Annonce du TP (1 min)

**À dire** : « La panne, c'était le négatif : un fichier qui n'existe pas. Au TP, tu fais
le positif : tu ajoutes à Filebeat un input filestream sur des **vrais** fichiers — les
logs nginx de dns-proxy, qui eux existent — avec un champ `log_source: nginx` pour les
reconnaître. Tu génères du trafic, et tu retrouves tes lignes nginx dans Kibana, filtrées.
20 minutes. Au prochain chapitre : faire parler les équipements réseau — le syslog qui vient
d'ailleurs. »
