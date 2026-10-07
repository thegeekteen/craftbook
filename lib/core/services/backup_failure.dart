import '../../l10n/gen/app_localizations.dart';
import '../error/failures.dart';

/// Why a file can't be restored. Each maps to one message the user sees.
enum BackupProblem {
  /// Not an SQLite file at all: a photo, a PDF, an empty file.
  notSqlite('This isn’t a Craftbook backup file.'),

  /// SQLite, but truncated or damaged.
  corrupt('This backup is damaged and can’t be restored.'),

  /// A healthy SQLite database that some other app made.
  wrongApp('This file belongs to a different app, not Craftbook.'),

  /// Made by a later Craftbook than this one; we can't read its schema.
  newerVersion(
      'This backup was made with a newer Craftbook. Update the app first.'),

  /// From an older Craftbook, but upgrading it failed.
  upgradeFailed(
      'This backup couldn’t be upgraded to this version of Craftbook.'),

  /// Opens and upgrades, but tables or columns the app needs are missing.
  schemaMismatch('This backup is missing data Craftbook needs.');

  const BackupProblem(this.message);

  /// English fallback, for logs and callers without a language at hand.
  final String message;

  /// What the user reads, in the app's language.
  String localized(AppLocalizations l10n) => switch (this) {
        notSqlite => l10n.backupProblemNotSqlite,
        corrupt => l10n.backupProblemCorrupt,
        wrongApp => l10n.backupProblemWrongApp,
        newerVersion => l10n.backupProblemNewerVersion,
        upgradeFailed => l10n.backupProblemUpgradeFailed,
        schemaMismatch => l10n.backupProblemSchemaMismatch,
      };
}

/// A backup that was rejected before anything on the phone was touched.
class BackupFailure extends Failure {
  final BackupProblem problem;

  BackupFailure(this.problem) : super(problem.message);

  @override
  List<Object?> get props => [problem];
}
