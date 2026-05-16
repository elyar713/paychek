/// Placeholders ARB pour [flutter gen-l10n] (clés @…).
void applyArbPlaceholderMetadata(Map<String, dynamic> map) {
  map['@deletePortfolioTitle'] = {
    'placeholders': {
      'name': {'type': 'String'},
    },
  };
  for (final pk in ['resultStatBullet1', 'resultStatBullet2']) {
    map['@$pk'] = {
      'placeholders': {
        'percent': {'type': 'int'},
      },
    };
  }
  map['@modelSavedSnackbar'] = {
    'placeholders': {
      'name': {'type': 'String'},
    },
  };
  map['@analyseCopyLabel'] = {
    'placeholders': {
      'label': {'type': 'String'},
    },
  };
  map['@analyseTemplateApplied'] = {
    'placeholders': {
      'name': {'type': 'String'},
    },
  };
  map['@mentalSleepImpact'] = {
    'placeholders': {
      'percent': {'type': 'int'},
    },
  };
  map['@analyseImpactLine'] = {
    'placeholders': {
      'percent': {'type': 'int'},
    },
  };
  map['@exportPdfFailedWithError'] = {
    'placeholders': {
      'error': {'type': 'String'},
    },
  };
  map['@analyseCopyNumber'] = {
    'placeholders': {
      'n': {'type': 'int'},
    },
  };
  map['@dashboardTradeCount'] = {
    'placeholders': {
      'count': {'type': 'int'},
    },
  };
  map['@dashboardPerfHourWinRate'] = {
    'placeholders': {
      'percent': {'type': 'int'},
    },
  };
}
