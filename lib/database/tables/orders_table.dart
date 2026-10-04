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
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}

/// Channels table
class Channels extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get commissionRate => real().withDefault(const Constant(0.0))();
  RealColumn get transactionFeeRate => real().withDefault(const Constant(0.0))();
  RealColumn get flatFee => real().withDefault(const Constant(0.0))();
  RealColumn get shippingPaidByUs => real().withDefault(const Constant(0.0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
