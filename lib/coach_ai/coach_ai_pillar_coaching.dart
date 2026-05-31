import 'coach_ai_query_text.dart';
import 'coach_ai_response_format.dart';

/// « Comment améliorer ma stratégie à 60 % ? » → coaching actionnable, pas audit ENREGISTRÉ.
/// Stats pilier pour réponses locales Coach.
class PillarCoachingStats {
  const PillarCoachingStats({
    required this.id,
    required this.title,
    required this.recorded,
    required this.total,
    required this.nonRespect,
    required this.winrateRecorded,
    required this.pnlRecorded,
  });

  final String id;
  final String title;
  final int recorded;
  final int total;
  final int nonRespect;
  final double winrateRecorded;
  final double pnlRecorded;

  int get missing => total - recorded;
  int get completionPercent => total > 0 ? (recorded * 100 / total).round() : 0;
  int get weaknessScore => missing * 2 + nonRespect * 5;
}

abstract final class CoachAiPillarCoaching {
  static const String focus = 'pillar_improvement';

  /// « Tu penses quoi de ma stratégie ? », « quel est ton avis sur mon setup ? »
  static bool isStrategyOpinionQuestion(String question) {
    final q = CoachAiQueryText.forMatching(question);
    if (!RegExp(r'strat|setup|playbook').hasMatch(q)) return false;
    return RegExp(
      r"qu'en penses|que penses|pense[s-]? tu|ton avis|what do you think|"
      r"comment tu vois|tu en dis quoi|ton opinion|"
      r'tu penses? comment|tu pense comment|what do you think of|'
      r'comment.{0,25}(ma strat|mon setup|my strategy)|'
      r'c.?est (bien|correct|solide|nul|mauvais).{0,20}strat',
    ).hasMatch(q);
  }

  /// « Quels points renforcer ? », « quel point prioriser ? »
  static bool isReinforcementQuestion(String question) {
    final q = CoachAiQueryText.forMatching(question);
    return RegExp(
      r'quels? points?|quel(le)?s? points?|quelle point|'
      r'point.{0,35}renforcer|renforcer|renforce|'
      r'faiblesse|travail.{0,30}renforcer|priorit|'
      r'what.{0,25}strengthen|what.{0,25}focus on|'
      r'ou concentrer|sur quoi me concentrer',
    ).hasMatch(q);
  }

  /// « Donne-moi un système d'entraînement », « programme 4 semaines »…
  static bool isTrainingSystemQuestion(String question) {
    final q = CoachAiQueryText.forMatching(question);
    return RegExp(
      r'systeme\s+d.?entrainement|système\s+d.?entraînement|'
      r'programme\s+d.?entrainement|plan\s+d.?entrainement|'
      r'\bentrainement\b|\bentraînement\b|training\s+system|'
      r'programme\s+(4\s+)?semaines?|planning\s+semaine',
    ).hasMatch(q);
  }

  static bool isImprovementQuestion(String question) {
    if (isTrainingSystemQuestion(question)) return true;
    if (isReinforcementQuestion(question)) return true;
    final q = CoachAiQueryText.forMatching(question);
    if (q.isEmpty) return false;

    if (RegExp(
      r'où\s+(est|se trouve)|where\s+is|comment\s+(modifier|ajouter|créer|creer|configurer|accéder|acceder)',
    ).hasMatch(q) &&
        RegExp(r'page|onglet|menu|bouton|engrenage|⚙').hasMatch(q)) {
      return false;
    }

    final hasTopic = RegExp(
      r'strat(é|e)gie|strategy|setup|playbook|checklist|analyse|analysis|plan|'
      r'état mental|etat mental|mental state|discipline|respect|pilier',
    ).hasMatch(q);
    if (!hasTopic) return false;

    return RegExp(
      r'comment\s+(j.?)?\s*(améliorer|ameliorer|ameliore|mieux|travailler|booster|renforcer|optimiser|'
      r'atteindre|viser|passer|monter|augmenter)|'
      r'je\s+veux\s+(améliorer|ameliorer|ameliore|mieux|travailler|booster|renforcer|optimiser)|'
      r"j'?aimerais\s+(améliorer|ameliorer|ameliore)|"
      r'how\s+(can\s+)?i\s+improve|how\s+to\s+improve|what\s+should\s+i\s+do|'
      r'conseils?\s+pour|plan\s+pour|roadmap|'
      r'dit.?moi.{0,30}(astuce|conseil|solution)|'
      r'\bastuces?\b|'
      r'quelle(s)?\s+solution|'
      r'(solution|conseil|astuce).{0,35}(améliorer|ameliorer|ameliore|mieux)|'
      r'(améliorer|ameliorer|ameliore).{0,35}(solution|conseil|astuce)|'
      r'donne[\s-]?moi.{0,40}(solution|conseil|astuce)|'
      r'give\s+me.{0,40}(solution|tip|advice)|'
      r'(que\s+(me\s+)?|tu\s+(me\s+)?)proposes?|'
      r'que\s+faire\s+pour|'
      r'aide[\s-]?moi\s+(à|a)\s+(améliorer|ameliorer|ameliore)|'
      r'besoin\s+d.?aide\s+(sur|pour).{0,20}(strat|checklist|analyse|mental|discipline)',
    ).hasMatch(q);
  }

