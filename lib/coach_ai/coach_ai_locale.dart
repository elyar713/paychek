import 'coach_ai_query_text.dart';

/// Langues alignées sur [AppLocalizations.supportedLocales] (de, en, es, fr, ko, pt).
abstract final class CoachAiLocale {
  static String normalize(String code) =>
      CoachAiQueryText.normalizeCoachLanguageCode(code);

  static bool isFrench(String code) => normalize(code) == 'fr';

  static bool isEnglish(String code) => normalize(code) == 'en';

  /// Étapes help locales : FR ou EN (autres langues → EN, pas FR).
  static bool useFrenchHelpSteps(String code) => isFrench(code);

  /// Choix de texte UI / cartes coach.
  static String pick(
    String code, {
    required String fr,
    required String en,
    String? de,
    String? es,
    String? pt,
    String? ko,
  }) {
    return switch (normalize(code)) {
      'en' => en,
      'de' => de ?? en,
      'es' => es ?? en,
      'pt' => pt ?? en,
      'ko' => ko ?? en,
      _ => fr,
    };
  }

  /// Consigne cloud : réponse entière dans la langue cible.
  static String mustRespondIn(String code) {
    return switch (normalize(code)) {
      'en' => 'MANDATORY: Write the entire answer in English.',
      'de' => 'PFLICHT: Schreibe die gesamte Antwort auf Deutsch.',
      'es' => 'OBLIGATORIO: Escribe toda la respuesta en español.',
      'pt' => 'OBRIGATÓRIO: Escreva toda a resposta em português.',
      'ko' => '필수: 전체 답변을 한국어로 작성하세요.',
      _ => 'OBLIGATOIRE : réponds entièrement en français.',
    };
  }

  static String welcomeMessage(String code) {
    return pick(
      code,
      fr:
          'Bonjour, je suis ton AI Coach. Pose-moi une question sur ton trading, ta discipline, ta stratégie ou l’utilisation de PAYCHEK.',
      en:
          'Hello, I am your AI Coach. Ask me about your trading, discipline, strategy, or how to use PAYCHEK.',
      de:
          'Hallo, ich bin dein AI Coach. Frag mich zu Trading, Disziplin, Strategie oder der PAYCHEK-App.',
      es:
          'Hola, soy tu AI Coach. Pregúntame sobre tu trading, disciplina, estrategia o el uso de PAYCHEK.',
      pt:
          'Olá, sou o teu AI Coach. Pergunta sobre trading, disciplina, estratégia ou o uso do PAYCHEK.',
      ko:
          '안녕하세요, AI 코치입니다. 트레이딩, 규율, 전략 또는 PAYCHEK 사용법에 대해 질문해 주세요.',
    );
  }

  static String whereToTapHeading(String code) => pick(
        code,
        fr: 'Où cliquer dans l’app :',
        en: 'Where to tap in the app:',
        de: 'Wo in der App tippen:',
        es: 'Dónde tocar en la app:',
        pt: 'Onde tocar na app:',
        ko: '앱에서 누를 위치:',
      );

  static String inPaychekHeading(String code) => pick(
        code,
        fr: 'Dans PAYCHEK :',
        en: 'In PAYCHEK:',
        de: 'In PAYCHEK:',
        es: 'En PAYCHEK:',
        pt: 'No PAYCHEK:',
        ko: 'PAYCHEK에서:',
      );
}
