import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_label.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../widgets/note_card.dart';

/// The shop's notebook.
class NotesPage extends StatelessWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NotesBloc>()..add(const LoadNotes()),
      child: const _NotesView(),
    );
  }
}

class _NotesView extends StatelessWidget {
  const _NotesView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NotesBloc>();
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: BlocConsumer<NotesBloc, NotesState>(
        listenWhen: (prev, s) =>
            s is NotesError ||
            (s is NotesLoaded &&
                s.message != null &&
                (prev is! NotesLoaded || prev.serial != s.serial)),
        listener: (context, state) {
          if (state is NotesError) {
            context.showSnackBar(state.message, isError: true);
          }
          if (state is NotesLoaded) {
            final deleted = state.deleted;
            context.showSnackBar(
              state.message!,
              isError: state.isError,
              onAction: deleted == null ? null : () => bloc.add(RestoreNoteEvent(deleted)),
            );
          }
        },
        builder: (context, state) {
          if (state is NotesError) {
            return Center(
              child: ErrorState(
                message: state.message,
                onRetry: () => bloc.add(const LoadNotes()),
              ),
            );
          }
          if (state is! NotesLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.all.isEmpty) {
            return Center(
              child: EmptyState(
                icon: Icons.sticky_note_2_outlined,
                title: 'No notes yet',
                message: 'Keep supplier details, product ideas and packing how-tos here.',
                actionLabel: 'Add note',
                onAction: () => _open(context, null),
              ),
            );
          }
          return _NoteList(state: state);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(context, null),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Note'),
      ),
    );
  }
}

/// Opens the editor and reloads once it saved or deleted something.
Future<void> _open(BuildContext context, int? id) async {
  final bloc = context.read<NotesBloc>();
  final result = await context.push<Object?>(
    id == null ? RouteNames.newNote : RouteNames.notePath(id),
  );
  if (result == null) return;
  bloc.add(const LoadNotes());
  if (result is Note && context.mounted) {
    context.showSnackBar(
      '${result.displayTitle} deleted',
      onAction: () => bloc.add(RestoreNoteEvent(result)),
    );
  }
}

class _NoteList extends StatelessWidget {
  final NotesLoaded state;

  const _NoteList({required this.state});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<NotesBloc>();
    final pinned = state.pinned;
    final others = state.others;

    Widget card(Note note) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: NoteCard(
            key: ValueKey(note.id),
            note: note,
            onTap: () => _open(context, note.id),
            onLongPress: () => _NoteActions.open(context, bloc, note),
            onTogglePin: () => bloc.add(ToggleNotePinEvent(note.id!)),
          ),
        );

    return ListView(
      padding: AppSpacing.page.copyWith(bottom: AppSpacing.fabClearance),
      children: [
        AppSearchField(
          hint: 'Search notes',
          onChanged: (q) => bloc.add(SearchNotes(q)),
        ),
        const SizedBox(height: AppSpacing.md),
        if (pinned.isEmpty && others.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: 'No matches',
              message: 'No note mentions "${state.query.trim()}".',
            ),
          ),
        if (pinned.isNotEmpty) ...[
          SectionLabel('Pinned · ${pinned.length}'),
          const SizedBox(height: AppSpacing.sm),
          for (final note in pinned) card(note),
          if (others.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            SectionLabel('Others · ${others.length}'),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
        for (final note in others) card(note),
      ],
    );
  }
}

enum _NoteAction { togglePin, delete }

/// Long-press actions on a note. The sheet only picks one; the page carries
/// it out, since a dialog can't hang off a sheet that has already closed.
class _NoteActions extends StatelessWidget {
  final Note note;

  const _NoteActions({required this.note});

  static Future<void> open(BuildContext context, NotesBloc bloc, Note note) async {
    final action = await showAppSheet<_NoteAction>(
      context: context,
      title: note.displayTitle,
      builder: (_) => _NoteActions(note: note),
    );
    if (!context.mounted) return;
    switch (action) {
      case _NoteAction.togglePin:
        bloc.add(ToggleNotePinEvent(note.id!));
      case _NoteAction.delete:
        final confirmed = await ConfirmDialog.show(
          context,
          title: 'Delete note?',
          message: '${note.displayTitle} is removed from your notebook.',
          confirmText: 'Delete',
          isDestructive: true,
        );
        if (confirmed) bloc.add(DeleteNoteEvent(note.id!));
      case null:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(note.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded),
          title: Text(note.isPinned ? 'Unpin' : 'Pin to Today'),
          onTap: () => Navigator.pop(context, _NoteAction.togglePin),
        ),
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(Icons.delete_outline_rounded, color: c.alert),
          title: Text('Delete', style: TextStyle(color: c.alert)),
          onTap: () => Navigator.pop(context, _NoteAction.delete),
        ),
      ],
    );
  }
}
