import '../../../../core/error/result.dart';
import '../../../../core/factory/coverage.dart';
import '../entities/database_info.dart';
import '../repositories/shop_data_repository.dart';
import 'get_coverage_report.dart';

/// Reads the database underneath the app: which schema, which file, how many
/// rows in each table, and which of the app's options the data used.
class GetDatabaseInfo {
  final ShopDataRepository shopData;
  final GetCoverageReport coverage;

  const GetDatabaseInfo({required this.shopData, required this.coverage});

  Future<Result<DatabaseInfo>> call() async {
    final Map<String, int> counts;
    switch (await shopData.tableCounts()) {
      case Error(:final failure):
        return Error<DatabaseInfo>(failure);
      case Success(:final value):
        counts = value;
    }

    final String location;
    switch (await shopData.location()) {
      case Error(:final failure):
        return Error<DatabaseInfo>(failure);
      case Success(:final value):
        location = value;
    }

    final CoverageReport report;
    switch (await coverage()) {
      case Error(:final failure):
        return Error<DatabaseInfo>(failure);
      case Success(:final value):
        report = value;
    }

    return Success(DatabaseInfo(
      schemaVersion: shopData.schemaVersion,
      location: location,
      tableCounts: counts,
      coverage: report,
    ));
  }
}