  /// Question centrée sur la stratégie (pas un comparatif 4 piliers).
  static bool isStrategyScopedQuestion(String question) {
    final q = CoachAiQueryText.forMatching(question);
    return RegExp(
      r'ma strat|mon setup|de ma strat|sur ma strat|my strategy|'
      r'cette strat|du setup|breakout',
    ).hasMatch(q);
  }

  static String resolvePillarId(String question) {
    final q = CoachAiQueryText.forMatching(question);
    if (RegExp(r'checklist').hasMatch(q)) return 'checklist';
    if (RegExp(r'analyse|analysis|plan d.?analyse').hasMatch(q)) return 'analysis';
    if (RegExp(r'état mental|etat mental|mental state|\bmental\b|psycho|émotion|emotion')
        .hasMatch(q)) {
      return 'mental';
    }
    return 'strategy';
  }

  static String pillarTitle(String pillarId, String languageCode) {
    if (languageCode == 'fr') {
      return switch (pillarId) {
        'checklist' => 'Checklist',
        'analysis' => 'Analyse',
        'mental' => 'État mental',
        _ => 'Stratégie',
      };
    }
    return switch (pillarId) {
      'checklist' => 'Checklist',
      'analysis' => 'Analysis',
      'mental' => 'Mental state',
      _ => 'Strategy',
    };
  }

  static int? extractTargetPercent(String question) {
    final q = CoachAiQueryText.forMatching(question);
    final pct = RegExp(r'(\d{1,3})\s*%').firstMatch(q);
    if (pct != null) return int.tryParse(pct.group(1)!);
    final bare = RegExp(
      r'(?:à|a|to|vers|atteindre|viser|passer)\s+(\d{1,3})\b',
    ).firstMatch(q);
    if (bare != null) return int.tryParse(bare.group(1)!);
    return null;
  }

  static Map<String, dynamic> contextToJson({
    required String pillarId,
    required String pillarTitle,
    required int tradesTotal,
    required int recorded,
    required int missing,
    required int nonRespect,
    required double? winrateRecorded,
    required double? pnlRecorded,
    required int? targetPercent,
    required String languageCode,
  }) {
    final completionPercent =
        tradesTotal > 0 ? ((recorded * 100) / tradesTotal).round() : 0;
    return <String, dynamic>{
      'pillarId': pillarId,
      'pillarTitle': pillarTitle,
      'targetPercent': targetPercent,
      'tradesTotal': tradesTotal,
      'recordedCount': recorded,
      'missingCount': missing,
      'completionPercent': completionPercent,
      'nonRespectCount': nonRespect,
      'winrateRecordedPercent': ?winrateRecorded,
      'pnlRecorded': ?pnlRecorded,
      'fillHintPath': languageCode == 'fr'
          ? 'Ajouter un trade → lier checklist, analyse, stratégie et état mental'
          : 'Add Trade → link checklist, analysis, strategy and mental state',
      'coachInstructions': CoachAiResponseFormat.pillarImprovementInstructions(languageCode),
    };
  }

