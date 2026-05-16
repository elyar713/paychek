import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'reglage_portfolio_editor_widgets.dart';
import 'reglage_single_portfolio_editor_sheet.dart';
import 'user_portfolio_models.dart';
import 'user_portfolio_store.dart';
import 'user_portfolio_scope.dart';

/// Gestion des portefeuilles (multi-brokers) : créer, nommer, modifier, supprimer.
/// Éditer un portefeuille (nom, capital, devise) — utilisé depuis Réglages (icône crayon).
Future<void> showReglageSinglePortfolioEditor(
  BuildContext context, {
  required UserPortfolioStore store,
  UserPortfolio? existing,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: ReglageSinglePortfolioEditorSheet(
          store: store,
          existing: existing,
        ),
      );
    },
  );
}

Future<void> showReglagePortfoliosManagerSheet(BuildContext context) {
  final store = UserPortfolioScope.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: _PortfoliosManagerBody(store: store),
      );
    },
  );
}

class _PortfoliosManagerBody extends StatelessWidget {
  const _PortfoliosManagerBody({required this.store});

  final UserPortfolioStore store;

  Future<void> _openEditor(BuildContext context, UserPortfolio? existing) async {
    await showReglageSinglePortfolioEditor(context, store: store, existing: existing);
  }

  Future<void> _confirmDelete(BuildContext context, UserPortfolio p) async {
    if (p.id == kDefaultPortfolioId) return;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final l = AppLocalizations.of(ctx)!;
        return AlertDialog(
          backgroundColor: const Color(0xFF141414),
          title: Text(
            l.deletePortfolioTitle(p.name),
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel, style: GoogleFonts.plusJakartaSans(color: DashboardTokens.muted)),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.delete, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800)),
            ),
          ],
        );
      },
    );
    if (ok == true) await store.remove(p.id);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.88,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF0E0E10),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border.all(color: const Color(0xFF1A1A1A)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: DashboardTokens.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Portefeuilles',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
            Text(
              'Un portefeuille par broker ou compte — nommez-les et renseignez capital + devise.',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: DashboardTokens.muted,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.icon(
                onPressed: () => _openEditor(context, null),
                style: FilledButton.styleFrom(
                  backgroundColor: kReglagePortfolioBrandTeal,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.add_rounded, size: 22),
                label: Text(
                  'Ajouter un portefeuille',
                  style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListenableBuilder(
                listenable: store,
                builder: (context, _) {
                  if (store.items.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          '« $kDefaultPortfolioName » sera créé avec votre capital.\n'
                          'Ajoutez d’autres portefeuilles pour plusieurs brokers.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            color: DashboardTokens.muted,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    itemCount: store.items.length,
                    separatorBuilder: (context, _) =>
                        const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final p = store.items[i];
                      return Material(
                        color: const Color(0xFF121214),
                        borderRadius: BorderRadius.circular(14),
                        child: InkWell(
                          onTap: () => _openEditor(context, p),
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        p.name.isEmpty ? 'Sans nom' : p.name,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 15,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        store.displayLine(p),
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 13,
                                          color: DashboardTokens.muted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, color: Colors.white70, size: 20),
                                  onPressed: () => _openEditor(context, p),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.delete_outline,
                                    color: p.id == kDefaultPortfolioId
                                        ? Colors.white12
                                        : Colors.white38,
                                    size: 20,
                                  ),
                                  onPressed: p.id == kDefaultPortfolioId
                                      ? null
                                      : () => _confirmDelete(context, p),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
