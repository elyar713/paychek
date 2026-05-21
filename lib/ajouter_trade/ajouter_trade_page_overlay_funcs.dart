part of 'ajouter_trade_page.dart';

void _ajouterTradeCloseCommission(_AjouterTradePageState s) {
  s._commissionOverlay?.remove();
  s._commissionOverlay = null;
}

void _ajouterTradeCloseStrategieMenu(_AjouterTradePageState s) {
  s._strategieMenuOverlay?.remove();
  s._strategieMenuOverlay = null;
}

void _ajouterTradeCloseTradeDateTimeOverlay(
  _AjouterTradePageState s, {
  /// Ne pas appeler [State.setState] (ex. pendant [State.dispose]) : le widget peut
  /// encore être vu comme [State.mounted] alors que le cycle est déjà `defunct`.
  bool suppressRebuild = false,
}) {
  s._tradeDateTimeOverlay?.remove();
  s._tradeDateTimeOverlay = null;
  s._tradeDateTimeOverlayForEntree = null;
  if (!suppressRebuild && s.mounted) {
    // ignore: invalid_use_of_protected_member
    s.setState(() {});
  }
}

void _ajouterTradeToggleStrategieMenu(
  _AjouterTradePageState s,
  BuildContext context,
  List<StrategieSetupCardData> setups,
) {
  if (s._strategieMenuOverlay != null) {
    _ajouterTradeCloseStrategieMenu(s);
    return;
  }
  final box =
      s._strategieFieldKey.currentContext?.findRenderObject() as RenderBox?;
  if (box == null || !box.hasSize) return;
  final w = box.size.width;
  final topLeft = box.localToGlobal(Offset.zero);
  final fieldTop = topLeft.dy;
  final fieldBottom = topLeft.dy + box.size.height;
  final media = MediaQuery.of(context);
  final safeTop = media.padding.top + 8;
  final safeBottom = media.size.height - media.padding.bottom - 8;
  final spaceBelow = (safeBottom - fieldBottom - 5).clamp(0, 9999).toDouble();
  final spaceAbove = (fieldTop - safeTop - 5).clamp(0, 9999).toDouble();
  final showBelow = spaceBelow >= 160 || spaceBelow >= spaceAbove;
  final maxH = (showBelow ? spaceBelow : spaceAbove).clamp(140, 220).toDouble();
  final overlayState = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (overlayCtx) {
      return SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _ajouterTradeCloseStrategieMenu(s),
                behavior: HitTestBehavior.opaque,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.12),
                ),
              ),
            ),
            CompositedTransformFollower(
              link: s._strategieLayerLink,
              showWhenUnlinked: false,
              targetAnchor:
                  showBelow ? Alignment.bottomLeft : Alignment.topLeft,
              followerAnchor:
                  showBelow ? Alignment.topLeft : Alignment.bottomLeft,
              offset: showBelow ? const Offset(0, 5) : const Offset(0, -5),
              child: Material(
                color: Colors.transparent,
                elevation: 10,
                shadowColor: Colors.black54,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: w,
                  constraints: BoxConstraints(maxHeight: maxH),
                  decoration: BoxDecoration(
                    color: DashboardTokens.cardBoxBg.withValues(alpha: 0.98),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: DashboardTokens.cardBoxBorder,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(9),
                    child: ListView(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      children: [
                        for (final setup in setups)
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                // ignore: invalid_use_of_protected_member
                                s.setState(
                                  () => s._strategieChoisie = setup.title,
                                );
                                _ajouterTradeCloseStrategieMenu(s);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 11,
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 9,
                                      height: 9,
                                      decoration: BoxDecoration(
                                        color: setup.dotColor,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        setup.title,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: DashboardTokens.onMatteEmphasis,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 12,
                                          height: 1.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
  s._strategieMenuOverlay = entry;
  overlayState.insert(entry);
}

void _ajouterTradeToggleCommissionPopover(
  _AjouterTradePageState s,
  BuildContext context,
) {
  if (s._commissionOverlay != null) {
    _ajouterTradeCloseCommission(s);
    return;
  }
  final overlayState = Overlay.of(context);
  final entry = OverlayEntry(
    builder: (overlayCtx) {
      final l = AppLocalizations.of(overlayCtx)!;
      return SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _ajouterTradeCloseCommission(s),
                behavior: HitTestBehavior.opaque,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.28),
                ),
              ),
            ),
            CompositedTransformFollower(
              link: s._commissionLayerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 6),
              child: Material(
                color: Colors.transparent,
                elevation: 10,
                shadowColor: Colors.black54,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: 152,
                  padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                  decoration: BoxDecoration(
                    color: DashboardTokens.cardBoxBg.withValues(alpha: 0.93),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: DashboardTokens.cardBoxBorder),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        l.ajouterTradeCommissionFeesLabel,
                        style: Theme.of(overlayCtx).textTheme.labelSmall
                            ?.copyWith(
                              color: DashboardTokens.labelGrey,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                              letterSpacing: 0.2,
                            ),
                      ),
                      const SizedBox(height: 6),
                      SizedBox(
                        height: 32,
                        child: TextField(
                          controller: s._commissionFeeController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                            signed: false,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]'),
                            ),
                          ],
                          style: const TextStyle(
                            color: DashboardTokens.onMatteEmphasis,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: DashboardTokens.scaffoldMatte
                                .withValues(alpha: 0.88),
                            hintText: '0',
                            hintStyle: TextStyle(
                              color: DashboardTokens.muted
                                  .withValues(alpha: 0.45),
                              fontSize: 12,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: DashboardTokens.cardBoxBorder,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: DashboardTokens.cardBoxBorder,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: DashboardTokens.accent,
                                width: 1.1,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                          ),
                          onChanged: (_) => s._requestGainRecalc(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
  s._commissionOverlay = entry;
  overlayState.insert(entry);
}

void _ajouterTradeToggleTradeDateTimeOverlay(
  _AjouterTradePageState s,
  BuildContext context, {
  required bool entree,
}) {
  if (s._tradeDateTimeOverlay != null &&
      s._tradeDateTimeOverlayForEntree == entree) {
    _ajouterTradeCloseTradeDateTimeOverlay(s);
    return;
  }
  _ajouterTradeCloseTradeDateTimeOverlay(s);

  final link = entree ? s._entreeDateLayerLink : s._sortieDateLayerLink;
  final rowKey = entree ? s._entreeDateRowKey : s._sortieDateRowKey;
  var draft = entree ? s._entreeDateTime : s._sortieDateTime;
  final box = rowKey.currentContext?.findRenderObject() as RenderBox?;
  final measured =
      (box != null && box.hasSize) ? box.size.width : 240.0;
  final widthBasis = math.min(
    measured,
    AjouterTradeDateAndCheckboxColumn.checkboxBlockMaxWidth,
  );
  final screenW = MediaQuery.sizeOf(context).width;
  final popoverW = math.min(
    math.max(widthBasis, 232.0),
    screenW - 20,
  );

  final overlayState = Overlay.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (overlayCtx) {
      const pickerPreferredH = 216.0;
      const gap = 6.0;

      final media = MediaQuery.of(overlayCtx);
      final safeTop = media.padding.top;
      final safeBottom = media.size.height -
          media.padding.bottom -
          media.viewInsets.bottom;

      final rowBox = rowKey.currentContext?.findRenderObject() as RenderBox?;
      var rowTop = safeTop + 80.0;
      var rowBottom = rowTop + 28.0;
      if (rowBox != null && rowBox.hasSize) {
        final o = rowBox.localToGlobal(Offset.zero);
        rowTop = o.dy;
        rowBottom = o.dy + rowBox.size.height;
      }

      final spaceBelow = (safeBottom - rowBottom - gap).clamp(0.0, 9999.0);
      final spaceAbove = (rowTop - safeTop - gap).clamp(0.0, 9999.0);

      final bool showBelow;
      if (spaceBelow >= pickerPreferredH) {
        showBelow = true;
      } else if (spaceAbove >= pickerPreferredH) {
        showBelow = false;
      } else {
        showBelow = spaceBelow >= spaceAbove;
      }

      final available = showBelow ? spaceBelow : spaceAbove;
      final pickerH = math
          .min(pickerPreferredH, available)
          .clamp(180.0, pickerPreferredH);

      return SizedBox.expand(
        child: Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _ajouterTradeCloseTradeDateTimeOverlay(s),
                behavior: HitTestBehavior.opaque,
                child: ColoredBox(
                  color: Colors.black.withValues(alpha: 0.18),
                ),
              ),
            ),
            CompositedTransformFollower(
              link: link,
              showWhenUnlinked: false,
              targetAnchor: showBelow
                  ? (entree ? Alignment.bottomLeft : Alignment.bottomRight)
                  : (entree ? Alignment.topLeft : Alignment.topRight),
              followerAnchor: showBelow
                  ? (entree ? Alignment.topLeft : Alignment.topRight)
                  : (entree ? Alignment.bottomLeft : Alignment.bottomRight),
              offset: Offset(0, showBelow ? gap : -gap),
              child: Container(
                width: popoverW,
                height: pickerH,
                decoration: BoxDecoration(
                  color: DashboardTokens.cardBoxBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: DashboardTokens.onMatteEmphasis
                        .withValues(alpha: 0.28),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.55),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                clipBehavior: Clip.hardEdge,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8.5),
                  child: SizedBox(
                    width: popoverW,
                    height: pickerH,
                    child: CupertinoTheme(
                      data: CupertinoThemeData(
                        brightness: Brightness.dark,
                        primaryColor: DashboardTokens.accent,
                        textTheme: CupertinoTextThemeData(
                          dateTimePickerTextStyle: TextStyle(
                            color: DashboardTokens.onMatteEmphasis
                                .withValues(alpha: 0.96),
                            fontSize: 12.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      child: CupertinoDatePicker(
                        mode: CupertinoDatePickerMode.dateAndTime,
                        initialDateTime: draft,
                        minimumDate: DateTime(2000, 1, 1),
                        maximumDate: DateTime(2100, 12, 31),
                        use24hFormat: true,
                        onDateTimeChanged: (dt) {
                          draft = dt;
                          // ignore: invalid_use_of_protected_member
                          s.setState(() {
                            if (entree) {
                              s._entreeDateTime = dt;
                            } else {
                              s._sortieDateTime = dt;
                            }
                          });
                          if (entree) {
                            s._applyNewsFlagsFromChecklist();
                            s._applySessionMindsetToFormIfEnabled();
                          }
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
  s._tradeDateTimeOverlayForEntree = entree;
  s._tradeDateTimeOverlay = entry;
  overlayState.insert(entry);
  if (s.mounted) {
    // ignore: invalid_use_of_protected_member
    s.setState(() {});
  }
}