  /// Réponse locale si le cloud (Gemini / deploy) est indisponible.
  static String buildLocalAnswer({
    required String pillarId,
    required String pillarTitle,
    required int tradesTotal,
    required int recorded,
    required int missing,
    required int nonRespect,
    required double winrateRecorded,
    required double pnlRecorded,
    required int? targetPercent,
    required String languageCode,
  }) {
    final pct = tradesTotal > 0 ? ((recorded * 100) / tradesTotal).round() : 0;
    final wr = winrateRecorded.toStringAsFixed(0);
    final intro = _buildImprovementIntro(
      pillarTitle: pillarTitle,
      tradesTotal: tradesTotal,
      recorded: recorded,
      missing: missing,
      nonRespect: nonRespect,
      winrateRecorded: winrateRecorded,
      pnlRecorded: pnlRecorded,
      pct: pct,
      targetPercent: targetPercent,
      languageCode: languageCode,
    );
    final setupHint = _buildPillarSetupHint(pillarId: pillarId, languageCode: languageCode);
    final nonRespectLine = _buildNonRespectLine(
      nonRespect: nonRespect,
      languageCode: languageCode,
    );
    final closer = _buildImprovementCloser(
      pillarTitle: pillarTitle,
      pct: pct,
      recorded: recorded,
      tradesTotal: tradesTotal,
      languageCode: languageCode,
    );
    final trainingBlock = shouldIncludeTrainingSystem(pillarId: pillarId, completionPercent: pct)
        ? '\n\n${_buildIntegratedTrainingSection(
            pillarId: pillarId,
            pillarTitle: pillarTitle,
            tradesTotal: tradesTotal,
            recorded: recorded,
            nonRespect: nonRespect,
            winrateRecorded: winrateRecorded,
            pnlRecorded: pnlRecorded,
            languageCode: languageCode,
          )}'
        : '';

    if (languageCode == 'fr') {
      return '$intro\n\n'
          '1. (Renseignement) Sur chaque nouveau trade : Ajouter trade → lie ta $pillarTitle avant d’exécuter. '
          'Tu es à $recorded/$tradesTotal trades renseignés ($pct %) — vise +2 trades/semaine bien documentés.\n'
          '2. (Non-respect) $nonRespectLine\n'
          '3. (Setup) $setupHint\n'
          '4. (Revue) 1×/semaine : filtre les 5 derniers trades avec $pillarTitle liée — winrate $wr%, PnL $pnlRecorded. '
          'Cherche : entrée hors plan ? sortie par peur ? perte trop grande ?\n'
          '5. (Discipline) Si état mental faible ou 2 non-respect d’affilée → pas de trade (règle d’or PAYCHEK).\n\n'
          '$closer$trainingBlock';
    }
    return '$intro\n\n'
        '1. (Logging) On every new trade: Add Trade → link $pillarTitle before execution. '
        'You are at $recorded/$tradesTotal logged ($pct %) — aim for +2 well-documented trades per week.\n'
        '2. (Violations) $nonRespectLine\n'
        '3. (Setup) $setupHint\n'
        '4. (Review) Weekly: review last 5 trades with $pillarTitle linked — $wr% WR, PnL $pnlRecorded. '
        'Look for: off-plan entries? fear exits? oversized losses?\n'
        '5. (Discipline) Low mental state or 2 violations in a row → no trade (PAYCHEK gold rule).\n\n'
        '$closer$trainingBlock';
  }

  /// Programme 4 semaines intégré au plan Stratégie quand le journal est peu documenté.
  static bool shouldIncludeTrainingSystem({
    required String pillarId,
    required int completionPercent,
  }) {
    return pillarId == 'strategy' && completionPercent < 50;
  }

  static String _buildImprovementIntro({
    required String pillarTitle,
    required int tradesTotal,
    required int recorded,
    required int missing,
    required int nonRespect,
    required double winrateRecorded,
    required double pnlRecorded,
    required int pct,
    required int? targetPercent,
    required String languageCode,
  }) {
    final wr = winrateRecorded.toStringAsFixed(0);
    final goalNote = targetPercent != null
        ? (languageCode == 'fr'
            ? ' Objectif ~$targetPercent % = part de trades avec $pillarTitle liée (pas un winrate garanti).'
            : ' Target ~$targetPercent % = share of trades with $pillarTitle linked (not a guaranteed winrate).')
        : '';

    if (languageCode == 'fr') {
      if (pct < 15 || missing > nonRespect * 2) {
        final scope = pct < 15
            ? 'presque tout ton journal'
            : 'une grande partie de ton journal';
        return 'Pour améliorer ta $pillarTitle : tu renseignes seulement $pct % de tes trades ($recorded/$tradesTotal) — '
            'sur $scope, tu trades encore sans plan clair.$goalNote '
            'Sur les $recorded documentés : winrate $wr%, PnL $pnlRecorded — l’idée peut tenir, mais sans trace tu ne sauras jamais quoi corriger.';
      }
      if (pct < 50) {
        return 'Pour améliorer ta $pillarTitle : tu renseignes seulement $pct % de tes trades ($recorded/$tradesTotal) — '
            'tu trades encore souvent sans plan clair.$goalNote '
            'Sur les $recorded documentés : winrate $wr%, PnL $pnlRecorded — l’idée peut tenir, mais sans trace tu ne sauras jamais quoi corriger.';
      }
      if (nonRespect > 0 && nonRespect >= recorded ~/ 3) {
        return 'Pour améliorer ta $pillarTitle : tu documentes mieux ($recorded/$tradesTotal), '
            'mais $nonRespect non-respect montrent que tu entres souvent contre ton propre plan.$goalNote '
            'Corriger l’exécution vaut plus qu’un nouveau setup — c’est le levier le plus rentable cette semaine.';
      }
      if (pnlRecorded < 0 && winrateRecorded >= 40) {
        return 'Pour améliorer ta $pillarTitle : $wr% de winrate sur les trades documentés, '
            'mais PnL $pnlRecorded — le problème n’est probablement pas ton analyse, '
            'c’est la taille des pertes ou les sorties anticipées.$goalNote';
      }
      return 'Pour améliorer ta $pillarTitle : bonne base ($recorded/$tradesTotal renseignés, winrate $wr%).$goalNote '
          'L’enjeu maintenant : zéro non-respect volontaire et constance semaine après semaine.';
    }

    if (pct < 15 || missing > nonRespect * 2) {
      final scope = pct < 15
          ? 'almost your entire journal'
          : 'much of your journal';
      return 'To improve your $pillarTitle: only $pct% of trades are logged ($recorded/$tradesTotal) — '
          'on $scope you still trade without a clear plan.$goalNote '
          'On the $recorded logged: $wr% WR, PnL $pnlRecorded — the idea may work, but without logs you cannot fix what breaks.';
    }
    if (pct < 50) {
      return 'To improve your $pillarTitle: only $pct% of trades are logged ($recorded/$tradesTotal) — '
          'you often trade without a clear plan.$goalNote '
          'On the $recorded logged: $wr% WR, PnL $pnlRecorded — the idea may work, but without logs you cannot fix what breaks.';
    }
    if (nonRespect > 0 && nonRespect >= recorded ~/ 3) {
      return 'To improve your $pillarTitle: better logging ($recorded/$tradesTotal), '
          'but $nonRespect violations show you often trade against your own plan.$goalNote '
          'Fixing execution beats changing the setup — highest ROI this week.';
    }
    if (pnlRecorded < 0 && winrateRecorded >= 40) {
      return 'To improve your $pillarTitle: $wr% WR on logged trades but PnL $pnlRecorded — '
          'the issue is likely loss size or early exits, not the core analysis.$goalNote';
    }
    return 'To improve your $pillarTitle: solid base ($recorded/$tradesTotal logged, $wr% WR).$goalNote '
        'Next lever: zero avoidable violations and weekly consistency.';
  }

  static String _buildPillarSetupHint({
    required String pillarId,
    required String languageCode,
  }) {
    if (languageCode == 'fr') {
      return switch (pillarId) {
        'analysis' =>
          'Page Analyse : rédige ou épingle ton plan du jour (bias, S/R, invalidation) — vérifie qu’il matche le marché actuel (TF, volume).',
        'checklist' =>
          'Checklist : valide chaque item avant d’entrer — si un point manque, tu trades sans filet.',
        'mental' =>
          'État mental : note ton score avant chaque entrée — sous ton seuil, la règle PAYCHEK dit stop.',
        _ =>
          'Page Stratégie : vérifie que ton setup épinglé correspond au marché du jour (TF, volume, invalidation).',
      };
    }
    return switch (pillarId) {
      'analysis' =>
        'Analysis page: write or star today’s plan (bias, S/R, invalidation) — confirm it fits current market (TF, volume).',
      'checklist' =>
        'Checklist: validate every item before entry — missing one means trading without a safety net.',
      'mental' =>
        'Mental state: log your score before each entry — below your threshold, PAYCHEK says stop.',
      _ =>
        'Strategy page: confirm your starred setup fits today’s market (TF, volume, invalidation).',
    };
  }

  static String _buildNonRespectLine({
    required int nonRespect,
    required String languageCode,
  }) {
    if (nonRespect == 0) {
      return languageCode == 'fr'
          ? 'Aucun non-respect relevé — garde cette discipline et lie quand même chaque trade pour capitaliser dessus.'
          : 'No violations logged — keep that discipline and still link every trade to build on it.';
    }
    return languageCode == 'fr'
        ? 'Tu as $nonRespect non-respect : pour chacun, note l’item ignoré + la règle « si X → je ne trade pas ».'
        : 'You have $nonRespect rule breaks: for each, note what you ignored and a clear « if X → no trade » rule.';
  }

  static String _buildImprovementCloser({
    required String pillarTitle,
    required int pct,
    required int recorded,
    required int tradesTotal,
    required String languageCode,
  }) {
    final projected = tradesTotal > 0
        ? ((recorded + 8) * 100 / tradesTotal).round().clamp(0, 100)
        : pct;
    if (languageCode == 'fr') {
      return '→ Prochaine session : lie ta $pillarTitle avant le premier clic. '
          '+2 trades/semaine bien documentés → tu passes de $pct % à ~$projected % en un mois — '
          'assez pour que le coach t’aide vraiment sur tes pertes.';
    }
    return '→ Next session: link your $pillarTitle before the first click. '
        '+2 logged trades/week → you move from $pct% to ~$projected% in a month — '
        'enough for the coach to actually help with your losses.';
  }

  static String _buildIntegratedTrainingSection({
    required String pillarId,
    required String pillarTitle,
    required int tradesTotal,
    required int recorded,
    required int nonRespect,
    required double winrateRecorded,
    required double pnlRecorded,
    required String languageCode,
  }) {
    final bridge = languageCode == 'fr'
        ? '—— Système d’entraînement PAYCHEK (4 semaines) ——\n'
            'Applique ce calendrier après les 5 actions ci-dessus :\n\n'
        : '—— PAYCHEK 4-week training system ——\n'
            'Apply this calendar after the 5 actions above:\n\n';
    return '$bridge${_buildTrainingSystemBody(
      pillarId: pillarId,
      pillarTitle: pillarTitle,
      tradesTotal: tradesTotal,
      recorded: recorded,
      nonRespect: nonRespect,
      winrateRecorded: winrateRecorded,
      pnlRecorded: pnlRecorded,
      languageCode: languageCode,
    )}';
  }

  static String _buildTrainingSystemBody({
    required String pillarId,
    required String pillarTitle,
    required int tradesTotal,
    required int recorded,
    required int nonRespect,
    required double winrateRecorded,
    required double pnlRecorded,
    required String languageCode,
  }) {
    final w1Target = recorded + 2;
    final w2Target = recorded + 4;
    final w3Target = recorded + 6;
    final w4Target = recorded + 8;
    final pct4 = tradesTotal > 0
        ? ((w4Target * 100) / tradesTotal).round().clamp(0, 100)
        : 0;
    final setupPage = pillarId == 'strategy'
        ? (languageCode == 'fr' ? 'Page Stratégie' : 'Strategy page')
        : pillarTitle;

    if (languageCode == 'fr') {
      final week3 = pnlRecorded < 0 && winrateRecorded >= 50
          ? 'Semaine 3 — PnL (tu gagnes souvent mais PnL $pnlRecorded)\n'
              '• Règle fixe : perte max = 1R, objectif min = 1,5R — pas de sortie avant stop ou RR prévu.\n'
              '• Interdit : sortie par peur sur un trade gagnant.\n'
              '• Revue : sur tes 3 derniers gains documentés, as-tu coupé trop tôt ?\n'
              '• KPI : PnL de la semaine ≥ 0 sur les trades avec $pillarTitle liée.\n'
          : 'Semaine 3 — Exécution\n'
              '• Chaque trade : stop et RR écrits avant l’entrée ($setupPage + Ajouter trade).\n'
              '• Revue mi-semaine : 3 trades — respect du plan oui/non.\n'
              '• KPI : $w3Target trades liés cumulés, PnL semaine stable.\n';

      return 'Semaine 1 — TRACE (rien d’autre)\n'
          '• Avant chaque clic broker : $setupPage → setup épinglé validé → Ajouter trade → $pillarTitle liée.\n'
          '• Interdit cette semaine : changer de setup ou trader « au feeling ».\n'
          '• Soir : cocher respect / non-respect honnêtement.\n'
          '• KPI : +2 trades documentés ($recorded → $w1Target).\n\n'
          'Semaine 2 — NON-RESPECT ZÉRO (nouveaux trades)\n'
          '• Matin : relire tes $nonRespect non-respect passés → 1 règle « si X → je ne trade pas » par type d’erreur.\n'
          '• Garde-fou : signal incomplet (TF, volume, invalidation) → pas de trade.\n'
          '• 2 non-respect d’affilée → fin de session.\n'
          '• KPI : 0 non-respect sur les trades de la semaine, $w2Target trades liés cumulés.\n\n'
          '$week3\n'
          'Semaine 4 — CONSOLIDATION\n'
          '• Objectif : $w4Target trades avec $pillarTitle liée (~$pct4 % du journal).\n'
          '• Revue hebdo : 5 derniers trades liés — entrée hors plan ? peur ? perte trop grande ?\n'
          '• Max 1 ajustement de setup si les données le justifient (pas avant $w4Target trades).\n'
          '• KPI : +2 trades documentés, discipline stable 2 semaines de suite.\n\n'
          'Règles d’or (tout le mois)\n'
          '• Pas de trade sans $pillarTitle liée.\n'
          '• État mental bas → stop.\n'
          '• Ne change pas de playbook tant que tu n’as pas $w4Target+ trades liés avec exécution propre.\n\n'
          '→ Démarre demain : semaine 1, trade n°1 avec $pillarTitle liée avant le clic.';
    }

    final week3 = pnlRecorded < 0 && winrateRecorded >= 50
        ? 'Week 3 — PnL (you win often but PnL $pnlRecorded)\n'
            '• Fixed rule: max loss = 1R, min target = 1.5R — no exit before stop or planned RR.\n'
            '• Banned: fear exits on winning trades.\n'
            '• Review: last 3 documented wins — did you cut too early?\n'
            '• KPI: week PnL ≥ 0 on trades with $pillarTitle linked.\n'
        : 'Week 3 — Execution\n'
            '• Every trade: stop and RR written before entry ($setupPage + Add Trade).\n'
            '• Mid-week review: 3 trades — plan respected yes/no.\n'
            '• KPI: $w3Target linked trades cumulative.\n';

    return 'Week 1 — TRACE (only)\n'
        '• Before every broker click: $setupPage → validate starred setup → Add Trade → link $pillarTitle.\n'
        '• Banned this week: new setup or “feeling” trades.\n'
        '• Evening: honest respect / violation check.\n'
        '• KPI: +2 documented trades ($recorded → $w1Target).\n\n'
        'Week 2 — ZERO NEW VIOLATIONS\n'
        '• Morning: review your $nonRespect past violations → one « if X → no trade » rule each.\n'
        '• Guardrail: incomplete signal (TF, volume, invalidation) → no trade.\n'
        '• 2 violations in a row → end session.\n'
        '• KPI: 0 violations on new trades, $w2Target linked cumulative.\n\n'
        '$week3\n'
        'Week 4 — CONSOLIDATION\n'
        '• Target: $w4Target trades with $pillarTitle linked (~$pct4% of journal).\n'
        '• Weekly review: last 5 linked trades — off-plan? fear? oversized loss?\n'
        '• Max 1 setup tweak if data supports it (not before $w4Target linked trades).\n'
        '• KPI: +2 logged trades, stable discipline 2 weeks in a row.\n\n'
        'Gold rules (all month)\n'
        '• No trade without $pillarTitle linked.\n'
        '• Low mental state → stop.\n'
        '• Do not change playbook until $w4Target+ linked trades with clean execution.\n\n'
        '→ Start tomorrow: week 1, trade #1 with $pillarTitle linked before the click.';
  }

  /// Réponse autonome (autres piliers ou demande explicite hors plan intégré).
  static String buildTrainingSystemAnswer({
    required String pillarId,
    required String pillarTitle,
    required int tradesTotal,
    required int recorded,
    required int nonRespect,
    required double winrateRecorded,
    required double pnlRecorded,
    required String languageCode,
  }) {
    final pct = tradesTotal > 0 ? ((recorded * 100) / tradesTotal).round() : 0;
    final wr = winrateRecorded.toStringAsFixed(0);
    if (shouldIncludeTrainingSystem(pillarId: pillarId, completionPercent: pct)) {
      return buildLocalAnswer(
        pillarId: pillarId,
        pillarTitle: pillarTitle,
        tradesTotal: tradesTotal,
        recorded: recorded,
        missing: tradesTotal - recorded,
        nonRespect: nonRespect,
        winrateRecorded: winrateRecorded,
        pnlRecorded: pnlRecorded,
        targetPercent: null,
        languageCode: languageCode,
      );
    }

    final headline = languageCode == 'fr'
        ? 'Tu es à $recorded/$tradesTotal sur $pillarTitle ($pct %). '
            'Programme 4 semaines pour documenter, respecter ton plan et stabiliser tes résultats :\n\n'
        : 'You are at $recorded/$tradesTotal on $pillarTitle ($pct%). '
            '4-week plan to log, respect your plan and stabilize results:\n\n';

    if (languageCode == 'fr' && pillarId == 'strategy') {
      return 'Ton setup peut fonctionner ($wr% WR sur $recorded trades liés), '
          'mais avec seulement $pct % du journal documenté et $nonRespect non-respect, '
          'tu ne peux pas encore prouver quoi corriger.\n\n$headline'
          '${_buildTrainingSystemBody(
            pillarId: pillarId,
            pillarTitle: pillarTitle,
            tradesTotal: tradesTotal,
            recorded: recorded,
            nonRespect: nonRespect,
            winrateRecorded: winrateRecorded,
            pnlRecorded: pnlRecorded,
            languageCode: languageCode,
          )}';
    }

    return '$headline${_buildTrainingSystemBody(
      pillarId: pillarId,
      pillarTitle: pillarTitle,
      tradesTotal: tradesTotal,
      recorded: recorded,
      nonRespect: nonRespect,
      winrateRecorded: winrateRecorded,
      pnlRecorded: pnlRecorded,
      languageCode: languageCode,
    )}';
  }

  static List<PillarCoachingStats> statsFromPillars({
    required int tradesTotal,
    required List<({
      String id,
      String title,
      int recorded,
      int nonRespect,
      double winrateRecorded,
      double pnlRecorded,
    })> pillars,
  }) {
    return [
      for (final p in pillars)
        PillarCoachingStats(
          id: p.id,
          title: p.title,
          recorded: p.recorded,
          total: tradesTotal,
          nonRespect: p.nonRespect,
          winrateRecorded: p.winrateRecorded,
          pnlRecorded: p.pnlRecorded,
        ),
    ];
  }

  /// Avis coach sur le setup épinglé + exécution journalière.
  static String buildLocalStrategyOpinionAnswer({
    required bool hasSetup,
    required String setupTitle,
    required String patternHint,
    required PillarCoachingStats strategy,
    required String languageCode,
  }) {
    final wr = strategy.winrateRecorded.toStringAsFixed(0);
    final setupLine = hasSetup && setupTitle.trim().isNotEmpty
        ? 'Ton setup « $setupTitle »'
        : 'Ta stratégie PAYCHEK';

    if (languageCode == 'fr') {
      final verdict = strategy.recorded < 15
          ? '$setupLine est structuré (breakout + volume, invalidation claire), mais tu ne l’as presque pas testé sur ton journal — difficile d’avoir un avis honnête tant que tu ne lies pas la stratégie trade après trade.'
          : strategy.nonRespect > strategy.recorded ~/ 2
              ? '$setupLine est cohérent sur le papier ; sur ${strategy.recorded} trades documentés le problème vient surtout des ${strategy.nonRespect} non-respect, pas du concept.'
              : '$setupLine tient la route : sur les trades documentés, winrate $wr% — l’enjeu est surtout la constance d’exécution et le respect du risque.';

      return 'Tu me demandes mon avis — voici ma lecture directe :\n\n'
          '$verdict\n\n'
          '1. (Points forts) Signal M15 + volume au-dessus de la moyenne et stop sous la mèche : c’est lisible et reproductible${patternHint.isEmpty ? '.' : ' ($patternHint).'}\n'
          '2. (Point faible) Seulement ${strategy.recorded} trades sur ${strategy.total} avec stratégie liée : sans trace, tu optimises à l’aveugle.\n'
          '3. (Exécution) PnL ${strategy.pnlRecorded} avec $wr% de winrate documenté : surveille taille de perte vs gains (RR et sorties anticipées).\n'
          '4. (Conclusion) Je garderais ce setup et je travaillerais d’abord la discipline (documenter + zéro non-respect volontaire) avant d’en changer un mot.';
    }

    final verdict = strategy.recorded < 15
        ? '$setupLine looks solid on paper (breakout + volume, clear invalidation), but you barely linked it in your journal — hard to judge until every trade is logged.'
        : strategy.nonRespect > strategy.recorded ~/ 2
            ? '$setupLine is coherent; on ${strategy.recorded} logged trades, ${strategy.nonRespect} violations matter more than the concept.'
            : '$setupLine holds up: $wr% WR on logged trades — consistency and risk respect are the main levers.';

    return 'You asked what I think — here is my direct read:\n\n'
        '$verdict\n\n'
        '1. (Strengths) M15 close + volume spike with stop under the wick is clear and repeatable.\n'
        '2. (Weakness) Only ${strategy.recorded} of ${strategy.total} trades linked to strategy — optimize with data, not guesses.\n'
        '3. (Execution) PnL ${strategy.pnlRecorded} at $wr% WR: watch loss size vs winners (RR and early exits).\n'
        '4. (Bottom line) Keep the setup; fix logging and honest non-respect before changing the playbook.';
  }

  /// Coaching sur la stratégie uniquement (répond à la question, pas un tableau de stats).
  static String buildLocalStrategyReinforcementAnswer({
    required PillarCoachingStats strategy,
    required List<String> topViolationLabels,
    required String languageCode,
  }) {
    final wr = strategy.winrateRecorded.toStringAsFixed(0);
    final viol = topViolationLabels.isEmpty
        ? null
        : topViolationLabels.take(3).join(', ');

    if (languageCode == 'fr') {
      final intro = strategy.missing > strategy.nonRespect
          ? 'Tu me demandes quoi renforcer sur ta stratégie : le premier levier n’est pas de changer de setup, c’est de documenter chaque trade (seulement ${strategy.recorded} sur ${strategy.total} ont une stratégie liée). Sans trace, tu ne peux pas savoir quoi corriger.'
          : 'Tu me demandes quoi renforcer sur ta stratégie : ton setup peut tenir la route (${strategy.recorded} trades documentés, winrate $wr%), mais tu as ${strategy.nonRespect} non-respect — le levier numéro un est l’exécution honnête des règles, pas un nouveau playbook.';

      final nonRespectLine = viol == null
          ? '2. (Non-respect) Après chaque trade, coche ce que tu as vraiment respecté ; si tu ignores une règle, note pourquoi avant le prochain signal.'
          : '2. (Non-respect) Règles les plus souvent cassées : $viol — revois-les en fin de session et ajoute un garde-fou « si je suis tenté de violer → pas de trade ».';

      final training = shouldIncludeTrainingSystem(
        pillarId: 'strategy',
        completionPercent: strategy.completionPercent,
      )
          ? '\n\n${_buildIntegratedTrainingSection(
              pillarId: 'strategy',
              pillarTitle: 'Stratégie',
              tradesTotal: strategy.total,
              recorded: strategy.recorded,
              nonRespect: strategy.nonRespect,
              winrateRecorded: strategy.winrateRecorded,
              pnlRecorded: strategy.pnlRecorded,
              languageCode: languageCode,
            )}'
          : '';

      return '$intro\n\n'
          '1. (Priorité) Avant le prochain clic : Ajouter trade → stratégie liée + signal M15/volume validés ; objectif : +2 trades documentés cette semaine.\n'
          '$nonRespectLine\n'
          '3. (Exécution) PnL ${strategy.pnlRecorded} malgré $wr% de winrate sur les trades documentés : vérifie le stop sous la mèche de breakout et la sortie au RR prévu (pas sortie anticipée par peur).\n'
          '4. (Garde-fou) Deux non-respect stratégie d’affilée ou état mental bas → fin de session (règle d’or PAYCHEK).$training';
    }

    final intro = strategy.missing > strategy.nonRespect
        ? 'You asked what to reinforce in your strategy: don’t change the setup yet — log strategy on every trade (only ${strategy.recorded} of ${strategy.total} are linked). Without data you can’t fix what’s broken.'
        : 'You asked what to reinforce: the setup may be fine (${strategy.recorded} logged, $wr% WR) but ${strategy.nonRespect} rule breaks mean honest execution matters more than a new playbook.';

    final nonRespectLine = viol == null
        ? '2. (Violations) After each trade, honestly mark non-respect before taking the next signal.'
        : '2. (Violations) Most broken rules: $viol — review them after the session.';

    final training = shouldIncludeTrainingSystem(
      pillarId: 'strategy',
      completionPercent: strategy.completionPercent,
    )
        ? '\n\n${_buildIntegratedTrainingSection(
            pillarId: 'strategy',
            pillarTitle: 'Strategy',
            tradesTotal: strategy.total,
            recorded: strategy.recorded,
            nonRespect: strategy.nonRespect,
            winrateRecorded: strategy.winrateRecorded,
            pnlRecorded: strategy.pnlRecorded,
            languageCode: languageCode,
          )}'
        : '';

    return '$intro\n\n'
        '1. (Priority) Before the next entry: Add Trade → link strategy + confirm M15/volume signal; aim for +2 logged trades this week.\n'
        '$nonRespectLine\n'
        '3. (Execution) PnL ${strategy.pnlRecorded} with $wr% WR on logged trades: honor breakout-candle stop and planned RR exits.\n'
        '4. (Guardrail) Two strategy violations in a row or low mental state → stop trading for the day.$training';
  }

  /// Répond à « quels points renforcer » sur un pilier (coaching, pas listing de KPIs).
  static String buildLocalReinforcementAnswer({
    required List<PillarCoachingStats> pillars,
    String? highlightPillarId,
    required String languageCode,
    List<String> topViolationLabels = const [],
  }) {
    if (pillars.isEmpty) {
      return languageCode == 'fr'
          ? 'Renseigne tes trades dans Ajouter trade pour que je puisse te dire quoi renforcer.'
          : 'Log trades in Add Trade so I can tell you what to reinforce.';
    }
    final sorted = [...pillars]..sort((a, b) => b.weaknessScore.compareTo(a.weaknessScore));
    final p = highlightPillarId == null
        ? sorted.first
        : sorted.firstWhere(
            (x) => x.id == highlightPillarId,
            orElse: () => sorted.first,
          );
    if (p.id == 'strategy' || highlightPillarId == 'strategy') {
      return buildLocalStrategyReinforcementAnswer(
        strategy: p,
        topViolationLabels: topViolationLabels,
        languageCode: languageCode,
      );
    }
    return buildLocalPillarCoachingAnswer(
      pillar: p,
      languageCode: languageCode,
      topViolationLabels: topViolationLabels,
    );
  }

  static String buildLocalPillarCoachingAnswer({
    required PillarCoachingStats pillar,
    required String languageCode,
    List<String> topViolationLabels = const [],
  }) {
    final wr = pillar.winrateRecorded.toStringAsFixed(0);
    final viol = topViolationLabels.take(2).join(', ');
    final title = pillar.title;

    if (languageCode == 'fr') {
      return 'Sur ta $title, voici ce que je te conseille de renforcer en priorité :\n\n'
          '1. (Trace) Lie ta $title sur chaque trade avant d’exécuter — tu es à ${pillar.recorded}/${pillar.total} ; sans ça, aucun conseil ne t’aide vraiment.\n'
          '2. (Non-respect) ${pillar.nonRespect} non-respect : ${viol.isEmpty ? "après chaque session, note l’item ignoré et la règle « si X → je ne trade pas »." : "focus : $viol."}\n'
          '3. (Exécution) Winrate $wr% sur les trades documentés, PnL ${pillar.pnlRecorded} : le problème est souvent la taille des pertes ou les sorties, pas l’idée de base.\n'
          '4. (Semaine) Objectif concret : +2 trades bien renseignés et zéro non-respect volontaire sur ce pilier.';
    }
    return 'On your $title, here is what to reinforce first:\n\n'
        '1. (Logging) Link $title on every trade before entry — you are at ${pillar.recorded}/${pillar.total}.\n'
        '2. (Violations) ${pillar.nonRespect} breaks: ${viol.isEmpty ? "log what you ignored after each session." : "focus: $viol."}\n'
        '3. (Execution) $wr% WR on logged trades, PnL ${pillar.pnlRecorded}: often exits and loss size, not the core idea.\n'
        '4. (This week) +2 well-logged trades, zero avoidable violations on this pillar.';
  }

  /// Détection large : stratégie + intention coaching (évite l’audit « ENREGISTRÉ »).
  static bool looksLikeStrategyCoaching(String question, {String? priorFocus}) {
    final q = CoachAiQueryText.forMatching(question);
    final strategyThread = priorFocus == focus ||
        priorFocus == 'strategie' ||
        priorFocus == 'strategy_today';
    final mentionsStrategy =
        RegExp(r'strat|setup|playbook|breakout').hasMatch(q);
    final coachingIntent = RegExp(
      r'amélior|amelior|solution|astuce|conseil|renforc|avis|pense|'
      r'point|plan|propose|donne[\s-]?moi|que faire|aide[\s-]?moi|'
      r'comment|pourquoi|mieux|optimis|travaill|priorit|faiblesse|'
      r'feeling|suivre|respect|discipline|n.?arrive pas|pas suivi|'
      r'give me|how can i|what should i|tips?|advice',
    ).hasMatch(q);

    if (mentionsStrategy && coachingIntent) return true;
    if (strategyThread && coachingIntent) return true;
    return false;
  }

  /// Trades au feeling / ne tient pas la stratégie (récit court).
  static bool isStrategyDisciplineStruggle(String question) {
    final q = CoachAiQueryText.forMatching(question);
    return RegExp(
      r'feeling|au feeling|hors[\s-]?plan|'
      r'n.?arrive pas.{0,35}(suivre|respect|tenir)|'
      r'ne (tiens|suis) pas.{0,25}strat|pas suivi.{0,20}strat',
    ).hasMatch(q) &&
        RegExp(r'j.?ai|trade|strat|feeling|discipline').hasMatch(q);
  }

  static bool shouldAnswerLocally(String question, {String? priorFocus}) {
    if (isStrategyDisciplineStruggle(question)) return true;
    if (isStrategyOpinionQuestion(question) ||
        isImprovementQuestion(question) ||
        isReinforcementQuestion(question)) {
      return true;
    }
    if (looksLikeStrategyCoaching(question, priorFocus: priorFocus)) {
      return true;
    }
    if (priorFocus == focus ||
        priorFocus == 'strategie' ||
        priorFocus == 'strategy_today') {
      final q = CoachAiQueryText.forMatching(question);
      if (RegExp(
        r'point|renforcer|renforce|priorit|faiblesse|solution|astuce|conseil|'
        r'amélior|amelior|propose|donne|mieux|avis|pense|comment|aide|plan|oui mais',
      ).hasMatch(q)) {
        return true;
      }
    }
    return false;
  }

  /// Si le chargement journal / setup échoue, on affiche quand même un conseil (pas l’erreur cloud).
  static String buildEmergencyFallback(String languageCode) {
    if (languageCode == 'fr') {
      return 'Voici mon conseil sur ta stratégie PAYCHEK :\n\n'
          '1. Lie ta stratégie sur chaque trade (Ajouter trade) avant d’exécuter — sans trace, impossible de savoir quoi corriger.\n'
          '2. Respecte ton signal (M15 + volume) et ton stop sous la mèche de breakout ; note chaque non-respect honnêtement.\n'
          '3. Deux violations d’affilée ou état mental bas → fin de session.\n'
          '4. Revue hebdo : 5 derniers trades documentés, RR et sorties (pas de sortie par peur).\n'
          '5. Ne change pas de setup tant que tu n’as pas 15+ trades liés avec discipline stable.';
    }
    return 'Strategy coaching (PAYCHEK):\n\n'
        '1. Link strategy on every trade before entry — no logs, no fixes.\n'
        '2. Honor your signal (M15 + volume) and breakout-candle stop; log every violation.\n'
        '3. Two violations in a row or low mental state → stop for the day.\n'
        '4. Weekly review: last 5 logged trades, RR and exits.\n'
        '5. Don’t change the setup until 15+ linked trades with stable discipline.';
  }
}
