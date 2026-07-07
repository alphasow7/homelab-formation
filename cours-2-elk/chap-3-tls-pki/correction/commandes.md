# Correction TP chapitre 3

```bash
CERTS=/etc/elasticsearch/certs

# 1. Inspecter le cert du nœud
openssl x509 -in $CERTS/elastic-1/elastic-1.crt -noout -text | \
  grep -A1 "Subject Alternative Name"     # les SAN
openssl x509 -in $CERTS/elastic-1/elastic-1.crt -noout -issuer -dates

# 2. Empreinte de LA CA (à noter)
openssl x509 -in $CERTS/ca/ca.crt -noout -fingerprint -sha256
#   ex : sha256 Fingerprint=AB:CD:...

# 3. Régénérer le cert du nœud avec un SAN en plus, SANS refaire la CA
rm -f $CERTS/elastic-1.zip
rm -rf $CERTS/elastic-1
/usr/share/elasticsearch/bin/elasticsearch-certutil cert --silent --pem \
  --ca-cert $CERTS/ca/ca.crt --ca-key $CERTS/ca/ca.key \
  --name elastic-1 \
  --dns elastic-1 --dns elastic.lab.local --dns localhost \
  --ip 10.10.99.11 --ip 127.0.0.1 \
  --out $CERTS/elastic-1.zip --days 1095
unzip -o $CERTS/elastic-1.zip -d $CERTS
systemctl restart elasticsearch

# 4a. Le nouveau SAN est là
openssl x509 -in $CERTS/elastic-1/elastic-1.crt -noout -text | grep elastic.lab.local

# 4b. L'empreinte de la CA n'a PAS bougé (on n'a signé que le cert)
openssl x509 -in $CERTS/ca/ca.crt -noout -fingerprint -sha256
#   → identique à l'étape 2. C'est la preuve qu'on a réutilisé LA CA.
```

**La leçon** : régénérer un certificat ≠ régénérer la CA. Tant que la CA (le tampon du
notaire) ne change pas, tous les certs qu'elle a signés — présents et futurs — restent de
confiance les uns pour les autres.
