# Checklist d'hygiène des secrets (10 points)

À dérouler pour **chaque nouvelle machine ou service** du lab. Garde-la sous la main : elle
vaut pour toutes tes futures installs.

- [ ] **1. Mot de passe par défaut changé** — dès que « ça marche », avant tout le reste.
      Aucun `admin/admin`, `root/opnsense`, `elastic/changeme` ne survit à la première minute.
- [ ] **2. Mot de passe fort** — long, unique par service (pas le même partout), généré
      aléatoirement plutôt que choisi.
- [ ] **3. Changement qui PERSISTE** — passé par le système de config (pas d'édition à la
      main écrasée au boot) ; validé par un reboot-test quand le système a une mémoire.
- [ ] **4. Secret vaulté** — chaque secret sensible dans l'ansible-vault (préfixe `vault_`),
      **chiffré et versionné**, jamais en clair dans le repo ni sur un post-it.
- [ ] **5. `.vault_pass` protégé** — dans `.gitignore`, jamais committé
      (`git check-ignore ansible/.vault_pass`).
- [ ] **6. CA interne importée** — dans le trousseau du navigateur/OS, une fois, pour ne plus
      cliquer « Accepter le risque » et garder les vraies alertes rouges significatives.
- [ ] **7. Rotation planifiée** — un secret a une durée de vie ; le faire tourner
      périodiquement et **immédiatement** après toute fuite suspectée.
- [ ] **8. MFA / 2FA activé** si le service le propose (GUI d'admin, GitLab, etc.).
- [ ] **9. Accès distant restreint** — pas de login root distant en mot de passe seul ;
      clés SSH, comptes nominatifs, et surface d'écoute limitée aux réseaux nécessaires.
- [ ] **10. Inventaire tenu à jour** — la liste écrite des services et de leurs comptes ;
      on ne protège (ni ne fait tourner) que ce qu'on a recensé.
