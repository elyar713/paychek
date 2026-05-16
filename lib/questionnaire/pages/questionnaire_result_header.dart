import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../../l10n/app_localizations.dart';

/// En-tÃªte rÃ©sultat : titre + slogan (localisÃ©s).
class QuestionnaireResultHeader extends StatelessWidget {
  const QuestionnaireResultHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isWideWeb = kIsWeb && MediaQuery.sizeOf(context).width >= 900;
    final titleStyle = Theme.of(context).textTheme.headlineSmall?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          height: 1.2,
          fontSize: isWideWeb ? 28 : null,
        );
    final sloganStyle = Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.w400,
          height: 1.45,
          fontSize: isWideWeb ? 13 : null,
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.resultDontWorry,
          textAlign: TextAlign.center,
          style: titleStyle,
        ),
        SizedBox(height: isWideWeb ? 10 : 12),
        Text(
          l10n.resultHeaderSub,
          textAlign: TextAlign.center,
          style: sloganStyle,
          softWrap: true,
        ),
      ],
    );
  }
}



