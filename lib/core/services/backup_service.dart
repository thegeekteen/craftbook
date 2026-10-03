import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Handles SQLite database export and import.
class BackupService {
  static const _dbName = 'craftbook.sqlite';

  /// Returns the path to the current database file.
  static Future<String> get _dbPath async {
    final dir = await getApplicationDocumentsDirectory();
    return p.join(dir.path, _dbName);
  }

  /// Export the database file to a user-chosen location.
  static Future<bool> exportDatabase(BuildContext context) async {
    try {
      final dbFile = File(await _dbPath);
      if (!await dbFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Database file not found')),
          );
        }
        return false;
      }

      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final fileName = 'craftbook_backup_$timestamp.sqlite';

      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Save backup',
        fileName: fileName,
        type: FileType.any,
      );

      if (outputPath == null) return false; // User cancelled

      await dbFile.copy(outputPath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Backup saved successfully')),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
      return false;
    }
  }

  /// Import a database file from a user-chosen location.
  /// Returns true if import succeeded. The app should restart after.
  static Future<bool> importDatabase(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select backup file',
        type: FileType.any,
      );

      if (result == null || result.files.isEmpty) return false;

      final sourceFile = File(result.files.single.path!);
      if (!await sourceFile.exists()) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Selected file not found')),
          );
        }
        return false;
      }

      final dbPath = await _dbPath;
      final dbFile = File(dbPath);

      // Copy the backup over the current database
      await sourceFile.copy(dbPath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Backup imported. Please restart the app.'),
            duration: Duration(seconds: 5),
          ),
        );
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Import failed: $e')),
        );
      }
      return false;
    }
  }
}
