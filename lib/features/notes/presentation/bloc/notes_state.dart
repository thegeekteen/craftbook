import 'package:equatable/equatable.dart';

import '../../domain/entities/note.dart';

abstract class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

/// What a note action did, so the page can say it in the user's language.
enum NoteOutcome { pinned, unpinned, deleted, restored }

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  /// Every note, pinned first, then the most recently edited.
  final List<Note> all;
  final String query;

  /// Outcome of the last action, shown once. [serial] changes with every
  /// message so the same text twice still shows twice. A success sets
  /// [outcome] and [subject]; a failure sets [message] and [isError].
  final String? message;
  final NoteOutcome? outcome;
  final Note? subject;
  final bool isError;
  final int serial;

  /// Whether there is something to tell the user.
  bool get hasNotice => message != null || outcome != null;

  /// Set when [message] reports a delete, so the snackbar can offer Undo.
  final Note? deleted;

  const NotesLoaded({
    required this.all,
    this.query = '',
    this.message,
    this.outcome,
    this.subject,
    this.isError = false,
    this.serial = 0,
    this.deleted,
  });

  /// The notes matching [query], in list order.
  List<Note> get visible => [
        for (final n in all)
          if (n.matches(query)) n
      ];
  List<Note> get pinned => [
        for (final n in visible)
          if (n.isPinned) n
      ];
  List<Note> get others => [
        for (final n in visible)
          if (!n.isPinned) n
      ];

  NotesLoaded copyWith({List<Note>? all, String? query}) =>
      NotesLoaded(all: all ?? this.all, query: query ?? this.query);

  NotesLoaded withError(String message, int serial) => NotesLoaded(
        all: all,
        query: query,
        message: message,
        isError: true,
        serial: serial,
      );

  NotesLoaded withOutcome(NoteOutcome outcome, Note subject, int serial,
          {Note? deleted}) =>
      NotesLoaded(
        all: all,
        query: query,
        outcome: outcome,
        subject: subject,
        serial: serial,
        deleted: deleted,
      );

  @override
  List<Object?> get props =>
      [all, query, message, outcome, subject, isError, serial, deleted];
}

/// The notes couldn't be loaded.
class NotesError extends NotesState {
  final String message;

  const NotesError(this.message);

  @override
  List<Object?> get props => [message];
}
