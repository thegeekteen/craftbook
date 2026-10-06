import '../../../../core/factory/coverage.dart';

/// What the database underneath the app actually holds, and whether the fake
/// shop covered the whole app.
class DatabaseInfo {
  /// The schema the file is on, which is how you confirm a migration ran.
  final int schemaVersion;

  /// Where the file lives, or `in memory` in tests.
  final String location;

  /// Rows per table, keyed by the table's name in SQL.
  final Map<String, int> tableCounts;

  final CoverageReport coverage;

  const DatabaseInfo({
    required this.schemaVersion,
    required this.location,
    required this.tableCounts,
    required this.coverage,
  });

  int get totalRows =>
      tableCounts.values.fold<int>(0, (sum, count) => sum + count);

  List<String> get gaps => coverage.gaps;

  bool get isComplete => coverage.isComplete;
}
