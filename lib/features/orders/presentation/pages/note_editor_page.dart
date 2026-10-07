import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/note_codec.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/note/note_styles.dart';
import '../../../../core/widgets/note/note_toolbar.dart';

/// Full-screen rich-text editor for one order note.
///
/// Pops `(:note)` with the note to store — null when it was emptied — or null
/// itself when the user backed out, which leaves the saved note alone.
class NoteEditorPage extends StatefulWidget {
  final String? initialNote;

  const NoteEditorPage({super.key, this.initialNote});

  /// Pushes the editor over [context]. Not a router page: it is a modal step
  /// that hands a value back, the way the adjust-materials sheet does.
  static Future<({String? note})?> open(BuildContext context, {String? note}) {
    return Navigator.of(context).push<({String? note})>(
      MaterialPageRoute(builder: (_) => NoteEditorPage(initialNote: note)),
    );
  }

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late final QuillController _controller;
  final _focusNode = FocusNode();
  final _scrollController = ScrollController();

  /// How the note would be stored on open, so "changed" still means something
  /// when a legacy plain-text note becomes Delta JSON on first save.
  late final String? _opened;
  bool _changed = false;

  @override
  void initState() {
    super.initState();
    final document = Document.fromDelta(NoteCodec.decode(widget.initialNote));
    _controller = QuillController(
      document: document,
      // Caret at the end, ready to add to what's there.
      selection: TextSelection.collapsed(offset: document.length - 1),
    );
    _opened = _encoded;
    _controller.addListener(_onChange);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onChange)
      ..dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? get _encoded => NoteCodec.encode(_controller.document.toDelta());

  void _onChange() {
    final changed = _encoded != _opened;
    if (changed != _changed) setState(() => _changed = changed);
  }

  Future<void> _handleBack() async {
    if (!_changed) {
      Navigator.of(context).pop();
      return;
    }
    final discard = await ConfirmDialog.show(
      context,
      title: context.l10n.ordersDiscardChangesTitle,
      message: context.l10n.ordersNoteStaysMessage,
      confirmText: context.l10n.ordersDiscard,
      cancelText: context.l10n.ordersKeepEditing,
      isDestructive: true,
    );
    if (discard && mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        backgroundColor: c.surface,
        appBar: AppBar(
          backgroundColor: c.surface,
          leading: IconButton(
            tooltip: context.l10n.commonClose,
            icon: const Icon(Icons.close_rounded),
            onPressed: _handleBack,
          ),
          title: Text(NoteCodec.isBlank(widget.initialNote)
              ? context.l10n.ordersNoteAdd
              : context.l10n.ordersEditNote),
          // Up here rather than in a bottom bar, so it stays reachable while
          // the keyboard is open.
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.md),
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop((note: _encoded)),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                child: Text(context.l10n.commonSave),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(height: 1, thickness: 1, color: c.hair),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: QuillEditor(
                controller: _controller,
                focusNode: _focusNode,
                scrollController: _scrollController,
                config: QuillEditorConfig(
                  scrollable: true,
                  expands: true,
                  autoFocus: true,
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.gutter + 4,
                    AppSpacing.lg,
                    AppSpacing.gutter + 4,
                    AppSpacing.xl,
                  ),
                  placeholder: context.l10n.ordersNotePlaceholder,
                  textCapitalization: TextCapitalization.sentences,
                  customStyles: NoteStyles.editor(c),
                  customStyleBuilder: NoteStyles.lineStyles(c),
                ),
              ),
            ),
            NoteToolbar(
              controller: _controller,
              afterPressed: _focusNode.requestFocus,
            ),
          ],
        ),
      ),
    );
  }
}
