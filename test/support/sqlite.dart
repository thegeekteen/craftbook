import 'dart:ffi' show DynamicLibrary;

// ignore: depend_on_referenced_packages
import 'package:sqlite3/open.dart';

/// Lets drift's in-memory database load on Linux hosts that only ship the
/// versioned library name (libsqlite3.so.0).
void useHostSqlite() {
  open.overrideFor(OperatingSystem.linux, () {
    try {
      return DynamicLibrary.open('libsqlite3.so');
    } catch (_) {
      return DynamicLibrary.open('libsqlite3.so.0');
    }
  });
}
