import 'package:flutter/material.dart';

/// Textes par défaut alignés sur l’onglet **Stratégie** (rétroaction « Ajouter trade »).
/// [StrategieMesReglesSection] utilise [mesReglesDor] avec la [Locale] de l’app.
abstract final class StrategieFeedbackReference {
  StrategieFeedbackReference._();

  static const List<String> mesReglesDorDefautFr = <String>[
    'Je ne trade jamais si mon état mental est inférieur à 50%.',
    'Pas de FOMO : Si je rate le mouvement, je ne cours pas après le prix. J\'attends la prochaine opportunité.',
    'Accepter la perte : Mon stop-loss n\'est jamais repoussé.',
  ];

  static const List<String> mesReglesDorDefautEn = <String>[
    'I never trade when my mental state is below 50%.',
    'No FOMO: if I miss the move, I do not chase price. I wait for the next opportunity.',
    'Accept the loss: my stop loss is never moved further away.',
  ];

  static const List<String> mesReglesDorDefautDe = <String>[
    'Ich trade nie, wenn mein mentaler Zustand unter 50 % liegt.',
    'Kein FOMO: Wenn ich den Move verpasse, jage ich dem Preis nicht hinterher. Ich warte auf die nächste Chance.',
    'Verlust akzeptieren: Mein Stop-Loss wird nie nach außen verschoben.',
  ];

  static const List<String> mesReglesDorDefautEs = <String>[
    'Nunca opero cuando mi estado mental está por debajo del 50 %.',
    'Sin FOMO: si pierdo el movimiento, no persigo el precio. Espero la próxima oportunidad.',
    'Aceptar la pérdida: mi stop loss nunca se aleja más.',
  ];

  static const List<String> mesReglesDorDefautPt = <String>[
    'Nunca opero quando meu estado mental está abaixo de 50%.',
    'Sem FOMO: se perco o movimento, não corro atrás do preço. Espero a próxima oportunidade.',
    'Aceitar a perda: meu stop nunca é afastado.',
  ];

  static const List<String> mesReglesDorDefautKo = <String>[
    '멘탈 상태가 50% 미만이면 절대 매매하지 않습니다.',
    'FOMO 없음: 움직임을 놓치면 가격을 쫓지 않습니다. 다음 기회를 기다립니다.',
    '손실 수용: 스탑로스는 절대 멀리 밀지 않습니다.',
  ];

  /// Liste initiale (FR) — pages Stratégie non localisées.
  static const List<String> mesReglesDorDefaut = mesReglesDorDefautFr;

  static List<String> mesReglesDor(Locale locale) {
    switch (locale.languageCode.toLowerCase()) {
      case 'fr':
        return mesReglesDorDefautFr;
      case 'de':
        return mesReglesDorDefautDe;
      case 'es':
        return mesReglesDorDefautEs;
      case 'pt':
        return mesReglesDorDefautPt;
      case 'ko':
        return mesReglesDorDefautKo;
      default:
        return mesReglesDorDefautEn;
    }
  }

  /// Même libellés / ordre que la grille « Gestion du risque » (valeurs par défaut).
  static const List<({String label, String valeur})> gestionRisqueDefautFr =
      <({String label, String valeur})>[
    (label: 'RISQUE MAX / TRADE', valeur: '1%'),
    (label: 'PERTE MAX / JOUR', valeur: '3%'),
    (label: 'TRADE / JOUR', valeur: '3\nMaximum'),
    (label: 'RATIO R/R', valeur: '1:2\nMinimum'),
  ];

  static const List<({String label, String valeur})> gestionRisqueDefautEn =
      <({String label, String valeur})>[
    (label: 'MAX RISK / TRADE', valeur: '1%'),
    (label: 'MAX LOSS / DAY', valeur: '3%'),
    (label: 'TRADES / DAY', valeur: '3\nMaximum'),
    (label: 'R/R RATIO', valeur: '1:2\nMinimum'),
  ];

