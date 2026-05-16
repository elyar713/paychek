// Liens configurables pour la page Support & Feedback.
import 'paychek_support_public_inbox.dart';

abstract final class SupportFeedbackConfig {
  SupportFeedbackConfig._();

  static String get supportEmail => kPaychekSupportPublicInboxEmail;
}
