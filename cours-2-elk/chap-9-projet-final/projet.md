# Projet final du cours 2 — L'aiguille dans la botte de foin

**Temps cible : moins de 10 minutes, chronomètre en main.** C'est l'examen de sortie du
cours 2. Pas de nouvelle notion — tout ce que tu as branché (Elasticsearch, Logstash,
Filebeat, Kibana, syslog) va enfin servir à ce pour quoi on le fait : **voir un problème
sans se connecter à la machine.**

## La règle du jeu

Un script (`correction/generateur-incident.sh`) va provoquer **un incident discret** —
aléatoire, quelque part sur ton lab. Tu ne sauras PAS lequel. Ta mission : dire **QUOI**
(quel type d'incident), **OÙ** (quelle machine) et **QUAND** (l'heure approximative), en
**moins de 10 minutes**.

**L'interdit absolu** : tu n'as PAS le droit de te connecter en SSH aux VMs avant d'avoir
ta réponse. Pas de `ssh`, pas de `qm`, pas de GUI Proxmox. **Uniquement Kibana.** C'est
tout l'intérêt de l'examen : prouver que ton SIEM te suffit pour diagnostiquer à distance,
comme un analyste dans un vrai centre de supervision. Si tu te connectes à la machine pour
« vérifier », tu as triché — et surtout, tu t'es privé de la seule compétence que ce cours
t'a apprise.

## Lancer le générateur

Le script tourne sur **ton poste** et cible une VM du lab via **ansible ad-hoc**. Tu le
lances sans regarder ce qu'il fait — c'est volontaire : tu dois découvrir l'incident dans
Kibana, pas dans le terminal.

```bash
cd cours-2-elk/chap-9-projet-final
./correction/generateur-incident.sh
```

Le script choisit UN scénario au hasard (1 à 4), l'exécute, note l'heure de départ, et
range la solution dans `/tmp/solution-NEPASREGARDER.txt`. **Ne l'ouvre pas** avant d'avoir
rendu ta réponse — c'est ton juge, pas ton aide.

Attends ~1 minute que les logs remontent (Filebeat → Logstash → ES), puis ouvre Kibana et
**démarre ton chrono**.

## Les 4 scénarios possibles (tu ne sais pas lequel est tombé)

1. **Un service tué** — un service systemd est arrêté sur une VM. Il cesse d'émettre des
   logs ; parfois un log d'arrêt subsiste juste avant le silence.
2. **Un brute-force SSH** — une rafale de connexions SSH ratées s'abat sur une VM. Pic
   soudain de logs d'authentification.
3. **Un disque qui se remplit** — une VM se met à manquer d'espace disque et le crie dans
   ses logs à intervalle régulier.
4. **Des erreurs 500 nginx** — le serveur web se met à renvoyer des erreurs serveur. Pic
   de codes 5xx dans les logs nginx.

> **Prérequis du scénario 4** : les codes 5xx vivent dans l'`access.log` de nginx, pas
> dans journald. Il faut donc l'input **filestream nginx** de `dns-proxy` (le TP du
> chapitre 6, champ `log_source: nginx`). Si tu ne l'as pas posé, refais ce TP avant —
> sinon ce scénario reste invisible dans Kibana.

## La méthode d'investigation (large → étroit)

Ne cherche pas l'aiguille à la loupe dès la première seconde. Un bon analyste part LARGE
et resserre :

1. **QUAND** — d'abord le temps. Ouvre ton dashboard "Santé du lab" (chap. 8), fenêtre
   "Last 30 minutes". Repère **l'anomalie temporelle** : un pic de volume ? un pic de
   sévérité (le camembert `error`/`warning` qui gonfle) ? un creux (une couleur qui
   disparaît) ? Note l'heure.
2. **OÙ** — quelle machine. Le panneau "volume par `host.name`" ou un filtre `host.name`
   te dit sur quelle VM ça se passe.
3. **QUOI** — quel service, quel événement. Descends dans **Discover** : filtre sur
   l'heure + la machine, regarde `journald.unit`, `process.name`, le `message`. Lis les
   lignes. C'est là que l'incident se nomme.

