// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'earnings_dao.dart';

// ignore_for_file: type=lint
mixin _$EarningsDaoMixin on DatabaseAccessor<AppDatabase> {
  $OrdersTable get orders => attachedDatabase.orders;
  $OrderItemsTable get orderItems => attachedDatabase.orderItems;
  $OrderMaterialsTable get orderMaterials => attachedDatabase.orderMaterials;
  $ProductsTable get products => attachedDatabase.products;
  $MaterialsTable get materials => attachedDatabase.materials;
  $UnitsTable get units => attachedDatabase.units;
  EarningsDaoManager get managers => EarningsDaoManager(this);
}

class EarningsDaoManager {
  final _$EarningsDaoMixin _db;
  EarningsDaoManager(this._db);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db.attachedDatabase, _db.orders);
  $$OrderItemsTableTableManager get orderItems =>
      $$OrderItemsTableTableManager(_db.attachedDatabase, _db.orderItems);
  $$OrderMaterialsTableTableManager get orderMaterials =>
      $$OrderMaterialsTableTableManager(
          _db.attachedDatabase, _db.orderMaterials);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$MaterialsTableTableManager get materials =>
      $$MaterialsTableTableManager(_db.attachedDatabase, _db.materials);
  $$UnitsTableTableManager get units =>
      $$UnitsTableTableManager(_db.attachedDatabase, _db.units);
}
