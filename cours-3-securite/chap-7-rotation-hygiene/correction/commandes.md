# Correction TP chapitre 7 — audit d'hygiène

## 1. Auditer les comptes par défaut

Aucun outil : on essaie de se connecter avec le défaut, s'il passe → jamais changé.

| Service | Défaut d'usine | Test rapide | État attendu après TP |
|---|---|---|---|
| OPNsense | `root/opnsense` | login GUI/console | **roté + vaulté** |
| Kibana / elastic | `elastic/changeme` | login Kibana | roté + vaulté (cours 2) |
| PBS | `root@pam` défaut | UI :8007 | roté + `vault_pbs_root_password` |
| GitLab | `root` initial | login web | roté + `vault_gitlab_root_password` |
| Proxmox | selon install | UI :8006 | mot de passe fort |

Écris ta propre liste : c'est l'étape qui compte.

## 2. Roter OPNsense (proprement) et le vaulter

### Changer via le système de config (persiste)

Chemin GUI (le plus simple) : `System ▸ Access ▸ Users ▸ root ▸ nouveau mot de passe ▸ Save`.
Le Save appelle `write_config()` → gravé sur disque.

Chemin console (tcsh, tout dans `sh -c`), script PHP qui finit par `write_config()` :

```php
<?php
require_once("config.inc");
require_once("util.inc");
$new = "MDP-FORT";
foreach ($config['system']['user'] as $i => $u) {
    if ($u['name'] === 'root') {
        local_user_set_password($config['system']['user'][$i], $new);
        local_user_set($config['system']['user'][$i]);
    }
}
write_config("rotation mot de passe root");
echo "OK\n";
```

### Reboot-test (la preuve)

```bash
qm reboot 600        # depuis Proxmox, ~90 s
# se reconnecter : l'ancien "opnsense" échoue, le nouveau passe → persistance OK
```

### Ranger dans l'ansible-vault

```bash
cd cours-1-ansible/ansible
ansible-vault edit inventory/group_vars/opnsense/vault.yml
#   vault_opnsense_root_password: "MDP-FORT"

# vérifier :
ansible-vault view inventory/group_vars/opnsense/vault.yml | grep vault_opnsense_root_password
```

## 3. Importer la CA interne

```bash
# récupérer la CA du cours 2 (sur le nœud ELK)
scp root@elastic-1:/etc/elasticsearch/certs/ca/ca.crt ~/homelab-ca.crt

# vérifier que c'est une racine auto-signée
openssl x509 -in ~/homelab-ca.crt -noout -subject -issuer   # subject == issuer
```

Import selon la plateforme :

```bash
# macOS (trousseau système)
sudo security add-trusted-cert -d -r trustRoot \
  -k /Library/Keychains/System.keychain ~/homelab-ca.crt

# Linux (Debian/Ubuntu)
sudo cp ~/homelab-ca.crt /usr/local/share/ca-certificates/homelab-ca.crt
sudo update-ca-certificates

# Windows (admin)
certutil -addstore -f "Root" homelab-ca.crt
```

Firefox : `Paramètres ▸ Vie privée & sécurité ▸ Certificats ▸ Autorités ▸ Importer`
→ cocher « Confirmer cette AC pour identifier des sites web ».

### Vérifier le vert

Rafraîchir un service interne (redémarrer Firefox après import) :
`https://localhost:5601` (Kibana), `https://10.10.30.12:8200` (Vault),
`https://localhost:8443` (OPNsense) → cadenas **vert**, plus d'« Accepter le risque ».
Un seul import couvre tous les services signés par cette CA.
