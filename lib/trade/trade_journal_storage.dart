import 'dart:convert';
import 'dart:typed_data';

import 'package:shared_preferences/shared_preferences.dart';

import '../ajouter_trade/ajouter_trade_asset_class.dart';
import '../analyse/analyse_report_snapshot.dart';
import '../analyse/analyse_report_snapshot_codec.dart';
import '../reglage/paychek_prefs_scope.dart';
import '../reglage/user_portfolio_models.dart';
import 'trade_journal_mindset_migration.dart';
import 'trade_models.dart';

const _kBase = 'trade_journal_items_v1';
const _jsonRootV = 1;

String _prefsKey({String? firebaseUidOverride}) {
  if (firebaseUidOverride != null && firebaseUidOverride.trim().isNotEmpty) {
    return paychekScopedPrefsKeyForUid(_kBase, firebaseUidOverride);
  }
  return paychekScopedPrefsKey(_kBase);
}

Map<String, dynamic> _encodeTrade(TradeListItem t) {
  return <String, dynamic>{
    'id': t.id,
    'pair': t.pair,
    'side': t.side == TradeSide.vente ? 'vente' : 'achat',
    'amountLabel': t.amountLabel,
    'gainAmount': t.gainAmount,
    'commissionAmount': t.commissionAmount,
    'dateLine': t.dateLine,
    'entreeAt': t.entreeAt.toIso8601String(),
    'sortieAt': t.sortieAt?.toIso8601String(),
    'breakeven': t.breakeven,
    'avantNews': t.avantNews,
    'apresNews': t.apresNews,
    'quantiteLabel': t.quantiteLabel,
    'screenshotPath': t.screenshotPath,
    'screenshotBytesB64': t.screenshotBytes != null
        ? base64Encode(t.screenshotBytes!)
        : null,
    'prixEntreeLabel': t.prixEntreeLabel,
    'prixSortieLabel': t.prixSortieLabel,
    'checklistPct': t.checklistPct,
    'planPct': t.planPct,
    'strategiePct': t.strategiePct,
    'etatPct': t.etatPct,
    'mindset': switch (t.mindset) {
      TradeMindset.feeling => 'feeling',
      TradeMindset.none => 'none',
      TradeMindset.principe => 'principe',
    },
    'mindsetExplicit': t.mindsetExplicit,
    'strategieTitle': t.strategieTitle,
    'planReport': t.planReport == null
        ? null
        : encodeAnalyseReportSnapshot(t.planReport!),
    'linkedAnalyseReport': t.linkedAnalyseReport == null
        ? null
        : encodeAnalyseReportSnapshot(t.linkedAnalyseReport!),
    'linkedAnalysePdfBytesB64': t.linkedAnalysePdfBytes != null
        ? base64Encode(t.linkedAnalysePdfBytes!)
        : null,
    'linkedAnalysePdfFileName': t.linkedAnalysePdfFileName,
    'strategieNonRespectIds': t.strategieNonRespectIds.toList(),
    'planNonRespectIds': t.planNonRespectIds.toList(),
    'checklistNonRespectIds': t.checklistNonRespectIds.toList(),
    'etatNonRespectIds': t.etatNonRespectIds.toList(),
    'isProfit': t.isProfit,
    'assetClass': t.assetClass?.name,
    'performanceLite': t.performanceLite,
    'portfolioId': t.portfolioId,
    'psychTags': t.psychTags,
    if (t.userNote != null && t.userNote!.trim().isNotEmpty)
      'userNote': t.userNote!.trim(),
    'syncRev': t.syncRev,
  };
}

AjouterTradeAssetClass? _decodeAssetClass(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  for (final e in AjouterTradeAssetClass.values) {
    if (e.name == raw) return e;
  }
  return null;
}

