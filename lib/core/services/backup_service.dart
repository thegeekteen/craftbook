import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../database/app_database.dart';
import '../di/injection.dart';
import '../error/result.dart';
import '../widgets/app_restarter.dart';
import '../widgets/confirm_dialog.dart';
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
    File? snapshot;
    try {
      // VACUUM INTO writes a consistent copy even if a write is in flight;
      // reading the live file's bytes could catch one half-done.
      snapshot = await _store.scratchFile('export.sqlite');
      await getIt<AppDatabase>().customStatement('VACUUM INTO ?', [snapshot.path]);

      final bytes = await snapshot.readAsBytes();
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'craftbook_backup_$timestamp.sqlite';

      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save backup',
        fileName: fileName,
        type: FileType.any,
        bytes: bytes,
      );

      if (outputPath == null) return false;

      // On non-Android platforms, saveFile returns the path but
      // doesn't write bytes — copy manually.
      if (!Platform.isAndroid) {
        await snapshot.copy(outputPath);
      }

      messenger.showSnackBar(const SnackBar(content: Text('Backup saved successfully')));
      return true;
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $e')));
      return false;
    } finally {
      if (snapshot != null && await snapshot.exists()) await snapshot.delete();
    }
  }

  /// Pick a backup, check it, confirm with what's in it, then swap it in
  /// and reload the app. The data it replaces is kept for [undoRestore].
  static Future<bool> importDatabase(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select backup file',
        type: FileType.any,
        withData: true,
      );

      if (result == null || result.files.isEmpty) return false;

      final picked = result.files.single;
      final File candidate;
      if (picked.path != null && await File(picked.path!).exists()) {
        candidate = await _store.stageFile(picked.path!);
      } else if (picked.bytes != null) {
        // SAF on Android — no path, only bytes
        candidate = await _store.stageBytes(picked.bytes!);
      } else {
        messenger.showSnackBar(const SnackBar(content: Text('Could not read the selected file')));
        return false;
      }

      final BackupSummary summary;
      switch (await BackupValidator.validate(candidate)) {
        case Success(:final value):
          summary = value;
        case Error(:final failure):
          messenger.showSnackBar(SnackBar(content: Text(failure.message)));
          return false;
      }

      if (!context.mounted) return false;
      final confirmed = await ConfirmDialog.show(
        context,
        title: 'Restore this backup?',
        message: '${describe(summary)}\n\n'
            'Everything on this phone is replaced by it. '
            'You can undo this from More.',
        confirmText: 'Restore',
        isDestructive: true,
      );
      if (!confirmed || !context.mounted) return false;

      return await _swapAndRestart(
        context,
        () => _store.replaceLive(candidate, keepAsPreRestore: true),
        done: 'Backup restored',
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Restore failed: $e')));
      return false;
    }
  }

  /// Put back what was on the phone before the last restore.
  static Future<bool> undoRestore(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final confirmed = await ConfirmDialog.show(
        context,
        title: 'Undo last restore?',
        message: 'Goes back to the data you had before the last restore. '
            'Anything changed since then is lost.',
        confirmText: 'Undo restore',
        isDestructive: true,
      );
      if (!confirmed) return false;

      // It was our own live file, but check it anyway: it has sat on disk
      // since, and the app may have been updated in between.
      final candidate = await _store.stagePreRestore();
      if (await BackupValidator.validate(candidate) case Error(:final failure)) {
        messenger.showSnackBar(SnackBar(content: Text('Can\'t undo: ${failure.message}')));
        return false;
      }

      if (!context.mounted) return false;
      return await _swapAndRestart(
        context,
        () => _store.replaceLive(candidate, keepAsPreRestore: false),
        done: 'Restore undone',
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('Undo failed: $e')));
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
  static String describe(BackupSummary summary) {
    String count(int n, String noun) => '$n $noun${n == 1 ? '' : 's'}';
    final contents = '${count(summary.orders, 'order')}, '
        '${count(summary.materials, 'material')} and '
        '${count(summary.products, 'product')}.';
    return summary.schemaVersion < AppDatabase.currentSchemaVersion
        ? '$contents It was made with an older Craftbook and has been upgraded.'
        : contents;
  }

  /// Closes the database, runs [swap], and reloads the app on whatever
  /// file is now in place. [swap] puts the old file back if it fails.
  static Future<bool> _swapAndRestart(
    BuildContext context,
    Future<void> Function() swap, {
    required String done,
  }) async {
    final restarter = AppRestarter.maybeOf(context);
    final messenger = ScaffoldMessenger.of(context);

    await getIt<AppDatabase>().close();
    Object? error;
    try {
      await swap();
    } catch (e) {
      error = e;
    }

    final message = error == null ? done : 'Restore failed, nothing was changed: $error';
    if (restarter != null) {
      await restarter.restart(message: message);
    } else {
      // Only without an AppRestarter above the app (tests).
      messenger.showSnackBar(SnackBar(content: Text('$message. Restart the app.')));
    }
    return error == null;
  }
}
