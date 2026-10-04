// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_dao.dart';

// ignore_for_file: type=lint
mixin _$OrderDaoMixin on DatabaseAccessor<AppDatabase> {
  $OrdersTable get orders => attachedDatabase.orders;
  $OrderItemsTable get orderItems => attachedDatabase.orderItems;
  $OrderMaterialsTable get orderMaterials => attachedDatabase.orderMaterials;
  $OrderProductsTable get orderProducts => attachedDatabase.orderProducts;
  $ProductsTable get products => attachedDatabase.products;
  $MaterialsTable get materials => attachedDatabase.materials;
  $ProductStockMovementsTable get productStockMovements =>
      attachedDatabase.productStockMovements;
  $OrderFieldDefinitionsTable get orderFieldDefinitions =>
      attachedDatabase.orderFieldDefinitions;
  $OrderFieldValuesTable get orderFieldValues =>
      attachedDatabase.orderFieldValues;
  OrderDaoManager get managers => OrderDaoManager(this);
}

class OrderDaoManager {
  final _$OrderDaoMixin _db;
  OrderDaoManager(this._db);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db.attachedDatabase, _db.orders);
  $$OrderItemsTableTableManager get orderItems =>
      $$OrderItemsTableTableManager(_db.attachedDatabase, _db.orderItems);
  $$OrderMaterialsTableTableManager get orderMaterials =>
      $$OrderMaterialsTableTableManager(
          _db.attachedDatabase, _db.orderMaterials);
  $$OrderProductsTableTableManager get orderProducts =>
      $$OrderProductsTableTableManager(_db.attachedDatabase, _db.orderProducts);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$MaterialsTableTableManager get materials =>
      $$MaterialsTableTableManager(_db.attachedDatabase, _db.materials);
  $$ProductStockMovementsTableTableManager get productStockMovements =>
      $$ProductStockMovementsTableTableManager(
          _db.attachedDatabase, _db.productStockMovements);
  $$OrderFieldDefinitionsTableTableManager get orderFieldDefinitions =>
      $$OrderFieldDefinitionsTableTableManager(
          _db.attachedDatabase, _db.orderFieldDefinitions);
  $$OrderFieldValuesTableTableManager get orderFieldValues =>
      $$OrderFieldValuesTableTableManager(
          _db.attachedDatabase, _db.orderFieldValues);
}
