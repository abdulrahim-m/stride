import 'package:flutter/material.dart';
import 'package:mobile_client/features/notes/presentation/markdown/markdown_editing.dart';
import 'package:mobile_client/l10n/app_localizations.dart';

/// Formatting bar shown above the keyboard while the content is focused.
class MarkdownToolbar extends StatelessWidget {
  const MarkdownToolbar({
    super.key,
    required this.controller,
    required this.undo,
    required this.focusNode,
    required this.onAddImage,
  });

  /// Opens the "add image" flow (the page owns the image list).
  final VoidCallback onAddImage;

  final MarkdownTextController controller;
  final UndoHistoryController undo;
  final FocusNode focusNode;

  void _run(VoidCallback action) {
    action();
    focusNode.requestFocus(); // never let a button steal the caret
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    Widget button(IconData icon, String tooltip, VoidCallback? onPressed) {
      return IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: onPressed == null ? null : () => _run(onPressed),
      );
    }

    return TextFieldTapRegion(
      child: Material(
        color: cs.surface,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: cs.outlineVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
          child: SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              children: [
                ValueListenableBuilder<UndoHistoryValue>(
                  valueListenable: undo,
                  builder: (_, value, _) => Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      button(
                        Icons.undo,
                        l10n.note_undo,
                        value.canUndo ? undo.undo : null,
                      ),
                      button(
                        Icons.redo,
                        l10n.note_redo,
                        value.canRedo ? undo.redo : null,
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 12, indent: 12, endIndent: 12),
                button(Icons.format_bold, l10n.note_bold, controller.toggleBold),
                button(
                  Icons.format_italic,
                  l10n.note_italic,
                  controller.toggleItalic,
                ),
                button(
                  Icons.format_strikethrough,
                  l10n.note_strikethrough,
                  controller.toggleStrike,
                ),
                button(Icons.code, l10n.note_code, controller.toggleCode),
                const VerticalDivider(width: 12, indent: 12, endIndent: 12),
                button(Icons.title, l10n.note_heading, controller.toggleHeading),
                button(
                  Icons.format_list_bulleted,
                  l10n.note_bullet_list,
                  controller.toggleBullet,
                ),
                button(
                  Icons.format_list_numbered,
                  l10n.note_numbered_list,
                  controller.toggleNumbered,
                ),
                button(
                  Icons.checklist,
                  l10n.note_checklist,
                  controller.toggleChecklist,
                ),
                button(
                  Icons.format_quote,
                  l10n.note_quote,
                  controller.toggleQuote,
                ),
                const VerticalDivider(width: 12, indent: 12, endIndent: 12),
                button(
                  Icons.format_indent_decrease,
                  l10n.note_outdent,
                  controller.outdent,
                ),
                button(
                  Icons.format_indent_increase,
                  l10n.note_indent,
                  controller.indent,
                ),
                const VerticalDivider(width: 12, indent: 12, endIndent: 12),
                button(Icons.link, l10n.note_link, controller.insertLink),
                IconButton(
                  icon: const Icon(Icons.image_outlined),
                  tooltip: l10n.note_add_image,
                  onPressed: onAddImage,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
