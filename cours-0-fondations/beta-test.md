# Protocole de bêta-test — Cours 0

> Critère de la spec : **un élève « débutant technique » termine le cours 0 (chapitres
> 2→7) sans aide extérieure.** À valider AVANT le tournage — les textes sont le script
> des vidéos : chaque blocage trouvé ici est une vidéo qu'on ne re-tourne pas.

## Recrutement (action formateur)

**2-3 testeurs**, profil « débutant technique » strict :
- a déjà utilisé un terminal (peut naviguer, lancer une commande) ;
- sait ce qu'est une adresse IP ;
- n'a JAMAIS utilisé Proxmox ni fait de virtualisation sérieuse.

Où : collègues juniors, forums/discords FR homelab, entourage étudiant. Idéalement au
moins 1 sous Windows (chemin A) et 1 avec un vieux PC (chemin B).

## Déroulé

Le testeur suit **uniquement les fichiers écrits** (pas de vidéo — elles n'existent pas
encore) : `labs/lab-cours-0.md` → son chemin → chapitres 2 à 7 dans l'ordre
(script-video.md lu comme un texte de cours + demo.sh + tp.md + quiz.md).

**Règle d'or : interdiction d'aider.** Si le testeur bloque > 20 min, il note le blocage
(verbatim) et a le droit de chercher sur Internet (noter la requête qui a débloqué) —
c'est exactement ce que fera un vrai élève.

## Grille de recueil (par chapitre)

| Champ | Exemple |
|---|---|
| Temps passé | 38 min (cible : 30-45) |
| Bloqué ? où, combien de temps | « étape 4 du TP, 25 min » |
| Verbatim du blocage | « je ne savais pas où trouver l'IP de la VM » |
| Commande qui a échoué (copier-coller) | `qm importdisk ...` → erreur X |
| Question restée sans réponse | « pourquoi gw sans rien après ? » |
| Quiz : score | 4/5 |

## Critères de sortie

- [ ] **Au moins 1 testeur termine le chapitre 7 sans aide extérieure** (critère spec)
- [ ] Aucune commande de demo.sh/correction ne retourne d'erreur chez les testeurs
- [ ] Temps par chapitre ≤ 1,5× la cible pour la majorité des testeurs
- [ ] Tous les blocages > 20 min ont donné lieu à une correction du texte (indice ajouté,
      étape explicitée) — puis re-test du passage corrigé par un des testeurs

## Sortie du bêta-test

1. Compiler les grilles dans `beta-resultats.md` (non versionné public si verbatims
   sensibles).
2. Passe de correction sur les chapitres concernés (commits `fix(cours-0): beta —  …`).
3. GO tournage quand les 4 critères sont verts.
