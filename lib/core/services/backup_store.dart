import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// The database file, its pre-restore copy and scratch files, by path.
///
/// Holds no database connection: whoever swaps files closes the database
/// first. Directories are injectable so the swaps can run in tests.
class BackupStore {
  BackupStore({
    Future<Directory> Function()? dataDir,
    Future<Directory> Function()? scratchDir,
  })  : _dataDir = dataDir ?? getApplicationDocumentsDirectory,
        _scratchDir = scratchDir ?? getTemporaryDirectory;

  final Future<Directory> Function() _dataDir;
  final Future<Directory> Function() _scratchDir;

  static const dbName = 'craftbook.sqlite';
  static const _preRestoreName = 'craftbook.pre-restore.sqlite';
  static const _candidateName = 'restore_candidate.sqlite';

  /// Files SQLite keeps next to a database. A stale journal next to a
  /// swapped-in file would be replayed into it, so they go too.
  static const _sidecars = ['-journal', '-wal', '-shm'];

  Future<File> get liveFile async => File(p.join((await _dataDir()).path, dbName));

  /// What was on the phone before the last restore, for undo.
  Future<File> get preRestoreFile async => File(p.join((await _dataDir()).path, _preRestoreName));

  Future<bool> hasPreRestoreCopy() async => (await preRestoreFile).exists();

  /// A scratch file named [name], cleared of any earlier copy.
  Future<File> scratchFile(String name) async {
    final file = File(p.join((await _scratchDir()).path, name));
    await _deleteWithSidecars(file);
    return file;
  }

  /// Copies the picked file to scratch, so validating it never writes to
  /// the user's original.
  Future<File> stageFile(String path) async =>
      File(path).copy((await scratchFile(_candidateName)).path);

  Future<File> stageBytes(Uint8List bytes) async =>
      (await scratchFile(_candidateName)).writeAsBytes(bytes, flush: true);

  /// Copies the pre-restore file to scratch, to check it before undoing.
  Future<File> stagePreRestore() async => stageFile((await preRestoreFile).path);

  /// Puts [candidate] where the live database is. The database must be
  /// closed.
  ///
  /// With [keepAsPreRestore] the old live file becomes the pre-restore copy
  /// (a restore). Without it the old file and any pre-restore copy are
  /// dropped (an undo). If the move fails the old file goes back.
  Future<void> replaceLive(File candidate, {required bool keepAsPreRestore}) async {
    final live = await liveFile;
    final aside = keepAsPreRestore ? await preRestoreFile : File('${live.path}.replaced');

    await _deleteWithSidecars(aside);
    await _deleteSidecars(live);
    final hadLive = await live.exists();
    if (hadLive) await live.rename(aside.path);

    try {
      await _move(candidate, live);
    } catch (_) {
      if (hadLive) await aside.rename(live.path);
      rethrow;
    }

    if (!keepAsPreRestore) {
      await _deleteWithSidecars(aside);
      await _deleteWithSidecars(await preRestoreFile);
    }
  }

  /// Rename when possible; scratch and data can sit on different volumes.
  static Future<void> _move(File from, File to) async {
    try {
      await from.rename(to.path);
    } on FileSystemException {
      if (!await from.exists()) rethrow;
      await from.copy(to.path);
      await from.delete();
    }
  }

  static Future<void> _deleteSidecars(File file) async {
    for (final suffix in _sidecars) {
      final sidecar = File('${file.path}$suffix');
      if (await sidecar.exists()) await sidecar.delete();
    }
  }

  static Future<void> _deleteWithSidecars(File file) async {
    if (await file.exists()) await file.delete();
    await _deleteSidecars(file);
  }
}
