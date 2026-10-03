// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_dao.dart';

// ignore_for_file: type=lint
mixin _$ProductDaoMixin on DatabaseAccessor<AppDatabase> {
  $ProductsTable get products => attachedDatabase.products;
  $BomItemsTable get bomItems => attachedDatabase.bomItems;
  $MaterialsTable get materials => attachedDatabase.materials;
  $ProductStockMovementsTable get productStockMovements =>
      attachedDatabase.productStockMovements;
  $OrderProductsTable get orderProducts => attachedDatabase.orderProducts;
  $OrdersTable get orders => attachedDatabase.orders;
  $OrderItemsTable get orderItems => attachedDatabase.orderItems;
  ProductDaoManager get managers => ProductDaoManager(this);
}

class ProductDaoManager {
  final _$ProductDaoMixin _db;
  ProductDaoManager(this._db);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
  $$BomItemsTableTableManager get bomItems =>
      $$BomItemsTableTableManager(_db.attachedDatabase, _db.bomItems);
  $$MaterialsTableTableManager get materials =>
      $$MaterialsTableTableManager(_db.attachedDatabase, _db.materials);
  $$ProductStockMovementsTableTableManager get productStockMovements =>
      $$ProductStockMovementsTableTableManager(
          _db.attachedDatabase, _db.productStockMovements);
  $$OrderProductsTableTableManager get orderProducts =>
      $$OrderProductsTableTableManager(_db.attachedDatabase, _db.orderProducts);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db.attachedDatabase, _db.orders);
  $$OrderItemsTableTableManager get orderItems =>
      $$OrderItemsTableTableManager(_db.attachedDatabase, _db.orderItems);
}
