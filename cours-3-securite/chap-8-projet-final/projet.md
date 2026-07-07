# Projet final du cours 3 — ET DE TOUTE LA FORMATION — La boucle complète

**Temps cible : 45 min.** C'est l'examen de sortie du cours 3… mais surtout **le projet
final de toute la formation**. Tu as tout construit, cours après cours : un serveur
virtualisé (cours 0), une infra automatisée de A à Z (cours 1), un SIEM qui voit tout
(cours 2), des défenses en profondeur (cours 3). Aujourd'hui, une seule question :
**est-ce que ça marche ENSEMBLE ?**

Pas de nouvelle notion. Tu vas jouer, en une seule séance, **la boucle complète de la
sécurité** :

```
   ATTAQUE  ──►  DÉFENSE  ──►  DÉTECTION  ──►  OBSERVATION  ──►  RÉACTION
  (le scan)   (le pare-feu   (Suricata lève   (l'alerte dans   (tu écris la
              bloque)         l'alerte)         Kibana)          règle de blocage)
```

Tu vas te mettre dans la peau de **l'attaquant** (depuis ton poste, côté WAN, hors du
LAN) ET dans celle du **défenseur** (analyste SOC devant Kibana). Tu attaques ton propre
lab, tu regardes tes défenses réagir, tu retrouves la trace, et tu **fermes la porte**.

> Filet de sécurité : tu attaques ta **propre** IP WAN d'OPNsense, sur ton lab. Rien
> d'illégal, rien de dangereux — un scan de ports sur une machine qui t'appartient. Ne
> scanne **jamais** une IP qui n'est pas la tienne.

## Ce qu'il te faut avant de commencer

- OPNsense en pare-feu de périmètre : **WAN** (côté box) + **LAN** `192.168.99.1`
  (chap 2-3), avec un firewall par zone (chap 4).
- Suricata **actif sur le WAN** en mode détection (chap 5), rulesets chargés, export
  syslog vers le SIEM en place.
- Le SIEM ELK du cours 2 : **Kibana en `10.10.99.14`**, qui reçoit les alertes OPNsense
  (input Logstash syslog `5514`, cours 2 chap 7).
- **`nmap` installé sur ton poste** (l'attaquant) : `brew install nmap` (macOS) ou
  `sudo apt install nmap` (Linux). C'est ton seul outil d'attaque.
- L'**IP WAN d'OPNsense** (celle que ta box lui a donnée en DHCP) — note-la, tu vas la
  taper souvent. Dans ce document : `IP_WAN_OPNSENSE` (ex. `192.168.1.36`).

## Étape 1 — La reconnaissance (l'attaque)

Tu es l'attaquant. Première chose que fait un attaquant qui découvre une IP : il la
**scanne** pour voir quels ports sont ouverts, donc quels services attaquer.

Depuis **ton poste** (côté WAN, PAS depuis le LAN) :

```bash
# Note l'heure EXACTE avant de lancer — tu en auras besoin pour retrouver l'alerte
date
sudo nmap -sS -p- IP_WAN_OPNSENSE     # scan SYN de TOUS les ports (1-65535)
```

- `-sS` = scan SYN (« demi-ouvert », discret). Il **exige les droits root** (`sudo`).
  Sans root, `nmap` bascule tout seul en `-sT` (scan connect, plus bruyant mais sans
  privilège) — c'est bon aussi pour le projet.
- `-p-` = les 65535 ports. Un balayage complet, exactement le genre de bruit qu'un IDS
  connaît par cœur.

**Note l'heure de départ.** C'est ta clé pour retrouver l'alerte à l'étape 3.

## Étape 2 — La défense (le pare-feu bloque)

Regarde la sortie de `nmap`. Sur une IP WAN bien pare-feuée, tu dois voir quelque chose
comme :

```
All 65535 scanned ports on IP_WAN_OPNSENSE are in ignored states.
Not shown: 65535 filtered tcp ports (no-response)
```

`filtered` = le pare-feu **avale** les paquets sans répondre (drop silencieux). L'attaquant
ne voit **aucun port ouvert**, aucun service à attaquer. Le scan « part dans le vide » :
timeouts, rien à se mettre sous la dent. **C'est ta première victoire** : les règles des
chap 3-4 (policy DROP par défaut sur le WAN) font leur travail. Ton périmètre tient.

> Si tu vois des ports `open`, ce n'est pas forcément un échec — mais demande-toi
> lesquels et pourquoi (la GUI OPNsense en `443` ? une redirection oubliée ?). Un bon
> périmètre n'expose que le strict nécessaire.

## Étape 3 — La détection ET l'observation (retrouver l'alerte)

Le pare-feu a bloqué. Mais a-t-il **vu** l'attaque ? C'est le rôle de Suricata. Deux
endroits, deux niveaux de lecture :

**a) Dans OPNsense (la vue brute, en direct) :** `Services > Intrusion Detection >
Alerts`. Tu dois voir une (des) ligne(s) fraîche(s), signature type `ET SCAN Potential
SYN Scan` ou `ET SCAN Nmap …`, **source = l'IP de ton poste**, **destination = le WAN**.

