import 'dart:io';

import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/services/backup_store.dart';
import 'package:craftbook/core/services/backup_validator.dart';
import 'package:craftbook/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Directory root;
  late Directory data;
  late Directory scratch;
  late BackupStore store;

  setUp(() async {
    root = await Directory.systemTemp.createTemp('backup_store_');
    data = await Directory('${root.path}/data').create();
    scratch = await Directory('${root.path}/scratch').create();
    store =
        BackupStore(dataDir: () async => data, scratchDir: () async => scratch);
  });
  tearDown(() => root.delete(recursive: true));

  File inData(String name) => File('${data.path}/$name');
  File live() => inData(BackupStore.dbName);
  File preRestore() => inData('craftbook.pre-restore.sqlite');

  Future<File> candidate(String contents) async {
    final source = File('${root.path}/picked.sqlite')
      ..writeAsStringSync(contents);
    return store.stageFile(source.path);
  }

  test('staging copies the pick, leaving the original alone', () async {
    final source = File('${root.path}/picked.sqlite')
      ..writeAsStringSync('backup');
    final staged = await store.stageFile(source.path);
    staged.writeAsStringSync('changed by validation');
    expect(source.readAsStringSync(), 'backup');
    expect(staged.parent.path, scratch.path);
  });

  test('a restore swaps the backup in and keeps the old data', () async {
    live().writeAsStringSync('old');
    final staged = await candidate('new');

    await store.replaceLive(staged, keepAsPreRestore: true);

    expect(live().readAsStringSync(), 'new');
    expect(preRestore().readAsStringSync(), 'old');
    expect(staged.existsSync(), isFalse);
    expect(await store.hasPreRestoreCopy(), isTrue);
  });

  test('a restore clears a stale journal so it is not replayed into the backup',
      () async {
    live().writeAsStringSync('old');
    inData('${BackupStore.dbName}-journal').writeAsStringSync('stale');

    await store.replaceLive(await candidate('new'), keepAsPreRestore: true);

    expect(inData('${BackupStore.dbName}-journal').existsSync(), isFalse);
  });

  test('a second restore replaces the earlier pre-restore copy', () async {
    live().writeAsStringSync('first');
    await store.replaceLive(await candidate('second'), keepAsPreRestore: true);
    await store.replaceLive(await candidate('third'), keepAsPreRestore: true);

    expect(live().readAsStringSync(), 'third');
    expect(preRestore().readAsStringSync(), 'second');
  });

  test('undo puts the old data back and drops the copy', () async {
    live().writeAsStringSync('old');
    await store.replaceLive(await candidate('restored'),
        keepAsPreRestore: true);

    final staged = await store.stagePreRestore();
    await store.replaceLive(staged, keepAsPreRestore: false);

    expect(live().readAsStringSync(), 'old');
    expect(await store.hasPreRestoreCopy(), isFalse);
    expect(data.listSync().map((f) => f.uri.pathSegments.last),
        [BackupStore.dbName]);
  });

  test('a failed swap leaves the live data where it was', () async {
    live().writeAsStringSync('old');
    final missing = File('${scratch.path}/gone.sqlite');

    await expectLater(store.replaceLive(missing, keepAsPreRestore: true),
        throwsA(isA<FileSystemException>()));

    expect(live().readAsStringSync(), 'old');
    expect(preRestore().existsSync(), isFalse);
  });

  test('an export snapshot passes validation', () async {
    final db = AppDatabase.file(live());
    await db.customStatement(
        "INSERT INTO products (name, sell_price) VALUES ('Tulip', 450)");
    final snapshot = await store.scratchFile('export.sqlite');
    await db.customStatement('VACUUM INTO ?', [snapshot.path]);
    await db.close();

    expect(
      await BackupValidator.validate(snapshot),
      const Success(BackupSummary(
          schemaVersion: AppDatabase.currentSchemaVersion,
          orders: 0,
          materials: 0,
          products: 1)),
    );
  });
}
