# Chapitre 3 — TLS partout : ta propre autorité : script vidéo

> Durée cible : ~35 min. Prérequis : chapitre 2 (Elasticsearch mono-nœud en http).
> Rôle complet : `../ansible-extraits/roles/elk_certs/`. Commandes dans `demo.sh`.

## 1. Le concept (6 min)

**À dire** : « Ta bibliothèque va bientôt contenir TOUS tes journaux : logs
d'authentification, adresses IP, peut-être des secrets qui traînent dans une ligne de
log. C'est la pièce la plus sensible du lab. Elle mérite une porte qui ferme — c'est
TLS, le "cadenas" de HTTPS. »

**Trois mots, une analogie — le notaire** :
- La **CA** (autorité de certification) : le notaire. Elle appose un tampon.
- Le **certificat** : un document tamponné par le notaire — « cette machine est bien
  elastic-1 ».
- La **clé privée** : la preuve que tu es le propriétaire du document (jamais partagée).

« Le génie du système : quiconque connaît le tampon du notaire (la CA) peut vérifier un
document **sans appeler le notaire**. »

**Chiffré vs chiffré-ET-vérifié** : « HTTPS fait deux choses : chiffrer (personne ne lit)
ET authentifier (tu parles bien à la bonne machine). On va voir les deux séparément. »

## 2. Démo guidée (12 min)

**À montrer** : déployer `elk_certs` (recopié dans l'arbre, ajouté au play elk.yml après
elasticsearch). Puis, sur la VM :

```bash
# AVANT : ES parlait http. Maintenant il exige TLS.
curl http://localhost:9200            # → échec / connection reset
curl -k -u elastic:MDP https://localhost:9200   # chiffré, mais -k = "je ne vérifie pas" (aveu)
curl --cacert /etc/elasticsearch/certs/ca/ca.crt -u elastic:MDP https://localhost:9200  # chiffré ET vérifié
```

**À dire** : « Le `-k`, c'est un aveu : "chiffre, mais je ne vérifie pas à qui je parle".
Pratique pour un test, interdit en vrai. Avec `--cacert`, tu donnes le tampon du notaire :
curl vérifie que le certificat descend bien de TA CA. Voilà la différence entre "chiffré"
et "chiffré et de confiance". » Récupérer `ca.crt` sur le poste (on en aura besoin pour
Logstash, Kibana, Filebeat).

## 3. Encart vrai matériel (2 min)

**À filmer** : sur l'infra réelle, la même CA signe Elasticsearch, Kibana, GitLab ET le
coffre-fort Vault.

**À dire** : « Une seule autorité pour tout le lab. Un seul tampon à faire confiance —
importé une fois dans le navigateur, et tous les services internes deviennent verts. »

## 4. 💥 La panne du vrai monde (7 min)

**Mise en scène** : « L'erreur que j'ai réellement faite en montant ce cluster, et qui
m'a coûté une soirée. »

**Le récit (réel)** : « À l'origine, le rôle de certificats tournait sur CHAQUE nœud — et
chacun générait SA PROPRE CA. Résultat : le nœud A avait un tampon, le nœud B un autre.
Quand ils ont voulu se parler en TLS : `CertPathValidatorException: Path does not chain
with any of the trust anchors`. Traduction : "ce certificat n'a pas été tamponné par un
notaire que je connais". Le cluster est resté bloqué —
`master_not_discovered_exception`, santé 503 — jusqu'à ce que je comprenne. »

**On la rejoue (mono-nœud)** :
```bash
# CASSER : régénérer une DEUXIÈME CA et re-signer un cert avec elle
rm /etc/elasticsearch/certs/ca.zip
# ... relancer certutil ca puis signer un cert kibana-logstash avec la NOUVELLE CA
# OBSERVER : comparer les empreintes des deux CA
openssl x509 -in /etc/elasticsearch/certs/ca/ca.crt -noout -fingerprint -sha256
# (l'ancienne, notée avant, était différente → deux mondes étrangers)
```

**Morale (à l'écran, en gras)** : « Une PKI = **UNE** autorité. Si deux machines doivent
se faire confiance, leurs certificats descendent de la **même** CA. Et pour le vérifier,
compare les **empreintes** (`fingerprint`), jamais les noms de fichiers : deux fichiers
`ca.crt` peuvent être deux univers qui ne se reconnaîtront jamais. »

## 5. Annonce du TP (1 min)

**À dire** : « À toi : inspecte ton certificat (que contient-il vraiment ?), ajoute-lui un
nom alternatif, régénère-le SANS toucher à la CA, et prouve que l'empreinte de ta CA n'a
pas bougé. 20 minutes. Au prochain chapitre : le centre de tri — Logstash. »