**b) Dans Kibana (la vue SIEM, gardée et corrélable) :** c'est ici que tu joues
l'**analyste SOC**. `Discover` → index `logstash-syslog-*` → filtre KQL :

```
syslog_hostname : "OPNsense.internal" and message : "SCAN"
```

(adapte `"OPNsense.internal"` au champ hostname réel de tes documents ; `"SCAN"` à un mot
de ta signature.) Cale la fenêtre temporelle sur **l'heure notée à l'étape 1**.

**Analyse l'alerte** — c'est la partie « je sais lire une alerte », pas « j'ai un point
rouge » :

- **Qui ?** l'**IP source** = l'IP de ton poste (l'attaquant).
- **Quoi ?** la **signature** (ex. `ET SCAN Potential SYN Scan`) → un scan de ports.
- **Quand ?** le **`@timestamp`** → il colle à l'heure de ton `date` de l'étape 1.

Note ces trois éléments. Ils sont ta preuve que la boucle détection → observation
fonctionne : une attaque lancée côté WAN est **remontée jusqu'à ton écran d'analyste**,
sans que tu aies touché à OPNsense.

## Étape 4 — La réaction (tu écris la règle de blocage)

Jusqu'ici le pare-feu bloquait « par défaut » (aucun port ouvert). Maintenant tu vas
**cibler l'attaquant lui-même** et documenter ton choix. Deux voies — choisis-en une :

**Voie A — Passer Suricata en IPS (drop) sur la catégorie scan.**
`Services > Intrusion Detection > Administration` → coche **IPS mode** → **Save**,
**Apply**. Puis dans `Rules` (ou `Policy`), pour la catégorie/signature de scan, passe
l'action de **Alert** à **Drop**. Désormais Suricata ne se contente plus d'alerter : il
**coupe** le trafic qui matche la signature. *Coût :* un faux positif casse du trafic
légitime — d'où le fait qu'on ne le fait qu'**après** avoir observé (chap 5).

**Voie B — Une règle firewall OPNsense qui drop l'IP source.**
`Firewall > Rules > WAN` → **Add** une règle en tête : Action **Block**, Source =
**l'IP de ton poste** (celle repérée à l'étape 3), Destination = any → **Save**, **Apply**.
Tu blacklistes l'attaquant, indépendamment de ce qu'il tente ensuite. *Plus chirurgical,
plus simple à raisonner qu'un IPS sur signature.*

**Documente ton choix** dans ta réponse : quelle voie, pourquoi, et ce que ça coûte. Il
n'y a pas de « bonne » réponse unique — il y a un choix **raisonné**. (IPS = bloque *le
type d'attaque* pour tout le monde ; règle firewall = bloque *cet attaquant* précis.)

