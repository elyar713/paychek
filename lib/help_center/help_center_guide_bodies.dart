/// Corps embarqués (repli si le chargement asset échoue, ex. web dev + cache).
/// Source éditoriale : `assets/help_center/guides/{slug}/fr.txt`.
const Map<String, String> kHelpCenterEmbeddedGuideBodies = <String, String>{
  'dashboard': '''
Le Dashboard : Votre centre de contrôle
Le tableau de bord PAYCHEK est conçu pour vous donner une vision immédiate de votre santé financière et psychologique en tant que trader.

[img:assets/help_center/dashboard_capital_balance.gif]

1. La carte "Capital Balance"
C'est votre indicateur financier principal. Cette section regroupe trois données essentielles pour suivre votre évolution :

- Capital utilisateur : Le solde actuel de votre compte.
- Progression : Le pourcentage de variation de votre capital sur la période choisie.
- Montant de gain : La valeur monétaire nette de vos profits ou pertes.

2. Vos indicateurs de performance (Les anneaux)
Pour naviguer rapidement entre vos données techniques et vos comportements, utilisez les anneaux de suivi :

- Ring "Winrate" : Il illustre visuellement votre efficacité. Plus l'anneau est rempli, plus votre taux de réussite sur les trades est élevé.
- Ring "État du jour" : Un indicateur rapide de votre forme mentale pour la session en cours, tel que vous l'avez déclaré lors de votre préparation.
- Ring "Checklist" : Ce cercle représente votre taux de respect de la discipline. Il reflète le pourcentage de critères de votre checklist que vous avez validés avant de prendre position.

[img:assets/help_center/dashboard_capital_evolution.gif]

3. La carte "Capital Evolution" : Votre historique interactif
Cette section vous permet de visualiser graphiquement la croissance de votre capital. Au-delà du visuel, c'est un véritable outil de navigation :

- Sparklines interactives : Les lignes de tendance ne sont pas statiques. Cliquez directement sur n'importe quel point de la courbe pour accéder instantanément au(x) trade(s) correspondant(s) à cette date.
- Personnalisation hebdomadaire : Adaptez l'affichage à votre propre rythme. Rendez-vous dans vos Réglages pour choisir le mode d'affichage de vos barres de progression : 5 jours par semaine (pour suivre votre activité de trading classique) ou 7 jours par semaine (pour une vision complète).

4. Les indicateurs de performance (Best & Worst)
Pour analyser rapidement vos extrêmes, nous avons intégré deux cartes de synthèse situées sous votre graphique :

- Best Trade : Affiche votre performance la plus élevée. Un simple clic vous redirige vers le détail de ce trade pour comprendre ce qui a fonctionné.
- Plus grosse perte : Identifie votre trade le moins performant. Cliquez dessus pour analyser vos erreurs et éviter de les reproduire.

5. La carte "Analyse Personnalisée" : Votre vision sur mesure
Cette section affiche le rapport d'analyse que vous avez sélectionné comme favori. Elle vous permet de garder sous les yeux les indicateurs qui comptent le plus pour votre stratégie de trading actuelle.

[img:assets/help_center/dashboard_personal_analysis.gif]

- Personnalisez votre Dashboard : rendez-vous sur la page « Mon Analyse » et cliquez sur l'étoile à côté du rapport de votre choix.
- Mise à jour en temps réel : Dès que l'étoile est cochée, votre tableau de bord se met instantanément à jour pour afficher ce rapport prioritaire.
- Flexibilité totale : Vous pouvez changer de rapport favori aussi souvent que vous le souhaitez, en fonction de vos objectifs de la semaine ou de la période que vous analysez.

6. La "Checklist" de discipline : Votre garde-fou quotidien
La checklist est l'outil indispensable pour éviter le trading impulsif. Elle est intégrée directement sur votre tableau de bord pour vous accompagner avant chaque session.

[img:assets/help_center/dashboard_checklist.gif]

- Action rapide depuis le Dashboard : Vous pouvez cocher vos éléments de discipline instantanément sur la page d'accueil. C'est la première étape essentielle avant de lancer vos ordres sur le marché.
- Personnalisation complète : Vos règles de trading ne sont pas figées ? Aucun problème. Rendez-vous sur la page "Checklist" dédiée dans le menu latéral pour modifier, ajouter ou supprimer les critères de votre routine.
- Sync instantanée : Dès que vous modifiez un critère dans la page "Checklist", votre tableau de bord se met à jour immédiatement pour refléter vos nouvelles règles de trading.

7. Suivi de votre "État Mental" : La clé de votre psychologie

[img:assets/help_center/dashboard_mental_state.gif]

Le trading n'est pas seulement une question de chiffres ; c'est avant tout un état d'esprit. La carte "État Mental" de votre tableau de bord vous permet de visualiser instantanément votre disposition psychologique actuelle, un facteur déterminant pour vos performances.

- Visibilité en temps réel : Cette carte affiche votre état mental du jour. Elle est directement synchronisée avec vos saisies pour vous offrir une vue d'ensemble rapide sans avoir à naviguer dans les menus.
- Mise à jour centralisée : Vous avez changé d'avis ou vous souhaitez corriger votre saisie ? Rendez-vous simplement sur la page dédiée "État Mental" dans votre menu latéral. Vous pouvez y modifier tous les éléments et paramètres associés.
- Synchronisation instantanée : Dès que vous enregistrez vos modifications sur la page "État Mental", la carte de votre tableau de bord se met à jour automatiquement. Vous avez ainsi toujours une information fiable pour décider si vous êtes dans les meilleures conditions pour trader.

8. La carte "Stratégie" : Votre focus du moment

[img:assets/help_center/dashboard_strategy.gif]

Le trading est un métier de spécialisation. La carte "Stratégie" sur votre tableau de bord vous permet de garder votre plan d'action sous les yeux, sans aucune distraction.

- Vision immédiate : Affichez en un coup d'œil les détails de la stratégie que vous travaillez actuellement. Fini les allers-retours dans les menus ; votre plan est disponible dès l'ouverture de votre journal.
- Sélection prioritaire (Le système d'étoile) : Vous alternez entre plusieurs stratégies ou vous voulez vous concentrer sur une seule pendant une semaine ? Allez dans la page "Ma Stratégie", cochez l'étoile sur le plan que vous souhaitez privilégier, et il apparaîtra instantanément sur votre tableau de bord.
- Flexibilité totale : Vous changez de setup ou de marché ? Décochez l'étoile actuelle et activez-en une nouvelle. Votre dashboard s'adapte en temps réel à votre évolution.

9. Le Calendrier : Votre historique de trading en un coup d'œil

[img:assets/help_center/dashboard_calendar.png]

Le calendrier situé sur votre tableau de bord est bien plus qu'un simple outil de date. Il est la représentation visuelle de votre régularité et de votre activité sur les marchés.

- Vision globale de vos sessions : Visualisez instantanément vos jours de trading. Les dates marquées indiquent vos sessions actives, vous permettant de suivre votre rythme de travail hebdomadaire et mensuel.
- Navigation rapide : Vous souhaitez revoir une session spécifique ? Cliquez directement sur une date dans le calendrier pour filtrer vos données et accéder immédiatement aux informations et aux trades de ce jour précis.
- Suivi de votre régularité : Un coup d'œil rapide au calendrier suffit pour identifier vos périodes d'activité intense ou, au contraire, vos phases de repos, ce qui est crucial pour maintenir une bonne santé mentale de trader.

10. Analyse de performance personnalisée : Le pouvoir de la donnée
Ne vous contentez plus de regarder votre PnL. La section "Performance Personnalisée" vous permet de croiser vos données pour comprendre exactement pourquoi vous gagnez ou perdez de l'argent.

[img:assets/help_center/dashboard_custom_performance.gif]

- Créez vos propres corrélations : Vous voulez savoir si votre winrate est meilleur quand votre "État Mental" est élevé ? Ou si le respect strict de votre "Checklist" impacte réellement votre profitabilité ? Vous pouvez maintenant construire vos propres rapports en combinant tous les éléments de votre journal : état mental, checklist, stratégies, analyses techniques, et bien plus.
- Mise en lumière des failles : Grâce à cette analyse croisée, découvrez des habitudes invisibles. Peut-être réaliserez-vous que vos pertes surviennent majoritairement lors de sessions où votre état mental était en dessous de 50%, ou avec une stratégie précise.
- Dashboard sur mesure : Une fois votre rapport configuré, il devient votre meilleure arme décisionnelle. Comme pour vos autres rapports, vous pouvez l'épingler (via l'étoile) pour l'afficher en priorité sur votre tableau de bord.
''',
  'add_trade': '''
Ajouter un Trade : La précision au service de l'analyse
Ajouter un trade dans PAYCHEK a été conçu pour être aussi rapide que possible, tout en capturant les données cruciales pour votre progression.

[img:assets/help_center/add_trade.gif]

Saisie intuitive : Sélectionnez en quelques clics votre actif et votre marché. Utilisez nos raccourcis de remplissage rapide pour éviter les saisies manuelles répétitives.

Calcul automatique : Saisissez simplement vos prix d'entrée et de sortie. PAYCHEK calcule instantanément le résultat de votre trade, incluant les commissions que vous pouvez configurer via l'icône engrenage située à côté de vos cartes de capital.

Maîtrisez votre timing : Nous recommandons vivement de renseigner les dates et heures précises d'entrée et de sortie. Ces informations sont le moteur de vos futures analyses de performance et permettent à l'application de dresser un profil complet de votre style de trading.

Contexte de marché : Utilisez les boutons "Avant News" ou "Après News" pour classifier vos trades. Cette distinction est essentielle pour comprendre comment vous réagissez à la volatilité du marché et ajuster votre stratégie en conséquence.

[img:assets/help_center/add_trade_custom_actif.gif]

Ajout manuel d'actifs : Si la paire que vous tradez n'apparaît pas dans notre liste, cliquez sur l'engrenage situé juste à côté du champ "Quantité". Vous pourrez alors ajouter manuellement n'importe quel actif, instrument ou paire de devises.

Personnalisation durable : Une fois ajouté, cet actif devient disponible pour vos futurs trades, vous permettant de construire votre propre bibliothèque d'instruments de trading au fil de votre progression.

[img:assets/help_center/add_trade_screenshot_csv_note.gif]

Enrichissez votre journal : Captures d'écran, Analyses et Notes
Un bon journal ne se limite pas aux résultats financiers ; il documente tout le processus décisionnel. Utilisez cette section pour archiver chaque détail de vos trades.

Preuve visuelle (Capture d'écran) : Ne vous contentez pas de noter votre point d'entrée. Intégrez directement une capture d'écran de votre graphique. Cela permet de visualiser instantanément le setup et la configuration du marché au moment de la prise de position.

Importation CSV universelle : Fini les saisies manuelles fastidieuses. PAYCHEK est compatible avec 9 plateformes majeures :

- MT4, MT5, TradingView, Tradovate, cTrader, NinjaTrader, Quantower, ATAS, et Rithmic.

Importez vos données en quelques secondes et retrouvez tout l'historique de vos sessions instantanément.

Analyse et contexte :

- Case Analyse : Vous avez travaillé sur un rapport détaillé dans votre page "Mon Analyse" ? Exportez-le en PDF et joignez-le directement à votre trade pour garder une trace de votre réflexion.
- Case Note : Utilisez cet espace libre pour noter vos ressentis, vos doutes ou toute remarque particulière qui n'apparaît pas dans vos indicateurs. C'est ici que vous construisez votre propre expérience au fil des trades.
''',
};
