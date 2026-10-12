# TP chapitre 3 — Inspecte et régénère ton certificat

**Temps cible : 20 min.** Sur la VM elastic-1 (ssh via bastion).

## Énoncé

1. **Inspecte** le certificat du nœud :

```bash
openssl x509 -in /etc/elasticsearch/certs/elastic-1/elastic-1.crt -noout -text
```

   Trouve : les **SAN** (Subject Alternative Names — les noms/IP couverts), l'**émetteur**
   (Issuer — ta CA), les **dates** de validité.
2. **Note l'empreinte de LA CA** (tu vas la comparer après) :

```bash
openssl x509 -in /etc/elasticsearch/certs/ca/ca.crt -noout -fingerprint -sha256
```

3. **Ajoute un SAN** : régénère le certificat du nœud avec un nom DNS supplémentaire
   `elastic.lab.local` — **sans toucher à la CA** (tu la réutilises pour signer).
4. **Prouve** que le nouveau cert couvre bien `elastic.lab.local` (re-`openssl ... -text`),
   et surtout : **l'empreinte de la CA n'a pas changé** (re-commande de l'étape 2).

## Critères de réussite

- [ ] Tu sais lire les SAN, l'émetteur et les dates d'un certificat
- [ ] Le nouveau cert du nœud liste `elastic.lab.local` dans ses SAN
- [ ] L'empreinte SHA-256 de la CA est **identique** avant/après (tu n'as régénéré que le cert)

## Indices

<details>
<summary>Indice 1 — régénérer un cert sans refaire la CA</summary>

`elasticsearch-certutil cert --ca-cert .../ca/ca.crt --ca-key .../ca/ca.key --name elastic-1
--dns elastic-1 --dns elastic.lab.local --dns localhost --ip 10.10.99.11 ...` : tu passes
LA CA existante en `--ca-cert/--ca-key` → elle signe, elle n'est pas recréée. Supprime
d'abord l'ancien zip du nœud pour lever le `creates`.
</details>

<details>
<summary>Indice 2 — tester le nouveau nom</summary>

Ajoute `elastic-1 10.10.99.11` et `elastic.lab.local` dans le rôle DNS (cours 1) si ce
n'est pas déjà fait, puis : `curl --cacert ca.crt https://elastic.lab.local:9200`. Le nom
doit être dans les SAN du cert, sinon la vérification échoue (« Hostname mismatch »).
</details>

Correction : [`correction/commandes.md`](correction/commandes.md).
