// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_field_dao.dart';

// ignore_for_file: type=lint
mixin _$OrderFieldDaoMixin on DatabaseAccessor<AppDatabase> {
  $OrderFieldDefinitionsTable get orderFieldDefinitions =>
      attachedDatabase.orderFieldDefinitions;
  $OrdersTable get orders => attachedDatabase.orders;
  $OrderFieldValuesTable get orderFieldValues =>
      attachedDatabase.orderFieldValues;
  OrderFieldDaoManager get managers => OrderFieldDaoManager(this);
}

class OrderFieldDaoManager {
  final _$OrderFieldDaoMixin _db;
  OrderFieldDaoManager(this._db);
  $$OrderFieldDefinitionsTableTableManager get orderFieldDefinitions =>
      $$OrderFieldDefinitionsTableTableManager(
          _db.attachedDatabase, _db.orderFieldDefinitions);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db.attachedDatabase, _db.orders);
  $$OrderFieldValuesTableTableManager get orderFieldValues =>
      $$OrderFieldValuesTableTableManager(
          _db.attachedDatabase, _db.orderFieldValues);
}
