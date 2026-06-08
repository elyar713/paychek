import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../coach_ai/coach_ai_page.dart';
import '../reglage/user_portfolio_models.dart';
import '../reglage/user_portfolio_scope.dart';
import '../reglage/user_portfolio_store.dart';
import '../trade/trade_journal_helper.dart';
import '../trade/trade_journal_scope.dart';
import '../trade/trade_journal_store.dart';
import '../trade/trade_models.dart';
import 'admin_coach_journal_loader.dart';
import 'admin_theme.dart';

/// Labo Coach AI : compte **app** connecté en direct via Firestore (pas le compte admin).
class AdminCoachLabPage extends StatefulWidget {
  const AdminCoachLabPage({super.key});

  @override
  State<AdminCoachLabPage> createState() => _AdminCoachLabPageState();
}

class _AdminCoachLabPageState extends State<AdminCoachLabPage> {
  final _emailCtrl = TextEditingController();
  final _uidCtrl = TextEditingController();
  final _journalStore = TradeJournalStore(remoteMirrorOnly: true);
  final _portfolioStore = UserPortfolioStore();

  AdminCoachLiveSync? _liveSync;
  List<({String id, String email})> _recentUsers = const [];

  bool _connecting = false;
  bool _connected = false;
  String? _error;
  String? _connectedEmail;
  String? _connectedUid;
  int _tradeCountAll = 0;
  int _tradeCountActive = 0;
  String? _activePortfolioId;
  DateTime? _lastSyncAt;

  @override
  void initState() {
    super.initState();
    unawaited(_loadRecentUsers());
  }

  @override
  void dispose() {
    _liveSync?.cancel();
    _emailCtrl.dispose();
    _uidCtrl.dispose();
    _journalStore.dispose();
    super.dispose();
  }

  Future<void> _loadRecentUsers() async {
    try {
      final users = await AdminCoachJournalLoader.fetchRecentAppUsers();
      if (!mounted) return;
      setState(() => _recentUsers = users);
    } catch (_) {}
  }

  void _applyTrades(List<TradeListItem> trades) {
    _journalStore.replaceAll(trades);
    _refreshCounts();
  }

  void _applyPortfolios(
    List<UserPortfolio> portfolios,
    String? activePortfolioId,
  ) {
    if (portfolios.isNotEmpty) {
      _portfolioStore.applyInMemoryFromFirestore(
        portfolios: portfolios,
        activePortfolioId: activePortfolioId,
      );
    } else {
      final ids = AdminCoachJournalLoader.portfolioIdsIn(_journalStore.items);
      if (ids.isNotEmpty) {
        _portfolioStore.applyInMemoryFromFirestore(
          portfolios: [
            for (final id in ids)
              UserPortfolio(
                id: id,
                name: id == kDefaultPortfolioId ? kDefaultPortfolioName : id,
              ),
          ],
          activePortfolioId: ids.contains(kDefaultPortfolioId)
              ? kDefaultPortfolioId
              : ids.first,
        );
      }
    }
    _refreshCounts();
  }

  void _refreshCounts() {
    if (!mounted) return;
    final all = _journalStore.items.length;
    final pid = _portfolioStore.activePortfolioId;
    final active = coachAiJournalTradesForPortfolio(_journalStore, pid).length;
    setState(() {
      _tradeCountAll = all;
      _tradeCountActive = active;
      _activePortfolioId = pid;
      _lastSyncAt = DateTime.now();
    });
  }

  Future<void> _connect() async {
    setState(() {
      _connecting = true;
      _error = null;
    });

    try {
      var uid = _uidCtrl.text.trim();
      final email = _emailCtrl.text.trim();

      if (uid.isEmpty && email.isNotEmpty) {
        uid = await AdminCoachJournalLoader.resolveUidByEmail(email) ?? '';
        if (uid.isEmpty) {
          throw StateError(
            'Aucun utilisateur paychek_users avec cet e-mail. '
            'Ouvre l’app au moins une fois avec ce compte (connexion Firebase).',
          );
        }
      }

      if (uid.isEmpty) {
        throw StateError('Saisis l’e-mail du compte app ou son UID Firebase.');
      }

      _liveSync?.cancel();

      final trades = await AdminCoachJournalLoader.loadTradesForUid(uid);
      final pf = await AdminCoachJournalLoader.loadPortfoliosForUid(uid);

      _applyTrades(trades);
      _applyPortfolios(pf.portfolios, pf.activePortfolioId);

      _liveSync = AdminCoachJournalLoader.listenLive(
        uid: uid,
        onTrades: _applyTrades,
        onPortfolios: _applyPortfolios,
        onError: (e) {
          if (!mounted) return;
          setState(() => _error = '$e');
        },
      );

      final label = email.isNotEmpty
          ? email
          : _recentUsers
              .where((u) => u.id == uid)
              .map((u) => u.email)
              .firstOrNull ??
              uid;

      if (!mounted) return;
      setState(() {
        _connected = true;
        _connecting = false;
        _connectedUid = uid;
        _connectedEmail = label;
        _uidCtrl.text = uid;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = '$e';
        _connecting = false;
        _connected = false;
      });
    }
  }

