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

La "Boîte Noire" de votre Trading : Performance et Discipline
Le cœur de PAYCHEK réside dans sa capacité à transformer vos actions quotidiennes en données exploitables pour votre page Performance. Chaque trade est analysé non pas pour son résultat financier, mais pour sa conformité avec votre plan de jeu.

1. Typologie du Trade : Principe vs Feeling
Lors de l'ajout d'un trade, définissez la nature de votre exécution :

- Principe : Le trade a été pris en respectant scrupuleusement votre stratégie, routine et psychologie.
- Feeling : Le trade a été pris sous le coup de l'émotion.

[img:assets/help_center/add_trade_discipline_settings.png]

Personnalisation (L'Engrenage) : Cliquez sur l'engrenage à côté de cette section pour ajuster vos préférences. Par défaut, le mode "Feeling" masque les sections d'analyse pour simplifier la saisie, mais vous pouvez les activer ou désactiver à volonté.

Session de jour : Définissez un seuil de trades après lequel votre état passe automatiquement en "Feeling" pour éviter le surengagement.

2. La mesure du Respect de Stratégie (Le Slider)
Utilisez le slider de pourcentage pour quantifier votre niveau de respect de votre stratégie sur chaque trade. Ce chiffre est envoyé directement à votre page Performance pour corréler votre rigueur à votre rentabilité.

[img:assets/help_center/add_trade_discipline_sections.png]

3. Analyse de non-respect : Checklist, Plan et État Mental
Pour chaque trade, PAYCHEK vous permet d'identifier les zones de défaillance :

- Stratégie & Analyse : Si vous avez manqué un élément (ex: support/résistance, signal technique), cochez-le dans les listes dynamiques générées par vos pages Stratégie et Mon Analyse.
- Checklist : Si votre checklist quotidienne n'a pas été respectée, vous en serez informé avant de valider l'enregistrement du trade.
- État Mental : Visualisez votre état émotionnel actuel (ex: Peur 46%). Cochez les facteurs influents pour que PAYCHEK calcule précisément comment votre psychologie impacte votre Winrate.

4. Tags Emotionnels
Terminez votre saisie en taguant le trade avec l'émotion dominante : FOMO, Tilt, Revenge, etc. C'est ce tag qui permettra, sur le long terme, de visualiser quels types d'émotions "tuent" le plus rapidement votre capital.
''',
  'checklist': '''
Checklist : Votre protocole de préparation
La page Checklist est le socle de votre discipline. C'est ici que vous définissez vos règles d'engagement pour transformer votre trading de "réactionnel" en "méthodique".

[img:assets/help_center/checklist_schedule_reminders.gif]

1. Planification et Rappels intelligents
Ne manquez plus aucun événement majeur (annonces FED, statistiques économiques).

- Programmation anticipée : Créez vos checklists pour les jours, semaines ou mois à venir.
- Notification automatique : Si vous notez une annonce importante pour dans 2 semaines, PAYCHEK la mémorise. Le jour J, la checklist s'affiche automatiquement sur votre Dashboard au moment opportun pour vous préparer avant le trade.

2. Sections 100% Personnalisables
Votre trading est unique, votre checklist doit l'être aussi.

- Structure flexible : Vous êtes libre d'ajouter, supprimer ou renommer chaque section (Psychologie, Risk Management, Analyse Technique, etc.).
- Section "News" dédiée : Un espace fixe pour consigner les points économiques cruciaux du jour.

[img:assets/help_center/checklist_calendar_history.gif]

3. Historique et Analyse Post-Trade
Le calendrier situé en bas de page est votre outil de revue de discipline :

- Suivi rétrospectif : Consultez l'historique de vos routines passées.
- Détails et corrélations : Cliquez sur une date pour voir exactement quels éléments n'ont pas été cochés ce jour-là.
- Lien avec la performance : Comparez vos jours de "Checklist non respectée" avec vos jours de "Pertes". PAYCHEK vous aide à comprendre visuellement comment le relâchement dans votre routine impacte directement votre compte.
''',
  'calendar': '''
Calendrier : Votre centre de pilotage mensuel
Le calendrier PAYCHEK est conçu pour vous offrir une vision panoramique de votre activité. Il ne sert pas uniquement à consulter les dates, mais à analyser chaque étape de votre progression mensuelle.

[img:assets/help_center/calendar_objective_kpi.gif]

1. Indicateurs clés de performance (KPI)
Dès l'ouverture du calendrier, retrouvez vos statistiques essentielles :

Winrate, Nombre de trades et P&L mensuel : Un coup d'œil rapide sur vos chiffres clés.

Objectifs de mois : Utilisez la barre de progression pour suivre votre avancée. Cliquez sur l'engrenage à côté pour définir vos objectifs financiers ou de discipline du mois.

2. Navigation intelligente et vue détaillée
Interaction intuitive : Cliquez sur n'importe quel jour du calendrier : la carte adjacente affiche instantanément tous les trades effectués ce jour-là. Cliquez sur un trade pour accéder directement à sa fiche détaillée.

Sparkline de progression : Utilisez la ligne de tendance dynamique pour visualiser la courbe de vos résultats sur le mois. Comme pour le calendrier, cliquer sur un point de la courbe vous renvoie directement aux trades correspondants.

[img:assets/help_center/calendar_cumulative_history.gif]

Historique complet : Naviguez facilement entre les mois précédents (février, mars, etc.) via la barre de sélection pour comparer vos performances passées et ajuster votre stratégie.

3. Analyse approfondie et synthèse
Synthèse des extrêmes : Consultez la carte dédiée pour identifier vos "Meilleurs trades", votre "Nombre total de trades" et votre "Plus grosse perte du mois". Cette section est le meilleur outil pour identifier vos succès et vos axes d'amélioration.

Carte "Performance Totale" (Repli/Dépli) : Utilisez cette section modulable pour alterner entre une vue synthétique et une vue détaillée de tous les trades du mois. C'est l'outil idéal pour passer rapidement de l'analyse stratégique au détail technique de chaque position.
''',
  'mental_state': '''
État Mental : Votre "Bio-Data" de Trader
La performance n'est pas qu'une question de technique, c'est une question d'équilibre humain. La page État Mental est votre tableau de bord biologique : elle analyse comment vos habitudes quotidiennes impactent directement vos résultats financiers.

[img:assets/help_center/mental_state_impact_settings.gif]

1. Opération Psychologie Quotidienne
Chaque jour, effectuez votre "Check-up psycho". Utilisez les curseurs pour noter vos piliers de performance :

Routine Personnalisable : Sommeil, sport, méditation, ou tout autre élément que vous jugez vital pour votre personnalité.

Impact Calibré : Chaque slider dispose d'un réglage d'impact (positif ou négatif). Vous définissez vous-même ce qui vous aide à rester "tranchant" sur les marchés.

Le Ring de Performance : Visualisez instantanément votre état global de la journée via un graphique en anneau (Ring) qui agrège toutes vos données personnelles.

2. Configuration Expert (L'Engrenage)
Cliquez sur l'engrenage de la section pour définir le poids (en pourcentage) de chaque facteur dans votre état global. Si pour vous, le sommeil compte pour 60% de votre réussite et la méditation pour 10%, PAYCHEK vous permet de paramétrer cette réalité.

3. Corrélation Performance & Psycho
C'est ici que PAYCHEK devient un outil de diagnostic hors norme. Vos données d'État Mental sont synchronisées en temps réel avec vos trades :

[img:assets/help_center/mental_state_calendar.gif]

Historique visuel : Utilisez le calendrier pour naviguer dans le passé et voir comment votre état psycho a évolué.

Analyse de corrélation automatique : La page Performance affiche désormais les liens de cause à effet :

Exemple : "Quand votre état mental est à 50%, votre Winrate tombe à 44%." Cette visibilité vous permet de savoir exactement quel jour vous devez fermer votre plateforme de trading pour protéger votre capital.

4. Personnalisation de vos Sessions
Vous n'êtes pas contraint à une journée de trading standard. PAYCHEK s'adapte à votre vie et à vos horaires de marché.

Configuration des sessions (L'Engrenage) : Cliquez sur l'engrenage dans la barre d'outils du calendrier pour définir vos propres créneaux de trading.

Flexibilité totale : Que vous tradiez durant la session de Londres, New York, ou que vous ayez des horaires décalés, vous êtes libre de choisir les heures qui composent votre "journée de trade".
''',
  'my_strategy': '''
Ma Stratégie : Votre système d'audit interne
La page Stratégie est le cœur technologique de PAYCHEK. Elle permet de décomposer votre méthode de trading en critères objectifs afin de mesurer, avec une précision chirurgicale, ce qui génère vos profits et ce qui alimente vos pertes.

[img:assets/help_center/strategie_golden_rules_risk.gif]

1. Règle d'Or et Risk Management
Règles d'Or : Définissez vos principes non négociables. Si vous ne les respectez pas lors de la saisie d'un trade, PAYCHEK flaggera immédiatement l'écart.

Risk Management : Définissez vos limites (risque par trade, risque journalier, trades max par jour, ratio minimum).

Audit Automatique : PAYCHEK compare vos trades réels (importés manuellement ou via CSV) à ces limites. Vous saurez instantanément si vous avez "overtradé" ou dépassé votre risque autorisé.

[img:assets/help_center/strategie_sessions.gif]

2. Horaires et Sessions (Trading Sessions)
Configuration : Définissez vos sessions (Londres, Asie, US).

Analyse de performance : La page Performance corrèlera automatiquement votre Winrate avec vos horaires. Vous découvrirez peut-être que votre Winrate est de 60% sur Londres, mais de 30% sur US. À vous d'ajuster votre planning en conséquence.

[img:assets/help_center/strategie_setups_templates.gif]

3. Setup et Templates (Le cœur de l'analyse)
Créez vos stratégies point par point : Timeframe, Indicateurs, Patterns, Signaux d'alerte, Entrées, Stop-Loss (ST), Take-Profit (TP) et Breakeven.

Audit de Stratégie : Lors de l'ajout d'un trade, cochez les points que vous avez respectés. La page Performance calculera alors l'impact exact : "Quand vous ignorez le point 'Indicateur X' de votre stratégie, votre Winrate diminue de 15%."

[img:assets/help_center/strategie_calendar.gif]

4. Calendrier Stratégique
Visualisation : Un calendrier coloré vous montre quelle stratégie a été utilisée chaque jour.

Diagnostic rapide : Cliquez sur une journée pour voir instantanément les éléments de stratégie non respectés. C'est le moyen le plus rapide d'identifier pourquoi une journée a été un succès ou un échec.

5. Rapport PDF Exportable
Exportez l'intégralité de votre "Manuel de Stratégie" en format papier. Avoir votre plan sous les yeux, sur votre bureau, est le meilleur moyen de rester concentré pendant les périodes de forte volatilité.
''',
  'my_analysis': '''
My Analyse : Votre laboratoire de trading
La page My Analyse vous permet de formaliser votre réflexion avant même de passer à l'action. En structurant votre pensée selon trois piliers fondamentaux, vous éliminez le doute et renforcez la cohérence de vos décisions.

[img:assets/help_center/analyse_initial_config.gif]

1. Configuration Initiale
Identifiez votre Actif, nommez votre Thèse et fixez la Date de votre analyse.

Flexibilité totale : Utilisez les boutons ON/OFF pour désactiver les sections inutiles et alléger votre interface selon votre méthodologie.

[img:assets/help_center/analyse_three_pillars_impact.gif]

2. Les Trois Piliers de l'Analyse
Carte Fondamentale : Définissez le contexte (Timeframe, Biais directionnel, Phase de marché : Accumulation/Impulsion/Distribution). Utilisez l'espace "Structure" pour noter vos figures (Double Bottom, BOS, etc.) et le slider de confiance pour auto-évaluer la solidité de votre analyse. Intégrez vos données de Volume Profil (POC, VAH, VAL) pour confirmer vos niveaux.

Carte Zone Clé & SMC : Identifiez vos points de retournement. Ajoutez manuellement vos supports/résistances et cochez vos outils SMC (Order Block, FVG, Liquidité, Niveaux Fibonacci). Complétez avec une note de synthèse pour garder une trace claire de vos zones d'intérêt.

Carte Entrée : Formalisez votre déclencheur (Signal, Indicateur ou Figure chandelier). C'est votre "Trigger" final avant l'exécution.

[img:assets/help_center/analyse_report_save_sync.gif]

3. Sauvegarde, Export et Sync
Rapport Centralisé : Une fois le bouton "Sauvegarder" pressé, PAYCHEK génère une fiche récapitulative unique.

Synchro Dashboard : Cette fiche apparaît instantanément sur votre Dashboard.

Export PDF : Transformez votre analyse en document papier pour garder vos plans sous les yeux.

Audit de discipline : Ces données sont automatiquement liées à vos futurs trades. Lors de votre revue de performance, vous verrez en un coup d'œil quels éléments d'analyse ont été respectés ou ignorés, vous permettant d'ajuster votre stratégie avec des preuves statistiques.
''',
  'performance': '''
Performance : La vérité statistique
La page Performance est le miroir de votre activité. Elle ne se contente pas de compter vos gains, elle décode les mécanismes qui dictent votre réussite ou vos échecs.

[img:assets/help_center/performance_overview_kpis.png]

1. Vue d'ensemble (Header & KPIs)
Indicateurs clés : Visualisez instantanément le volume total, le solde net (Gain/Perte/Breakeven) et vos métriques de survie (Perte max, Durée moyenne d'un trade).

Index de Rigueur : Vos performances sont croisées avec votre assiduité. Attention : Les statistiques de discipline ne sont comptabilisées que si votre checklist et votre état mental sont remplis avant 23h59. Cette rigueur quotidienne est la clé de votre progression.

2. Diagnostic de Discipline
Audit des oublis : PAYCHEK liste vos trades "orphelins" (ceux sans checklist, stratégie ou analyse). Un clic suffit pour les compléter directement.

Corrélation Discipline/Winrate : Découvrez l'impact mathématique de votre rigueur :

- Winrate avec 100% de checklist vs Winrate sans checklist.
- Performance corrélée à vos différents états mentaux (Peur, Confiance, Fatigue, etc.).

3. Analyse Comportementale & Environnementale
Volume d'activité : Visualisez votre Winrate en fonction du nombre de trades quotidiens (ex: 1-5 trades vs 5-10 trades). Identifiez votre seuil de fatigue.

Analyse Temporelle & Technique :

- Sessions : Quel est votre Winrate sur Londres, Asie ou US ?
- Durée de position : Quelle fenêtre de temps optimise votre rentabilité (0-15 min vs >12h) ?
- Marchés : Quel actif est votre "vache à lait" et lequel est votre "piège" ?

[img:assets/help_center/performance_strategic_audit.gif]

4. Audit Stratégique & Exécution
Audit par Stratégie : Pour chaque stratégie définie, identifiez les éléments les plus souvent ignorés.

Barre de Talent : Identifiez vos trades basés uniquement sur le "Feeling" ou le "Principe".

Dashboard Personnalisable : Créez vos propres vues. Vous voulez savoir si votre "peur" fait baisser votre Winrate sur l'EUR/USD ? Ajoutez ce segment et visualisez l'impact en temps réel.

5. Export & Rapport
Icône PDF : Générez à tout moment votre rapport de performance complet. Idéal pour vos revues hebdomadaires ou pour présenter votre historique à un partenaire/mentor.

Pourquoi c'est l'argument ultime pour le 5 juin :
Tu forces le trader à réaliser que le problème n'est pas le marché, mais sa propre exécution. En montrant, par exemple, qu'un trader perd 20% de Winrate dès qu'il dépasse 5 trades par jour, tu lui donnes une règle d'or qu'il ne pourra plus jamais ignorer.
''',
  'trade_page': '''
Journal de Trade : Votre tableau de bord opérationnel
La page Trade est conçue pour une lecture immédiate et une analyse profonde de votre activité. Tout est structuré pour vous permettre de passer de la vision globale aux détails précis en un clic.

[img:assets/help_center/trade_page_header.gif]

1. Indicateurs de Performance (Header)
En haut de page, retrouvez vos trois piliers de suivi :

Gain/Perte global : Votre solde net, reflétant la santé financière de votre compte.

Ring de Winrate : Une représentation visuelle dynamique de votre taux de réussite.

Volume d'activité : Le nombre total de trades effectués.

2. Vue temporelle et progression
Barre de performance hebdomadaire : Visualisez instantanément la tendance de votre semaine en cours grâce à un indicateur visuel de progression.

Sélecteur de période (1D / 1W / 1M / ALL) : Ajustez votre vue pour isoler vos performances quotidiennes, hebdomadaires, mensuelles ou pour analyser l'intégralité de votre historique.

3. Classification et Filtrage
Gestion des positions : Un tableau de bord interactif pour classer vos trades par état : Gains, Pertes, Breakeven ou Positions en cours. Vous pouvez filtrer ces catégories pour identifier rapidement les trades qui ont impacté votre capital.

Analyse par actifs : Une section dédiée liste les instruments que vous avez tradés (MNQ, Nasdaq, EUR/USD, etc.) avec leur fréquence, vous permettant d'identifier vos actifs les plus rentables ou ceux qui vous coûtent le plus cher.

Gestion et Exportation : Votre Journal en action
La page Trade n'est pas seulement un historique, c'est un outil interactif qui vous permet d'analyser, de corriger et d'exporter votre performance en quelques secondes.

1. Navigation temporelle intuitive (1D / 1W / 1M / ALL)
Visualisez votre progression à votre rythme :

[img:assets/help_center/trade_page_period_bars.gif]

Vue dynamique : Sélectionnez 1D, 1W, 1M ou ALL. Les barres graphiques s'ajustent automatiquement pour représenter chaque période.

Accès rapide : Cliquez sur n'importe quelle barre graphique pour isoler et afficher instantanément la liste des trades correspondants à cette période précise.

2. Alertes de Discipline (Le message jaune)
PAYCHEK vous avertit en temps réel si votre analyse est incomplète :

Notifications intelligentes : Un message jaune apparaît sur vos trades si des éléments critiques sont manquants (Plan d'analyse, Checklist, État mental ou Stratégie).

Objectif : Ne laissez aucun trade "orphelin" d'analyse. Un trade sans analyse est une donnée perdue pour votre progression.

3. Gestion et Exportation
Édition et Suppression : Un menu à "3 points" est disponible sur chaque trade. Vous pouvez à tout moment modifier les détails d'une position ou supprimer une saisie erronée.

Exportation PDF : Besoin d'un bilan papier ou d'un compte-rendu pour un mentor ? Cliquez sur l'icône PDF pour générer instantanément un rapport complet incluant :

L'historique détaillé de vos trades.

Le récapitulatif de vos statistiques de performance.

Vos graphiques de progression.
''',
};
