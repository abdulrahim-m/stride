import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Offset of the first character of the line containing [offset].
int lineStartOf(String text, int offset) =>
    offset <= 0 ? 0 : text.lastIndexOf('\n', offset - 1) + 1;

/// Offset just past the last character of the line containing [offset].
int lineEndOf(String text, int offset) {
  final i = text.indexOf('\n', offset);
  return i == -1 ? text.length : i;
}

/// Converts between the markdown that is stored in the database and the
/// "display text" that lives inside the editor.
///
/// The editor shows list markers as real glyphs so the effect is visible while
/// typing, without needing widgets inside the text field:
///
///     markdown            display
///     - item              • item        (◦ / ▪)
///     - [ ] task          ☐ task
///     - [x] task          ☑ task
///       - sub item        ◦ sub item    (1 leading space per level)
///
/// Headers (`#`, `##`, `###`) stay as typed and are only styled.
class MarkdownCodec {
  MarkdownCodec._();

  static const unchecked = '☐';
  static const checked = '☑';

  /// Bullet glyph for a nesting level (= number of leading spaces).
  static String bullet(int level) => level <= 0
      ? '•'
      : level == 1
      ? '◦'
      : '▪';

  /// A list line in display form: indent, glyph, one space, content.
  static final RegExp displayItem = RegExp(r'^( *)(•|◦|▪|☐|☑) (.*)$');

  static final RegExp _mdItem = RegExp(
    r'^([ \t]*)[-*+] (?:\[([ xX])\](?: |$))?(.*)$',
  );

  static String fromMarkdown(String md) {
    final lines = md.replaceAll('\r\n', '\n').split('\n');
    return lines.map(_lineFromMd).join('\n');
  }

  static String _lineFromMd(String line) {
    final m = _mdItem.firstMatch(line);
    if (m == null) return line;
    final level = m.group(1)!.replaceAll('\t', '  ').length ~/ 2;
    final box = m.group(2);
    final glyph = box == null ? bullet(level) : (box == ' ' ? unchecked : checked);
    return '${' ' * level}$glyph ${m.group(3)}';
  }

  static String toMarkdown(String display) =>
      display.split('\n').map(_lineToMd).join('\n');

  static String _lineToMd(String line) {
    final m = displayItem.firstMatch(line);
    if (m == null) return line;
    final glyph = m.group(2)!;
    final marker = glyph == unchecked
        ? '- [ ] '
        : glyph == checked
        ? '- [x] '
        : '- ';
    return '${'  ' * m.group(1)!.length}$marker${m.group(3)}';
  }

  /// Makes sure a bullet line uses the glyph that matches its indentation.
  /// Never changes the length of the line.
  static String normalizeLine(String line) {
    final m = displayItem.firstMatch(line);
    if (m == null) return line;
    final glyph = m.group(2)!;
    if (glyph == unchecked || glyph == checked) return line;
    final want = bullet(m.group(1)!.length);
    return glyph == want ? line : '${m.group(1)}$want ${m.group(3)}';
  }
}

/// Turns display text (see [MarkdownCodec]) into styled spans.
///
/// With `hideMarkers: false` (the editor) the spans add up to exactly the
/// input text, markers are only dimmed. With `hideMarkers: true` (view mode)
/// `#`, `>`, `*`, `_`, `~~`, backticks and the link syntax are dropped, the
/// formatting stays, and links get a tap recognizer from [linkRecognizer].
class MarkdownSpans {
  MarkdownSpans._();

  static final RegExp headRe = RegExp(r'^(#{1,3}) (.*)$');
  static final RegExp quoteRe = RegExp(r'^> (.*)$');
  static final RegExp numberedRe = RegExp(r'^( *)(\d{1,3})\. (.*)$');

