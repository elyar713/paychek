part of 'performance_page.dart';

const Color _kGreen = Color(0xFF1eb48a);
const Color _kRed = Color(0xFFFF4D4D);
const Color _kBorder = Color(0xFF161616);
const Color _kGrey = Color(0xFF555555);
const Color _kFilterActive = Color(0xFF546E7A);

const double _kPerformanceLayoutWideBreakpoint = 920;
const double _kPerformanceContentMaxWidth = 1200;

class _PerformancePageState extends State<PerformancePage> with SingleTickerProviderStateMixin {
  List<Trade> _trades = [];
  TradeJournalStore? _journalStore;
  UserPortfolioStore? _portfolioStore;
  SavedPerformanceWidget? _savedWidget;

  StrategieGestionRisqueParams? _gestionParams;

  List<StrategieSessionPersisted> _strategieSessions =
      StrategieHorairesSessionsStorage.defaultSessions();

  PerformancePeriodFilter _periodFilter = PerformancePeriodFilter.all;
  DateTime? _customStartDate;

  /// Marché sélectionné pour les libellés de la section Volume (micro/mini vs fourchettes contrats).
  AjouterTradeAssetClass _volumeSectionMarche = AjouterTradeAssetClass.forex;

  late final AnimationController _pulseCtrl;

  DateTime get _anchorDate => anchorDateForTrades(_trades);

  PerformanceDateRange? get _range => rangeForPeriod(
        period: _periodFilter,
        anchor: _anchorDate,
        customStart: _customStartDate,
      );

  List<Trade> get _visibleTrades => filterTradesByRange(_trades, _range);

  /// Trades avec au moins un signal discipline (hors saisie minimale).
  List<Trade> get _disciplineVisibleTrades =>
      _visibleTrades.where((t) => !t.performanceLite).toList();

  bool get _embeddedInTabShell => widget.onCloseAsTab != null;

