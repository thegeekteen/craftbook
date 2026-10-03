import 'dart:io';
import 'dart:math';

import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/services/backup_failure.dart';
import 'package:craftbook/core/services/backup_service.dart';
import 'package:craftbook/core/services/backup_validator.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as raw;

import '../../support/sqlite.dart';

void main() {
  setUpAll(useHostSqlite);

  late Directory dir;
  setUp(() async => dir = await Directory.systemTemp.createTemp('backup_validator_'));
  tearDown(() => dir.delete(recursive: true));

  File fileNamed(String name) => File('${dir.path}/$name');

  /// A Craftbook database at the current schema with a bit of everything.
  Future<File> craftbookDb({String name = 'backup.sqlite', int orders = 2}) async {
    final file = fileNamed(name);
    final db = AppDatabase.file(file);
    await db.customStatement(
      "INSERT INTO materials (name, pack_size, pack_price, unit_cost, alert_level) "
      "VALUES ('Yarn', 10, 100, 10, 5)",
    );
    await db.customStatement("INSERT INTO products (name, sell_price) VALUES ('Tulip', 450)");
    for (var i = 0; i < orders; i++) {
      await db.customStatement(
        "INSERT INTO orders (customer_name, customer_address, order_date, ship_by_date, status, total_sales) "
        "VALUES ('Ana $i', 'Street $i', 0, 0, 'pending', 450)",
      );
    }
    await db.close();
    return file;
  }

  /// Raw access to edit a fixture into an older, broken or foreign shape.
  void edit(File file, void Function(raw.Database db) change) {
    final db = raw.sqlite3.open(file.path);
    try {
      change(db);
    } finally {
      db.dispose();
    }
  }

  Future<BackupProblem?> problemWith(File file) async => switch (await BackupValidator.validate(file)) {
        Success() => null,
        Error(:final failure) => (failure as BackupFailure).problem,
      };

  group('rejects files that are not SQLite', () {
    test('empty file', () async {
      final file = fileNamed('empty.sqlite')..createSync();
      expect(await problemWith(file), BackupProblem.notSqlite);
    });

    test('random bytes', () async {
      final random = Random(1);
      final file = fileNamed('noise.sqlite')
        ..writeAsBytesSync(List.generate(4096, (_) => random.nextInt(256)));
      expect(await problemWith(file), BackupProblem.notSqlite);
    });

    test('a text file renamed .sqlite', () async {
      final file = fileNamed('notes.sqlite')..writeAsStringSync('Shopping list\n' * 50);
      expect(await problemWith(file), BackupProblem.notSqlite);
    });

    test('a file that does not exist', () async {
      expect(await problemWith(fileNamed('missing.sqlite')), BackupProblem.notSqlite);
    });
  });

  test('rejects a damaged backup', () async {
    final file = await craftbookDb(orders: 400);
    final bytes = file.readAsBytesSync();
    // Keep the header, wipe the pages holding the tables.
    for (var i = 4096; i < bytes.length; i++) {
      bytes[i] = 0xAB;
    }
    file.writeAsBytesSync(bytes);
    expect(await problemWith(file), BackupProblem.corrupt);
  });

  group('rejects other apps\' databases', () {
    test('unrelated tables', () async {
      final file = fileNamed('photos.db');
      edit(file, (db) => db.execute('CREATE TABLE photos (id INTEGER PRIMARY KEY, path TEXT)'));
      expect(await problemWith(file), BackupProblem.wrongApp);
    });

    test('a different application id, even with matching tables', () async {
      final file = await craftbookDb();
      edit(file, (db) => db.execute('PRAGMA application_id = 1234'));
      expect(await problemWith(file), BackupProblem.wrongApp);
    });

    test('matching tables but never opened by drift', () async {
      final file = await craftbookDb();
      edit(file, (db) => db.execute('PRAGMA user_version = 0'));
      expect(await problemWith(file), BackupProblem.wrongApp);
    });
  });

  test('rejects a backup from a newer Craftbook', () async {
    final file = await craftbookDb();
    edit(file, (db) => db.execute('PRAGMA user_version = 99'));
    expect(await problemWith(file), BackupProblem.newerVersion);
  });

  test('rejects a backup missing a column the app needs', () async {
    final file = await craftbookDb();
    edit(file, (db) => db.execute('ALTER TABLE orders DROP COLUMN note'));
    expect(await problemWith(file), BackupProblem.schemaMismatch);
  });

  test('accepts a current backup and counts what is in it', () async {
    final file = await craftbookDb(orders: 3);
    expect(
      await BackupValidator.validate(file),
      const Success(BackupSummary(schemaVersion: 3, orders: 3, materials: 1, products: 1)),
    );
  });

  test('accepts an old backup without an application id', () async {
    final file = await craftbookDb();
    edit(file, (db) => db.execute('PRAGMA application_id = 0'));
    expect(await problemWith(file), isNull);
  });

  test('upgrades a schema 1 backup and keeps its orders', () async {
    final file = await craftbookDb(orders: 2);
    edit(file, (db) {
      db.execute('DROP TABLE product_stock_movements');
      db.execute('DROP TABLE order_products');
      for (final column in ['is_standalone', 'quantity_on_hand', 'quantity_promised', 'unit_cost', 'alert_level']) {
        db.execute('ALTER TABLE products DROP COLUMN $column');
      }
      db.execute('PRAGMA user_version = 1');
      db.execute('PRAGMA application_id = 0');
    });

    expect(
      await BackupValidator.validate(file),
      const Success(BackupSummary(schemaVersion: 1, orders: 2, materials: 1, products: 1)),
    );
    edit(file, (db) {
      expect(db.select('PRAGMA user_version').first.columnAt(0), AppDatabase.currentSchemaVersion);
      expect(db.select('PRAGMA application_id').first.columnAt(0), craftbookAppId);
      expect(db.select('SELECT is_standalone FROM products'), hasLength(1));
      expect(db.select('SELECT * FROM order_products'), isEmpty);
    });
  });

  test('upgrades a schema 2 backup through the v3 sign fix', () async {
    final file = await craftbookDb();
    edit(file, (db) {
      db.execute(
        "INSERT INTO product_stock_movements (product_id, type, quantity, unit_cost, reference) "
        "VALUES (1, 'adjusted', 3, 2.5, 'Adjusted -3 units')",
      );
      db.execute('PRAGMA user_version = 2');
    });

    expect(await problemWith(file), isNull);
    edit(file, (db) {
      expect(db.select('SELECT quantity FROM product_stock_movements').first['quantity'], -3);
    });
  });

  test('rejects an old backup whose upgrade fails', () async {
    // Claims schema 1, but already has the v2 columns the upgrade adds.
    final file = await craftbookDb();
    edit(file, (db) => db.execute('PRAGMA user_version = 1'));
    expect(await problemWith(file), BackupProblem.upgradeFailed);
  });

  group('describe', () {
    test('lists what the backup holds', () {
      expect(
        BackupService.describe(const BackupSummary(schemaVersion: 3, orders: 1, materials: 2, products: 0)),
        '1 order, 2 materials and 0 products.',
      );
    });

    test('says when an older backup was upgraded', () {
      expect(
        BackupService.describe(const BackupSummary(schemaVersion: 1, orders: 4, materials: 1, products: 3)),
        '4 orders, 1 material and 3 products. It was made with an older Craftbook and has been upgraded.',
      );
    });
  });
}
