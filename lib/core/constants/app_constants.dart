/// App-wide constants for limits, defaults, and configuration
class AppConstants {
  AppConstants._();

  // Pagination
  static const int ordersPerPage = 50;
  static const int materialsPerPage = 50;

  // Stock
  static const int defaultAlertLevel = 10;
  static const int defaultPackSize = 20;

  // Units of measure. The seeded list starts with this one, so on any database
  // this app created it lands on id 1.
  static const String defaultUnitLabel = 'pc';
  static const int defaultUnitId = 1;

  // Order
  static const int maxOrderItems = 100;
  static const int maxOrderMaterials = 200;

  // Date formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';

  // App info
  static const String appName = 'CraftBook';
}