  void _disconnect() {
    _liveSync?.cancel();
    _liveSync = null;
    _journalStore.clear();
    _portfolioStore.applyInMemoryFromFirestore(
      portfolios: [
        UserPortfolio(id: kDefaultPortfolioId, name: kDefaultPortfolioName),
      ],
      activePortfolioId: kDefaultPortfolioId,
    );
    setState(() {
      _connected = false;
      _connectedEmail = null;
      _connectedUid = null;
      _tradeCountAll = 0;
      _tradeCountActive = 0;
      _activePortfolioId = kDefaultPortfolioId;
      _lastSyncAt = null;
      _error = null;
    });
  }

  void _pickUser(({String id, String email}) user) {
    _emailCtrl.text = user.email.contains('@') ? user.email : '';
    _uidCtrl.text = user.id;
    unawaited(_connect());
  }

  @override
  Widget build(BuildContext context) {
    final syncLabel = _lastSyncAt == null
        ? '—'
        : '${_lastSyncAt!.hour.toString().padLeft(2, '0')}:'
            '${_lastSyncAt!.minute.toString().padLeft(2, '0')}:'
            '${_lastSyncAt!.second.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Coach AI — Labo',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Connecte un compte application (pas le compte admin). '
                'Les trades arrivent en direct depuis Firestore quand tu enregistres '
                'dans l’app avec ce même compte connecté.',
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 13,
                  color: AdminTheme.textMuted,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _emailCtrl,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 13,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: 'E-mail compte app',
                        labelStyle:
                            const TextStyle(color: AdminTheme.textMuted),
                        filled: true,
                        fillColor: AdminTheme.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AdminTheme.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _uidCtrl,
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 11,
                        color: Colors.white,
                      ),
                      decoration: InputDecoration(
                        labelText: 'UID (optionnel)',
                        labelStyle:
                            const TextStyle(color: AdminTheme.textMuted),
                        filled: true,
                        fillColor: AdminTheme.card,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: AdminTheme.border),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  FilledButton.icon(
                    onPressed:
                        _connecting ? null : () => unawaited(_connect()),
                    icon: _connecting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _connected
                                ? Icons.sync_rounded
                                : Icons.link_rounded,
                            size: 18,
                          ),
                    label: Text(_connected ? 'Reconnecter' : 'Connecter'),
                  ),
                  if (_connected) ...[
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: _disconnect,
                      child: const Text('Déconnecter'),
                    ),
                  ],
                ],
              ),
              if (_recentUsers.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  'Comptes récents',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AdminTheme.textDim,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    for (final u in _recentUsers.take(12))
                      ActionChip(
                        label: Text(
                          u.email.contains('@')
                              ? u.email
                              : '${u.id.substring(0, 8)}…',
                          style: GoogleFonts.plusJakartaSans(fontSize: 11),
                        ),
                        onPressed: _connecting ? null : () => _pickUser(u),
                      ),
                  ],
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 8),
                Text(
                  _error!,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: const Color(0xFFF87171),
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(
                    _connected ? Icons.circle : Icons.circle_outlined,
                    size: 10,
                    color: _connected
                        ? AdminTheme.accent
                        : AdminTheme.textDim,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _connected
                          ? 'En direct · $_connectedEmail · '
                              'UID ${_connectedUid!.substring(0, 8)}… · '
                              '$_tradeCountActive trade(s) actifs / $_tradeCountAll total · '
                              'portefeuille $_activePortfolioId · sync $syncLabel'
                          : 'Non connecté — choisis ton e-mail compte app',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 12,
                        color: AdminTheme.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
              if (_connected && _tradeCountAll == 0) ...[
                const SizedBox(height: 8),
                Text(
                  '0 trade dans Firestore : ouvre PAYCHEK avec ce compte, connecte-toi, '
                  'ajoute un trade — la liste se met à jour ici automatiquement.',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 12,
                    color: AdminTheme.warning,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFF1F2937)),
        Expanded(
          child: _connected
              ? Localizations.override(
                  context: context,
                  locale: const Locale('fr'),
                  child: TradeJournalScope(
                    store: _journalStore,
                    child: UserPortfolioScope(
                      store: _portfolioStore,
                      child: const CoachAiPage(),
                    ),
                  ),
                )
              : Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Connecte ton compte application pour utiliser le Coach '
                      'avec les mêmes trades que sur le téléphone ou le web.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        color: AdminTheme.textMuted,
                        height: 1.5,
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
