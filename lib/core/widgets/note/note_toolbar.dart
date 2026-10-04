import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../theme/colors.dart';
import '../../theme/dimens.dart';
import '../app_sheet.dart';
import 'note_styles.dart';

/// One row of formatting buttons for the note editor, meant to sit right above
/// the keyboard.
///
/// Built by hand rather than with Quill's own toolbar: that one sizes its
/// buttons for desktop and wraps to five rows on a phone. An order note needs
/// a handful of tools; [full] adds the rest for the notebook, still on one
/// scrolling row.
class NoteToolbar extends StatelessWidget {
  final QuillController controller;

  /// Runs after every button, so the caret (and keyboard) come back.
  final VoidCallback? afterPressed;

  /// Adds heading sizes, inline code, highlight, quote, code block, indent,
  /// alignment and links to the compact set.
  final bool full;

  const NoteToolbar({
    super.key,
    required this.controller,
    this.afterPressed,
    this.full = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(top: BorderSide(color: c.hair)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 48,
          child: ListenableBuilder(
            listenable: controller,
            builder: (context, _) {
              final attrs = controller.getSelectionStyle().attributes;
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 6),
                children: [
                  _button(Icons.undo_rounded, 'Undo',
                      onPressed: controller.hasUndo ? controller.undo : null),
                  _button(Icons.redo_rounded, 'Redo',
                      onPressed: controller.hasRedo ? controller.redo : null),
                  const _Divider(),
                  _toggle(
                      attrs, Attribute.bold, Icons.format_bold_rounded, 'Bold'),
                  _toggle(attrs, Attribute.italic, Icons.format_italic_rounded,
                      'Italic'),
                  _toggle(attrs, Attribute.underline,
                      Icons.format_underlined_rounded, 'Underline'),
                  _toggle(attrs, Attribute.strikeThrough,
                      Icons.strikethrough_s_rounded, 'Strikethrough'),
                  if (full) ...[
                    _toggle(attrs, Attribute.inlineCode, Icons.code_rounded,
                        'Inline code'),
                    _button(
                      Icons.format_color_fill_rounded,
                      'Highlight',
                      selected: attrs.containsKey(Attribute.background.key),
                      onPressed: () => _pickHighlight(context),
                      refocus: false,
                    ),
                  ],
                  const _Divider(),
                  if (full)
                    _toggle(attrs, Attribute.h1, Icons.format_size_rounded,
                        'Large heading'),
                  _toggle(attrs, Attribute.h2, Icons.title_rounded, 'Heading'),
                  if (full)
                    _toggle(attrs, Attribute.h3, Icons.text_fields_rounded,
                        'Small heading'),
                  if (full) const _Divider(),
                  _toggle(attrs, Attribute.unchecked, Icons.checklist_rounded,
                      'Checklist'),
                  _toggle(attrs, Attribute.ul,
                      Icons.format_list_bulleted_rounded, 'Bullet list'),
                  _toggle(attrs, Attribute.ol,
                      Icons.format_list_numbered_rounded, 'Numbered list'),
                  if (full) ...[
                    _toggle(attrs, Attribute.blockQuote,
                        Icons.format_quote_rounded, 'Quote'),
                    _toggle(attrs, Attribute.codeBlock,
                        Icons.data_object_rounded, 'Code block'),
                    const _Divider(),
                    _button(Icons.format_indent_decrease_rounded, 'Outdent',
                        onPressed: () => controller.indentSelection(false)),
                    _button(Icons.format_indent_increase_rounded, 'Indent',
                        onPressed: () => controller.indentSelection(true)),
                    _toggle(attrs, Attribute.centerAlignment,
                        Icons.format_align_center_rounded, 'Align centre'),
                    _toggle(attrs, Attribute.rightAlignment,
                        Icons.format_align_right_rounded, 'Align right'),
                    const _Divider(),
                    _button(
                      Icons.link_rounded,
                      'Link',
                      selected: attrs.containsKey(Attribute.link.key),
                      onPressed: () => _editLink(
                          context, attrs[Attribute.link.key]?.value as String?),
                      refocus: false,
                    ),
                  ],
                  const _Divider(),
                  _button(Icons.format_clear_rounded, 'Clear formatting',
                      onPressed: _clearFormat),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _toggle(Map<String, Attribute> attrs, Attribute attribute,
      IconData icon, String tooltip) {
    final current = attrs[attribute.key]?.value;
    // Ticked and unticked are both "a checklist" as far as the button goes.
    final on = attribute == Attribute.unchecked
        ? current == Attribute.unchecked.value ||
            current == Attribute.checked.value
        : current == attribute.value;
    return _button(
      icon,
      tooltip,
      selected: on,
      onPressed: () => controller
          .formatSelection(on ? Attribute.clone(attribute, null) : attribute),
    );
  }

  /// Strips every attribute in the selection, the way Quill's own button does.
  void _clearFormat() {
    final attributes = {
      for (final style in controller.getAllSelectionStyles())
        ...style.attributes.values,
    };
    for (final attribute in attributes) {
      controller.formatSelection(Attribute.clone(attribute, null));
    }
  }

  Future<void> _pickHighlight(BuildContext context) async {
    // Grabbed before the sheet takes focus away and Quill forgets it.
    final selection = controller.selection;
    final picked = await showAppSheet<({String? name})>(
      context: context,
      title: 'Highlight',
      builder: (_) => const _HighlightPicker(),
    );
    if (picked == null) return;
    controller
      ..updateSelection(selection, ChangeSource.local)
      ..formatSelection(BackgroundAttribute(picked.name));
    afterPressed?.call();
  }

  Future<void> _editLink(BuildContext context, String? current) async {
    final selection = controller.selection;
    final url = await showAppSheet<String>(
      context: context,
      title: current == null ? 'Add link' : 'Edit link',
      builder: (_) => _LinkForm(initial: current),
    );
    if (url == null) return;
    controller.updateSelection(selection, ChangeSource.local);
    if (url.isEmpty) {
      controller.formatSelection(Attribute.clone(Attribute.link, null));
    } else if (selection.isCollapsed && current == null) {
      // Nothing selected to turn into a link, so the address becomes the text.
      controller
        ..replaceText(
          selection.start,
          0,
          url,
          TextSelection.collapsed(offset: selection.start + url.length),
        )
        ..formatText(selection.start, url.length, LinkAttribute(url));
    } else {
      controller.formatSelection(LinkAttribute(url));
    }
    afterPressed?.call();
  }

  /// [refocus] is off for buttons that open a sheet: those bring the caret
  /// back themselves once the sheet closes.
  Widget _button(
    IconData icon,
    String tooltip, {
    required VoidCallback? onPressed,
    bool selected = false,
    bool refocus = true,
  }) {
    return _ToolButton(
      icon: icon,
      tooltip: tooltip,
      selected: selected,
      onPressed: onPressed == null
          ? null
          : () {
              onPressed();
              if (refocus) afterPressed?.call();
            },
    );
  }
}

/// Highlight swatches. Each pops with its palette name ([NoteStyles.palette]),
/// or null for none.
class _HighlightPicker extends StatelessWidget {
  const _HighlightPicker();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final palette = NoteStyles.palette(c);
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: [
        _Swatch(
          label: 'None',
          color: c.surface,
          icon: Icons.format_color_reset_rounded,
          onTap: () => Navigator.of(context).pop((name: null)),
        ),
        for (final MapEntry(:key, :value) in palette.entries)
          _Swatch(
            label: NoteStyles.highlightLabels[key] ?? key,
            color: value,
            onTap: () => Navigator.of(context).pop((name: key)),
          ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  final VoidCallback onTap;

  const _Swatch(
      {required this.label,
      required this.color,
      required this.onTap,
      this.icon});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Tooltip(
      message: label,
      child: InkResponse(
        onTap: onTap,
        radius: 26,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: c.hair, width: 1.5),
          ),
          child: icon == null ? null : Icon(icon, size: 20, color: c.muted),
        ),
      ),
    );
  }
}

/// A URL field. Pops with the trimmed address, or '' to remove the link.
class _LinkForm extends StatefulWidget {
  final String? initial;

  const _LinkForm({this.initial});

  @override
  State<_LinkForm> createState() => _LinkFormState();
}

class _LinkFormState extends State<_LinkForm> {
  late final _url = TextEditingController(text: widget.initial ?? 'https://');

  @override
  void dispose() {
    _url.dispose();
    super.dispose();
  }

  void _apply() {
    final url = _url.text.trim();
    if (url.isEmpty || url == 'https://') return;
    Navigator.of(context).pop(url);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _url,
          autofocus: true,
          keyboardType: TextInputType.url,
          autocorrect: false,
          decoration: const InputDecoration(labelText: 'Address'),
          onSubmitted: (_) => _apply(),
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            if (widget.initial != null)
              TextButton(
                onPressed: () => Navigator.of(context).pop(''),
                child: const Text('Remove link'),
              ),
            const Spacer(),
            FilledButton(onPressed: _apply, child: const Text('Apply')),
          ],
        ),
      ],
    );
  }
}

class _ToolButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool selected;
  final VoidCallback? onPressed;

  const _ToolButton({
    required this.icon,
    required this.tooltip,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 1),
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        isSelected: selected,
        icon: Icon(icon, size: 22),
        style: IconButton.styleFrom(
          fixedSize: const Size(36, 36),
          minimumSize: const Size(36, 36),
          padding: EdgeInsets.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          shape:
              const RoundedRectangleBorder(borderRadius: AppRadii.controlAll),
          backgroundColor: selected ? c.goSoft : null,
        ).copyWith(
          foregroundColor: WidgetStatePropertyAll(
            onPressed == null ? c.hair : (selected ? c.go : c.ink),
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child:
          VerticalDivider(width: 1, thickness: 1, color: context.colors.hair),
    );
  }
}
