# Kit de recrutement — bêta-test du cours 0

> Compagnon de [`beta-test.md`](beta-test.md), qui définit le protocole. Ce fichier-ci
> contient le matériel prêt à l'emploi : critères de sélection, annonces à publier,
> message d'accueil et check-list d'envoi.
>
> **Objectif : 2-3 testeurs.** Idéalement au moins 1 sous Windows (chemin A) et 1 avec un
> vieux PC (chemin B).

---

## 1. Le profil recherché (critères stricts)

Le critère de la spec est *« un élève débutant technique termine le cours 0 sans aide »*.
Un testeur trop avancé valide un cours qui n'est pas celui qu'on vend : il comblera les
trous sans s'en rendre compte, et les vrais blocages resteront invisibles jusqu'à la
publication.

| ✅ On cherche | ❌ On écarte |
|---|---|
| A déjà utilisé un terminal (naviguer, lancer une commande) | Admin sys, DevOps, dev backend |
| Sait ce qu'est une adresse IP | A déjà monté un serveur, un NAS, un Raspberry Pi « sérieux » |
| N'a **jamais** utilisé Proxmox | A déjà utilisé ESXi, Hyper-V, Proxmox, ou fait du KVM |
| Curieux, ira au bout par intérêt | Rend service par politesse (il abandonnera au chapitre 3) |

**Questions de filtrage** (à poser avant d'accepter quelqu'un) :

1. « Tu as déjà installé un système d'exploitation toi-même ? » → *oui = OK, sauf si c'est un hyperviseur.*
2. « Proxmox, ESXi, Hyper-V : ça te dit quelque chose ? » → *« non » ou « le nom seulement » = parfait. « J'en ai déjà installé » = écarter.*
3. « Tu es à l'aise pour taper des commandes dans un terminal ? » → *« un peu / je copie-colle » = idéal. « Jamais ouvert » = trop bas, il bloquera sur des choses hors périmètre du cours.*
4. « Tu as combien d'heures à y consacrer dans les 2 prochaines semaines ? » → *moins de 5 h = ne pas engager.*

## 2. Le matériel du testeur

| Chemin | Matériel requis | Note |
|---|---|---|
| **A — VirtualBox** | Son PC actuel, **16 Go de RAM minimum** | Le chemin de la majorité |
| **B — PC dédié** | Un PC libre, 8 Go mini (16 recommandé) + une clé USB | Setup identique au formateur |

⚠️ **Mac Apple Silicon (M1→M4) : chemin A impossible** — l'ISO Proxmox est x86. Ces
testeurs doivent prendre le chemin B ou être écartés s'ils n'ont pas de PC libre.

## 3. Annonce à publier

### Version forum / Discord homelab FR

> **[Recherche 2-3 bêta-testeurs débutants] Formation homelab Proxmox (gratuit)**
>
> Salut ! J'ai écrit une formation pour monter son premier homelab avec Proxmox, et avant
> de la filmer je cherche 2-3 personnes **débutantes** pour la tester en conditions réelles.
>
> **Le profil :** tu as déjà tapé des commandes dans un terminal, tu sais ce qu'est une
> adresse IP, mais tu n'as **jamais** touché à Proxmox ni à la virtualisation. C'est
> exactement le profil que je cherche — si tu es déjà admin sys, tu n'es malheureusement
> pas ma cible.
>
> **Ce que tu fais :** tu suis les 6 chapitres écrits, tu montes ton homelab pour de vrai
> (installation Proxmox, première VM, réseau, templates, sauvegardes, projet final), et tu
> notes **tout ce qui coince**. Les blocages sont le but : chaque endroit où tu galères est
> un endroit que je corrige avant de filmer.
>
> **Ce dont tu as besoin :** un PC avec 16 Go de RAM, **ou** un vieux PC dont tu peux te
> servir librement. Aucun achat, rien à payer.
>
> **Le temps :** environ 4 h à 4 h 30 au total, à ton rythme, sur 2 semaines.
>
> **Ce que tu y gagnes :** un homelab fonctionnel qui reste à toi, la formation complète
> gratuitement (et les suivantes : Ansible, ELK, sécurité), et ton nom dans les
> remerciements si tu le souhaites.
>
> Une seule règle : **je n'ai pas le droit de t'aider.** Si tu bloques, tu notes, tu
> cherches sur Internet comme tu le ferais normalement — c'est précisément la donnée qui
> m'intéresse.
>
> MP si ça te tente 👋

