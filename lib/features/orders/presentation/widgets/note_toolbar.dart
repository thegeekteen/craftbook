import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';

/// One row of formatting buttons for the note editor, meant to sit right above
/// the keyboard.
///
/// Built by hand rather than with Quill's own toolbar: that one sizes its
/// buttons for desktop and wraps to five rows on a phone, and an order note
/// needs a handful of tools, not font pickers and subscript.
class NoteToolbar extends StatelessWidget {
  final QuillController controller;

  /// Runs after every button, so the caret (and keyboard) come back.
  final VoidCallback? afterPressed;

  const NoteToolbar({super.key, required this.controller, this.afterPressed});

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
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 6),
                children: [
                  _button(Icons.undo_rounded, 'Undo',
                      onPressed: controller.hasUndo ? controller.undo : null),
                  _button(Icons.redo_rounded, 'Redo',
                      onPressed: controller.hasRedo ? controller.redo : null),
                  const _Divider(),
                  _toggle(attrs, Attribute.bold, Icons.format_bold_rounded, 'Bold'),
                  _toggle(attrs, Attribute.italic, Icons.format_italic_rounded, 'Italic'),
                  _toggle(attrs, Attribute.underline, Icons.format_underlined_rounded, 'Underline'),
                  _toggle(attrs, Attribute.strikeThrough, Icons.strikethrough_s_rounded, 'Strikethrough'),
                  const _Divider(),
                  _toggle(attrs, Attribute.h2, Icons.title_rounded, 'Heading'),
                  _toggle(attrs, Attribute.unchecked, Icons.checklist_rounded, 'Checklist'),
                  _toggle(attrs, Attribute.ul, Icons.format_list_bulleted_rounded, 'Bullet list'),
                  _toggle(attrs, Attribute.ol, Icons.format_list_numbered_rounded, 'Numbered list'),
                  const _Divider(),
                  _button(Icons.format_clear_rounded, 'Clear formatting', onPressed: _clearFormat),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _toggle(Map<String, Attribute> attrs, Attribute attribute, IconData icon, String tooltip) {
    final current = attrs[attribute.key]?.value;
    // Ticked and unticked are both "a checklist" as far as the button goes.
    final on = attribute == Attribute.unchecked
        ? current == Attribute.unchecked.value || current == Attribute.checked.value
        : current == attribute.value;
    return _button(
      icon,
      tooltip,
      selected: on,
      onPressed: () => controller.formatSelection(on ? Attribute.clone(attribute, null) : attribute),
    );
  }

  /// Strips every attribute in the selection, the way Quill's own button does.
  void _clearFormat() {
    final attributes = {
      for (final style in controller.getAllSelectionStyles()) ...style.attributes.values,
    };
    for (final attribute in attributes) {
      controller.formatSelection(Attribute.clone(attribute, null));
    }
  }

  Widget _button(
    IconData icon,
    String tooltip, {
    required VoidCallback? onPressed,
    bool selected = false,
  }) {
    return _ToolButton(
      icon: icon,
      tooltip: tooltip,
      selected: selected,
      onPressed: onPressed == null
          ? null
          : () {
              onPressed();
              afterPressed?.call();
            },
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
          shape: const RoundedRectangleBorder(borderRadius: AppRadii.controlAll),
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
      child: VerticalDivider(width: 1, thickness: 1, color: context.colors.hair),
    );
  }
}
