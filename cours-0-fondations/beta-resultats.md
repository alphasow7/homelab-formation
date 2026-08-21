# Résultats du bêta-test — cours 0

> Compilation des grilles renvoyées par les testeurs ([`beta-grille.md`](beta-grille.md)),
> selon le protocole de [`beta-test.md`](beta-test.md). **Ce fichier est anonymisé** :
> testeurs désignés par une lettre, aucun nom ni contact. Les grilles brutes vont dans
> `beta-brut/` (non versionné).
>
> **Statut : 🔲 non démarré** — aucun testeur recruté à ce jour.
> Recrutement : [`beta-recrutement.md`](beta-recrutement.md).

---

## 1. Panel

| Testeur | Chemin | OS / matériel | Date début | Date fin | Terminé sans aide ? |
|---|---|---|---|---|---|
| A | | | | | |
| B | | | | | |
| C | | | | | |

## 2. Critères de sortie (protocole §Critères de sortie)

- [ ] **C1 — Au moins 1 testeur termine le chapitre 7 sans aide extérieure** *(critère spec)*
- [ ] **C2 — Aucune commande de `demo.sh` / `correction/` ne retourne d'erreur chez les testeurs**
- [ ] **C3 — Temps par chapitre ≤ 1,5× la cible pour la majorité des testeurs**
- [ ] **C4 — Tous les blocages > 20 min ont donné lieu à une correction du texte**, puis
      re-test du passage corrigé par un des testeurs

**→ GO tournage uniquement quand les 4 sont verts.**

## 3. Temps par chapitre

Seuil d'alerte = 1,5 × la cible (critère C3).

| Étape | Cible | Seuil | A | B | C | C3 tenu ? |
|---|---|---|---|---|---|---|
| Lab (`labs/lab-cours-0.md`) | 45 min | 68 min | | | | |
| Chap. 2 — Installer Proxmox | 30 min | 45 min | | | | |
| Chap. 3 — Ta première VM | 30 min | 45 min | | | | |
| Chap. 4 — Le réseau Proxmox | 40 min | 60 min | | | | |
| Chap. 5 — Templates & cloud-init | 30 min | 45 min | | | | |
| Chap. 6 — Snapshots & sauvegardes | 35 min | 53 min | | | | |
| Chap. 7 — Projet final | 65 min | 98 min | | | | |
| **Total** | **≈ 4 h 35** | | | | | |

## 4. Blocages consolidés

Un blocage > 20 min = une correction obligatoire (C4). Gravité : 🔴 bloquant (abandon
possible) · 🟠 gênant (perte de temps) · 🟡 friction (confusion passagère).

| # | Chap. | Testeur | Verbatim | Durée | Gravité | Correction apportée | Commit | Re-testé |
|---|---|---|---|---|---|---|---|---|
| 1 | | | | | | | | |
| 2 | | | | | | | | |
| 3 | | | | | | | | |

> Convention de commit pour les corrections : `fix(cours-0): beta — <ce qui est corrigé>`

## 5. Commandes en échec (critère C2)

Toute commande de `demo.sh` ou `correction/` ayant échoué chez un testeur. C2 exige zéro
ligne non résolue dans ce tableau.

| Chap. | Commande | Erreur retournée | Cause | Corrigé | Commit |
|---|---|---|---|---|---|
| | | | | | |

## 6. Quiz

Un score bas et récurrent sur une même question signale un passage mal expliqué, pas un
testeur faible — la correction porte sur le **chapitre**, pas sur le quiz.

| Chap. | A /5 | B /5 | C /5 | Question(s) ratée(s) par ≥ 2 testeurs | Passage à revoir |
|---|---|---|---|---|---|
| 2 | | | | | |
| 3 | | | | | |
| 4 | | | | | |
| 5 | | | | | |
| 6 | | | | | |
| 7 | | | | | |

## 7. Notions jamais expliquées

Mots, sigles ou concepts que les testeurs ont dû aller chercher ailleurs. Chaque entrée
récurrente mérite une définition en clair dans le chapitre où le mot apparaît **la première
fois**.

| Notion | Signalée par | Apparaît d'abord au chap. | Traitement |
|---|---|---|---|
| | | | |

## 8. Verbatims marquants

Les phrases à garder telles quelles — utiles pour l'argumentaire Udemy, la vidéo d'appel,
et pour se souvenir de ce que ressent un débutant.

>

## 9. Décision

**Date de revue :** __________

| Critère | Statut | Commentaire |
|---|---|---|
| C1 — 1 testeur au bout, sans aide | | |
| C2 — 0 commande en échec | | |
| C3 — temps ≤ 1,5× cible | | |
| C4 — blocages corrigés + re-testés | | |

**Décision :** ☐ 🎬 **GO tournage** ☐ 🔁 Nouvelle passe de correction + re-test ☐ ⛔ Revoir la structure du cours

**Motivation :**

---

## Historique

| Date | Événement |
|---|---|
| | Recrutement lancé |
| | Premier testeur démarré |
| | Grilles compilées |
| | Passe de correction |
| | Décision GO/NO-GO |
