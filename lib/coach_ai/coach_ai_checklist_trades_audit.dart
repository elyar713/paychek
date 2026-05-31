import 'coach_ai_query_text.dart';

/// Checklist **sur les trades** (discipline enregistrée / non-respect) — pas la page Checklist du jour.
abstract final class CoachAiChecklistTradesAudit {
  static bool mentionsChecklist(String question) {
    final q = CoachAiQueryText.forMatching(question);
    return RegExp(r'che?ck\s*list|checklist|checkliste|cheklist|chekliste').hasMatch(q) ||
        CoachAiQueryText.containsAny(q, ['checklist', 'chekliste', 'cheklist']);
  }

  /// « Checklist avec mes trades, tu peux faire un audit ? »
  static bool isAuditQuestion(String question) {
    final q = CoachAiQueryText.forMatching(question);
    if (!mentionsChecklist(q)) return false;
    if (!RegExp(r'\btrades?\b|\bjournal\b').hasMatch(q)) return false;
    if (RegExp(
      r'audit|bilan|discipline|enregistr|non.?respect|respect|manquant|couverture|'
      r'combien|taux|pourcent',
    ).hasMatch(q)) {
      return true;
    }
    return RegExp(r'peux|possible|tu peux|faire un|faire une').hasMatch(q) &&
        RegExp(r'audit|bilan|analys').hasMatch(q);
  }
}
