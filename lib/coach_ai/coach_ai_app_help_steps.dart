/// Étapes UI concrètes par zone PAYCHEK (source : code app + Help Center).
abstract final class CoachAiAppHelpSteps {
  static const appFeaturePattern =
      r'che?ck\s*list|checklist|trade|strat(é|e)gie|strategie|analyse|analysis|'
      r'mental|émotion|emotion|performance|calendrier|calendar|dashboard|accueil|'
      r'engrenage|engrenage|⚙|feeling|principe|discipline|capital|commission|'
      r'quantité|quantite|actif|csv|import|tag|fomo|tilt|coach|réglage|reglage|'
      r'calculatrice|plus|menu|paychek|broker|portefeuille|setup|playbook|lens';

  static List<String> forTopic(String topicId, String languageCode) {
    final fr = languageCode == 'fr';
    return switch (topicId) {
      'app_overview' => fr ? _overviewFr : _overviewEn,
      'discipline_gear' => fr ? _disciplineGearFr : _disciplineGearEn,
      'principe_feeling' => fr ? _principeFeelingFr : _principeFeelingEn,
      'tag_psych' => fr ? _tagPsychFr : _tagPsychEn,
      'import_csv' => fr ? _importCsvFr : _importCsvEn,
      'capital_gear' => fr ? _capitalGearFr : _capitalGearEn,
      'quantite_gear' => fr ? _quantiteGearFr : _quantiteGearEn,
      'mental_state_gear' => fr ? _mentalStateGearFr : _mentalStateGearEn,
      'calendar_objectives_gear' => fr ? _calendarObjectivesGearFr : _calendarObjectivesGearEn,
      'dashboard' => fr ? _dashboardFr : _dashboardEn,
      'add_trade' => fr ? _addTradeFr : _addTradeEn,
      'trade_page' => fr ? _tradePageFr : _tradePageEn,
      'checklist_page' => fr ? _checklistPageFr : _checklistPageEn,
      'checklist_trade' => fr ? _checklistTradeFr : _checklistTradeEn,
      'calendar' => fr ? _calendarFr : _calendarEn,
      'mental_state' => fr ? _mentalStateFr : _mentalStateEn,
      'my_strategy' => fr ? _strategyFr : _strategyEn,
      'my_analysis' => fr ? _analysisFr : _analysisEn,
      'performance' => fr ? _performanceFr : _performanceEn,
      'plus_menu' => fr ? _plusMenuFr : _plusMenuEn,
      'reglage' => fr ? _reglageFr : _reglageEn,
      'coach_ai' => fr ? _coachAiFr : _coachAiEn,
      _ => fr ? _overviewFr : _overviewEn,
    };
  }

  static const _overviewFr = <String>[
    'Barre du bas : Accueil · Stats · Trade · Journal · Plus (⋯).',
    'Plus (⋯) : Checklist, État mental, Stratégie, Analyse, Performance, Coach AI, Calculatrice, Réglages.',
    'Ajouter / modifier un trade : onglet Trade → + ou tape un trade ; discipline (checklist, plan, stratégie, état, tags) sur le formulaire.',
    'Données reliées : ce que tu saisis alimente Dashboard, Performance et le Coach AI (si Pro / essai).',
  ];
  static const _overviewEn = <String>[
    'Bottom bar: Home · Stats · Trade · Journal · More (⋯).',
    'More menu: Checklist, Mental state, Strategy, Analysis, Performance, Coach AI, Calculator, Settings.',
    'Add/edit trade: Trade tab → + or tap a trade; discipline blocks on the form.',
    'Data is shared across Dashboard, Performance, and Coach AI.',
  ];