  static List<InlineSpan> build(
    String text, {
    required TextStyle base,
    required ColorScheme cs,
    bool hideMarkers = false,
    GestureRecognizer Function(String url)? linkRecognizer,
  }) {
    final hide = hideMarkers;
    final fs = base.fontSize ?? 16;
    final dim = cs.onSurface.withValues(alpha: 0.4);
    final lines = text.split('\n');
    final spans = <InlineSpan>[];

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final nl = i < lines.length - 1 ? '\n' : '';

      final head = headRe.firstMatch(line);
      if (head != null) {
        final level = head.group(1)!.length;
        final size = fs * (level == 1 ? 1.6 : (level == 2 ? 1.35 : 1.15));
        final hs = base.copyWith(fontSize: size, fontWeight: FontWeight.w700);
        if (!hide) {
          // Invisible and takes no room; the caret can't enter it, see
          // [MarkdownTextController.value].
          spans.add(
            TextSpan(
              text: '${head.group(1)} ',
              style: hs.copyWith(color: Colors.transparent, fontSize: 0.01),
            ),
          );
        }
        spans.addAll(_inline(head.group(2)!, hs, dim, cs, hide, linkRecognizer));
        if (nl.isNotEmpty) spans.add(TextSpan(text: nl, style: hs));
        continue;
      }

      final quote = quoteRe.firstMatch(line);
      if (quote != null) {
        final qs = base.copyWith(
          fontStyle: FontStyle.italic,
          color: cs.onSurface.withValues(alpha: 0.7),
        );
        if (!hide) {
          spans.add(
            TextSpan(
              text: '> ',
              style: base.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          );
        }
        spans.addAll(
          _inline(quote.group(1)!, qs, dim, cs, hide, linkRecognizer),
        );
        if (nl.isNotEmpty) spans.add(TextSpan(text: nl, style: qs));
        continue;
      }

      final num = numberedRe.firstMatch(line);
      if (num != null) {
        spans.add(TextSpan(text: num.group(1)!, style: base));
        spans.add(
          TextSpan(
            text: '${num.group(2)}. ',
            style: base.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
        spans.addAll(_inline(num.group(3)!, base, dim, cs, hide, linkRecognizer));
        if (nl.isNotEmpty) spans.add(TextSpan(text: nl, style: base));
        continue;
      }

      final item = MarkdownCodec.displayItem.firstMatch(line);
      if (item != null) {
        final indent = item.group(1)!;
        final glyph = item.group(2)!;
        final isBox =
            glyph == MarkdownCodec.unchecked || glyph == MarkdownCodec.checked;
        final done = glyph == MarkdownCodec.checked;
        if (indent.isNotEmpty) {
          spans.add(
            TextSpan(
              text: indent,
              style: base.copyWith(letterSpacing: fs * 0.9),
            ),
          );
        }
        spans.add(
          TextSpan(
            text: glyph,
            style: base.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
              fontSize: isBox ? fs * 1.25 : fs,
            ),
          ),
        );
        spans.add(TextSpan(text: ' ', style: base));
        final bodyStyle = done
            ? base.copyWith(decoration: TextDecoration.lineThrough, color: dim)
            : base;
        spans.addAll(
          _inline(item.group(3)!, bodyStyle, dim, cs, hide, linkRecognizer),
        );
        if (nl.isNotEmpty) spans.add(TextSpan(text: nl, style: bodyStyle));
        continue;
      }

      spans.addAll(_inline(line, base, dim, cs, hide, linkRecognizer));
      if (nl.isNotEmpty) spans.add(TextSpan(text: nl, style: base));
    }
    return spans;
  }

  // One pass, first alternative that matches wins. Group numbers: 1 bold+
  // italic, 2 bold, 3 strike, 4 code, 5 italic (*), 6 italic (_), 7/8 link.
  static final RegExp _inlineRe = RegExp(
    r'\*\*\*(.+?)\*\*\*'
    r'|\*\*(.+?)\*\*'
    r'|~~(.+?)~~'
    r'|`([^`]+)`'
    r'|\*([^*\s](?:[^*]*[^*\s])?)\*'
    r'|(?<![A-Za-z0-9])_([^_\s](?:[^_]*[^_\s])?)_(?![A-Za-z0-9])'
    r'|!?\[([^\]]*)\]\(([^)\s]+)\)',
  );

  /// Styles inline markdown. The returned spans always add up to exactly
  /// [text], markers are only dimmed, never removed, so offsets stay valid.
  static List<InlineSpan> _inline(
    String text,
    TextStyle style,
    Color dim,
    ColorScheme cs,
    bool hide,
    GestureRecognizer Function(String url)? onLink,
  ) {
    final out = <InlineSpan>[];
    var pos = 0;
    // Edit mode: markers stay, dimmed (offsets must match the text exactly).
    // View mode: markers are dropped.
    InlineSpan mark(String t) => hide
        ? const TextSpan(text: '')
        : TextSpan(text: t, style: style.copyWith(color: dim));

    for (final m in _inlineRe.allMatches(text)) {
      if (m.start > pos) {
        out.add(TextSpan(text: text.substring(pos, m.start), style: style));
      }
      final whole = m.group(0)!;
      if (m.group(1) != null) {
        out.add(mark('***'));
        out.addAll(
          _inline(
            m.group(1)!,
            style.copyWith(
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
            ),
            dim,
            cs,
            hide,
            onLink,
          ),
        );
        out.add(mark('***'));
      } else if (m.group(2) != null) {
        out.add(mark('**'));
        out.addAll(
          _inline(
            m.group(2)!,
            style.copyWith(fontWeight: FontWeight.w700),
            dim,
            cs,
            hide,
            onLink,
          ),
        );
        out.add(mark('**'));
      } else if (m.group(3) != null) {
        out.add(mark('~~'));
        out.addAll(
          _inline(
            m.group(3)!,
            style.copyWith(decoration: TextDecoration.lineThrough),
            dim,
            cs,
            hide,
            onLink,
          ),
        );
        out.add(mark('~~'));
      } else if (m.group(4) != null) {
        out.add(mark('`'));
        out.add(
          TextSpan(
            text: m.group(4),
            style: style.copyWith(
              fontFamily: 'monospace',
              backgroundColor: cs.onSurface.withValues(alpha: 0.08),
            ),
          ),
        );
        out.add(mark('`'));
      } else if (m.group(5) != null || m.group(6) != null) {
        final inner = (m.group(5) ?? m.group(6))!;
        final c = m.group(5) != null ? '*' : '_';
        out.add(mark(c));
        out.addAll(
          _inline(
            inner,
            style.copyWith(fontStyle: FontStyle.italic),
            dim,
            cs,
            hide,
            onLink,
          ),
        );
        out.add(mark(c));
      } else {
        // [label](url), shown as a link, the url part is dimmed.
        final label = m.group(7)!;
        final bang = whole.startsWith('!') ? '!' : '';
        out.add(mark('$bang['));
        final url = m.group(8)!;
        final isImage = bang.isNotEmpty;
        out.add(
          TextSpan(
            text: label,
            style: style.copyWith(
              color: cs.primary,
              decoration: TextDecoration.underline,
              decorationColor: cs.primary,
            ),
            recognizer: (hide && !isImage) ? onLink?.call(url) : null,
          ),
        );
        out.add(mark(']($url)'));
      }
      pos = m.end;
    }
    if (pos < text.length) {
      out.add(TextSpan(text: text.substring(pos), style: style));
    }
    return out;
  }
}

/// A text controller that styles markdown as you type and offers the line
/// operations used by the toolbar. Its [text] is the *display* text, use
/// [markdown] to get what should be stored.
class MarkdownTextController extends TextEditingController {
  MarkdownTextController({super.text});