  static const List<({String label, String valeur})> gestionRisqueDefautDe =
      <({String label, String valeur})>[
    (label: 'MAX. RISIKO / TRADE', valeur: '1%'),
    (label: 'MAX. VERLUST / TAG', valeur: '3%'),
    (label: 'TRADES / TAG', valeur: '3\nMaximum'),
    (label: 'R/R-VERHÄLTNIS', valeur: '1:2\nMinimum'),
  ];

  static const List<({String label, String valeur})> gestionRisqueDefautEs =
      <({String label, String valeur})>[
    (label: 'RIESGO MÁX / OPERACIÓN', valeur: '1%'),
    (label: 'PÉRDIDA MÁX / DÍA', valeur: '3%'),
    (label: 'OPERACIONES / DÍA', valeur: '3\nMáximo'),
    (label: 'RATIO R/R', valeur: '1:2\nMínimo'),
  ];

  static const List<({String label, String valeur})> gestionRisqueDefautPt =
      <({String label, String valeur})>[
    (label: 'RISCO MÁX / OPERAÇÃO', valeur: '1%'),
    (label: 'PERDA MÁX / DIA', valeur: '3%'),
    (label: 'OPERAÇÕES / DIA', valeur: '3\nMáximo'),
    (label: 'RATIO R/R', valeur: '1:2\nMínimo'),
  ];

  static const List<({String label, String valeur})> gestionRisqueDefautKo =
      <({String label, String valeur})>[
    (label: '거래당 최대 리스크', valeur: '1%'),
    (label: '일일 최대 손실', valeur: '3%'),
    (label: '일일 거래', valeur: '3\n최대'),
    (label: 'R/R 비율', valeur: '1:2\n최소'),
  ];

  static const List<({String label, String valeur})> gestionRisqueDefaut =
      gestionRisqueDefautFr;

  static List<({String label, String valeur})> gestionRisque(Locale locale) {
    switch (locale.languageCode.toLowerCase()) {
      case 'fr':
        return gestionRisqueDefautFr;
      case 'de':
        return gestionRisqueDefautDe;
      case 'es':
        return gestionRisqueDefautEs;
      case 'pt':
        return gestionRisqueDefautPt;
      case 'ko':
        return gestionRisqueDefautKo;
      default:
        return gestionRisqueDefautEn;
    }
  }

  /// Sessions par défaut (comme [StrategieHorairesSessionsSection] au chargement).
  static const List<({String titre, String sousTitre, String creneau})>
      horairesSessionsDefautFr =
      <({String titre, String sousTitre, String creneau})>[
    (
      titre: 'Session de Londres',
      sousTitre: 'Forte volatilité (Forex)',
      creneau: '09:00 - 11:30',
    ),
    (
      titre: 'Session de New York',
      sousTitre: 'Ouverture US (Indices)',
      creneau: '14:30 - 16:30',
    ),
    (
      titre: 'Zone Rouge (No Trade)',
      sousTitre: 'Fin de journée',
      creneau: 'Après 17:00',
    ),
  ];

  static const List<({String titre, String sousTitre, String creneau})>
      horairesSessionsDefautEn =
      <({String titre, String sousTitre, String creneau})>[
    (
      titre: 'London session',
      sousTitre: 'High volatility (Forex)',
      creneau: '09:00 - 11:30',
    ),
    (
      titre: 'New York session',
      sousTitre: 'US open (Indices)',
      creneau: '14:30 - 16:30',
    ),
    (
      titre: 'Red zone (no trade)',
      sousTitre: 'End of day',
      creneau: 'After 17:00',
    ),
  ];

  static const List<({String titre, String sousTitre, String creneau})>
      horairesSessionsDefautDe =
      <({String titre, String sousTitre, String creneau})>[
    (
      titre: 'London-Session',
      sousTitre: 'Hohe Volatilität (Forex)',
      creneau: '09:00 - 11:30',
    ),
    (
      titre: 'New-York-Session',
      sousTitre: 'US-Open (Indizes)',
      creneau: '14:30 - 16:30',
    ),
    (
      titre: 'Rote Zone (kein Trade)',
      sousTitre: 'Tagesende',
      creneau: 'Nach 17:00',
    ),
  ];