  static const _disciplineGearFr = <String>[
    'Ajouter trade → ⚙ à côté de Principe / Feeling → « Réglages discipline ».',
    'Mode Feeling : autoriser ou non checklist, stratégie, plan, état du moment en mode Feeling.',
    'Session du jour : auto Principe/Feeling selon le n° du trade du jour (CSV inclus).',
    'Curseur 1–5 : ex. 2 = trades 1–2 Principe, à partir du 3ᵉ Feeling.',
    'SECTIONS : activer/masquer chaque bloc sur ce formulaire.',
  ];
  static const _disciplineGearEn = <String>[
    'Add trade → ⚙ next to Principle/Feeling → Discipline settings.',
    'Feeling mode: allow discipline sections while Feeling.',
    'Daily session: auto Principle/Feeling by trade order.',
    'Slider 1–5: e.g. 2 = first two Principle, then Feeling.',
    'SECTIONS toggles per block on this form.',
  ];

  static const _principeFeelingFr = <String>[
    'Ajouter trade : boutons Principe (plan respecté) et Feeling (hors plan / tilt).',
    'Un trade = un choix ; re-tape le bouton actif pour repasser en neutre.',
    '⚙ à côté : réglages session auto et sections visibles (voir Réglages discipline).',
    'Le tag est enregistré sur le trade et utilisé en Performance / Coach.',
  ];
  static const _principeFeelingEn = <String>[
    'Add trade: Principle vs Feeling buttons tag your mindset.',
    'Tap again to clear; one choice per save.',
    '⚙ opens discipline settings (auto session, visible sections).',
    'Saved on the trade for Performance and Coach.',
  ];

  static const _tagPsychFr = <String>[
    'Ajouter trade → section TAG (sous discipline) : FOMO, TILT, Revenge, etc.',
    'Coche un ou plusieurs tags avant d’enregistrer.',
    'Le Coach peut lister tes trades par tag (ex. « quels trades en TILT »).',
    'Sans tag : pas de liste filtrée — seulement stats globales.',
  ];
  static const _tagPsychEn = <String>[
    'Add trade → TAG section: FOMO, TILT, Revenge, etc.',
    'Select tags before saving.',
    'Coach can list trades by tag.',
    'No tag = no filtered trade list.',
  ];

  static const _importCsvFr = <String>[
    'Ajouter trade → section import / relevé (CSV, MT5, etc.).',
    '⚙ import : options selon le broker (mapping colonnes si proposé).',
    'Les trades importés comptent pour la session Principe/Feeling si activée.',
    'Complète ensuite checklist / tags sur chaque trade si besoin.',
  ];
  static const _importCsvEn = <String>[
    'Add trade → import / statement section.',
    '⚙ for import options per broker.',
    'Imports count for daily Principle/Feeling session if enabled.',
    'Add checklist/tags per trade afterward if needed.',
  ];

  static const _capitalGearFr = <String>[
    'Ajouter trade → cartes Capital / Gain : ⚙ à côté du capital.',
    'Définir capital de référence, commissions, affichage gain % ou absolu.',
    'Impacte le calcul PnL affiché sur le trade et le journal.',
  ];
  static const _capitalGearEn = <String>[
    'Add trade → Capital/Gain cards: ⚙ next to capital.',
    'Set reference capital, commissions, % vs absolute display.',
    'Affects PnL shown on trades.',
  ];

  static const _quantiteGearFr = <String>[
    'Ajouter trade → champ Quantité : ⚙ à droite.',
    'Ajouter des actifs personnalisés, presets de lot, classes d’actifs.',
    'Les favoris réapparaissent dans la liste déroulante actif.',
  ];
  static const _quantiteGearEn = <String>[
    'Add trade → Quantity field: ⚙ on the right.',
    'Custom symbols, lot presets, asset classes.',
    'Favorites appear in the asset dropdown.',
  ];