## Étape 5 — La preuve (le 2e scan est bloqué)

Relance **exactement** le scan de l'étape 1 :

```bash
date
sudo nmap -sS -p- IP_WAN_OPNSENSE
```

Ce qui doit changer :

- **Voie A (IPS)** : la catégorie scan est maintenant en **Drop** — l'onglet Alerts
  d'OPNsense montre l'action `drop`/`blocked` (plus seulement `alert`), le scan est coupé
  encore plus tôt.
- **Voie B (firewall)** : ton IP est **blacklistée** — le scan ne passe même plus la
  première règle WAN. `Firewall > Log Files > Live View` montre tes paquets bloqués par
  **ta** règle.

Tu viens de **fermer la porte que tu avais toi-même trouvée**. Boucle bouclée :
attaque → défense → détection → observation → **réaction**.

## Critères de réussite (mesurables)

Rends ta réponse avec ces 5 cases cochées :

- [ ] **Le scan est bloqué par le pare-feu** (étape 2 : ports `filtered`, aucun `open`
      exploitable, l'attaquant ne trouve rien)
- [ ] **L'alerte est trouvée dans Kibana** avec son **IP source** et son **heure**
      (`@timestamp` cohérent avec le `date` de l'étape 1) — capture ou KQL à l'appui
- [ ] **Une règle de blocage est en place** — IPS drop OU règle firewall — et tu as
      **documenté ton choix** (voie A ou B, pourquoi, ce que ça coûte)
- [ ] **Le 2e scan confirme le blocage** (drop IPS visible, ou IP blacklistée dans le log
      firewall)
- [ ] **Tu sais raconter la boucle complète** à voix haute :
      *« j'ai attaqué depuis mon poste, le pare-feu a bloqué, Suricata a détecté, l'alerte
      est remontée dans mon SIEM, je l'ai analysée, j'ai écrit une règle, le 2e scan est
      mort. »*

## Les 4 cours dans ce seul projet

| Cours | Ce qu'il apporte ICI | La preuve à l'écran |
|---|---|---|
| **Cours 0 — Fondations (Proxmox)** | La VM OPNsense **tourne dessus** — le pare-feu est une machine virtuelle sur ton hyperviseur. Sans virtualisation, pas de pare-feu à héberger. | La VM OPNsense dans l'inventaire Proxmox |
| **Cours 1 — Ansible (IaC)** | L'**infra provisionnée** et reproductible : les segments réseau, les zones firewall, tout est décrit en code. | `pve-firewall compile`, les rôles de zone |
| **Cours 2 — ELK (SIEM)** | L'**alerte visible** : sans le SIEM, l'attaque resterait invisible dans un onglet OPNsense. Kibana la garde et la corrèle. | L'alerte Suricata dans `logstash-syslog-*` |
| **Cours 3 — Sécurité** | Le **pare-feu + l'IDS + la réaction** : détecter, bloquer, et fermer la porte. La défense en profondeur. | Le scan `filtered`, la règle de blocage, le 2e scan mort |

## Et après ?

Tu viens de jouer la boucle complète de la sécurité, **de bout en bout**, sur une infra
que tu as construite toi-même. Regarde le chemin : au premier chapitre du cours 0, tu ne
savais peut-être pas ce qu'est un hyperviseur. Aujourd'hui, tu as un **datacenter
miniature** — virtualisé, automatisé, observé, défendu — et tu sais l'**attaquer et le
défendre**. Ce ne sont pas quatre compétences séparées : c'est un métier. Plusieurs,
même. Et ce lab est ton **portfolio vivant**.

La suite t'appartient : orchestration (K3S), CI/CD (avec ton GitLab), haute
disponibilité, VPN d'accès… Tu as maintenant le socle pour tout ça.

Bravo. Vraiment.

Correction : [`correction/attaque.sh`](correction/attaque.sh).