  static const _maxIndent = 6;
  static final RegExp _head = MarkdownSpans.headRe;
  static final RegExp _quote = MarkdownSpans.quoteRe;
  static final RegExp _numbered = MarkdownSpans.numberedRe;

  String get markdown => MarkdownCodec.toMarkdown(text);

  static final RegExp _headMarker = RegExp(r'^#{1,3} ');

  /// The `#` of a heading is invisible, so the caret must never rest inside
  /// it (typing there would break the heading without any visible reason).
  @override
  set value(TextEditingValue newValue) {
    super.value = _outOfHeadingMarker(newValue);
  }

  TextEditingValue _outOfHeadingMarker(TextEditingValue v) {
    final sel = v.selection;
    if (!sel.isValid || !sel.isCollapsed) return v;
    final off = sel.baseOffset;
    if (off < 0 || off > v.text.length) return v;
    final ls = lineStartOf(v.text, off);
    final m = _headMarker.firstMatch(
      v.text.substring(ls, lineEndOf(v.text, off)),
    );
    if (m == null || off >= ls + m.end) return v;
    return v.copyWith(selection: TextSelection.collapsed(offset: ls + m.end));
  }

  // ------------------------------------------------------------ rendering
  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final theme = Theme.of(context);
    final base = style ?? theme.textTheme.bodyLarge ?? const TextStyle();
    return TextSpan(
      style: base,
      children: MarkdownSpans.build(text, base: base, cs: theme.colorScheme),
    );
  }

