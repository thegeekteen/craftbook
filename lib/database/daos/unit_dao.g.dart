// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_dao.dart';

// ignore_for_file: type=lint
mixin _$UnitDaoMixin on DatabaseAccessor<AppDatabase> {
  $UnitsTable get units => attachedDatabase.units;
  $MaterialsTable get materials => attachedDatabase.materials;
  $ProductsTable get products => attachedDatabase.products;
  UnitDaoManager get managers => UnitDaoManager(this);
}

class UnitDaoManager {
  final _$UnitDaoMixin _db;
  UnitDaoManager(this._db);
  $$UnitsTableTableManager get units =>
      $$UnitsTableTableManager(_db.attachedDatabase, _db.units);
  $$MaterialsTableTableManager get materials =>
      $$MaterialsTableTableManager(_db.attachedDatabase, _db.materials);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db.attachedDatabase, _db.products);
}
