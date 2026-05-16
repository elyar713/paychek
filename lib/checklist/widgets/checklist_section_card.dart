import 'package:flutter/material.dart';

import '../checklist_tokens.dart';
import 'checklist_section_header_row.dart';

/// Carte gris très foncé + bordure : en-tête + contenu.
class ChecklistSectionCard extends StatelessWidget {
  const ChecklistSectionCard({
    super.key,
    required this.sectionTitle,
    required this.children,
    /// `true` quand la carte est dans la grille large (Row + [IntrinsicHeight]) :
    /// hauteur imposée → liste scrollable. **Ne pas** utiliser de [LayoutBuilder] ici
    /// (incompatible avec [IntrinsicHeight]).
    this.inlineRowLayout = false,
    this.onMenuSelected,
    this.titleEditing = false,
    this.titleEditController,
    this.titleFocusNode,
    this.onTitleSubmitted,
    this.onTitleInteraction,
  });

  final String sectionTitle;
  final List<Widget> children;
  final bool inlineRowLayout;
  final ValueChanged<String>? onMenuSelected;

  final bool titleEditing;
  final TextEditingController? titleEditController;
  final FocusNode? titleFocusNode;
  final VoidCallback? onTitleSubmitted;
  final VoidCallback? onTitleInteraction;

  Widget _buildBody() {
    final header = ChecklistSectionHeaderRow(
      title: sectionTitle,
      onMenuSelected: onMenuSelected,
      editingTitle: titleEditing,
      titleEditController: titleEditController,
      titleFocusNode: titleFocusNode,
      onTitleSubmitted: onTitleSubmitted,
      onTitleInteraction: onTitleInteraction,
    );
    const gap = SizedBox(height: ChecklistTokens.sectionHeaderToItemsGap);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
    if (!inlineRowLayout) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          header,
          gap,
          body,
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        header,
        gap,
        Expanded(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: body,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(ChecklistTokens.cardRadius),
      child: Container(
        width: double.infinity,
        padding: ChecklistTokens.sectionCardPadding,
        decoration: BoxDecoration(
          color: ChecklistTokens.cardBg,
          borderRadius: BorderRadius.circular(ChecklistTokens.cardRadius),
          border: Border.all(
            color: ChecklistTokens.sectionCardBorder,
            width: 1,
          ),
        ),
        child: _buildBody(),
      ),
    );
  }
}
