import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/utils/note_codec.dart';
import 'note_styles.dart';

/// A saved note, rendered but not editable as text.
///
/// Takes the stored string as-is: rich notes come back formatted and the plain
/// text written before rich notes existed still reads correctly, so callers
/// never have to know which they are holding.
///
/// With [onChanged], to-do boxes can be ticked and the updated note is handed
/// back; without it they are display-only.
class NoteView extends StatefulWidget {
  final String raw;
  final ValueChanged<String?>? onChanged;

  const NoteView({super.key, required this.raw, this.onChanged});

  @override
  State<NoteView> createState() => _NoteViewState();
}

class _NoteViewState extends State<NoteView> {
  late QuillController _controller;
  StreamSubscription<DocChange>? _changes;
  final _focusNode = FocusNode(canRequestFocus: false);
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _load(widget.raw);
  }

  @override
  void didUpdateWidget(NoteView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Compared against what's on screen, not the old widget: after a tick the
    // parent echoes the same note back (nothing to do), and after a failed
    // save it sends the old one, which has to undo the tick.
    if (NoteCodec.encode(NoteCodec.decode(widget.raw)) == _shown) return;
    _changes?.cancel();
    _controller.dispose();
    _load(widget.raw);
  }

  @override
  void dispose() {
    _changes?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? get _shown => NoteCodec.encode(_controller.document.toDelta());

  void _load(String raw) {
    _controller = QuillController(
      document: Document.fromDelta(NoteCodec.decode(raw)),
      selection: const TextSelection.collapsed(offset: 0),
      readOnly: true,
    );
    // A checkbox tap is the only way a read-only document changes.
    _changes = _controller.document.changes.listen((_) => widget.onChanged?.call(_shown));
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // QuillEditor.basic makes its own focus node and scroll controller and
    // never disposes them, so this view owns both instead.
    return QuillEditor(
      focusNode: _focusNode,
      scrollController: _scrollController,
      controller: _controller,
      config: QuillEditorConfig(
        // It lives inside a card in a scrolling page, so it sizes to content.
        scrollable: false,
        padding: EdgeInsets.zero,
        expands: false,
        autoFocus: false,
        showCursor: false,
        enableInteractiveSelection: false,
        checkBoxReadOnly: widget.onChanged == null,
        customStyles: NoteStyles.editor(c),
        customStyleBuilder: NoteStyles.lineStyles(c),
      ),
    );
  }
}
