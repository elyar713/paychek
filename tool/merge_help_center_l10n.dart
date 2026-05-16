// Run: dart run tool/merge_help_center_l10n.dart
import 'dart:convert';
import 'dart:io';

final _root = Directory.current;
final _l10n = Directory('${_root.path}/lib/l10n');

Future<void> main() async {
  final enRaw = await File('${_l10n.path}/app_en.arb').readAsString();
  final en = jsonDecode(enRaw) as Map<String, dynamic>;
  final helpKeys = en.keys.where((k) => k.startsWith('helpCenter')).toList()..sort();

  const supportSection = <String, String>{
    'fr': 'Aide et support',
    'de': 'Support',
    'es': 'Soporte',
    'pt': 'Suporte',
    'ko': '지원',
  };

  const chrome = <String, Map<String, String>>{
    'de': {
      'helpCenterTitle': 'Hilfe-Center',
      'helpCenterSubtitle': 'Kurzantworten und Erklärungen zur Nutzung der App.',
      'helpCenterSearchHint': 'Suchen…',
      'helpCenterVersionMobile': 'Mobile-Ansicht',
      'helpCenterVersionWeb': 'Web-Ansicht',
      'helpCenterEmptyResults': 'Keine Treffer.',
      'helpCenterArticleAddTradeTitle': 'Trade hinzufügen',
      'helpCenterArticleEditTradeTitle': 'Trade- und Journal-Übersicht',
      'helpCenterArticleChecklistTitle': 'Checkliste',
      'helpCenterArticleCalendarTitle': 'Kalender',
      'helpCenterArticleMentalStateTitle': 'Mentaler Zustand',
      'helpCenterArticleExportPdfTitle': 'PDF exportieren',
      'helpCenterArticleResetDataTitle': 'Lokale Daten löschen',
      'helpCenterArticleMyStrategyTitle': 'Meine Strategie — Playbook',
      'helpCenterArticleMyAnalysisTitle': 'Meine Analyse — Tradingpläne',
      'helpCenterArticlePerformanceTitle': 'Performance — Trading-Scanner',
    },
    'es': {
      'helpCenterTitle': 'Centro de ayuda',
      'helpCenterSubtitle': 'Respuestas rápidas y explicaciones para usar la app.',
      'helpCenterSearchHint': 'Buscar…',
      'helpCenterVersionMobile': 'Versión móvil',
      'helpCenterVersionWeb': 'Versión web',
      'helpCenterEmptyResults': 'Sin resultados.',
      'helpCenterArticleAddTradeTitle': 'Añadir un trade',
      'helpCenterArticleEditTradeTitle': 'Diario — página de trade',
      'helpCenterArticleChecklistTitle': 'Lista de comprobación',
      'helpCenterArticleCalendarTitle': 'Calendario',
      'helpCenterArticleMentalStateTitle': 'Estado mental',
      'helpCenterArticleExportPdfTitle': 'Exportar PDF',
      'helpCenterArticleResetDataTitle': 'Borrar datos locales',
      'helpCenterArticleMyStrategyTitle': 'Mi estrategia — Playbook',
      'helpCenterArticleMyAnalysisTitle': 'Mi análisis — planes de trading',
      'helpCenterArticlePerformanceTitle': 'Rendimiento — escáner de trading',
    },
    'pt': {
      'helpCenterTitle': 'Central de ajuda',
      'helpCenterSubtitle': 'Respostas rápidas e explicações sobre o uso do app.',
      'helpCenterSearchHint': 'Pesquisar…',
      'helpCenterVersionMobile': 'Versão móvel',
      'helpCenterVersionWeb': 'Versão Web',
      'helpCenterEmptyResults': 'Sem resultados.',
      'helpCenterArticleAddTradeTitle': 'Adicionar um trade',
      'helpCenterArticleEditTradeTitle': 'Diário — página do trade',
      'helpCenterArticleChecklistTitle': 'Checklist',
      'helpCenterArticleCalendarTitle': 'Calendário',
      'helpCenterArticleMentalStateTitle': 'Estado mental',
      'helpCenterArticleExportPdfTitle': 'Exportar PDF',
      'helpCenterArticleResetDataTitle': 'Apagar dados locais',
      'helpCenterArticleMyStrategyTitle': 'Minha estratégia — Playbook',
      'helpCenterArticleMyAnalysisTitle': 'Minha análise — planos de trade',
      'helpCenterArticlePerformanceTitle': 'Desempenho — scanner de trades',
    },
    'ko': {
      'helpCenterTitle': '고객센터',
      'helpCenterSubtitle': '앱 사용에 대한 간단한 답변과 설명을 확인하세요.',
      'helpCenterSearchHint': '검색…',
      'helpCenterVersionMobile': '모바일 버전',
      'helpCenterVersionWeb': '웹 버전',
      'helpCenterEmptyResults': '결과가 없습니다.',
      'helpCenterArticleAddTradeTitle': '거래 추가',
      'helpCenterArticleEditTradeTitle': '트레이드 — 일지 화면',
      'helpCenterArticleChecklistTitle': '체크리스트',
      'helpCenterArticleCalendarTitle': '캘린더',
      'helpCenterArticleMentalStateTitle': '멘탈 상태',
      'helpCenterArticleExportPdfTitle': 'PDF 내보내기',
      'helpCenterArticleResetDataTitle': '로컬 데이터 삭제',
      'helpCenterArticleMyStrategyTitle': '내 전략 — 플레이북',
      'helpCenterArticleMyAnalysisTitle': '내 분석 — 트레이딩 플랜',
      'helpCenterArticlePerformanceTitle': '퍼포먼스 — 트레이딩 스캐너',
    },
  };

  const shortBody = <String, Map<String, String>>{
    'de': {
      'helpCenterArticleAddTradeBody':
          'Öffne den Tab „Hinzufügen“, fülle die Felder aus (Asset, Einstieg, Stop, Ziel …) und speichere. Optional kannst du einen Screenshot anhängen.',
      'helpCenterArticleExportPdfBody':
          'Unter „Trade“ oder „Performance“ „PDF exportieren“ wählen. Schlägt es fehl, Berechtigungen prüfen und erneut versuchen.',
      'helpCenterArticleResetDataBody':
          'Unter Einstellungen > Daten kannst du die auf diesem Gerät gespeicherten Daten löschen. Das lässt sich nicht rückgängig machen; einen App-Neustart danach empfehlen wir.',
    },
    'es': {
      'helpCenterArticleAddTradeBody':
          'Ve a la pestaña Añadir, rellena los campos (activo, entrada, stop, objetivo…) y guarda. Puedes adjuntar una captura si lo necesitas.',
      'helpCenterArticleExportPdfBody':
          'En Trade o Rendimiento, usa Exportar PDF. Si falla, revisa los permisos e inténtalo de nuevo.',
      'helpCenterArticleResetDataBody':
          'En Ajustes > Datos puedes borrar los datos guardados en este dispositivo. Es irreversible; conviene reiniciar la app después.',
    },
    'pt': {
      'helpCenterArticleAddTradeBody':
          'Vá ao separador Adicionar, preencha os campos (ativo, entrada, stop, alvo…) e guarde. Pode anexar uma captura de ecrã se precisar.',
      'helpCenterArticleExportPdfBody':
          'Em Trade ou Desempenho, use Exportar PDF. Se falhar, verifique as permissões e tente novamente.',
      'helpCenterArticleResetDataBody':
          'Em Definições > Dados pode apagar os dados guardados neste dispositivo. É irreversível; recomendamos reiniciar a app depois.',
    },
    'ko': {
      'helpCenterArticleAddTradeBody':
          '추가 탭에서 필드를 입력하세요(종목, 진입, 손절, 목표 등). 저장하면 됩니다. 필요하면 스크린샷을 첨부할 수 있습니다.',
      'helpCenterArticleExportPdfBody':
          '트레이드 또는 퍼포먼스에서 PDF 내보내기를 사용하세요. 실패하면 권한을 확인한 뒤 다시 시도하세요.',
      'helpCenterArticleResetDataBody':
          '설정 > 데이터에서 이 기기에 저장된 데이터를 지울 수 있습니다. 되돌릴 수 없으며, 이후 앱을 다시 시작하는 것이 좋습니다.',
    },
  };

  for (final loc in ['de', 'es', 'pt', 'ko']) {
    final path = '${_l10n.path}/app_$loc.arb';
    final arb = jsonDecode(await File(path).readAsString()) as Map<String, dynamic>;

    arb['settingsSupportSection'] = supportSection[loc]!;
    for (final k in helpKeys) {
      arb[k] = en[k];
    }
    chrome[loc]!.forEach((k, v) {
      arb[k] = v;
    });
    shortBody[loc]!.forEach((k, v) {
      arb[k] = v;
    });

    await File(path).writeAsString(_writeArb(arb));
    stdout.writeln('Updated app_$loc.arb (${helpKeys.length} help keys)');
  }

  final frPath = '${_l10n.path}/app_fr.arb';
  final fr = jsonDecode(await File(frPath).readAsString()) as Map<String, dynamic>;
  fr['settingsSupportSection'] = supportSection['fr']!;
  fr['helpCenterTitle'] = 'Centre d’aide';
  fr['helpCenterSubtitle'] =
      'Réponses rapides et explications pour utiliser l’app.';
  fr['helpCenterSearchHint'] = 'Rechercher…';
  fr['helpCenterVersionMobile'] = 'Version mobile';
  fr['helpCenterVersionWeb'] = 'Version Web';
  fr['helpCenterEmptyResults'] = 'Aucun résultat.';
  fr['helpCenterArticleAddTradeTitle'] = 'Ajouter un trade';
  fr['helpCenterArticleAddTradeBody'] =
      'Va dans l’onglet Ajouter, remplis les champs (actif, entrée, stop, objectif…), puis enregistre. Tu peux joindre une capture si besoin.';
  fr['helpCenterArticleExportPdfTitle'] = 'Exporter un PDF';
  fr['helpCenterArticleExportPdfBody'] =
      'Depuis Trade ou Performance, utilise Exporter en PDF. En cas d’échec, vérifie les autorisations et réessaie.';
  fr['helpCenterArticleResetDataTitle'] = 'Effacer les données locales';
  fr['helpCenterArticleResetDataBody'] =
      'Dans Réglages > Données, tu peux effacer les données stockées sur cet appareil. C’est irréversible ; un redémarrage de l’app est recommandé ensuite.';
  await File(frPath).writeAsString(_writeArb(fr));
  stdout.writeln('Updated app_fr.arb (FR chrome + short stubs)');
}

String _writeArb(Map<String, dynamic> arb) {
  final enc = JsonEncoder.withIndent('  ');
  return '${enc.convert(arb)}\n';
}