  static const List<({String titre, String sousTitre, String creneau})>
      horairesSessionsDefautEs =
      <({String titre, String sousTitre, String creneau})>[
    (
      titre: 'Sesión de Londres',
      sousTitre: 'Alta volatilidad (Forex)',
      creneau: '09:00 - 11:30',
    ),
    (
      titre: 'Sesión de Nueva York',
      sousTitre: 'Apertura EE. UU. (índices)',
      creneau: '14:30 - 16:30',
    ),
    (
      titre: 'Zona roja (sin operar)',
      sousTitre: 'Fin del día',
      creneau: 'Después de 17:00',
    ),
  ];

  static const List<({String titre, String sousTitre, String creneau})>
      horairesSessionsDefautPt =
      <({String titre, String sousTitre, String creneau})>[
    (
      titre: 'Sessão de Londres',
      sousTitre: 'Alta volatilidade (Forex)',
      creneau: '09:00 - 11:30',
    ),
    (
      titre: 'Sessão de Nova York',
      sousTitre: 'Abertura EUA (índices)',
      creneau: '14:30 - 16:30',
    ),
    (
      titre: 'Zona vermelha (sem operar)',
      sousTitre: 'Fim do dia',
      creneau: 'Após 17:00',
    ),
  ];

  static const List<({String titre, String sousTitre, String creneau})>
      horairesSessionsDefautKo =
      <({String titre, String sousTitre, String creneau})>[
    (
      titre: '런던 세션',
      sousTitre: '높은 변동성(포렉스)',
      creneau: '09:00 - 11:30',
    ),
    (
      titre: '뉴욕 세션',
      sousTitre: '미국 개장(지수)',
      creneau: '14:30 - 16:30',
    ),
    (
      titre: '레드 존(매매 금지)',
      sousTitre: '장 마감',
      creneau: '17:00 이후',
    ),
  ];

  static const List<({String titre, String sousTitre, String creneau})>
      horairesSessionsDefaut = horairesSessionsDefautFr;

  static List<({String titre, String sousTitre, String creneau})> horairesSessions(
    Locale locale,
  ) {
    switch (locale.languageCode.toLowerCase()) {
      case 'fr':
        return horairesSessionsDefautFr;
      case 'de':
        return horairesSessionsDefautDe;
      case 'es':
        return horairesSessionsDefautEs;
      case 'pt':
        return horairesSessionsDefautPt;
      case 'ko':
        return horairesSessionsDefautKo;
      default:
        return horairesSessionsDefautEn;
    }
  }

  /// Index 0..2 pour les trois sessions par défaut, ou null si titre personnalisé.
  static int? horairesSessionSlotIndex(String title) {
    final needle = title.trim().toLowerCase();
    for (var slot = 0; slot < 3; slot++) {
      for (final code in ['fr', 'en', 'de', 'es', 'pt', 'ko']) {
        final t = horairesSessions(Locale(code))[slot].titre.trim().toLowerCase();
        if (t == needle) return slot;
      }
    }
    const legacy = <String, int>{
      'london session': 0,
      'session de londres': 0,
      'session de new york': 1,
      'new york session': 1,
      'zone rouge (no trade)': 2,
      'red zone (no trade)': 2,
    };
    return legacy[needle];
  }

  /// Repère la plage horaire (créneau) d’une session par défaut (0..2), ou null.
  static int? horairesSessionSlotForCreneau(String creneau) {
    final needle = creneau.trim().toLowerCase();
    for (var slot = 0; slot < 3; slot++) {
      for (final code in ['fr', 'en', 'de', 'es', 'pt', 'ko']) {
        final c = horairesSessions(Locale(code))[slot].creneau.trim().toLowerCase();
        if (c == needle) return slot;
      }
    }
    return null;
  }
}
