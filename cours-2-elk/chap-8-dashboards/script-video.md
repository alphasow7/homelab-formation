# Chapitre 8 — Dashboards de service : script vidéo

> Durée cible : ~22 min. Prérequis : l'ELK complet du cours (Filebeat journald sur les 4
> VMs, syslog de l'hyperviseur, data view `logstash-*` dans Kibana).
> Chapitre **pratique-Kibana** : le concept est court, l'essentiel se joue à la souris
> dans Lens. RIEN ne s'importe ici — l'élève CONSTRUIT (l'import, c'était le chap. 5).

## 1. Le concept (4 min)

**À dire** : « Jusqu'ici, tu vas chercher tes logs un par un dans Discover. C'est bien
pour enquêter, mais épuisant pour surveiller. Un **dashboard**, c'est l'inverse : une
seule page qui répond d'un coup d'œil à UNE question — “est-ce que ça va ?”. Vert partout,
tu fermes l'onglet ; un pic rouge quelque part, tu sais déjà où creuser.

Pour le construire, Kibana te donne **Lens** : tu glisses-déposes un champ, il devine la
visualisation. Pas une ligne de code, pas de requête à écrire. Tu choisis une métrique
(le plus souvent : **Count**, "combien de lignes"), un découpage (par machine, par
service, par sévérité), et Lens dessine.

Les champs qui font un bon dashboard de logs, tu les connais déjà — ce sont ceux que
Filebeat et le pipeline ont posés :

- `host.name` — **quelle machine** a émis la ligne ;
- `journald.unit` — **quel service systemd** (nginx.service, ssh.service, cron.service…) ;
- `log.syslog.priority` ou le niveau — **la sévérité** (info, warning, error, critical) ;
- `process.name` — **quel programme** a écrit.

Quatre champs, quatre questions : où, quel service, à quel point c'est grave, quel
programme. Tout dashboard de logs se construit avec ça. »

## 2. Démo guidée — construire "Santé du lab" (14 min)

**À montrer** : Kibana ouvert (`https://localhost:5601` via le tunnel SSH). **Analytics >
Dashboard > Create dashboard**. « Page blanche. On va la remplir à la main, trois
panneaux. »

### Panneau (a) — Volume de logs dans le temps par machine (4 min)

**À montrer** : **Create visualization** → Lens s'ouvre.

1. Type de visu : **Bar (stacked)** — barres empilées.
2. **Horizontal axis** : glisse **@timestamp** → Lens propose un histogramme temporel.
3. **Vertical axis** : la métrique **Count of records** (par défaut).
4. **Break down by** : glisse **host.name** (ou `host.name.keyword`), agrégation **Terms**,
   taille 4.

**À dire** : « Chaque barre = une tranche de temps ; chaque couleur = une machine. Tu
lis d'un coup le RYTHME normal du lab. Le jour où une couleur explose ou DISPARAÎT, tu
le vois sans lire une seule ligne. » **Save and return.**

### Panneau (b) — Répartition par sévérité (4 min)

**À montrer** : **Create visualization** → Lens.

1. Type : **Pie** (camembert).
2. **Slice by** : glisse le champ de niveau — **log.syslog.priority** (ou `log.level` /
   le niveau selon ce que le pipeline a produit), agrégation **Terms**.
3. Métrique (taille des parts) : **Count**.

**À dire** : « Le camembert de la sévérité. En bonne santé, une part ÉNORME d'`info` et
des miettes de warning/error. C'est justement pour ça qu'on le regarde : le jour où la
part `error` gonfle, la géométrie du camembert change à l'œil nu. » **Save and return.**

### Panneau (c) — Top 10 des unités systemd les plus bavardes (4 min)

**À montrer** : **Create visualization** → Lens.

1. Type : **Table**.
2. **Rows** : glisse **journald.unit** (ou `.keyword`), agrégation **Terms**, **taille 10**,
   trié par **Count** décroissant.
3. Colonne métrique : **Count of records**.

**À dire** : « Le palmarès des services qui parlent le plus. En temps normal c'est
toujours à peu près les mêmes têtes. Un service qui bondit dans le classement, ou un
inconnu qui apparaît, c'est un signal. » **Save and return.**

### Sauvegarder (2 min)

**À montrer** : **Save** en haut à droite → titre **"Santé du lab"**. « Sauvé. Maintenant
il vit : ouvre-le demain, il s'est mis à jour tout seul. C'est ta vigie. »

## 3. Encart vrai matériel (2 min)

**À filmer** : sur l'infra réelle du formateur, la liste des dashboards : **GitLab**,
**Vault**, **DNS**… un par service.

**À dire** : « En vrai, on ne fait pas UN dashboard fourre-tout : on en fait un PAR
service qui compte. Et regarde la recette — c'est EXACTEMENT la tienne : le volume dans
le temps, la répartition par sévérité, le top des process. Ce que tu viens d'apprendre sur
le lab se décline à l'infini : même recette, un dashboard par service. GitLab qui se tait,
Vault qui crache des erreurs, le DNS qui s'affole — trois pages, trois coups d'œil. »

## 4. 💡 L'astuce du vrai monde (1 min)

**À dire** : « Les niveaux de log. La quasi-totalité de tes lignes sont des `info` — du
bruit de fond parfaitement normal, un serveur qui raconte sa vie. Le SIGNAL, lui, est
dans `warning`, `error`, `critical`. Un débutant met tout à plat et se noie dans l'`info`.
Un bon dashboard met le bruit en sourdine et le signal en avant : c'est pour ça que le
camembert de sévérité est là. Réflexe pro : quand tu enquêtes, filtre d'emblée
`log.syslog.priority < 6` (ou `not log.level : info`) — tu jettes 95 % du volume et il ne
reste que ce qui mérite ton attention. »

## 5. Annonce du TP (1 min)

**À dire** : « À toi de construire un vrai dashboard de service : celui de **nginx** sur
dns-proxy. Trois panneaux — les hits dans le temps, la répartition des codes de réponse,
le top des IP clientes. Mêmes gestes que “Santé du lab”, mais sur les logs nginx du chap.
6. 25 minutes. Ensuite, le grand final du cours : je cache un incident quelque part sur ton
lab, et tu as dix minutes pour le trouver — sans jamais te connecter aux machines. »
