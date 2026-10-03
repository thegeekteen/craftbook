/// Route name constants for go_router navigation
class RouteNames {
  RouteNames._();

  // Today / Calendar
  static const String today = '/';
  static const String calendarWeek = '/calendar/week';
  static const String calendarMonth = '/calendar/month';

  // Orders
  static const String orders = '/orders';
  static const String newOrder = '/orders/new';
  static const String orderDetail = '/orders/:id';

  // Stock / Materials
  static const String materials = '/materials';
  static const String newMaterial = '/materials/new';
  static const String materialDetail = '/materials/:id';
  static const String receiveStock = '/materials/:id/receive';
  static const String buyList = '/stock/buy-list';

  // Products
  static const String products = '/products';
  static const String productEditor = '/products/:id/edit';
  static const String newProduct = '/products/new';
  static const String receiveProductStock = '/products/:id/receive';
  static const String channels = '/channels';

  // Earnings
  static const String earnings = '/earnings';
  static const String productEarnings = '/earnings/:productId';

  /// Concrete paths for parameterised routes.
  static String orderPath(int id) => '/orders/$id';
  static String materialPath(int id) => '/materials/$id';
  static String receiveStockPath(int id) => '/materials/$id/receive';
  static String productEditorPath(int id) => '/products/$id/edit';
  static String receiveProductStockPath(int id) => '/products/$id/receive';
  static String productEarningsPath(int id, DateTime start, DateTime end) =>
      '/earnings/$id?start=${start.millisecondsSinceEpoch}'
      '&end=${end.millisecondsSinceEpoch}';

  // Settings
  static const String settings = '/settings';
}
