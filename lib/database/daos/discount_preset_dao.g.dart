// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'discount_preset_dao.dart';

// ignore_for_file: type=lint
mixin _$DiscountPresetDaoMixin on DatabaseAccessor<AppDatabase> {
  $DiscountPresetsTable get discountPresets => attachedDatabase.discountPresets;
  DiscountPresetDaoManager get managers => DiscountPresetDaoManager(this);
}

class DiscountPresetDaoManager {
  final _$DiscountPresetDaoMixin _db;
  DiscountPresetDaoManager(this._db);
  $$DiscountPresetsTableTableManager get discountPresets =>
      $$DiscountPresetsTableTableManager(
          _db.attachedDatabase, _db.discountPresets);
}
