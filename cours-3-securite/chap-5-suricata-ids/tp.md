# TP chapitre 5 — Un ruleset de plus, une alerte, et la retrouver dans Kibana

**Temps cible : 25 min.** Tu pars d'un Suricata déjà actif sur le WAN en mode détection
(la démo). Tu vas : **ajouter un ruleset abuse.ch supplémentaire**, **vérifier que les
règles sont vraiment chargées** (l'effet, pas le "OK"), **déclencher une alerte de test**
par un scan, et la **retrouver dans Kibana** filtrée par le hostname OPNsense.

Rappel : pas de rôle Ansible. Tout se fait dans le **GUI OPNsense**, sa **console**, ton
**poste**, et **Kibana**.

## Énoncé

1. **Ajoute un ruleset abuse.ch supplémentaire.**
   Dans le GUI : `Services > Intrusion Detection > Download`. Coche un **abuse.ch** que tu
   n'avais pas encore (ex. `abuse.ch/URLhaus`, ou `abuse.ch/Feodo Tracker` si tu ne
   l'avais pas). Clique **Download & Update**.

2. **Vérifie l'EFFET, pas le message.** Sur la console OPNsense (SSH) :
   - `configctl ids status` → doit être *running*.
   - Compte les règles chargées :
     ```sh
     sh -c "wc -l /usr/local/etc/suricata/rules/*.rules | tail -1"
     ```
     Le total doit avoir **augmenté** (ton ruleset en plus). Si tu vois `0` → tu es tombé
     dans la panne du cours : regarde l'indice 1.

3. **Déclenche une alerte de test.** Depuis ton **poste**, scanne le WAN d'OPNsense :
   ```bash
   sudo nmap -sS -T4 -p 1-1000 192.168.1.36   # adapte l'IP WAN
   ```

4. **Retrouve l'alerte** — d'abord dans OPNsense (`Services > Intrusion Detection >
   Alerts`), puis dans **Kibana** → Discover → index `logstash-syslog-*`, filtrée par le
   hostname OPNsense :
   ```
   syslog_hostname : "OPNsense.internal" and message : "SCAN"
   ```
   (adapte `"OPNsense.internal"` à ce que rapporte réellement le champ hostname de tes
   documents, et `"SCAN"` à un mot présent dans ta signature — ou filtre sur le type
   d'événement `suricata`.)

## Critères de réussite

- [ ] Un ruleset abuse.ch **de plus** est actif, et le **compte de règles a augmenté**
- [ ] Tu sais dire combien de règles sont chargées (un chiffre, pas un "OK")
- [ ] Le scan produit une alerte dans l'**onglet Alerts** d'OPNsense
- [ ] La même alerte remonte dans **Kibana**, filtrée par le hostname OPNsense

## Indices

<details>
<summary>Indice 1 — 0 règle après un "OK" ? L'ordre template reload PUIS update</summary>

C'est LA panne du chapitre. En console, le "Apply" du GUI est une commande séparée : sans
elle, `rule-updater.config` reste vide et l'update ne télécharge rien, tout en répondant
"OK". Le fix, **dans cet ordre** :

```sh
configctl template reload OPNsense/IDS   # = le Apply CLI ; remplit rule-updater.config
configctl ids update                     # maintenant il a la liste -> télécharge + charge
configctl ids start
sh -c "wc -l /usr/local/etc/suricata/rules/*.rules | tail -1"   # doit être > 0
```

`template reload` **AVANT** `update`. Un "OK" n'est pas une preuve : compte les règles.
</details>

<details>
<summary>Indice 2 — Où voir les alertes : onglet Alerts (OPNsense) ET Kibana</summary>

Deux endroits, deux usages :

- **OPNsense** : `Services > Intrusion Detection > Alerts`. La vue "brute", en direct sur
  le pare-feu. Tu y vois la signature (ex. `ET SCAN ...`), la source, la destination.
- **Kibana** : `Discover` → index `logstash-syslog-*`. La vue "SIEM", où l'alerte est
  gardée et corrélable avec le reste. Filtre par le hostname OPNsense :
  `syslog_hostname : "OPNsense.internal"`. Ajoute un mot de la signature
  (`and message : "SCAN"`) pour ne garder que ton alerte de test.

Si rien n'arrive dans Kibana alors que l'onglet Alerts OPNsense montre bien l'alerte : le
problème est dans le **transport syslog** (System > Settings > Logging), pas dans Suricata.
C'est le chaînon export du cours 2 chap 7.
</details>

Correction : [`correction/commandes.md`](correction/commandes.md).
