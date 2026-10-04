/// App-wide constants for limits, defaults, and configuration
class AppConstants {
  AppConstants._();

  // Pagination
  static const int ordersPerPage = 50;
  static const int materialsPerPage = 50;

  // Stock
  static const int defaultAlertLevel = 10;
  static const int defaultPackSize = 20;

  // Order
  static const int maxOrderItems = 100;
  static const int maxOrderMaterials = 200;

  // Date formats
  static const String dateFormat = 'dd MMM yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd MMM yyyy HH:mm';

  // Currency
  static const String currencySymbol = '₱';
  static const String currencyCode = 'PHP';

  // App info
  static const String appName = 'CraftBook';
}