  // ------------------------------------------------------- toolbar actions
  /// Cycles the line(s) through `#` → `##` → `###` → plain.
  void toggleHeading() => _editSelectedLines((line) {
    if (MarkdownCodec.displayItem.hasMatch(line)) return line;
    final m = _head.firstMatch(line);
    if (m == null) return '# $line';
    final n = m.group(1)!.length;
    return n >= 3 ? m.group(2)! : '${'#' * (n + 1)} ${m.group(2)}';
  });

  // ------------------------------------------------------- inline formatting
  void toggleBold() => _toggleWrap('**');

  void toggleItalic() => _toggleWrap('*');

  void toggleStrike() => _toggleWrap('~~');

  void toggleCode() => _toggleWrap('`');

  /// Wraps the selection (or the word under the caret) in [marker], or
  /// removes the marker if it is already wrapped.
  void _toggleWrap(String marker) {
    final t = text;
    var sel = selection.isValid
        ? selection
        : TextSelection.collapsed(offset: t.length);
    var start = sel.start;
    var end = sel.end;

    if (sel.isCollapsed) {
      // Grow to the word around the caret.
      while (start > 0 && !_isSpace(t[start - 1])) {
        start--;
      }
      while (end < t.length && !_isSpace(t[end])) {
        end++;
      }
    }

    final m = marker.length;
    final star = marker.startsWith('*');
    int run(int from, int dir) {
      var n = 0;
      var i = from;
      while (i >= 0 && i < t.length && t[i] == '*') {
        n++;
        i += dir;
      }
      return n;
    }

    bool wrapped;
    if (star) {
      final n = math.min(run(start - 1, -1), run(end, 1));
      wrapped = marker == '**' ? n >= 2 : n == 1 || n == 3;
    } else {
      wrapped =
          start >= m &&
          end + m <= t.length &&
          t.substring(start - m, start) == marker &&
          t.substring(end, end + m) == marker;
    }

    if (wrapped) {
      final out = t.replaceRange(end, end + m, '').replaceRange(start - m, start, '');
      value = value.copyWith(
        text: out,
        selection: TextSelection(
          baseOffset: sel.baseOffset - m,
          extentOffset: sel.extentOffset - m,
        ),
        composing: TextRange.empty,
      );
      return;
    }

    if (start == end) {
      // Empty selection on an empty spot: drop a pair and sit between them.
      value = value.copyWith(
        text: t.replaceRange(start, end, '$marker$marker'),
        selection: TextSelection.collapsed(offset: start + m),
        composing: TextRange.empty,
      );
      return;
    }
    value = value.copyWith(
      text: t.replaceRange(start, end, '$marker${t.substring(start, end)}$marker'),
      selection: TextSelection(
        baseOffset: sel.baseOffset + m,
        extentOffset: sel.extentOffset + m,
      ),
      composing: TextRange.empty,
    );
  }

  static bool _isSpace(String c) => c == ' ' || c == '\n' || c == '\t';

  /// Turns the selection (or a placeholder) into `[text](https://)` and
  /// selects the url part, ready to be typed over.
  void insertLink() {
    final t = text;
    final sel = selection.isValid
        ? selection
        : TextSelection.collapsed(offset: t.length);
    final label = sel.isCollapsed ? '' : t.substring(sel.start, sel.end);
    const url = 'https://';
    final insert = '[$label]($url)';
    final urlStart = sel.start + label.length + 3;
    value = value.copyWith(
      text: t.replaceRange(sel.start, sel.end, insert),
      selection: label.isEmpty
          ? TextSelection.collapsed(offset: sel.start + 1)
          : TextSelection(baseOffset: urlStart, extentOffset: urlStart + url.length),
      composing: TextRange.empty,
    );
  }

