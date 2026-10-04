// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'material_dao.dart';

// ignore_for_file: type=lint
mixin _$MaterialDaoMixin on DatabaseAccessor<AppDatabase> {
  $MaterialsTable get materials => attachedDatabase.materials;
  $StockMovementsTable get stockMovements => attachedDatabase.stockMovements;
  $OrderMaterialsTable get orderMaterials => attachedDatabase.orderMaterials;
  MaterialDaoManager get managers => MaterialDaoManager(this);
}

class MaterialDaoManager {
  final _$MaterialDaoMixin _db;
  MaterialDaoManager(this._db);
  $$MaterialsTableTableManager get materials =>
      $$MaterialsTableTableManager(_db.attachedDatabase, _db.materials);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(
          _db.attachedDatabase, _db.stockMovements);
  $$OrderMaterialsTableTableManager get orderMaterials =>
      $$OrderMaterialsTableTableManager(
          _db.attachedDatabase, _db.orderMaterials);
}