  void _handleLeadingBack() {
    if (_embeddedInTabShell) {
      widget.onCloseAsTab!.call();
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  void initState() {
    super.initState();
    StrategieSetupsStore.ensureLoaded();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _loadSavedWidget();
    _loadLensContext();
  }

  Future<void> _loadLensContext() async {
    final g = await StrategieGestionRisqueStorage.load();
    final sess = await StrategieHorairesSessionsStorage.load();
    if (!mounted) return;
    setState(() {
      _gestionParams = g;
      _strategieSessions = sess;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var changed = false;
    final next = TradeJournalScope.of(context);
    if (!identical(_journalStore, next)) {
      _journalStore?.removeListener(_onJournalChanged);
      _journalStore = next;
      _journalStore!.addListener(_onJournalChanged);
      changed = true;
    }
    final nextP = UserPortfolioScope.of(context);
    if (!identical(_portfolioStore, nextP)) {
      _portfolioStore?.removeListener(_onJournalChanged);
      _portfolioStore = nextP;
      _portfolioStore!.addListener(_onJournalChanged);
      changed = true;
    }
    if (changed) _applyTradeSource();
  }

  void _onJournalChanged() => _applyTradeSource();

  void _applyTradeSource() {
    if (!mounted) return;
    final items = activeJournalTradesOrDemo(context);
    setState(() => _trades = performanceTradesFromJournal(items));
    _syncKpiToDashboard();
  }

  void _syncKpiToDashboard() {
    PerformanceKpiSync.instance.mirrorFromPerformance(
      trades: _trades,
      periodFilter: _periodFilter,
      customStartDate: _customStartDate,
    );
  }

  Future<void> _loadSavedWidget() async {
    final w = await PerformanceWidgetStorage.load();
    if (!mounted) return;
    setState(() => _savedWidget = w);
  }

  @override
  void dispose() {
    _journalStore?.removeListener(_onJournalChanged);
    _portfolioStore?.removeListener(_onJournalChanged);
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCustomPeriodStart() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customStartDate ?? _anchorDate,
      firstDate: DateTime(2000),
      lastDate: _anchorDate,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(useMaterial3: true).copyWith(
            colorScheme: ColorScheme.dark(
              primary: _kGreen,
              surface: const Color(0xFF1A1A1A),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() {
      _periodFilter = PerformancePeriodFilter.custom;
      _customStartDate = picked;
    });
    _syncKpiToDashboard();
  }

  Widget _buildPeriodFilterBar() {
    final code = Localizations.localeOf(context).languageCode;
    String t(String fr, String en, String es, String de, String pt, String ko) =>
        perf6(code, fr, en, es, de, pt, ko);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _resetAllPeriodIcon(),
            _periodChip(
              t('Aujourd\'hui', 'Today', 'Hoy', 'Heute', 'Hoje', '오늘'),
              PerformancePeriodFilter.oneDay,
            ),
            _periodChip(
              t('Hier', 'Yesterday', 'Ayer', 'Gestern', 'Ontem', '어제'),
              PerformancePeriodFilter.yesterday,
            ),
            _periodChip(
              t('Cette semaine', 'This week', 'Esta semana', 'Diese Woche', 'Esta semana', '이번 주'),
              PerformancePeriodFilter.oneWeek,
            ),
            _periodChip(
              t('Ce mois', 'This month', 'Este mes', 'Dieser Monat', 'Este mês', '이번 달'),
              PerformancePeriodFilter.currentMonth,
            ),
            const SizedBox(width: 8),
            _customDatePill(),
          ],
        ),
      ),
    );
  }

  Widget _resetAllPeriodIcon() {
    final code = Localizations.localeOf(context).languageCode;
    String t(String fr, String en, String es, String de, String pt, String ko) =>
        perf6(code, fr, en, es, de, pt, ko);
    final active = _periodFilter == PerformancePeriodFilter.all;
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        padding: EdgeInsets.zero,
        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
        tooltip: t('Tout l\'historique', 'All history', 'Todo el historial', 'Gesamte Historie', 'Todo o histórico', '전체 기록'),
        onPressed: () {
          setState(() {
            _periodFilter = PerformancePeriodFilter.all;
          });
          _syncKpiToDashboard();
        },
        icon: Icon(
          Icons.filter_list_off_rounded,
          size: 20,
          color: active ? _kFilterActive : _kGrey,
        ),
      ),
    );
  }

  Widget _periodChip(String label, PerformancePeriodFilter period) {
    final active = _periodFilter == period;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() => _periodFilter = period);
            _syncKpiToDashboard();
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: active ? Colors.white : const Color(0xFF121212),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: active ? Colors.white : const Color(0xFF3A3A3A),
              ),
            ),
            child: Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: active ? Colors.black : _kGrey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _customDatePill() {
    final code = Localizations.localeOf(context).languageCode;
    String t(String fr, String en, String es, String de, String pt, String ko) =>
        perf6(code, fr, en, es, de, pt, ko);
    final active = _periodFilter == PerformancePeriodFilter.custom;
    final label = _customStartDate == null
        ? t('Date', 'Date', 'Fecha', 'Datum', 'Data', '날짜')
        : '${_customStartDate!.day.toString().padLeft(2, '0')}/${_customStartDate!.month.toString().padLeft(2, '0')}/${_customStartDate!.year}';
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _pickCustomPeriodStart,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: active ? Colors.white : const Color(0xFF121212),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? Colors.white : const Color(0xFF3A3A3A),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.calendar_today_outlined,
                size: 14,
                color: active ? Colors.black87 : _kGrey,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: active ? Colors.black87 : _kGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    /// Trades avec contexte discipline (hors saisie minimale si ce filtre est réactivé).
    final disc = _disciplineVisibleTrades;

    final agg = disc.isEmpty
        ? const TradeAggregates(wins: 0, losses: 0, breakeven: 0)
        : aggregateTrades(disc);
    final lens = buildPaychekLensSnapshot(disc, locale: locale);
    final horaireViol = computeHoraireTradingViolationStats(
      trades: disc,
      sessions: _strategieSessions,
    );
    final gestion = _gestionParams ?? StrategieGestionRisqueParams.defaults;
    final capStore = UserCapitalScope.of(context);
    final capital = UserPortfolioScope.of(context).effectiveCapitalAmount(capStore);
    final lensStrategieWarnings = paychekStrategieWarnings(
      trades: disc,
      params: gestion,
      sessions: _strategieSessions,
      capitalAmount: capital,
      locale: locale,
    );
    final buckets = durationBucketWinRates(disc);
    final slots = timeSlotWinRates(disc, locale: locale);
    final dailyJournalBuckets = dailyJournalVolumeBucketWinRatesLocalized(
      disc,
      locale: locale,
    );
    final assetBarStats = computeTopAssetBarStats(_visibleTrades);
    final dayIntensityHistogram = computeDayIntensityHistogramBuckets(_visibleTrades);

    final winPct = (agg.winrate * 100).round();
    final lite = widget.liteFreemiumRestricted;

    return PopScope(
      canPop: !_embeddedInTabShell,
      onPopInvokedWithResult: (didPop, result) {
        if (_embeddedInTabShell) {
          if (!didPop) widget.onCloseAsTab!.call();
          return;
        }
        if (didPop) widget.onNavigateToDashboard?.call();
      },
        child: Scaffold(
        backgroundColor: DashboardTokens.scaffoldMatte,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide =
                  constraints.maxWidth >= _kPerformanceLayoutWideBreakpoint;
              final maxW = math.min(
                _kPerformanceContentMaxWidth,
                constraints.maxWidth,
              );
              final pad = EdgeInsets.fromLTRB(
                wide ? 24 : 16,
                10,
                wide ? 24 : 16,
                28,
              );

              final savedInsight = _savedWidget == null
                  ? null
                  : SavedWidgetInsightCard(
                      config: _savedWidget!,
                      series: MetricSeriesBundle.forMetric(
                        _savedWidget!.metricIndex,
                        disc,
                        AppLocalizations.of(context)!,
                        locale: Localizations.localeOf(context),
                      ),
                      tradesEmpty: disc.isEmpty,
                      onRemove: () async {
                        await PerformanceWidgetStorage.clear();
                        if (!mounted) return;
                        setState(() => _savedWidget = null);
                      },
                    );

              final gap = wide ? 14.0 : 16.0;

              final List<Widget> bodyChildren = lite
                  ? [
                      _buildHeader(),
                      _buildLiteFreemiumStatsPlaceholder(),
                    ]
                  : [
                _buildHeader(),
                _dataSourceBanner(),
                if (wide) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _cardGlobal(winPct, agg)),
                      SizedBox(width: gap),
                      Expanded(
                        child: _cardEye(lens, lensStrategieWarnings),
                      ),
                    ],
                  ),
                  SizedBox(height: gap),
                  _buildPeriodFilterBar(),
                  SizedBox(height: gap),
                  _cardDailyJournalVolume(dailyJournalBuckets),
                  SizedBox(height: gap),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _cardTimeSlots(slots, horaireViol),
                      ),
                      SizedBox(width: gap),
                      Expanded(child: _cardDuration(buckets)),
                    ],
                  ),
                  SizedBox(height: gap),
                  _cardNewsTiming(disc),
                  SizedBox(height: gap),
                  _cardDiscipline(),
                  SizedBox(height: gap),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _cardVolume()),
                      SizedBox(width: gap),
                      Expanded(
                        child: _cardMostTradedAssetBars(assetBarStats),
                      ),
                    ],
                  ),
                  SizedBox(height: gap),
                  _cardDayIntensityHistogram(dayIntensityHistogram),
                ] else ...[
                  _cardGlobal(winPct, agg),
                  const SizedBox(height: 12),
                  _buildPeriodFilterBar(),
                  const SizedBox(height: 16),
                  _cardEye(lens, lensStrategieWarnings),
                  const SizedBox(height: 16),
                  _cardDailyJournalVolume(dailyJournalBuckets),
                  const SizedBox(height: 16),
                  _cardTimeSlots(slots, horaireViol),
                  const SizedBox(height: 16),
                  _cardNewsTiming(disc),
                  const SizedBox(height: 16),
                  _cardDiscipline(),
                  const SizedBox(height: 16),
                  _cardDuration(buckets),
                  const SizedBox(height: 16),
                  _cardVolume(),
                  const SizedBox(height: 16),
                  _cardMostTradedAssetBars(assetBarStats),
                  const SizedBox(height: 16),
                  _cardDayIntensityHistogram(dayIntensityHistogram),
                ],
                if (savedInsight != null) ...[
                  SizedBox(height: gap),
                  savedInsight,
                ],
              ];

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxW),
                  child: SingleChildScrollView(
                    padding: pad,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: bodyChildren,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _setVolumeSectionMarche(AjouterTradeAssetClass m) {
    setState(() => _volumeSectionMarche = m);
  }

  Future<void> _exportPerformancePdf() async {
    final gestion = _gestionParams ?? StrategieGestionRisqueParams.defaults;
    final capStore = UserCapitalScope.of(context);
    final capital = UserPortfolioScope.of(context).effectiveCapitalAmount(capStore);
    await exportPerformancePdf(
      context,
      disciplineTrades: _disciplineVisibleTrades,
      visibleTradesForAssets: _visibleTrades,
      periodFilter: _periodFilter,
      anchor: _anchorDate,
      customStart: _customStartDate,
      sessions: _strategieSessions,
      gestionParams: gestion,
      capitalAmount: capital,
      journalItemCount: activeJournalTradesOrDemo(context).length,
      l: AppLocalizations.of(context)!,
      uiLocale: Localizations.localeOf(context),
    );
  }
}
