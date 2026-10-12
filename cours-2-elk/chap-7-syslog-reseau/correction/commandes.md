# Correction TP chapitre 7 — Le syslog du bastion dans ELK

## 1. (Si besoin) installer rsyslog — LA subtilité du TP

Ces Debian minimales n'ont pas rsyslog par défaut (cf. panne Filebeat du chap 6). Si le
service n'existe pas, on l'installe. Le segment du bastion n'a pas Internet → masquerade
temporaire sur le nœud (réflexe cours 1) :

```bash
# --- SUR LE NŒUD PROXMOX (root) : ouvrir le NAT le temps de l'apt ---
iptables -t nat -A POSTROUTING -s 10.10.99.0/24 -o vmbr0 -j MASQUERADE

# --- SUR LE BASTION (root) ---
apt update && apt install -y rsyslog

# --- SUR LE NŒUD PROXMOX : refermer le NAT ---
iptables -t nat -D POSTROUTING -s 10.10.99.0/24 -o vmbr0 -j MASQUERADE
```

## 2. Configurer le forward syslog (sur le bastion, root)

```bash
cat > /etc/rsyslog.d/90-forward-elk.conf <<'EOF'
*.* @10.10.99.14:5514
EOF

systemctl restart rsyslog
```

Rappel : `@` = **UDP**, `@@` = **TCP**. Ici UDP, comme à la démo.

## 3. Provoquer une tentative SSH ratée (sur le bastion)

```bash
ssh mauvaisuser@localhost
# mot de passe bidon, ou Ctrl-C : le but est que le SSH REFUSE.
```

Vérification locale que l'échec s'écrit bien côté bastion :

```bash
journalctl -u ssh --no-pager | tail       # ou -u sshd selon la VM
# → ligne du type "Failed password for invalid user mauvaisuser" / "Invalid user mauvaisuser"
```

## 4. Retrouver le log dans Kibana

Kibana → **Discover** → data view `logstash-*` (elle couvre `logstash-syslog-*`) →
requête **KQL** :

```
syslog_hostname : "bastion" and syslog_program : "sshd" and message : "mauvaisuser"
```

`syslog_hostname` vient de l'en-tête syslog (le hostname du bastion), pas de l'adresse
de l'expéditeur : c'est le grok ajouté à la démo qui l'extrait. Variantes utiles si
`mauvaisuser` n'apparaît pas tel quel :

```
syslog_hostname : "bastion" and message : "Failed"
syslog_hostname : "bastion" and message : "invalid user"
```

Si le champ n'existe pas dans Kibana : Stack Management → Data Views → `logstash-*` →
**Refresh field list**. Si les documents portent `_syslogparsefailure` : la ligne ne
colle pas au motif grok — lis `message` tel quel et compare.

## 5. Diagnostic si rien n'arrive (les 3 maillons, dans l'ordre)

```bash
# 1. Réseau/pare-feu : le 5514 est-il ouvert bastion -> kibana-logstash ?
#    (un logger qui part mais n'arrive jamais = souvent un port bloqué)
logger -p auth.warning "TEST-SYSLOG-depuis-bastion"

# 2. Écoute de Logstash — À FAIRE SUR kibana-logstash : tcp ET udp attendus.
ss -tulnp | grep 5514

# 3. Format : rsyslog émet du RFC 3164/5424 par défaut → maillon bon d'office avec rsyslog.

# 4. Parsing : le document existe mais sans syslog_hostname ? Cherche le tag
#    _syslogparsefailure dans Kibana — le grok n'a pas reconnu la ligne.
```