  // ------------------------------------------------------------ line blocks
  void toggleQuote() => _editSelectedLines((line) {
    if (MarkdownCodec.displayItem.hasMatch(line)) return line;
    final q = _quote.firstMatch(line);
    if (q != null) return q.group(1)!;
    final h = _head.firstMatch(line);
    return '> ${h != null ? h.group(2)! : line}';
  });

  /// Numbers the selected lines 1., 2., 3., or strips the numbers again.
  void toggleNumbered() {
    var n = 0;
    _editSelectedLines((line) {
      final m = _numbered.firstMatch(line);
      if (m != null) return '${m.group(1)}${m.group(3)}';
      if (MarkdownCodec.displayItem.hasMatch(line)) return line;
      n++;
      final h = _head.firstMatch(line);
      return '$n. ${h != null ? h.group(2)! : line}';
    });
  }

  void toggleBullet() => _toggleList(checklist: false);

  void toggleChecklist() => _toggleList(checklist: true);

  void _toggleList({required bool checklist}) => _editSelectedLines((line) {
    final m = MarkdownCodec.displayItem.firstMatch(line);
    if (m != null) {
      final glyph = m.group(2)!;
      final isBox =
          glyph == MarkdownCodec.unchecked || glyph == MarkdownCodec.checked;
      if (isBox == checklist) return m.group(3)!; // same kind: remove marker
      final indent = m.group(1)!;
      final g = checklist
          ? MarkdownCodec.unchecked
          : MarkdownCodec.bullet(indent.length);
      return '$indent$g ${m.group(3)}';
    }
    var body = line;
    final h = _head.firstMatch(line);
    if (h != null) body = h.group(2)!;
    final lead = RegExp(r'^ *').stringMatch(body)!;
    final rest = body.substring(lead.length);
    final g = checklist
        ? MarkdownCodec.unchecked
        : MarkdownCodec.bullet(lead.length);
    return '$lead$g $rest';
  });

  void indent() => _editSelectedLines((line) {
    final m = MarkdownCodec.displayItem.firstMatch(line);
    if (m == null || m.group(1)!.length >= _maxIndent) return line;
    return MarkdownCodec.normalizeLine(' $line');
  });

  void outdent() => _editSelectedLines((line) {
    final m = MarkdownCodec.displayItem.firstMatch(line);
    if (m == null || m.group(1)!.isEmpty) return line;
    return MarkdownCodec.normalizeLine(line.substring(1));
  });

  /// If the caret sits right next to a ☐/☑ glyph (i.e. the user tapped it),
  /// flips it and returns true.
  bool toggleCheckboxAtCaret() {
    final sel = selection;
    if (!sel.isValid || !sel.isCollapsed) return false;
    final t = text;
    final off = sel.baseOffset;
    final ls = lineStartOf(t, off);
    final le = lineEndOf(t, off);
    final m = MarkdownCodec.displayItem.firstMatch(t.substring(ls, le));
    if (m == null) return false;
    final glyph = m.group(2)!;
    if (glyph != MarkdownCodec.unchecked && glyph != MarkdownCodec.checked) {
      return false;
    }
    final gs = ls + m.group(1)!.length;
    if (off != gs && off != gs + 1) return false;
    final flipped = glyph == MarkdownCodec.unchecked
        ? MarkdownCodec.checked
        : MarkdownCodec.unchecked;
    value = value.copyWith(
      text: t.replaceRange(gs, gs + 1, flipped),
      composing: TextRange.empty,
    );
    return true;
  }

  /// Applies [transform] to every line touched by the selection and keeps the
  /// selection on the same content.
  void _editSelectedLines(String Function(String line) transform) {
    final t = text;
    final sel = selection.isValid
        ? selection
        : TextSelection.collapsed(offset: t.length);
    final lines = t.split('\n');
    final starts = <int>[];
    var p = 0;
    for (final l in lines) {
      starts.add(p);
      p += l.length + 1;
    }
    int lineOf(int off) {
      var i = 0;
      while (i + 1 < lines.length && starts[i + 1] <= off) {
        i++;
      }
      return i;
    }

    final first = lineOf(sel.start);
    final last = lineOf(sel.end);
    final out = <String>[];
    var base = sel.baseOffset;
    var extent = sel.extentOffset;

    for (var i = 0; i < lines.length; i++) {
      final old = lines[i];
      final neu = (i >= first && i <= last) ? transform(old) : old;
      out.add(neu);
      final delta = neu.length - old.length;
      if (delta == 0) continue;
      base += _shift(sel.baseOffset, starts[i], delta);
      extent += _shift(sel.extentOffset, starts[i], delta);
    }

    value = value.copyWith(
      text: out.join('\n'),
      selection: TextSelection(baseOffset: base, extentOffset: extent),
      composing: TextRange.empty,
    );
  }