### Version entourage / collègue junior (message direct)

> Salut [prénom], j'ai un service à te demander — et je pense que ça peut t'intéresser.
>
> J'ai écrit une formation pour apprendre à monter un « homelab » : transformer un PC en
> petit serveur pour héberger ses trucs à la maison. Avant de la filmer, j'ai besoin de la
> faire tester par quelqu'un qui **ne connaît pas** le sujet — et c'est exactement pour ça
> que je pense à toi.
>
> Concrètement : tu suis mes instructions écrites, tu montes ton serveur pour de vrai, et
> tu me dis à chaque fois que tu es perdu. Le but n'est pas que ça marche du premier coup —
> le but est de trouver mes trous. Plus tu bloques, plus tu m'es utile.
>
> Il te faut juste un PC avec 16 Go de RAM (ou un vieux PC qui traîne). Compte 4 h en tout,
> à ton rythme sur 2 semaines. Tu gardes le serveur à la fin, et je te donne toutes mes
> formations.
>
> Le seul truc : je n'aurai pas le droit de t'aider pendant. Ça te dit ?

## 4. Message d'accueil (à envoyer au testeur retenu)

> Merci d'avoir accepté 🙏 Voici tout ce qu'il te faut.
>
> **1. Par quoi commencer :** ouvre `labs/lab-cours-0.md`. Il te fait choisir entre deux
> chemins (VirtualBox sur ton PC, ou un vieux PC dédié). Suis celui qui correspond à ta
> situation, puis enchaîne les chapitres **2 à 7 dans l'ordre**.
>
> **2. Dans chaque chapitre**, lis `script-video.md` comme un cours (c'est le texte des
> futures vidéos), puis fais le TP (`tp.md`), puis le quiz (`quiz.md`). `demo.sh` contient
> les commandes si tu préfères copier-coller. Si tu es vraiment bloqué, `correction/`
> existe — mais **note-le** avant d'y aller.
>
> **3. Remplis la grille** (`beta-grille.md`) au fur et à mesure, pas à la fin : un tableau
> par chapitre, ça prend 2 minutes. Ce que je veux surtout, ce sont tes **mots exacts**
> quand tu bloques (« je ne comprenais pas où trouver l'IP »), et les **commandes qui ont
> échoué**, copiées-collées avec leur message d'erreur.
>
> **4. La règle d'or : je ne peux pas t'aider.** Si tu bloques plus de 20 minutes, tu notes
> le blocage, puis tu as le droit de chercher sur Internet — note juste la recherche qui
> t'a débloqué. C'est exactement ce que fera un vrai élève, et c'est l'information la plus
> précieuse pour moi.
>
> **5. Si tu abandonnes**, dis-le-moi — sans gêne. Savoir *où* et *pourquoi* quelqu'un
> lâche vaut de l'or, et c'est un résultat de test valide, pas un échec de ta part.
>
> Bon courage, et merci encore 🚀

## 5. Check-list d'envoi

- [ ] Testeur filtré avec les 4 questions du §1
- [ ] Chemin (A ou B) confirmé, RAM/matériel vérifié — Apple Silicon → chemin B obligatoire
- [ ] Accès au dépôt donné (lien GitHub, ou zip du `cours-0-fondations/` + `labs/`)
- [ ] `beta-grille.md` envoyé, renommé à son prénom
- [ ] Message d'accueil (§4) envoyé
- [ ] Date de point à mi-parcours convenue (après le chapitre 4)
- [ ] **Rappel personnel : ne pas répondre aux demandes d'aide.** Accuser réception, noter,
      ne rien expliquer. C'est le plus dur du protocole.

## 6. Suivi

| Testeur | Chemin | Contacté | A commencé | Chapitre atteint | Grille reçue |
|---|---|---|---|---|---|
| | | | | | |
| | | | | | |
| | | | | | |