TradeListItem? _decodeTrade(Map<String, dynamic> m) {
  try {
    final id = m['id'] as String?;
    final pair = m['pair'] as String?;
    if (id == null || pair == null) return null;

    final sideRaw = m['side'] as String?;
    final side = sideRaw == 'vente' ? TradeSide.vente : TradeSide.achat;

    final entreeAt = DateTime.tryParse(m['entreeAt'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0);
    final sortieRaw = m['sortieAt'] as String?;
    final sortieAt =
        sortieRaw != null && sortieRaw.isNotEmpty ? DateTime.tryParse(sortieRaw) : null;

    final mindsetRaw = m['mindset'] as String?;
    final performanceLite = m['performanceLite'] as bool? ?? false;
    final mindsetExplicit = m['mindsetExplicit'] as bool? ??
        legacyMindsetExplicitFromMap(
          mindsetRaw: mindsetRaw,
          performanceLite: performanceLite,
        );
    final TradeMindset mindset;
    if (performanceLite) {
      mindset = TradeMindset.none;
    } else {
      mindset = switch (mindsetRaw) {
        'feeling' => TradeMindset.feeling,
        'none' => TradeMindset.none,
        'principe' => TradeMindset.principe,
        _ => TradeMindset.principe,
      };
    }

    AnalyseReportSnapshot? planReport;
    final pr = m['planReport'];
    if (pr is Map) {
      planReport = decodeAnalyseReportSnapshot(Map<String, dynamic>.from(pr));
    }

    AnalyseReportSnapshot? linkedAnalyseReport;
    final lar = m['linkedAnalyseReport'];
    if (lar is Map) {
      linkedAnalyseReport =
          decodeAnalyseReportSnapshot(Map<String, dynamic>.from(lar));
    }

    Uint8List? linkedAnalysePdfBytes;
    final lapb = m['linkedAnalysePdfBytesB64'] as String?;
    if (lapb != null && lapb.isNotEmpty) {
      try {
        linkedAnalysePdfBytes = Uint8List.fromList(base64Decode(lapb));
      } catch (_) {}
    }

    Uint8List? screenshotBytes;
    final b64 = m['screenshotBytesB64'] as String?;
    if (b64 != null && b64.isNotEmpty) {
      try {
        screenshotBytes = Uint8List.fromList(base64Decode(b64));
      } catch (_) {}
    }

    List<String> stringList(String key) {
      final raw = m[key];
      if (raw is! List) return const [];
      return [for (final e in raw) e.toString()];
    }

    Set<String> stringSet(String key) => stringList(key).toSet();

    return TradeListItem(
      id: id,
      pair: pair,
      side: side,
      amountLabel: m['amountLabel'] as String? ?? '',
      gainAmount: (m['gainAmount'] as num?)?.toDouble() ?? 0,
      commissionAmount: (m['commissionAmount'] as num?)?.toDouble() ?? 0,
      dateLine: m['dateLine'] as String? ?? '',
      entreeAt: entreeAt,
      sortieAt: sortieAt,
      breakeven: m['breakeven'] as bool? ?? false,
      avantNews: m['avantNews'] as bool? ?? false,
      apresNews: m['apresNews'] as bool? ?? false,
      quantiteLabel: m['quantiteLabel'] as String?,
      screenshotPath: m['screenshotPath'] as String?,
      screenshotBytes: screenshotBytes,
      prixEntreeLabel: m['prixEntreeLabel'] as String?,
      prixSortieLabel: m['prixSortieLabel'] as String?,
      checklistPct: (m['checklistPct'] as num?)?.toDouble() ?? 0,
      planPct: (m['planPct'] as num?)?.toDouble() ?? 0,
      strategiePct: (m['strategiePct'] as num?)?.toDouble() ?? 0,
      etatPct: (m['etatPct'] as num?)?.toDouble() ?? 0,
      mindset: mindset,
      mindsetExplicit: mindsetExplicit,
      strategieTitle: m['strategieTitle'] as String? ?? '',
      planReport: planReport,
      linkedAnalyseReport: linkedAnalyseReport,
      linkedAnalysePdfBytes: linkedAnalysePdfBytes,
      linkedAnalysePdfFileName: m['linkedAnalysePdfFileName'] as String?,
      strategieNonRespectIds: stringSet('strategieNonRespectIds'),
      planNonRespectIds: stringSet('planNonRespectIds'),
      checklistNonRespectIds: stringSet('checklistNonRespectIds'),
      etatNonRespectIds: stringSet('etatNonRespectIds'),
      isProfit: m['isProfit'] as bool? ?? true,
      assetClass: _decodeAssetClass(m['assetClass'] as String?),
      performanceLite: performanceLite,
      portfolioId: m['portfolioId'] as String? ?? kDefaultPortfolioId,
      psychTags: stringList('psychTags'),
      userNote: () {
        final raw = m['userNote'] as String?;
        if (raw == null) return null;
        final t = raw.trim();
        return t.isEmpty ? null : t;
      }(),
      syncRev: (m['syncRev'] as num?)?.round() ?? 0,
    );
  } catch (_) {
    return null;
  }
}

/// Même décodage que les prefs (sync cloud / disque).
TradeListItem? tradeJournalTradeFromMap(Map<String, dynamic> m) => _decodeTrade(m);

/// Carte pour Firestore : pas de capture base64 (limite taille doc 1 Mo) — les bytes restent en local.
Map<String, dynamic> tradeJournalTradeToMapForFirestore(TradeListItem t) {
  final m = Map<String, dynamic>.from(_encodeTrade(t));
  m.remove('screenshotBytesB64');
  m.remove('linkedAnalysePdfBytesB64');
  return m;
}

/// Persistance locale du journal (clé [paychekScopedPrefsKey] / uid explicite).
abstract final class TradeJournalStorage {
  TradeJournalStorage._();

  static Future<void> save(
    List<TradeListItem> items, {
    String? firebaseUidOverride,
  }) async {
    final p = await SharedPreferences.getInstance();
    final payload = <String, dynamic>{
      'v': _jsonRootV,
      'items': items.map(_encodeTrade).toList(),
    };
    await p.setString(_prefsKey(firebaseUidOverride: firebaseUidOverride), jsonEncode(payload));
  }

  /// `null` si aucune donnée ou JSON invalide ; liste vide si journal explicitement vide.
  static Future<List<TradeListItem>?> load({String? firebaseUidOverride}) async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_prefsKey(firebaseUidOverride: firebaseUidOverride));
    if (raw == null || raw.isEmpty) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final m = Map<String, dynamic>.from(decoded);
      final list = m['items'];
      if (list is! List) return null;
      final out = <TradeListItem>[];
      for (final e in list) {
        if (e is! Map) continue;
        final t = _decodeTrade(Map<String, dynamic>.from(e));
        if (t != null) out.add(t);
      }
      final migrated = applyJournalMindsetTalentMigration(out);
      if (journalMindsetMigrationWouldChange(out)) {
        await save(migrated, firebaseUidOverride: firebaseUidOverride);
      }
      return migrated;
    } catch (_) {
      return null;
    }
  }
}
