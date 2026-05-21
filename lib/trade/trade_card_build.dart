part of 'trade_card.dart';

extension _TradeCardBuild on TradeCard {
  Widget _buildTradeCard(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final t = Theme.of(context).textTheme;
    final amountColor = item.isProfit
        ? TradeTokens.profitNeon
        : TradeTokens.lossNeon;
    final sideLabel = item.side == TradeSide.vente
        ? l.tradeSideSellShort
        : l.tradeSideBuyShort;
    final tagBg = item.side == TradeSide.vente
        ? TradeTokens.tagSell.withValues(alpha: 0.2)
        : TradeTokens.tagBuy.withValues(alpha: 0.2);
    final tagFg = item.side == TradeSide.vente
        ? TradeTokens.tagSell
        : TradeTokens.tagBuy;
    final sideOrBreakevenLabel = item.breakeven
        ? l.tradeSideBreakevenShort
        : sideLabel;
    final sideOrBreakevenBg = item.breakeven
        ? TradeTokens.pillInactiveBg
        : tagBg;
    final sideOrBreakevenFg = item.breakeven
        ? TradeTokens.textSecondary.withValues(alpha: 0.95)
        : tagFg;

    final duration = item.sortieAt?.difference(item.entreeAt);

    return TapRegion(
      onTapOutside: (event) {
        if (expanded) onTapOutsideWhenExpanded();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: TradeTokens.cardBg,
          borderRadius: BorderRadius.circular(TradeTokens.radiusLg),
          border: Border.all(color: TradeTokens.cardBorder),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(TradeTokens.radiusLg),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              item.pair,
                              style: t.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: sideOrBreakevenBg,
                                borderRadius: BorderRadius.circular(
                                  TradeTokens.radiusSideBadge,
                                ),
                                border: item.breakeven
                                    ? Border.all(color: TradeTokens.cardBorder)
                                    : null,
                              ),
                              child: Builder(
                                builder: (context) {
                                  final ui = _mindsetUi(l);
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        ui.icon,
                                        size: 12,
                                        color: ui.color.withValues(alpha: 0.95),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        sideOrBreakevenLabel,
                                        style: TextStyle(
                                          color: sideOrBreakevenFg,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 9,
                                          letterSpacing: 0.4,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            item.amountLabel,
                            style: t.titleMedium?.copyWith(
                              color: amountColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            expanded ? Icons.expand_less : Icons.expand_more,
                            size: 18,
                            color: TradeTokens.textSecondary,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ListenableBuilder(
                    listenable: Listenable.merge([
                      UserCapitalScope.of(context),
                      UserPortfolioScope.of(context),
                    ]),
                    builder: (context, _) {
                      final g = UserCapitalScope.of(context);
                      final cap = UserPortfolioScope.of(
                        context,
                      ).effectiveCapitalAmount(g);
                      final pctVsCapital = (cap != null && cap > 0)
                          ? (item.gainAmount / cap) * 100.0
                          : null;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Expanded(
                            child: Text(
                              formatTradeEntryDateLine(item.entreeAt, context),
                              style: (t.bodySmall ?? const TextStyle())
                                  .copyWith(
                                    color: TradeTokens.textDate,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w400,
                                  ),
                            ),
                          ),
                          if (pctVsCapital != null)
                            Text(
                              l.tradePctOfCapital(
                                '${pctVsCapital >= 0 ? '+' : ''}${pctVsCapital.toStringAsFixed(2).replaceAll('.', ',')}',
                              ),
                              style: t.labelSmall?.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                                color: pctVsCapital == 0
                                    ? TradeTokens.textSecondary
                                    : (pctVsCapital > 0
                                          ? TradeTokens.profitNeon
                                          : TradeTokens.lossNeon),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    child: !expanded
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Divider(height: 1, color: TradeTokens.divider),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final ui = _mindsetUi(l);
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: TradeTokens.pillInactiveBg,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: TradeTokens.cardBorder,
                                            ),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                ui.icon,
                                                size: 16,
                                                color: ui.color,
                                              ),
                                              const SizedBox(width: 6),
                                              Text(
                                                ui.label,
                                                style: t.labelSmall?.copyWith(
                                                  color: Colors.white,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.2,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                    const Spacer(),
                                    IconButton(
                                      tooltip: l.tradeExportPdfTooltip,
                                      onPressed: onExportPdf,
                                      icon: const Icon(
                                        Icons.picture_as_pdf_rounded,
                                        size: 18,
                                        color: TradeTokens.textSecondary,
                                      ),
                                    ),
                                    PopupMenuButton<String>(
                                      tooltip: l.tradeActionsTooltip,
                                      color: TradeTokens.cardBg,
                                      icon: const Icon(
                                        Icons.more_vert,
                                        size: 18,
                                        color: TradeTokens.textSecondary,
                                      ),
                                      onSelected: (v) {
                                        if (v == 'edit') onEdit();
                                        if (v == 'delete') onDelete();
                                      },
                                      itemBuilder: (context) => [
                                        PopupMenuItem<String>(
                                          value: 'edit',
                                          child: Text(
                                            l.tradeEditMenu,
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        PopupMenuItem<String>(
                                          value: 'delete',
                                          child: Text(
                                            l.delete,
                                            style: TextStyle(
                                              color: TradeTokens.lossNeon,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _MiniStat(
                                        label: l.tradeLabelChecklist,
                                        value: '${item.checklistPct.round()}%',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _MiniStat(
                                        label: l.tradeLabelPlan,
                                        value: '${item.planPct.round()}%',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _MiniStat(
                                        label: l.tradeLabelStrategie,
                                        value: '${item.strategiePct.round()}%',
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: _MiniStat(
                                        label: l.tradeLabelEtat,
                                        value: '${item.etatPct.round()}%',
                                      ),
                                    ),
                                  ],
                                ),
                                if (item.userNote != null &&
                                    item.userNote!.trim().isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      l.tradeNoteSectionTitle,
                                      style: t.labelSmall?.copyWith(
                                        color: TradeTokens.textSecondary,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    item.userNote!.trim(),
                                    style: t.bodySmall?.copyWith(
                                      color: Colors.white.withValues(alpha: 0.92),
                                      fontSize: 11,
                                      height: 1.45,
                                    ),
                                  ),
                                ],
                                if (item.psychTags.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      l.tradeTagsSection,
                                      style: t.labelSmall?.copyWith(
                                        color: TradeTokens.textSecondary,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 6,
                                    children: [
                                      for (final tag in item.psychTags)
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          decoration: BoxDecoration(
                                            color: TradeTokens.pillInactiveBg,
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            border: Border.all(
                                              color: TradeTokens.cardBorder,
                                            ),
                                          ),
                                          child: Text(
                                            tag,
                                            style: t.labelSmall?.copyWith(
                                              color: Colors.white,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _MiniLine(
                                        label: l.tradeLabelDuration,
                                        value: duration == null
                                            ? '—'
                                            : _formatDuration(l, duration),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _MiniLine(
                                        label: l.tradeLabelSession,
                                        value: _sessionLabel(l, item.entreeAt),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                _MiniLine(
                                  label: l.tradeLabelHours,
                                  value:
                                      '${_formatHourMinute(item.entreeAt)} → '
                                      '${item.sortieAt == null ? '—' : _formatHourMinute(item.sortieAt!)}',
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _MiniLine(
                                        label: l.tradeLabelEntry,
                                        value: item.prixEntreeLabel ?? '—',
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _MiniLine(
                                        label: l.tradeLabelExit,
                                        value: item.prixSortieLabel ?? '—',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                _MiniLine(
                                  label: l.ajouterTradeCommissionFeesLabel,
                                  value: item.commissionAmount <= 0
                                      ? '0,00\$'
                                      : '${item.commissionAmount.toStringAsFixed(2).replaceAll('.', ',')}\$',
                                ),
                                if (item.avantNews || item.apresNews) ...[
                                  const SizedBox(height: 6),
                                  _MiniLine(
                                    label: l.tradeLabelNews,
                                    value: [
                                      if (item.avantNews)
                                        l.ajouterTradeCheckboxAvantNews,
                                      if (item.apresNews)
                                        l.ajouterTradeCheckboxApresNews,
                                    ].join(', '),
                                  ),
                                ],
                                const SizedBox(height: 8),
                                Text(
                                  l.tradeDayTradeNumber(tradeNumberOfDay),
                                  style: t.bodySmall?.copyWith(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                ...() {
                                  final plan = _resolvePlanNonRespect(l);
                                  final strat = _resolveStrategieNonRespect(
                                    l,
                                    Localizations.localeOf(context),
                                  );
                                  final cl = _resolveChecklistNonRespect(l);
                                  final etat = _resolveEtatNonRespect();
                                  if (plan.isEmpty &&
                                      strat.isEmpty &&
                                      cl.isEmpty &&
                                      etat.isEmpty) {
                                    return const <Widget>[];
                                  }
                                  return <Widget>[
                                    const SizedBox(height: 10),
                                    Text(
                                      l.tradeNotRespected,
                                      style: t.labelSmall?.copyWith(
                                        color: DashboardTokens.titleGold,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    if (plan.isNotEmpty) ...[
                                      _MiniSectionTitle(l.tradeSectionPlan),
                                      for (final n in plan) _MiniBullet(n),
                                      const SizedBox(height: 6),
                                    ],
                                    if (strat.isNotEmpty) ...[
                                      _MiniSectionTitle(
                                        l.tradeSectionStrategie,
                                      ),
                                      for (final n in strat) _MiniBullet(n),
                                      const SizedBox(height: 6),
                                    ],
                                    if (cl.isNotEmpty) ...[
                                      _MiniSectionTitle(
                                        l.tradeSectionChecklist,
                                      ),
                                      for (final n in cl) _MiniBullet(n),
                                      const SizedBox(height: 6),
                                    ],
                                    if (etat.isNotEmpty) ...[
                                      _MiniSectionTitle(l.tradeSectionEtat),
                                      for (final n in etat) _MiniBullet(n),
                                    ],
                                  ];
                                }(),
                                ...() {
                                  final hasBytes = item.screenshotBytes != null &&
                                      item.screenshotBytes!.isNotEmpty;
                                  final hasPath = item.screenshotPath != null &&
                                      item.screenshotPath!.trim().isNotEmpty;
                                  if (!hasBytes && !hasPath) {
                                    return const <Widget>[];
                                  }
                                  return <Widget>[
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: AspectRatio(
                                        aspectRatio: 16 / 9,
                                        child: (kIsWeb && hasBytes)
                                            ? Image.memory(
                                                item.screenshotBytes!,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                              )
                                            : (kIsWeb && !hasBytes)
                                                ? ColoredBox(
                                                    color: TradeTokens.pillInactiveBg,
                                                    child: Center(
                                                      child: Text(
                                                        l.tradeScreenshotUnavailableWeb,
                                                        style: t.bodySmall?.copyWith(
                                                          color:
                                                              TradeTokens.textSecondary,
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Image.file(
                                                    File(item.screenshotPath!),
                                                    fit: BoxFit.cover,
                                                    width: double.infinity,
                                                    errorBuilder:
                                                        (context, error, stack) {
                                                      return ColoredBox(
                                                        color: TradeTokens
                                                            .pillInactiveBg,
                                                        child: Center(
                                                          child: Text(
                                                            l.tradeScreenshotLoadError,
                                                            style: t.bodySmall
                                                                ?.copyWith(
                                                                  color: TradeTokens
                                                                      .textSecondary,
                                                                  fontSize: 11,
                                                                  fontWeight:
                                                                      FontWeight.w600,
                                                                ),
                                                          ),
                                                        ),
                                                      );
                                                    },
                                                  ),
                                      ),
                                    ),
                                  ];
                                }(),
                                ...() {
                                  final pdf = item.linkedAnalysePdfBytes;
                                  if (pdf == null || pdf.isEmpty) {
                                    return const <Widget>[];
                                  }
                                  final actif =
                                      item.linkedAnalyseReport?.actif.trim();
                                  final hint = (actif != null && actif.isNotEmpty)
                                      ? '$actif · ${l.tradeLinkedAnalyseOpenPdf}'
                                      : l.tradeLinkedAnalyseOpenPdf;
                                  return <Widget>[
                                    const SizedBox(height: 10),
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: TextButton.icon(
                                        onPressed: () =>
                                            openTradeLinkedAnalysePdf(
                                          context,
                                          item,
                                        ),
                                        icon: const Icon(
                                          Icons.picture_as_pdf_outlined,
                                          size: 18,
                                          color: DashboardTokens.titleGold,
                                        ),
                                        label: Text(
                                          hint,
                                          style: t.labelSmall?.copyWith(
                                            color: DashboardTokens.titleGold,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ];
                                }(),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
