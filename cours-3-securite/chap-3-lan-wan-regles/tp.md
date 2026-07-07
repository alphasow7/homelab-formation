# TP chapitre 3 — Le moindre privilège en action

**Temps cible : 25 min.** Dans le GUI d'OPNsense (`https://192.168.99.1`, ou via ton
tunnel SSH) + une VM du LAN pour tester.

## Contexte

Ton LAN a le droit d'aller sur Internet (défaut d'OPNsense) et tu as vu au cours de la
démo qu'il peut joindre Kibana. Mais dans les faits, **le LAN n'a besoin de rien d'autre
sur le segment ELK** : ni Elasticsearch (9200), ni Logstash, ni SSH direct sur les nœuds.
On applique le **moindre privilège** : on ouvre juste Kibana, on ferme le reste du segment
`10.10.99.0/24` depuis le LAN.

## Énoncé

1. **Autorise SEULEMENT Kibana** : une règle `Pass` sur l'interface **LAN**, source
   **LAN net**, destination **`10.10.99.14`**, port **`5601`**.
2. **Bloque le reste du segment ELK** : une règle `Block` sur l'interface **LAN**, source
   **LAN net**, destination **`10.10.99.0/24`** (tout le segment), tous ports.
3. **Range les deux règles dans le bon ordre** (c'est le cœur du TP — voir les indices) et
   fais **Apply changes**.
4. **Teste** depuis une VM du LAN :
   - Kibana joignable : `curl -k https://10.10.99.14:5601` → répond ;
   - un autre hôte/port du segment bloqué : `curl -k --max-time 5 https://10.10.99.11:9200`
     → **timeout / connexion refusée** (10.10.99.11 = un nœud Elasticsearch).

## Critères de réussite

- [ ] `https://10.10.99.14:5601` (Kibana) répond depuis le LAN
- [ ] `https://10.10.99.11:9200` (ES) **ne répond pas** depuis le LAN (timeout)
- [ ] Dans **Firewall > Rules > LAN**, la règle **Pass Kibana** est **au-dessus** de la
      règle **Block segment ELK**
- [ ] Internet fonctionne toujours depuis le LAN (`ping 8.8.8.8`) — tu n'as bloqué que le
      segment ELK, pas tout

## Indices

<details>
<summary>Indice 1 — l'ordre des règles compte : « first match »</summary>

OPNsense évalue les règles d'une interface **de haut en bas** et **s'arrête à la première
qui matche** (*first match wins*). Si ta règle `Block 10.10.99.0/24` est **au-dessus** de
ton `Pass ...14:5601`, le trafic vers Kibana matche d'abord le block → Kibana est bloqué,
alors que tu voulais l'autoriser. L'ordre n'est pas décoratif : il change le résultat.
</details>

<details>
<summary>Indice 2 — la bonne structure : allow précis, puis block large</summary>

Le motif du moindre privilège, c'est **« autorise l'exception d'abord, bloque le général
ensuite »** :

1. en haut : `Pass` LAN net → `10.10.99.14:5601` (l'exception précise, Kibana) ;
2. juste en dessous : `Block` LAN net → `10.10.99.0/24` (le général, tout le reste du
   segment).

Le paquet vers `10.10.99.14:5601` matche la règle 1 et passe. Tout autre paquet vers le
segment ne matche pas la règle 1 (mauvais port ou mauvaise IP), descend, et matche la
règle 2 : bloqué. Glisse la règle Pass au-dessus du Block dans le GUI (poignée de
déplacement), puis **Apply**.
</details>

Correction : [`correction/regles.md`](correction/regles.md).
