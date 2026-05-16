import 'package:flutter/material.dart';

import '../dashboard/dashboard_tokens.dart';
import '../l10n/app_localizations.dart';
import 'ajouter_trade_asset_class.dart';
import 'ajouter_trade_side.dart';

/// Deux boutons **séparés** Buy/Long et Sell/Short (plus grands que l’ancienne piste unique).
class AjouterTradeDirectionBar extends StatelessWidget {
  const AjouterTradeDirectionBar({
    super.key,
    required this.side,
    required this.longColor,
    required this.shortColor,
    required this.onLong,
    required this.onShort,
  });

  final AjouterTradeSide side;
  final Color longColor;
  final Color shortColor;
  final VoidCallback onLong;
  final VoidCallback onShort;

  static const double _buttonHeight = 52;
  static const double _gap = 14;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    // Hauteur bornée obligatoire : dans un [ScrollView], un [Row] en stretch reçoit h=∞.
    return SizedBox(
      height: _buttonHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _AjouterTradeDirectionSideButton(
              label: l10n.ajouterTradeDirectionBuyLong,
              selected: side == AjouterTradeSide.long,
              activeFill: longColor,
              onTap: onLong,
              height: _buttonHeight,
            ),
          ),
          const SizedBox(width: _gap),
          Expanded(
            child: _AjouterTradeDirectionSideButton(
              label: l10n.ajouterTradeDirectionSellShort,
              selected: side == AjouterTradeSide.short,
              activeFill: shortColor,
              onTap: onShort,
              height: _buttonHeight,
            ),
          ),
        ],
      ),
    );
  }
}

class _AjouterTradeDirectionSideButton extends StatelessWidget {
  const _AjouterTradeDirectionSideButton({
    required this.label,
    required this.selected,
    required this.activeFill,
    required this.onTap,
    required this.height,
  });

  final String label;
  final bool selected;
  final Color activeFill;
  final VoidCallback onTap;
  final double height;

  @override
  Widget build(BuildContext context) {
    final inactiveText = DashboardTokens.muted;
    final activeText = Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: Colors.white24,
        highlightColor: Colors.transparent,
        child: Ink(
          height: height,
          decoration: BoxDecoration(
            color: selected ? activeFill : DashboardTokens.cardBoxBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? activeFill : DashboardTokens.cardBoxBorder,
              width: 1,
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                      height: 1.15,
                      color: selected ? activeText : inactiveText,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Types de marché : **toute la liste reste visible** (piste + pastille comme avant) ;
/// **glissement** horizontal (doigt) : passe au marché suivant / précédent.
class AjouterTradeAssetClassTrack extends StatelessWidget {
  const AjouterTradeAssetClassTrack({
    super.key,
    required this.value,
    required this.onSelected,
  });

  final AjouterTradeAssetClass value;
  final ValueChanged<AjouterTradeAssetClass> onSelected;

  static const double trackHeight = 40;
  static const double _pad = 3;

  /// Bleu marine **mat** (pastille sous le marché sélectionné).
  static const Color _thumbNavyMatte = Color(0xFF2C3A48);

  static const double _swipeVelocityThreshold = 220;

  @override
  Widget build(BuildContext context) {
    final items = AjouterTradeAssetClass.values;
    final n = items.length;
    final inactive = DashboardTokens.muted;
    final active = Colors.white;
    final idx = value.index.clamp(0, n - 1);

    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final inner = w - _pad * 2;
        final thumbW = inner / n;
        final thumbLeft = _pad + idx * thumbW;

        void shiftSelection(int delta) {
          final next = (idx + delta).clamp(0, n - 1);
          if (next != idx) onSelected(items[next]);
        }

        return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragEnd: (details) {
                final v = details.primaryVelocity;
                if (v == null) return;
                if (v < -_swipeVelocityThreshold) {
                  shiftSelection(1);
                } else if (v > _swipeVelocityThreshold) {
                  shiftSelection(-1);
                }
              },
              child: SizedBox(
                height: trackHeight,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: DashboardTokens.cardBoxBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: DashboardTokens.cardBoxBorder),
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      left: thumbLeft,
                      top: _pad,
                      width: thumbW,
                      height: trackHeight - _pad * 2,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          color: _thumbNavyMatte,
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        for (var i = 0; i < n; i++)
                          Expanded(
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => onSelected(items[i]),
                                borderRadius: BorderRadius.circular(8),
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: Text(
                                      items[i].label,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style:
                                          Theme.of(
                                            context,
                                          ).textTheme.labelLarge?.copyWith(
                                                fontSize: 10,
                                                fontWeight: FontWeight.w800,
                                                color: idx == i ? active : inactive,
                                              ) ??
                                          TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: idx == i ? active : inactive,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            );
      },
    );
  }
}
