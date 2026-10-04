import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../theme/colors.dart';
import '../../theme/dimens.dart';
import '../../theme/text_styles.dart';

/// Quill has its own style vocabulary; this maps it onto [CraftColors] and
/// [AppTextStyles] so notes read like the rest of the app in both themes.
abstract final class NoteStyles {
  /// Editor content styles, shared by the editor and the order page so a note
  /// looks the same while it is written and after it is saved.
  static DefaultStyles editor(CraftColors c) {
    final base = AppTextStyles.bodyMedium.copyWith(color: c.ink, height: 1.45);
    final mono = base.copyWith(fontFamily: AppTextStyles.mono, fontSize: 13);
    const flat = HorizontalSpacing(0, 0);

    DefaultTextBlockStyle block(TextStyle style,
            [VerticalSpacing above = VerticalSpacing.zero]) =>
        DefaultTextBlockStyle(style, flat, above, VerticalSpacing.zero, null);

    final heading =
        AppTextStyles.displaySmall.copyWith(color: c.ink, height: 1.3);

    return DefaultStyles(
      paragraph: block(base),
      h1: block(heading.copyWith(fontSize: 22), const VerticalSpacing(12, 4)),
      h2: block(heading.copyWith(fontSize: 18), const VerticalSpacing(10, 4)),
      h3: block(heading.copyWith(fontSize: 16), const VerticalSpacing(8, 2)),
      h4: block(base.copyWith(fontWeight: FontWeight.w700)),
      h5: block(base.copyWith(fontWeight: FontWeight.w700)),
      h6: block(base.copyWith(fontWeight: FontWeight.w700)),
      lineHeightNormal: block(base),
      lineHeightTight: block(base.copyWith(height: 1.2)),
      lineHeightOneAndHalf: block(base.copyWith(height: 1.75)),
      lineHeightDouble: block(base.copyWith(height: 2.1)),
      bold: const TextStyle(fontWeight: FontWeight.w700),
      italic: const TextStyle(fontStyle: FontStyle.italic),
      underline: const TextStyle(decoration: TextDecoration.underline),
      strikeThrough: const TextStyle(decoration: TextDecoration.lineThrough),
      small: const TextStyle(fontSize: 12),
      subscript: const TextStyle(
        fontFeatures: [FontFeature.liningFigures(), FontFeature.subscripts()],
      ),
      superscript: const TextStyle(
        fontFeatures: [FontFeature.liningFigures(), FontFeature.superscripts()],
      ),
      inlineCode: InlineCodeStyle(
        style: mono.copyWith(color: c.ink),
        backgroundColor: c.paper,
        radius: const Radius.circular(AppRadii.tag),
      ),
      link: base.copyWith(color: c.go, decoration: TextDecoration.underline),
      color: c.ink,
      placeHolder: block(base.copyWith(color: c.muted)),
      lists: DefaultListBlockStyle(
        base,
        flat,
        const VerticalSpacing(4, 4),
        const VerticalSpacing(2, 2),
        null,
        _NoteCheckbox(c),
      ),
      quote: DefaultTextBlockStyle(
        base.copyWith(color: c.muted),
        const HorizontalSpacing(12, 0),
        const VerticalSpacing(6, 6),
        VerticalSpacing.zero,
        BoxDecoration(
            border: Border(left: BorderSide(width: 3, color: c.hair))),
      ),
      code: DefaultTextBlockStyle(
        mono.copyWith(color: c.ink, height: 1.45),
        const HorizontalSpacing(10, 8),
        const VerticalSpacing(8, 0),
        VerticalSpacing.zero,
        BoxDecoration(color: c.paper, borderRadius: AppRadii.controlAll),
      ),
      indent: block(base),
      align: block(base),
      leading: block(base.copyWith(color: c.muted)),
      sizeSmall: const TextStyle(fontSize: 12.5),
      sizeLarge: const TextStyle(fontSize: 17),
      sizeHuge: const TextStyle(fontSize: 21),
      palette: palette(c),
    );
  }

  /// Highlight colours by the name stored in the note. Names rather than hex,
  /// so a highlight follows the theme instead of glaring in dark mode.
  static Map<String, Color> palette(CraftColors c) => {
        'warn': c.warnSoft,
        'go': c.goSoft,
        'coin': c.coinSoft,
        'alert': c.alertSoft,
      };

  static const highlightLabels = {
    'warn': 'Sand',
    'go': 'Green',
    'coin': 'Lavender',
    'alert': 'Rose',
  };

  /// Line-level extras Quill can't express through [DefaultStyles]: a ticked
  /// to-do fades and is struck through, so what's left to do stands out.
  static TextStyle Function(Attribute) lineStyles(CraftColors c) =>
      (attribute) {
        if (attribute == Attribute.checked) {
          return TextStyle(
            color: c.muted,
            decoration: TextDecoration.lineThrough,
            decorationColor: c.muted,
          );
        }
        return const TextStyle();
      };
}

/// The to-do box, in app colours instead of Quill's grey Material default.
class _NoteCheckbox implements QuillCheckboxBuilder {
  final CraftColors c;

  const _NoteCheckbox(this.c);

  @override
  Widget build({
    required BuildContext context,
    required bool isChecked,
    required ValueChanged<bool> onChanged,
  }) {
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Semantics(
        checked: isChecked,
        child: InkResponse(
          onTap: () => onChanged(!isChecked),
          radius: 18,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              color: isChecked ? c.go : c.surface,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: isChecked ? c.go : c.muted, width: 1.5),
            ),
            child: isChecked
                ? Icon(Icons.check_rounded, size: 14, color: c.onAccent)
                : null,
          ),
        ),
      ),
    );
  }
}
