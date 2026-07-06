# Quiz chapitre 6 — Snapshots & sauvegardes

## Question 1 — Quelle est LA différence fondamentale entre snapshot et sauvegarde ?

- A. Le snapshot est plus lent à créer
- B. Le snapshot vit sur le même disque que la VM ; la sauvegarde est une copie indépendante ✅
- C. La sauvegarde ne fonctionne que sur les templates
- D. Il n'y en a pas, ce sont deux noms pour la même chose

**Explication** : si le disque meurt, les snapshots meurent avec — seule la sauvegarde
survit à la panne matérielle.

## Question 2 — Quand prendre un snapshot ?

- A. Une fois par an
- B. Jamais, c'est dangereux
- C. Avant chaque manipulation risquée (mise à jour, changement de config…) ✅
- D. Uniquement quand la VM est éteinte

**Explication** : c'est le filet du trapéziste — une commande, dix secondes, et un
`rollback` te ramène avant la bêtise.

## Question 3 — Que veut dire `--mode snapshot` dans vzdump ?

- A. La sauvegarde ne contient que le snapshot le plus récent
- B. La VM est éteinte pendant la sauvegarde
- C. La VM reste allumée pendant la sauvegarde ✅
- D. La sauvegarde est incrémentale

**Explication** : vzdump fige un instantané interne et copie à partir de lui — le service
continue de tourner pendant la copie.

## Question 4 — Pourquoi restaurer une sauvegarde qu'on n'a PAS besoin de restaurer ?

- A. Pour libérer de l'espace disque
- B. Parce qu'une sauvegarde jamais restaurée n'est pas prouvée — on teste AVANT le crash ✅
- C. Pour mettre à jour le fichier de sauvegarde
- D. C'est inutile, si vzdump n'affiche pas d'erreur c'est bon

**Explication** : la panne du chapitre — c'est en restaurant « un mardi tranquille »
qu'on découvre les mauvaises surprises, pas le jour du désastre.

## Question 5 — Que fait `qmrestore backup.vma.zst 9198` si la VM 9101 d'origine existe encore ?

- A. Elle écrase la VM 9101
- B. Elle échoue toujours
- C. Elle crée une NOUVELLE VM 9198 depuis la sauvegarde, sans toucher à 9101 ✅
- D. Elle fusionne les deux VMs

**Explication** : restaurer vers un nouvel id est le moyen sûr de tester une sauvegarde
sans risquer l'original — c'est exactement ce que fait la démo.

---

**Réponses : 1-B, 2-C, 3-C, 4-B, 5-C.**
