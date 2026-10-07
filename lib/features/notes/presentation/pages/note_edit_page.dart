import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/note_codec.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/note/note_styles.dart';
import '../../../../core/widgets/note/note_toolbar.dart';
import '../../domain/entities/note.dart';
import '../bloc/note_edit_cubit.dart';
import '../../../../core/utils/l10n_extension.dart';

/// Writes a new note ([noteId] null) or edits one, full screen.
///
/// Pops with `true` after a save and with the deleted [Note] after a delete,
/// so the page below can reload and offer Undo.
class NoteEditPage extends StatelessWidget {
  final int? noteId;

  const NoteEditPage({super.key, this.noteId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NoteEditCubit>()..load(noteId),
      child: BlocBuilder<NoteEditCubit, NoteEditState>(
        builder: (context, state) {
          if (state.note case final Note note) return _NoteEditor(note: note);
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: state.isLoading
                  ? const CircularProgressIndicator()
                  : ErrorState(message: state.error!),
            ),
          );
        },
      ),
    );
  }
}

class _NoteEditor extends StatefulWidget {
  final Note note;

  const _NoteEditor({required this.note});

  @override
  State<_NoteEditor> createState() => _NoteEditorState();
}

class _NoteEditorState extends State<_NoteEditor> {
  late final _title = TextEditingController(text: widget.note.title);
  late final QuillController _body;
  final _bodyFocus = FocusNode();
  final _scrollController = ScrollController();
  late bool _pinned = widget.note.isPinned;

  /// The body re-encoded on open, so "changed" still means something when a
  /// note saved by an older version is normalised on load.
  late final String? _openedBody;
  bool _changed = false;
  bool _busy = false;

  bool get _isNew => widget.note.id == null;

  @override
  void initState() {
    super.initState();
    final document = Document.fromDelta(NoteCodec.decode(widget.note.body));
    _body = QuillController(
      document: document,
      selection: TextSelection.collapsed(offset: document.length - 1),
    );
    _openedBody = _encodedBody;
    _body.addListener(_onChange);
    _title.addListener(_onChange);
  }

  @override
  void dispose() {
    _body
      ..removeListener(_onChange)
      ..dispose();
    _title.dispose();
    _bodyFocus.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  String? get _encodedBody => NoteCodec.encode(_body.document.toDelta());

  void _onChange() {
    final changed = _title.text != widget.note.title ||
        _encodedBody != _openedBody ||
        _pinned != widget.note.isPinned;
    if (changed != _changed) setState(() => _changed = changed);
  }

  void _togglePin() {
    setState(() => _pinned = !_pinned);
    _onChange();
  }

  Future<void> _save() async {
    // A new note left empty is just closed, not refused.
    if (!_changed && _isNew) {
      context.pop();
      return;
    }
    setState(() => _busy = true);
    final result = await context.read<NoteEditCubit>().save(
          widget.note.copyWith(
            title: _title.text,
            body: () => _encodedBody,
            isPinned: _pinned,
          ),
        );
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Success():
        context.pop(true);
      case Error(:final failure):
        context.showSnackBar(failure.message, isError: true);
    }
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final confirmed = await ConfirmDialog.show(
      context,
      title: l10n.notesDeleteTitle,
      message: l10n.notesDeleteMessage(widget.note.titleOr(l10n.notesUntitled)),
      confirmText: l10n.commonDelete,
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    final result = await context.read<NoteEditCubit>().delete(widget.note.id!);
    if (!mounted) return;
    switch (result) {
      case Success():
        context.pop(widget.note);
      case Error(:final failure):
        context.showSnackBar(failure.message, isError: true);
    }
  }

  Future<void> _handleBack() async {
    if (!_changed) {
      context.pop();
      return;
    }
    final l10n = context.l10n;
    final discard = await ConfirmDialog.show(
      context,
      title: l10n.notesDiscardTitle,
      message: _isNew ? l10n.notesDiscardNew : l10n.notesDiscardEdit,
      confirmText: l10n.notesDiscardConfirm,
      cancelText: l10n.notesKeepEditing,
      isDestructive: true,
    );
    if (discard && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    const sidePadding = AppSpacing.gutter + 4;
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
            tooltip: l10n.commonClose,
            icon: const Icon(Icons.close_rounded),
            onPressed: _handleBack,
          ),
          title: Text(_isNew ? l10n.notesNewNote : l10n.notesEditNote),
          actions: [
            IconButton(
              tooltip: _pinned ? l10n.notesUnpin : l10n.notesPinToToday,
              onPressed: _togglePin,
              icon: Icon(
                _pinned ? Icons.push_pin_rounded : Icons.push_pin_outlined,
                color: _pinned ? c.go : null,
              ),
            ),
            if (!_isNew)
              PopupMenuButton<void>(
                tooltip: l10n.notesMore,
                itemBuilder: (_) => [
                  PopupMenuItem(
                    onTap: _delete,
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline_rounded,
                            size: 20, color: c.alert),
                        const SizedBox(width: AppSpacing.md),
                        Text(l10n.commonDelete,
                            style: TextStyle(color: c.alert)),
                      ],
                    ),
                  ),
                ],
              ),
            // Up here rather than in a bottom bar, so it stays reachable while
            // the keyboard is open.
            Padding(
              padding: const EdgeInsets.only(
                  left: AppSpacing.xs, right: AppSpacing.md),
              child: FilledButton(
                onPressed: _busy ? null : _save,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 38),
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                ),
                child: Text(l10n.commonSave),
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
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  sidePadding, AppSpacing.lg, sidePadding, 0),
              child: TextField(
                controller: _title,
                autofocus: _isNew,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                onSubmitted: (_) => _bodyFocus.requestFocus(),
                style: AppTextStyles.displaySmall.copyWith(color: c.ink),
                // The app theme outlines every field; a title reads as a
                // heading, so every border is cleared explicitly.
                decoration: InputDecoration(
                  hintText: l10n.notesTitleHint,
                  hintStyle:
                      AppTextStyles.displaySmall.copyWith(color: c.muted),
                  isCollapsed: true,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
            Expanded(
              child: QuillEditor(
                controller: _body,
                focusNode: _bodyFocus,
                scrollController: _scrollController,
                config: QuillEditorConfig(
                  scrollable: true,
                  expands: true,
                  autoFocus: !_isNew,
                  padding: const EdgeInsets.fromLTRB(
                    sidePadding,
                    AppSpacing.md,
                    sidePadding,
                    AppSpacing.xl,
                  ),
                  placeholder: l10n.notesBodyHint,
                  textCapitalization: TextCapitalization.sentences,
                  customStyles: NoteStyles.editor(c),
                  customStyleBuilder: NoteStyles.lineStyles(c),
                ),
              ),
            ),
            NoteToolbar(
              controller: _body,
              full: true,
              afterPressed: _bodyFocus.requestFocus,
            ),
          ],
        ),
      ),
    );
  }
}
