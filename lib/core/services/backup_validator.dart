import 'dart:convert';
import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

import '../../database/app_database.dart';
import '../error/result.dart';
import 'backup_failure.dart';

/// What the user is about to restore, shown before they confirm.
class BackupSummary extends Equatable {
  /// Schema version the file was saved with, before any upgrade.
  final int schemaVersion;
  final int orders;
  final int materials;
  final int products;

  const BackupSummary({
    required this.schemaVersion,
    required this.orders,
    required this.materials,
    required this.products,
  });

  @override
  List<Object?> get props => [schemaVersion, orders, materials, products];
}

/// Checks that a file is a Craftbook backup this version can use.
class BackupValidator {
  BackupValidator._();

  static final _sqliteMagic = ascii.encode('SQLite format 3\u0000');

  /// Tables every Craftbook database has had since schema 1. A database
  /// without them was made by something else.
  static const _coreTables = {
    'orders',
    'order_items',
    'order_materials',
    'materials',
    'products',
    'bom_items',
    'channels',
    'stock_movements',
    'settings',
  };

  /// Validates [file] and upgrades it in place to the current schema.
  ///
  /// [file] must be a scratch copy: an older backup is migrated as part of
  /// the check, so a migration that fails costs nothing.
  static Future<Result<BackupSummary>> validate(File file) async {
    if (!await _hasSqliteHeader(file)) {
      return Error(BackupFailure(BackupProblem.notSqlite));
    }

    final int version;
    switch (_inspect(file)) {
      case Success(:final value):
        version = value;
      case Error(:final failure):
        return Error(failure);
    }

    final db = AppDatabase.file(file);
    try {
      try {
        // The first query opens the database, which runs any migrations.
        await db.customSelect('SELECT 1').get();
      } catch (_) {
        return Error(BackupFailure(BackupProblem.upgradeFailed));
      }
      if (!await _hasEveryColumn(db)) {
        return Error(BackupFailure(BackupProblem.schemaMismatch));
      }

      Future<int> count(String table) async => (await db
              .customSelect('SELECT COUNT(*) AS n FROM $table')
              .getSingle())
          .read<int>('n');
      return Success(BackupSummary(
        schemaVersion: version,
        orders: await count('orders'),
        materials: await count('materials'),
        products: await count('products'),
      ));
    } finally {
      await db.close();
    }
  }

  static Future<bool> _hasSqliteHeader(File file) async {
    // The SQLite header alone is 100 bytes.
    if (!await file.exists() || await file.length() < 100) return false;
    final handle = await file.open();
    try {
      final head = await handle.read(_sqliteMagic.length);
      for (var i = 0; i < _sqliteMagic.length; i++) {
        if (head[i] != _sqliteMagic[i]) return false;
      }
      return true;
    } finally {
      await handle.close();
    }
  }

  /// Read-only checks on the raw file. Returns its schema version.
  static Result<int> _inspect(File file) {
    final raw.Database db;
    try {
      db = raw.sqlite3.open(file.path, mode: raw.OpenMode.readOnly);
    } on raw.SqliteException {
      return Error(BackupFailure(BackupProblem.corrupt));
    }
    try {
      final check = db.select('PRAGMA quick_check');
      if (check.length != 1 || check.first.columnAt(0) != 'ok') {
        return Error(BackupFailure(BackupProblem.corrupt));
      }

      final appId = db.select('PRAGMA application_id').first.columnAt(0) as int;
      // Backups from before the id was stamped carry 0; the table check
      // below is what identifies those.
      if (appId != 0 && appId != craftbookAppId) {
        return Error(BackupFailure(BackupProblem.wrongApp));
      }

      final tables = db
          .select("SELECT name FROM sqlite_master WHERE type = 'table'")
          .map((row) => row['name'] as String)
          .toSet();
      if (!tables.containsAll(_coreTables)) {
        return Error(BackupFailure(BackupProblem.wrongApp));
      }

      // Drift keeps its schema version here; 0 means drift never opened it.
      final version = db.select('PRAGMA user_version').first.columnAt(0) as int;
      if (version < 1) return Error(BackupFailure(BackupProblem.wrongApp));
      if (version > AppDatabase.currentSchemaVersion) {
        return Error(BackupFailure(BackupProblem.newerVersion));
      }
      return Success(version);
    } on raw.SqliteException {
      // "file is not a database", "disk image is malformed" and friends.
      return Error(BackupFailure(BackupProblem.corrupt));
    } finally {
      db.dispose();
    }
  }

  /// Compares the file against drift's generated tables, so the check
  /// follows the schema without a hand-kept list.
  static Future<bool> _hasEveryColumn(AppDatabase db) async {
    for (final table in db.allTables) {
      final rows = await db
          .customSelect('PRAGMA table_info("${table.actualTableName}")')
          .get();
      final present = rows.map((r) => r.read<String>('name')).toSet();
      if (present.isEmpty) return false;
      if (!table.$columns.every((c) => present.contains(c.name))) return false;
    }
    return true;
  }
}
