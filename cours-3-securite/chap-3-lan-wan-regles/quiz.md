# Quiz chapitre 3 — LAN, WAN & premières règles

## Question 1 — Sur OPNsense, l'interface **WAN**, c'est…

- A. Le réseau de tes VMs de confiance
- B. La patte côté monde, branchée vers Internet / la box FAI ✅
- C. Une interface de secours utilisée seulement si le LAN tombe
- D. Le réseau des sauvegardes

**Explication** : WAN = *Wide Area Network*, la patte côté monde (Internet/box). Le LAN
est la patte côté lab, tes machines de confiance. OPNsense est assis entre les deux.

## Question 2 — Par défaut, le pare-feu d'OPNsense…

- A. Autorise tout, dans les deux sens
- B. Bloque tout, dans les deux sens (y compris ta sortie Internet)
- C. Bloque tout ce qui entre par le WAN, autorise ce qui sort du LAN ✅
- D. Bloque le LAN et ouvre le WAN à Internet

**Explication** : le bon défaut, c'est « fermé par défaut côté monde, on ouvre au cas par
cas ». Rien n'entre par le WAN sans autorisation explicite ; le LAN peut sortir.

## Question 3 — Dans l'anatomie d'une règle, que représente le champ **destination** ?

- A. L'action à appliquer (allow ou block)
- B. La machine ou le réseau **où va** le trafic ✅
- C. L'interface physique de la carte réseau
- D. Le nom de la règle

**Explication** : une règle = action + source (d'où ça vient) + destination (où ça va) +
port (quel service) + direction. La destination, c'est la cible du trafic
(ex. `10.10.99.14`).

## Question 4 — Pourquoi mettre le LAN d'OPNsense en `192.168.1.1` quand la box FAI est déjà en `192.168.1.x` casse-t-il le réseau ?

- A. Parce que `192.168.1.1` est une adresse réservée interdite
- B. Parce que le WAN et le LAN annoncent le **même réseau** → le routeur ne sait plus par quelle interface envoyer les paquets ✅
- C. Parce que le DHCP de la box refuse les VMs
- D. Parce qu'OPNsense n'aime pas les adresses en 192.168

**Explication** : deux interfaces revendiquant `192.168.1.0/24`, la table de routage
(`netstat -rn`) a le subnet en double, la route par défaut devient ambiguë. Un routeur
choisit sa sortie d'après le réseau de destination — s'il y en a deux identiques, le choix
est impossible. **Un subnet, un rôle.**

## Question 5 — OPNsense évalue les règles d'une interface « first match ». Concrètement ?

- A. Il applique la règle la plus restrictive du lot
- B. Il applique toutes les règles qui matchent, dans l'ordre
- C. Il lit de haut en bas et s'arrête à la **première règle qui matche** ✅
- D. Il applique la dernière règle de la liste

**Explication** : *first match wins*. Une règle `Block segment` placée **au-dessus** d'un
`Pass Kibana` bloquerait Kibana avant même d'atteindre le Pass. D'où le motif : autorise
l'exception précise d'abord, bloque le général ensuite.

---

**Réponses : 1-B, 2-C, 3-B, 4-B, 5-C.**
