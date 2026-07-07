# Correction chapitre 3 — Les règles, dans l'ordre

À créer dans **Firewall > Rules > LAN**, puis **Apply changes**. L'ordre (de haut en bas)
est **essentiel** : OPNsense applique la première règle qui matche (*first match wins*).

## Ordre final des règles (LAN)

| # | Action | Source  | Destination      | Port | Description             |
|---|--------|---------|------------------|------|-------------------------|
| 1 | **Pass**  | LAN net | `10.10.99.14`       | `5601` | `LAN -> Kibana (autorise)` |
| 2 | **Block** | LAN net | `10.10.99.0/24`     | *any* | `LAN -> segment ELK (bloque le reste)` |
| 3 | *(défaut)* | LAN net | any | any | règle par défaut « allow LAN to any » (Internet) — laissée telle quelle |

> La règle 1 doit être **au-dessus** de la règle 2. La règle par défaut d'OPNsense
> (« Default allow LAN to any ») reste **sous** ces deux-là : elle laisse le LAN sortir sur
> Internet, mais ne s'applique **jamais** au segment ELK, déjà traité par les règles 1 et 2.

## Détail des règles

### Règle 1 — Pass Kibana (l'exception précise, EN HAUT)

- Action : **Pass**
- Interface : **LAN** — Direction : **in** — Protocol : **TCP**
- Source : **LAN net**
- Destination : **Single host** → `10.10.99.14`
- Destination port range : **5601** à **5601**
- Description : `LAN -> Kibana (autorise)`

### Règle 2 — Block segment ELK (le général, JUSTE EN DESSOUS)

- Action : **Block**
- Interface : **LAN** — Direction : **in** — Protocol : **any**
- Source : **LAN net**
- Destination : **Network** → `10.10.99.0/24`
- Destination port : **any**
- Description : `LAN -> segment ELK (bloque le reste)`

## Pourquoi cet ordre (rappel)

Un paquet du LAN vers `10.10.99.14:5601` matche la **règle 1** → il passe.
Un paquet du LAN vers `10.10.99.11:9200` (Elasticsearch) ne matche **pas** la règle 1
(mauvaise IP et mauvais port), descend, matche la **règle 2** → il est bloqué.
Un paquet du LAN vers Internet (`8.8.8.8`) ne matche ni 1 ni 2, descend, matche la règle
par défaut → il sort. **Le moindre privilège : on n'a ouvert que ce qui est nécessaire.**

Si on inversait 1 et 2, le trafic vers Kibana matcherait le Block en premier → Kibana
serait injoignable. C'est tout l'enjeu du *first match*.

## Test de validation

```sh
# Depuis une VM du LAN :
curl -k https://10.10.99.14:5601              # Kibana : répond (login page)
curl -k --max-time 5 https://10.10.99.11:9200 # Elasticsearch : timeout (bloqué)
ping -c 3 8.8.8.8                             # Internet : OK (règle par défaut intacte)
```
