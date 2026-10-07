import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/app_database.dart';
import '../../l10n/gen/app_localizations.dart';
import '../di/injection.dart';
import '../error/failures.dart';
import '../error/result.dart';
import '../utils/l10n_extension.dart';
import '../widgets/app_restarter.dart';
import '../widgets/confirm_dialog.dart';
import 'backup_failure.dart';
import 'backup_store.dart';
import 'backup_validator.dart';

/// Handles SQLite database export and import.
class BackupService {
  BackupService._();

  static BackupStore get _store => getIt<BackupStore>();

  /// Export a snapshot of the database to a user-chosen location.
  /// On Android, uses SAF with bytes (required by file_picker).
  static Future<bool> exportDatabase(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    File? snapshot;
    try {
      // VACUUM INTO writes a consistent copy even if a write is in flight;
      // reading the live file's bytes could catch one half-done.
      snapshot = await _store.scratchFile('export.sqlite');
      await getIt<AppDatabase>()
          .customStatement('VACUUM INTO ?', [snapshot.path]);

      final bytes = await snapshot.readAsBytes();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'craftbook_backup_$timestamp.sqlite';

      final saved = await FilePicker.saveFile(
        dialogTitle: l10n.backupSaveDialogTitle,
        fileName: fileName,
        bytes: bytes,
      );

      if (saved == null) return false;

      messenger.showSnackBar(SnackBar(content: Text(l10n.backupSaved)));
      return true;
    } catch (e) {
      messenger
          .showSnackBar(SnackBar(content: Text(l10n.backupExportFailed('$e'))));
      return false;
    } finally {
      if (snapshot != null && await snapshot.exists()) await snapshot.delete();
    }
  }

  /// Pick a backup, check it, confirm with what's in it, then swap it in
  /// and reload the app. The data it replaces is kept for [undoRestore].
  static Future<bool> importDatabase(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final picked = await FilePicker.pickFile(
        dialogTitle: l10n.backupPickDialogTitle,
      );

      if (picked == null) return false;

      final File candidate;
      final path = picked.path;
      if (path != null && await File(path).exists()) {
        candidate = await _store.stageFile(path);
      } else {
        // SAF on Android hands back a content:// URI with no local path.
        candidate = await _store.stageBytes(await picked.readAsBytes());
      }

      final BackupSummary summary;
      switch (await BackupValidator.validate(candidate)) {
        case Success(:final value):
          summary = value;
        case Error(:final failure):
          messenger.showSnackBar(
              SnackBar(content: Text(_failureText(l10n, failure))));
          return false;
      }

      if (!context.mounted) return false;
      final confirmed = await ConfirmDialog.show(
        context,
        title: l10n.backupRestoreTitle,
        message: l10n.backupRestoreMessage(describe(summary, l10n)),
        confirmText: l10n.commonRestore,
        isDestructive: true,
      );
      if (!confirmed || !context.mounted) return false;

      return await _swapAndRestart(
        context,
        () => _store.replaceLive(candidate, keepAsPreRestore: true),
        done: l10n.backupRestored,
      );
    } catch (e) {
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.backupRestoreFailed('$e'))));
      return false;
    }
  }

  /// Put back what was on the phone before the last restore.
  static Future<bool> undoRestore(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final confirmed = await ConfirmDialog.show(
        context,
        title: l10n.backupUndoTitle,
        message: l10n.backupUndoMessage,
        confirmText: l10n.backupUndoConfirm,
        isDestructive: true,
      );
      if (!confirmed) return false;

      // It was our own live file, but check it anyway: it has sat on disk
      // since, and the app may have been updated in between.
      final candidate = await _store.stagePreRestore();
      if (await BackupValidator.validate(candidate)
          case Error(:final failure)) {
        messenger.showSnackBar(SnackBar(
            content: Text(l10n.backupCantUndo(_failureText(l10n, failure)))));
        return false;
      }

      if (!context.mounted) return false;
      return await _swapAndRestart(
        context,
        () => _store.replaceLive(candidate, keepAsPreRestore: false),
        done: l10n.backupRestoreUndone,
      );
    } catch (e) {
      messenger
          .showSnackBar(SnackBar(content: Text(l10n.backupUndoFailed('$e'))));
      return false;
    }
  }

  /// Whether there is a restore to undo. False when the check itself fails,
  /// which only hides the undo row.
  static Future<bool> canUndoRestore() async {
    try {
      return await _store.hasPreRestoreCopy();
    } catch (_) {
      return false;
    }
  }

  /// One line on what a backup holds, for the confirm dialog.
  static String describe(BackupSummary summary, AppLocalizations l10n) {
    final contents = l10n.backupContents(
        summary.orders, summary.materials, summary.products);
    return summary.schemaVersion < AppDatabase.currentSchemaVersion
        ? l10n.backupContentsUpgraded(contents)
        : contents;
  }

  /// A validator failure in the user's language; other failures keep their
  /// own message.
  static String _failureText(AppLocalizations l10n, Failure failure) =>
      failure is BackupFailure
          ? failure.problem.localized(l10n)
          : failure.message;

  /// Closes the database, runs [swap], and reloads the app on whatever
  /// file is now in place. [swap] puts the old file back if it fails.
  static Future<bool> _swapAndRestart(
    BuildContext context,
    Future<void> Function() swap, {
    required String done,
  }) async {
    final restarter = AppRestarter.maybeOf(context);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;

    await getIt<AppDatabase>().close();
    Object? error;
    try {
      await swap();
    } catch (e) {
      error = e;
    }

    final message = error == null ? done : l10n.backupSwapFailed('$error');
    if (restarter != null) {
      await restarter.restart(message: message);
    } else {
      // Only without an AppRestarter above the app (tests).
      messenger.showSnackBar(
          SnackBar(content: Text(l10n.backupRestartApp(message))));
    }
    return error == null;
  }
}