  static const _mentalStateGearFr = <String>[
    'Page État mental (Plus ou accueil) — ⚙ sur une section (émotions, sommeil, facteurs).',
    'Ajuster le poids % de chaque facteur dans le score global du jour.',
    'Sur une émotion : ⚙ pour renommer / options ; + pour ajouter une émotion.',
    'Ce n’est pas l’engrenage Principe/Feeling d’Ajouter trade.',
  ];
  static const _mentalStateGearEn = <String>[
    'Mental State page — ⚙ on a section (emotions, sleep, factors).',
    'Set weight % for global daily score.',
    'Per emotion: ⚙ rename/options; + add emotion.',
    'Not the Add-trade Principle/Feeling gear.',
  ];

  static const _calendarObjectivesGearFr = <String>[
    'Calendrier (Plus) : ⚙ près des objectifs du mois.',
    'Fixer objectifs financiers ou de discipline du mois.',
    'Barre de progression = avancement vs objectif.',
  ];
  static const _calendarObjectivesGearEn = <String>[
    'Calendar: ⚙ near monthly objectives.',
    'Set financial or discipline goals.',
    'Progress bar shows month advancement.',
  ];

  static const _dashboardFr = <String>[
    'Onglet Accueil (barre du bas) : capital, winrate, évolution.',
    'Cartes : checklist du jour, état mental, stratégie, analyse — tape pour ouvrir la page.',
    'Calendrier : tape une date pour voir les trades du jour.',
    'Meilleur / pire trade : tape pour ouvrir le détail.',
  ];
  static const _dashboardEn = <String>[
    'Home tab: capital, winrate, equity curve.',
    'Cards open Checklist, Mental state, Strategy, Analysis.',
    'Calendar: tap a day for trades.',
    'Best/worst trade chips are tappable.',
  ];

  static const _addTradeFr = <String>[
    'Trade → + ou ouvrir un trade : formulaire Ajouter trade.',
    'Haut : actif, entrée/sortie, quantité (⚙ actifs), capital (⚙ commissions).',
    'Milieu : Principe/Feeling + ⚙ discipline ; checklist, plan, stratégie, état, TAG psych.',
    'Bas : enregistrer — alimente Trade, Stats, Performance, Coach.',
  ];
  static const _addTradeEn = <String>[
    'Trade → + : Add trade form.',
    'Top: symbol, prices, qty (⚙ assets), capital (⚙ fees).',
    'Middle: Principle/Feeling + ⚙ discipline; checklist, plan, strategy, state, psych TAG.',
    'Save feeds Trade, Stats, Performance, Coach.',
  ];

  static const _tradePageFr = <String>[
    'Onglet Trade : journal chronologique.',
    'Filtres jour / semaine / mois en haut.',
    'Tape une ligne → Ajouter trade (édition) pour compléter discipline ou tags.',
  ];
  static const _tradePageEn = <String>[
    'Trade tab: chronological journal.',
    'Day/week/month filters.',
    'Tap a row to edit and complete discipline/tags.',
  ];

  static const _checklistPageFr = <String>[
    'Checklist : carte accueil ou Plus → Checklist.',
    'Section : ⋯ → Éditer (lignes, +, supprimer) ; « Ajouter une section » en bas.',
    'NEWS : interrupteur on/off ; rappels programmés sur le dashboard.',
    'Calendrier bas : historique des jours cochés.',
  ];
  static const _checklistPageEn = <String>[
    'Checklist: home card or More menu.',
    'Section ⋯ → Edit; Add section at bottom.',
    'NEWS toggle; scheduled reminders on dashboard.',
    'Bottom calendar: history.',
  ];

  static const _checklistTradeFr = <String>[
    'Trade → ouvrir un trade : bloc Checklist = % du jour d’entrée.',
    'Non-respect : cases sur ce trade.',
    'Modifier les items : page Checklist (pas sur le trade).',
  ];
  static const _checklistTradeEn = <String>[
    'Open a trade: Checklist block = entry-day %.',
    'Non-respect checkboxes on the trade.',
    'Edit items on Checklist page.',
  ];

