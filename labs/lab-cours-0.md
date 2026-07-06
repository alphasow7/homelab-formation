# Lab du cours 0 — de quoi as-tu besoin ?

Deux chemins, mêmes TPs :

| | Chemin A — VirtualBox | Chemin B — vieux PC dédié |
|---|---|---|
| Matériel | Ton PC (16 Go RAM mini) | Un PC libre (8 Go mini, 16 recommandé) |
| Coût | 0 € | 0 € (ou 100-200 € d'occasion) |
| Réalisme | Proxmox « imbriqué » (nested) | Identique à la vraie vie |
| Performances | Correctes (suffisant pour les TPs) | Meilleures |

👉 Hésitant ? Prends le **chemin A** : tu pourras toujours migrer plus tard
(chapitre 6 : sauvegarde/restauration — c'est littéralement un TP).

## Choisis ton chemin

- **[Chemin A — Proxmox dans VirtualBox](chemin-a-virtualbox.md)** : tu installes Proxmox dans une machine virtuelle sur ton PC actuel. Rien à acheter, rien à casser. C'est le chemin de la majorité des élèves.
- **[Chemin B — Proxmox sur un vieux PC](chemin-b-pc-dedie.md)** : tu as un PC qui traîne ? Il devient ton serveur. C'est exactement le setup du formateur.

Dans les deux cas, tu arrives au même endroit : une interface web Proxmox qui t'attend.

## Combien de temps ?

- Chemin A : environ **45 minutes**.
- Chemin B : environ **45 minutes** aussi, plus le temps de préparer la clé USB.

Prends ton temps. Ce n'est pas une course, et chaque écran est expliqué.

## Un mot sur les erreurs

Tu vas peut-être bloquer quelque part. C'est normal — tout le monde bloque la première fois. Chaque guide a une section « Ça coince ? » avec les blocages les plus fréquents et comment t'en sortir. Lis-la avant de paniquer.

---

✅ **Vérification avant de continuer** : la GUI Proxmox s'affiche et tu es connecté en root. C'est tout ce qu'il faut pour le chapitre 2.

<!--
Pour le formateur (À FAIRE avant tournage) :
- Valider le chemin A de bout en bout sur VirtualBox : dérouler chemin-a-virtualbox.md
  en conditions réelles et vérifier que le guide tient dans les 45 minutes annoncées.
- Vérifier au passage que les numéros de version (Proxmox 9.x, VirtualBox 7.x)
  correspondent toujours aux dernières versions disponibles.
-->