Chaque resserrement est un filtre KQL. Garde-les : ils sont ta preuve.

## Critères de réussite

Rends ta réponse AVANT d'ouvrir la solution :

- [ ] **La machine** (`host.name`) exacte
- [ ] **Le service / le type d'incident** (nom du service, ou "brute-force SSH", "disque
      plein", "erreurs 500")
- [ ] **L'heure** approximative de début (à quelques minutes près)
- [ ] **Les requêtes KQL** que tu as utilisées pour y arriver (capture d'écran ou
      copier-coller — c'est la partie "je sais faire", pas juste "j'ai deviné")
- [ ] Le tout en **moins de 10 minutes**, **sans jamais t'être connecté à une VM**

Puis, et seulement puis : `cat /tmp/solution-NEPASREGARDER.txt` pour te corriger.

## Corrigé — comment chaque scénario se manifeste dans Kibana

<details>
<summary>Scénario 1 — Service tué (nginx sur dns-proxy)</summary>

Sur "Santé du lab", la couleur `dns-proxy` **maigrit ou disparaît** du panneau volume
(nginx ne loggue plus). Dans le top des unités, `nginx.service` **chute**. Signal
révélateur : dans Discover, `host.name : "dns-proxy" and journald.unit : "nginx.service"`
montre un **log d'arrêt** (`Stopped ...` / `Deactivated`) puis **plus rien**. QUAND = juste
après ce dernier log. QUOI = nginx arrêté. OÙ = dns-proxy.

Piège : une absence de logs est plus dure à voir qu'un pic. C'est pour ça qu'on regarde le
top des unités et les creux, pas seulement les pics.
</details>

<details>
<summary>Scénario 2 — Brute-force SSH (sur le bastion)</summary>

**Pic de volume** franc sur la machine ciblée, sévérité qui monte. Dans Discover :
`process.name : "sshd"` (ou `journald.unit : "ssh.service"`) sur la fenêtre du pic →
une **rafale** de `Failed password` / `Invalid user baduser` / `authentication failure`,
toutes en quelques secondes. QUAND = la salve. QUOI = brute-force SSH. OÙ = la machine du
pic (le bastion). Le nombre de tentatives rapprochées est la signature.
</details>

<details>
<summary>Scénario 3 — Disque qui se remplit (sur elastic-1)</summary>

Pas de métriques dans ce cours : l'incident se voit via un **logger explicite** répété.
Dans Discover, cherche le message : `message : "disk usage high"` (ou filtre la sévérité
`warning`/`error` sur la fenêtre). Plusieurs lignes identiques à intervalle régulier sur
`host.name : "elastic-1"`. QUAND = première occurrence. QUOI = disque qui se remplit. OÙ =
elastic-1. La répétition régulière d'un même message d'alerte est la signature.
</details>

<details>
<summary>Scénario 4 — Erreurs 500 nginx (sur dns-proxy)</summary>

Ton dashboard "nginx — dns-proxy" (TP chap. 8) est fait pour ça : le **camembert des codes
de réponse** voit une part **`500`** apparaître là où il n'y avait que du `200`. Dans
Discover : `log_source : "nginx" and response >= 500` → les requêtes fautives, avec l'heure
et l'URL. QUAND = début du pic 5xx. QUOI = erreurs serveur nginx. OÙ = dns-proxy.
</details>

## Et après ?

Tu viens de diagnostiquer une panne **sans toucher la machine**. C'est un vrai métier — ça
s'appelle l'analyse SOC. Tu sais désormais VOIR ton infra. Au **cours 3**, on apprend à la
DÉFENDRE : pare-feu, détection d'intrusion, coffre-fort à secrets — et toutes ces alertes
de sécurité viendront atterrir ICI, dans ton SIEM. Les yeux d'abord, les boucliers ensuite.
À très vite.

Générateur d'incident : [`correction/generateur-incident.sh`](correction/generateur-incident.sh).
