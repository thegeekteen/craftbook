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
  static const String editOrder = '/orders/:id/edit';
  static const String orderDetail = '/orders/:id';

  // Stock / Materials. The list is the Products page's Materials tab;
  // [materials] redirects there.
  static const String materials = '/materials';
  static const String materialsTab = '/products?tab=materials';
  static const String newMaterial = '/materials/new';
  static const String materialDetail = '/materials/:id';
  static const String editMaterial = '/materials/:id/edit';
  static const String receiveStock = '/materials/:id/receive';
  static const String buyList = '/stock/buy-list';

  // Products
  static const String products = '/products';
  static const String newProduct = '/products/new';
  static const String productDetail = '/products/:id';
  static const String productEditor = '/products/:id/edit';
  static const String receiveProductStock = '/products/:id/receive';
  static const String channels = '/channels';
  static const String orderFields = '/order-fields';
  static const String socialLinks = '/social-links';
  static const String discounts = '/discounts';

  // Units of measure. Top-level, like channels and order fields, because the
  // material and product editors are pushed pages outside the shell.
  static const String units = '/units';

  // Reports (the earnings feature)
  static const String reports = '/reports';
  static const String productReport = '/reports/:productId';
  static const String receivables = '/receivables';

  /// Concrete paths for parameterised routes.
  static String orderPath(int id) => '/orders/$id';
  static String editOrderPath(int id) => '/orders/$id/edit';
  static String materialPath(int id) => '/materials/$id';
  static String editMaterialPath(int id) => '/materials/$id/edit';
  static String receiveStockPath(int id) => '/materials/$id/receive';
  static String productPath(int id) => '/products/$id';
  static String productEditorPath(int id) => '/products/$id/edit';
  static String receiveProductStockPath(int id) => '/products/$id/receive';
  static String productReportPath(int id, DateTime start, DateTime end) =>
      '/reports/$id?start=${start.millisecondsSinceEpoch}'
      '&end=${end.millisecondsSinceEpoch}';

  // Notes
  static const String notes = '/notes';
  static const String newNote = '/notes/new';
  static const String noteDetail = '/notes/:id';
  static String notePath(int id) => '/notes/$id';

  // Settings
  static const String settings = '/settings';
  static const String about = '/about';

  // Debug tools. Only reachable on a debug build, and top-level like the other
  // pushed pages, because it has no business showing a bottom bar.
  static const String debugDatabase = '/debug/database';
}
