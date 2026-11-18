import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile_client/features/notes/presentation/markdown/markdown_editing.dart';
import 'package:mobile_client/l10n/app_localizations.dart';
import 'package:mobile_client/shared/dialogs/dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

/// Read-only rendering of a note: the same formatting as the editor, with the
/// markers (`#`, `*`, `_`, `~~`, backticks, link syntax) removed. Links open
/// in the browser after a "you are leaving the app" confirmation.
class MarkdownView extends StatefulWidget {
  const MarkdownView({
    super.key,
    required this.text,
    required this.style,
    this.textDirection,
  });

  /// The editor's display text ([MarkdownTextController.text]).
  final String text;
  final TextStyle style;
  final TextDirection? textDirection;

  @override
  State<MarkdownView> createState() => _MarkdownViewState();
}

class _MarkdownViewState extends State<MarkdownView> {
  final List<TapGestureRecognizer> _recognizers = [];

  void _disposeRecognizers() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _disposeRecognizers();
    super.dispose();
  }

  GestureRecognizer _recognizerFor(String url) {
    final r = TapGestureRecognizer()..onTap = () => _open(url);
    _recognizers.add(r);
    return r;
  }

  Future<void> _open(String raw) async {
    final l10n = AppLocalizations.of(context)!;
    var url = raw.trim();
    var uri = Uri.tryParse(url);
    if (uri != null && !uri.hasScheme) {
      url = 'https://$url';
      uri = Uri.tryParse(url);
    }
    const allowed = {'http', 'https', 'mailto', 'tel'};
    if (uri == null || !allowed.contains(uri.scheme)) return;

    final ok = await showConfirmDialog(
      context,
      title: l10n.note_link_leave_title,
      message: l10n.note_link_leave_body(url),
      confirmLabel: l10n.note_link_open,
    );
    if (!ok) return;
    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && mounted) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(l10n.note_link_failed)));
    }
  }

  @override
  Widget build(BuildContext context) {
    _disposeRecognizers();
    final cs = Theme.of(context).colorScheme;
    final spans = MarkdownSpans.build(
      widget.text,
      base: widget.style,
      cs: cs,
      hideMarkers: true,
      linkRecognizer: _recognizerFor,
    );
    return SelectionArea(
      child: SizedBox(
        width: double.infinity,
        child: Text.rich(
          TextSpan(style: widget.style, children: spans),
          textDirection: widget.textDirection,
        ),
      ),
    );
  }
}
