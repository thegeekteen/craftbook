import 'package:drift/drift.dart';

/// Orders table definition
class Orders extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get customerName => text()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get orderDate => dateTime()();
  DateTimeColumn get shipByDate => dateTime()();
  DateTimeColumn get packedAt => dateTime().nullable()();
  DateTimeColumn get shippedAt => dateTime().nullable()();
  TextColumn get status => text()();
  IntColumn get channelId => integer().nullable()();
  RealColumn get totalSales => real()();
  RealColumn get totalMaterialCost => real().withDefault(const Constant(0.0))();
  RealColumn get channelFees => real().withDefault(const Constant(0.0))();
  RealColumn get shippingCost => real().withDefault(const Constant(0.0))();
  RealColumn get profit => real().withDefault(const Constant(0.0))();

  /// Sum of the order's discount lines, so reports needn't load them.
  RealColumn get discountTotal => real().withDefault(const Constant(0.0))();

  /// Tax rate in percent copied from Settings when the order was saved;
  /// null when the order has no tax.
  RealColumn get taxRate => real().nullable()();
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();

  /// True when the item prices already include the tax; false when it is
  /// added on top of them.
  BoolColumn get taxInclusive => boolean().withDefault(const Constant(true))();
  BoolColumn get isPaid => boolean().withDefault(const Constant(true))();
  DateTimeColumn get paidAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// One discount on one order. [amount] is what it took off, worked out when
/// the order was saved.
class OrderDiscounts extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get orderId =>
      integer().references(Orders, #id, onDelete: KeyAction.cascade)();
  TextColumn get label => text()();

  /// 'percent' | 'fixed'
  TextColumn get kind => text()();
  RealColumn get value => real()();
  RealColumn get amount => real()();
  IntColumn get position => integer().withDefault(const Constant(0))();
}

/// Discounts the shop offers often, for one-tap use on an order.
class DiscountPresets extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get label => text()();

  /// 'percent' | 'fixed'
  TextColumn get kind => text()();
  RealColumn get value => real()();
  IntColumn get position => integer().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

/// Channels table
class Channels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get commissionRate => real().withDefault(const Constant(0.0))();
  RealColumn get transactionFeeRate =>
      real().withDefault(const Constant(0.0))();
  RealColumn get flatFee => real().withDefault(const Constant(0.0))();
  RealColumn get shippingPaidByUs => real().withDefault(const Constant(0.0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// Whether new orders on this channel start out paid. Marketplaces
  /// collect up front; walk-in and chat sales often don't.
  BoolColumn get paidByDefault => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