  /// How far an offset moves when the line starting at [lineStart] changes
  /// length by [delta], never moves it in front of the line start.
  static int _shift(int offset, int lineStart, int delta) {
    if (offset < lineStart) return 0;
    if (delta >= 0) return delta;
    final floor = lineStart - offset;
    return floor > delta ? floor : delta;
  }
}

/// Makes typing behave like a list-aware editor.
class MarkdownInputFormatter extends TextInputFormatter {
  static final RegExp _dash = RegExp(r'^( *)- ');
  static final RegExp _dashBox = RegExp(r'^( *)(?:•|◦|▪) \[([ xX]?)\] ');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (!newValue.selection.isValid || !newValue.selection.isCollapsed) {
      return newValue;
    }
    // Never rewrite text while the IME is composing a word.
    if (newValue.composing.isValid && !newValue.composing.isCollapsed) {
      return newValue;
    }
    final grew = newValue.text.length - oldValue.text.length;
    if (grew == 1) {
      return _enter(oldValue, newValue) ??
          _enterPrefixed(oldValue, newValue) ??
          _typed(newValue);
    }
    if (grew == -1) return _backspace(oldValue, newValue) ?? newValue;
    if (grew > 1) return _pasted(oldValue, newValue) ?? newValue;
    return newValue;
  }

  TextEditingValue? _enter(TextEditingValue old, TextEditingValue neu) {
    final p = neu.selection.baseOffset - 1;
    if (p < 0 || neu.text[p] != '\n') return null;
    if (!old.selection.isValid ||
        !old.selection.isCollapsed ||
        old.selection.baseOffset != p) {
      return null;
    }
    if (neu.text.replaceRange(p, p + 1, '') != old.text) return null;

    final t = old.text;
    final ls = lineStartOf(t, p);
    final le = lineEndOf(t, p);
    final m = MarkdownCodec.displayItem.firstMatch(t.substring(ls, le));
    if (m == null) return null;
    final indent = m.group(1)!;
    if (p - ls < indent.length + 2) return null; // caret is before the marker

    if (m.group(3)!.isEmpty) {
      // Empty item: step out one level, or end the list.
      final newLine = indent.isNotEmpty
          ? MarkdownCodec.normalizeLine(t.substring(ls + 1, le))
          : '';
      return TextEditingValue(
        text: t.replaceRange(ls, le, newLine),
        selection: TextSelection.collapsed(offset: ls + newLine.length),
      );
    }

    final glyph = m.group(2)!;
    final marker =
        '$indent${glyph == MarkdownCodec.checked ? MarkdownCodec.unchecked : glyph} ';
    return TextEditingValue(
      text: neu.text.replaceRange(p + 1, p + 1, marker),
      selection: TextSelection.collapsed(offset: p + 1 + marker.length),
    );
  }

  static final RegExp _numberedLine = RegExp(r'^( *)(\d{1,3})\. (.*)$');
  static final RegExp _quoteLine = RegExp(r'^> (.*)$');

  /// Enter on a numbered or quoted line: continue it (2. → 3., > → >), or on
  /// an empty one end the block.
  TextEditingValue? _enterPrefixed(TextEditingValue old, TextEditingValue neu) {
    final p = neu.selection.baseOffset - 1;
    if (p < 0 || neu.text[p] != '\n') return null;
    if (!old.selection.isValid ||
        !old.selection.isCollapsed ||
        old.selection.baseOffset != p) {
      return null;
    }
    if (neu.text.replaceRange(p, p + 1, '') != old.text) return null;

    final t = old.text;
    final ls = lineStartOf(t, p);
    final le = lineEndOf(t, p);
    final line = t.substring(ls, le);

    String? marker; // what the new line starts with
    String content;
    int markerLen;
    final n = _numberedLine.firstMatch(line);
    final q = _quoteLine.firstMatch(line);
    if (n != null) {
      content = n.group(3)!;
      markerLen = n.group(1)!.length + n.group(2)!.length + 2;
      marker = '${n.group(1)}${int.parse(n.group(2)!) + 1}. ';
    } else if (q != null) {
      content = q.group(1)!;
      markerLen = 2;
      marker = '> ';
    } else {
      return null;
    }
    if (p - ls < markerLen) return null; // caret is before the marker

    if (content.isEmpty) {
      return TextEditingValue(
        text: t.replaceRange(ls, le, ''),
        selection: TextSelection.collapsed(offset: ls),
      );
    }
    return TextEditingValue(
      text: neu.text.replaceRange(p + 1, p + 1, marker),
      selection: TextSelection.collapsed(offset: p + 1 + marker.length),
    );
  }

  TextEditingValue? _backspace(TextEditingValue old, TextEditingValue neu) {
    if (!old.selection.isValid || !old.selection.isCollapsed) return null;
    final d = neu.selection.baseOffset;
    if (d < 0 || d != old.selection.baseOffset - 1) return null;
    if (old.text.replaceRange(d, d + 1, '') != neu.text) return null;

    final t = old.text;
    if (t[d] != ' ') return null;
    final ls = lineStartOf(t, d);
    final le = lineEndOf(t, d);
    final m = MarkdownCodec.displayItem.firstMatch(t.substring(ls, le));
    if (m == null) return null;
    final indent = m.group(1)!.length;
    if (d != ls + indent + 1) return null; // not the space after the glyph

    return TextEditingValue(
      text: t.replaceRange(ls + indent, ls + indent + 2, ''),
      selection: TextSelection.collapsed(offset: ls + indent),
    );
  }

  TextEditingValue _typed(TextEditingValue neu) {
    final c = neu.selection.baseOffset;
    final t = neu.text;
    final ls = lineStartOf(t, c);
    final le = lineEndOf(t, c);
    final line = t.substring(ls, le);

    final dash = _dash.firstMatch(line);
    if (dash != null && c == ls + dash.end) {
      final indent = dash.group(1)!;
      final repl = '$indent${MarkdownCodec.bullet(indent.length)} ';
      return neu.copyWith(text: t.replaceRange(ls, ls + dash.end, repl));
    }

    final box = _dashBox.firstMatch(line);
    if (box != null && c == ls + box.end) {
      final mark = box.group(2)!.trim().isEmpty
          ? MarkdownCodec.unchecked
          : MarkdownCodec.checked;
      final repl = '${box.group(1)}$mark ';
      return TextEditingValue(
        text: t.replaceRange(ls, ls + box.end, repl),
        selection: TextSelection.collapsed(offset: ls + repl.length),
      );
    }

    final norm = MarkdownCodec.normalizeLine(line);
    if (norm != line) {
      return neu.copyWith(text: t.replaceRange(ls, le, norm));
    }
    return neu;
  }

  TextEditingValue? _pasted(TextEditingValue old, TextEditingValue neu) {
    if (!old.selection.isValid) return null;
    final start = old.selection.start;
    final end = neu.selection.baseOffset;
    final tail = old.text.substring(old.selection.end);
    if (end < start ||
        !neu.text.endsWith(tail) ||
        neu.text.length - tail.length != end ||
        neu.text.substring(0, start) != old.text.substring(0, start)) {
      return null;
    }

    final inserted = neu.text.substring(start, end);
    final atLineStart = start == 0 || neu.text[start - 1] == '\n';
    String converted;
    if (atLineStart) {
      converted = MarkdownCodec.fromMarkdown(inserted);
    } else {
      final i = inserted.indexOf('\n');
      converted = i == -1
          ? inserted
          : inserted.substring(0, i + 1) +
                MarkdownCodec.fromMarkdown(inserted.substring(i + 1));
    }
    if (converted == inserted) return null;
    return TextEditingValue(
      text: neu.text.replaceRange(start, end, converted),
      selection: TextSelection.collapsed(offset: start + converted.length),
    );
  }
}
