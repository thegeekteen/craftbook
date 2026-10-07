import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_search_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_label.dart';
import '../../domain/entities/note.dart';
import '../bloc/notes_bloc.dart';
import '../bloc/notes_event.dart';
import '../bloc/notes_state.dart';
import '../widgets/note_actions.dart';
import '../widgets/note_card.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../l10n/gen/app_localizations.dart';

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
    final l10n = context.l10n;
    final bloc = context.read<NotesBloc>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.commonNotes)),
      body: BlocConsumer<NotesBloc, NotesState>(
        listenWhen: (prev, s) =>
            s is NotesError ||
            (s is NotesLoaded &&
                s.hasNotice &&
                (prev is! NotesLoaded || prev.serial != s.serial)),
        listener: (context, state) {
          if (state is NotesError) {
            context.showSnackBar(state.message, isError: true);
          }
          if (state is NotesLoaded) {
            final deleted = state.deleted;
            context.showSnackBar(
              noteNotice(l10n, state),
              isError: state.isError,
              onAction: deleted == null
                  ? null
                  : () => bloc.add(RestoreNoteEvent(deleted)),
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
                title: l10n.notesEmptyTitle,
                message: l10n.notesEmptyMessage,
                actionLabel: l10n.notesAddNote,
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
        label: Text(l10n.notesFab),
      ),
    );
  }
}

/// The snackbar text for the last action in [state].
String noteNotice(AppLocalizations l10n, NotesLoaded state) {
  final subject = state.subject;
  final title = subject?.titleOr(l10n.notesUntitled) ?? '';
  return switch (state.outcome) {
    NoteOutcome.pinned => l10n.notesOutcomePinned,
    NoteOutcome.unpinned => l10n.notesOutcomeUnpinned,
    NoteOutcome.deleted => l10n.notesOutcomeDeleted(title),
    NoteOutcome.restored => l10n.notesOutcomeRestored(title),
    null => state.message ?? '',
  };
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
      context.l10n
          .notesOutcomeDeleted(result.titleOr(context.l10n.notesUntitled)),
      onAction: () => bloc.add(RestoreNoteEvent(result)),
    );
  }
}

class _NoteList extends StatelessWidget {
  final NotesLoaded state;

  const _NoteList({required this.state});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<NotesBloc>();
    final pinned = state.pinned;
    final others = state.others;

    Widget card(Note note) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: NoteCard(
            key: ValueKey(note.id),
            note: note,
            onTap: () => _open(context, note.id),
            onLongPress: () => _noteActions(context, bloc, note),
            onTogglePin: () => bloc.add(ToggleNotePinEvent(note.id!)),
          ),
        );

    return ListView(
      padding: AppSpacing.page.copyWith(bottom: AppSpacing.fabClearance),
      children: [
        AppSearchField(
          hint: l10n.notesSearchHint,
          onChanged: (q) => bloc.add(SearchNotes(q)),
        ),
        const SizedBox(height: AppSpacing.md),
        if (pinned.isEmpty && others.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: EmptyState(
              icon: Icons.search_off_rounded,
              title: l10n.notesNoMatches,
              message: l10n.notesNoMatchesMessage(state.query.trim()),
            ),
          ),
        if (pinned.isNotEmpty) ...[
          SectionLabel(l10n.notesPinnedHeader(pinned.length)),
          const SizedBox(height: AppSpacing.sm),
          for (final note in pinned) card(note),
          if (others.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.sm),
            SectionLabel(l10n.notesOthersHeader(others.length)),
            const SizedBox(height: AppSpacing.sm),
          ],
        ],
        for (final note in others) card(note),
      ],
    );
  }
}

/// Carries out the note's long-press menu.
Future<void> _noteActions(
    BuildContext context, NotesBloc bloc, Note note) async {
  final action = await NoteActions.pick(context, note);
  if (!context.mounted) return;
  switch (action) {
    case NoteAction.togglePin:
      bloc.add(ToggleNotePinEvent(note.id!));
    case NoteAction.delete:
      if (await NoteActions.confirmDelete(context, note)) {
        bloc.add(DeleteNoteEvent(note.id!));
      }
    case null:
      break;
  }
}