  static const _calendarFr = <String>[
    'Plus → Calendrier : vue mensuelle PnL / discipline.',
    'Objectifs mois : ⚙ pour les définir.',
    'Tape un jour : détail trades et routine.',
  ];
  static const _calendarEn = <String>[
    'More → Calendar: monthly PnL/discipline.',
    'Monthly goals: ⚙ to set.',
    'Tap a day for detail.',
  ];

  static const _mentalStateFr = <String>[
    'Plus → État mental : curseurs du jour (focus, sommeil, stress…).',
    'Émotions : chips + ; ⚙ poids des facteurs dans le score global.',
    'Calendrier EM : historique ; synchronisé avec la carte accueil.',
    'Jour d’entrée d’un trade : EM du jour compte pour la discipline trade.',
  ];
  static const _mentalStateEn = <String>[
    'More → Mental state: daily sliders.',
    'Emotions: chips; ⚙ factor weights.',
    'Calendar + dashboard card stay in sync.',
    'Trade entry day uses that day’s mental state.',
  ];

  static const _strategyFr = <String>[
    'Plus → Stratégie : règles d’or, setups, sessions.',
    'Créer / éditer un setup ; calendrier d’usage des stratégies.',
    'Lier un setup sur Ajouter trade → section Stratégie.',
  ];
  static const _strategyEn = <String>[
    'More → Strategy: rules, setups, sessions.',
    'Edit setups; strategy calendar.',
    'Link setup on Add trade → Strategy section.',
  ];

  static const _analysisFr = <String>[
    'Plus → Mon analyse : plans et rapports PDF.',
    'Créer un plan ; l’attacher sur Ajouter trade → Plan d’analyse.',
    'Curseur % respect du plan + non-respect sur le trade.',
  ];
  static const _analysisEn = <String>[
    'More → Analysis: plans and PDF reports.',
    'Create a plan; attach on Add trade.',
    'Respect slider + non-respect on trade.',
  ];

  static const _performanceFr = <String>[
    'Plus → Performance (ou Stats barre du bas) : KPI, graphiques, Lens.',
    'Filtre trades enregistrés vs incomplets (discipline).',
    'Export rapport ; seuils stratégie / psychologie selon tes saisies.',
  ];
  static const _performanceEn = <String>[
    'More → Performance / Stats tab: KPIs, charts, Lens.',
    'Recorded vs incomplete discipline filter.',
    'Report export; thresholds from your data.',
  ];

  static const _plusMenuFr = <String>[
    'Bouton Plus (⋯) en bas à droite : menu radial / liste.',
    'Entrées : Checklist, État mental, Stratégie, Analyse, Performance, Coach AI, Calculatrice, Réglages.',
    'Certaines fonctions Pro : essai ou abonnement requis.',
  ];
  static const _plusMenuEn = <String>[
    'Plus (⋯) bottom-right: feature menu.',
    'Checklist, Mental state, Strategy, Analysis, Performance, Coach AI, Calculator, Settings.',
    'Some items need Pro/trial.',
  ];

  static const _reglageFr = <String>[
    'Plus → Réglages : compte, langue, portefeuilles / brokers, abonnement.',
    'Layout dashboard personnalisable (cartes).',
    'CGV, confidentialité, support.',
  ];
  static const _reglageEn = <String>[
    'More → Settings: account, language, portfolios, subscription.',
    'Custom dashboard layout.',
    'Legal, privacy, support.',
  ];

  static const _coachAiFr = <String>[
    'Plus → Coach AI (Pro / essai) : questions sur tes trades et l’app.',
    'Performance, tags psych, discipline : réponses basées sur ton journal.',
    'Questions « comment faire » : étapes écran par écran (mode d’emploi).',
  ];
  static const _coachAiEn = <String>[
    'More → Coach AI (Pro/trial): trading + app questions.',
    'Uses your journal for stats and how-to steps.',
    'How-to questions show on-screen steps.',
  ];
}
