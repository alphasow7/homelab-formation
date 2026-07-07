# Métadonnées Udemy — Cours 2

## Titre (≤ 60 caractères)

**ELK : monte ton SIEM et ton observabilité à la maison**
(53 caractères)

## Sous-titre

Elasticsearch, Logstash, Kibana, Filebeat : centralise, cherche et visualise les logs de
tout ton lab — jusqu'à traquer un incident en moins de 10 minutes.

## Description (AIDA)

**[Attention]** « Il s'est passé quelque chose hier à 23h sur une de tes machines. » Sans
logs centralisés, cette phrase est un cauchemar : te connecter partout, fouiller à la
main, et découvrir que la rotation a déjà effacé l'indice.

**[Intérêt]** Ce cours te fait construire, brique par brique, ta propre plateforme
d'observabilité — le même stack ELK que les entreprises utilisent comme SIEM. Sur le fil
rouge des cours précédents : ton lab Proxmox, piloté par Ansible, dont chaque machine
enverra désormais ses logs dans une bibliothèque centrale, indexée et cherchable en
millisecondes.

**[Désir]** À la fin du cours :
- **Elasticsearch** stocke et indexe tes logs (mono-nœud, avec le cluster expliqué) ;
- une **PKI interne** (ta propre autorité de certification) chiffre tout le stack en TLS ;
- **Logstash** trie et enrichit — tu transformes des lignes illisibles en champs
  interrogeables (grok) ;
- **Kibana** te donne Discover, KQL et des **dashboards** que tu construis toi-même (Lens) ;
- **Filebeat** collecte sur chaque VM, et même l'hyperviseur envoie son **syslog** ;
- et l'épreuve finale : un incident caché sur ton lab, que tu traques en **moins de
  10 minutes sans quitter Kibana**.

Toujours la rubrique **💥 « la panne du vrai monde »** : la CA générée deux fois qui a
bloqué mon cluster en 503, l'import de dashboard qui « réussit » en HTTP 200 mais ne charge
rien, et surtout mes dashboards restés désespérément vides parce que Filebeat surveillait
des fichiers de logs… qui n'existaient pas. Des incidents réels, rejoués et diagnostiqués
avec toi — tu apprends autant à dépanner qu'à construire.

**[Action]** Rejoins le cours : repo Git fourni (rôles Ansible dérivés d'une vraie infra),
corrections taguées par chapitre, critères de réussite mesurables.

## Objectifs d'apprentissage (6)

1. Déployer et interroger Elasticsearch (index, documents, recherche, santé du cluster)
2. Sécuriser un stack avec une PKI interne (CA, certificats, TLS de bout en bout)
3. Construire un pipeline Logstash et parser des logs avec grok
4. Explorer et visualiser dans Kibana (Discover, KQL, dashboards Lens)
5. Collecter les logs de tout un parc (Filebeat journald + syslog réseau)
6. Investiguer un incident dans un SIEM avec une méthode d'analyste (large → étroit)

## Prérequis

- Les cours « Proxmox » et « Ansible » de la série (ou un lab équivalent : 3-4 VMs
  pilotées par Ansible — le rattrapage est indiqué)
- **Prévois la RAM** : Elasticsearch est gourmand (voir la fiche lab-depart du cours)
- Aucun niveau ELK requis : on part de zéro

## Public cible

- Ceux qui ont fini Proxmox + Ansible et veulent voir ce que fait vraiment leur infra
- Aspirants analystes SOC / ingénieurs observabilité qui veulent un lab concret sur le CV
- Admins qui en ont assez du `grep` sur dix machines

## Prix

Prix catalogue : 64,99 € — lancement à 16,99 € (bundle des 3 cours à proposer).

## Curriculum (sections = chapitres)

1. Observabilité : pourquoi (logs, métriques, dispo ; l'archi ELK) — 20 min
2. Elasticsearch : la bibliothèque (index, documents, le « yellow » démystifié) — 40 min
3. TLS partout : ta propre autorité (+ 💥 la CA générée deux fois) — 35 min
4. Logstash : le centre de tri (+ le moment grok : texte → données) — 40 min
5. Kibana : la salle de lecture (+ 💥 l'import qui « réussit » sans rien faire) — 40 min
6. Filebeat : les facteurs (+ 💥 les dashboards vides / fichiers inexistants) — 35 min
7. Syslog réseau : les équipements sans agent alimentent le SIEM — 30 min
8. Dashboards de service : construis tes tableaux de bord (Lens) — 35 min
9. Projet final : l'aiguille dans la botte de foin (< 10 min dans Kibana) — 20 min + 45 min de projet
