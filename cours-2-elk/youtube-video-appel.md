# Vidéo YouTube d'appel — « Je vois TOUT ce qui se passe sur mon réseau »

**Durée cible : ~16 min.** Publication : ~2 semaines avant la sortie du cours Udemy.
**Miniature** : un écran Kibana avec un pic rouge de logs + une loupe + texte « QUI A FAIT
ÇA ? ». 

## Déroulé

### Hook (0:00-1:30) — l'aiguille dans la botte de foin

**À montrer** : « Quelqu'un vient d'attaquer une de mes machines. Je ne sais pas laquelle,
ni quand. Regarde. » Kibana plein écran : un pic de volume dans le temps → clic pour
zoomer sur le pic → filtre sur la machine → les lignes « Failed password for invalid user »
défilent. Chrono incrusté : **1:24**. « Machine trouvée, attaque identifiée, heure exacte.
Une minute et demie, sans me connecter à un seul serveur. Voilà ce que change un SIEM. »

### Le problème (1:30-3:30)

La ssh-archéologie : 4 machines, 40 fichiers de logs, 4 formats, et l'info qui disparaît
avec la rotation. « Sans centralisation, "il s'est passé quoi hier à 23h ?" est une
question sans réponse. »

### Le pipeline en accéléré (3:30-10:00)

Construire ELK, version timelapse :
- **Elasticsearch** = la bibliothèque indexée (indexer un doc, le chercher en 5 ms) ;
- **Logstash** = le centre de tri — LE moment grok : une ligne de log nginx illisible
  → des champs propres (code HTTP, IP, URL). « Avant : du texte. Après : des données. » ;
- **Kibana** = la salle de lecture ;
- **Filebeat** = les facteurs qui ramassent sur chaque machine.
Montrer les logs des 4 VMs + de l'hyperviseur qui affluent dans Discover.

### Les dashboards (10:00-13:00)

Construire en direct (Lens, glisser-déposer) un dashboard « santé » : volume par machine,
sévérité, top services. « Le bruit en sourdine, le signal en avant. » Le dashboard réel de
l'infra (2M+ docs) en guise de « voilà où ça mène ».

### Outro (13:00-16:00)

**À dire** : « Le cours complet en description : la porte blindée (TLS et ta propre
autorité de certification), les agents partout, le syslog des équipements réseau, et mes
VRAIES pannes — la CA générée deux fois qui a bloqué mon cluster, les dashboards restés
vides parce que Filebeat regardait des fichiers qui n'existaient pas. Prérequis : mes cours
Proxmox et Ansible (liens). Prochaine étape de la série : la sécurité — pare-feu OPNsense,
détection d'intrusion, coffre-fort à secrets. Et ces alertes-là, tu sais déjà où elles
vont arriver : ici, dans ton SIEM. Abonne-toi. »

## Checklist tournage

- [ ] Le générateur d'incident lancé à blanc → un scénario spectaculaire pour le hook (brute-force)
- [ ] Chrono incrusté sur le hook (crédibilité du « < 2 min »)
- [ ] La séquence grok filmée en gros plan (avant/après = le moment de bascule)
- [ ] Description : liens Udemy cours 2 + cours 0/1, repo, chapitrage
