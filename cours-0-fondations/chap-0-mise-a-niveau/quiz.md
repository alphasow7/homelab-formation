# Quiz chapitre 0 — Mise à niveau

**5 questions, une seule bonne réponse par question.** Les réponses sont en bas.

## Question 1 — Clé publique vs clé privée : quel est le rôle de chacune ?

- A. La publique sert à ouvrir, la privée sert à fermer
- B. La publique est le cadenas qu'on distribue partout, la privée est LA clé qui ne quitte jamais ton poste ✅
- C. Les deux doivent être copiées sur le serveur pour que ça marche
- D. Ce sont deux copies de la même clé, l'une de secours

**Explication** : la clé publique (le `.pub`) peut être déposée sur toutes les machines
sans risque, comme un cadenas ; seule la clé privée, gardée sur ton poste, permet d'ouvrir.

## Question 2 — Que fait la commande `ssh-copy-id utilisateur@ip` ?

- A. Elle copie ta clé PRIVÉE sur la machine distante
- B. Elle génère une nouvelle paire de clés sur la machine distante
- C. Elle ajoute ta clé PUBLIQUE dans le fichier `authorized_keys` de la machine distante ✅
- D. Elle supprime le mot de passe du compte distant

**Explication** : `ssh-copy-id` pose ton « cadenas » (la clé publique) dans
`~/.ssh/authorized_keys` de l'autre machine — la clé privée, elle, ne voyage jamais.

## Question 3 — À quoi sert la passerelle (gateway) ?

- A. À attribuer automatiquement les adresses IP
- B. À traduire les noms de domaine en adresses IP
- C. À chiffrer le trafic entre deux machines
- D. À faire sortir le trafic destiné aux machines qui ne sont pas sur ton réseau local ✅

**Explication** : la passerelle est « la sortie du quartier » — dès qu'une machine n'est
pas dans ta « rue », ton trafic passe par elle (chez toi, c'est ta box, visible avec
`ip route` sur la ligne `default via ...`).

## Question 4 — En DHCP, qui attribue son adresse IP à ta machine ?

- A. Le serveur DHCP du réseau (chez toi, ta box), qui lui prête une adresse ✅
- B. Ta machine choisit elle-même une adresse au hasard
- C. Le serveur DNS
- D. Le fournisseur d'accès Internet, une par une, à la main

**Explication** : à son arrivée sur le réseau, la machine demande une adresse et le serveur
DHCP lui en prête une (un « bail »), avec la passerelle et le DNS en prime.

## Question 5 — Que fait la commande `dig +short example.com` ?

- A. Elle teste si example.com répond au ping
- B. Elle interroge l'annuaire DNS et affiche l'adresse IP derrière le nom example.com ✅
- C. Elle télécharge la page d'accueil d'example.com
- D. Elle affiche la passerelle utilisée pour joindre example.com

**Explication** : `dig` pose la question au DNS (« l'annuaire ») et `+short` réduit la
réponse à l'essentiel — l'adresse IP correspondant au nom.

---

**Réponses : 1-B, 2-C, 3-D, 4-A, 5-B.**
