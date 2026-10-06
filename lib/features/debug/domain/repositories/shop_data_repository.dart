import '../../../../core/error/result.dart';

/// Everything the debug tools need that has to touch the database file itself.
///
/// This is the one place outside the Drift layer that names tables, which is
/// why it is small and separated: seeding the rest goes through the app's own
/// use cases so a seed exercises the same rules a shop owner's tap does.
abstract class ShopDataRepository {
  /// The schema the file is on.
  int get schemaVersion;

  /// Runs [work] as one transaction, so a seed that fails halfway leaves the
  /// shop exactly as it was.
  Future<T> inTransaction<T>(Future<T> Function() work);

  /// Deletes every row in the shop's tables and puts the seeded units back,
  /// leaving a database that reads like a fresh install.
  Future<Result<void>> wipeAll();

  /// Row counts per SQL table name, including tables this file doesn't know
  /// about, so a new feature can't be left out.
  Future<Result<Map<String, int>>> tableCounts();

  /// The file's path, or `in memory`.
  Future<Result<String>> location();

  /// Stamps when an order was packed and left, which the app otherwise sets to
  /// now.
  Future<Result<void>> backdateOrder({
    required int orderId,
    DateTime? packedAt,
    DateTime? shippedAt,
  });

  /// Moves an item's stock history back [days] days, so a product page shows a
  /// shop that has been running a while.
  Future<Result<void>> backdateStockHistory({
    int? materialId,
    int? productId,
    required int days,
  });
}
