import 'package:craftbook/features/stock/domain/entities/material.dart';
import 'package:craftbook/features/stock/presentation/material_list_filter.dart';
import 'package:flutter_test/flutter_test.dart';

final _at = DateTime(2026, 1, 1);

Material _material(int id, String name,
        {double onHand = 10,
        double promised = 0,
        double alert = 2,
        bool archived = false}) =>
    Material(
      id: id,
      name: name,
      packSize: 10,
      packPrice: 100,
      unitCost: 10,
      quantityOnHand: onHand,
      quantityPromised: promised,
      alertLevel: alert,
      isArchived: archived,
      createdAt: _at,
      updatedAt: _at,
    );

void main() {
  final materials = [
    _material(1, 'Yarn', promised: 3),
    _material(2, 'Glue', onHand: 1),
    _material(3, 'Beads'),
    _material(4, 'Old ribbon', archived: true),
  ];
  List<String> names(List<Material> ms) => ms.map((m) => m.name).toList();

  test('leaves archived out and puts low stock first', () {
    final v = MaterialCatalogueView(materials: materials);
    expect(names(v.apply(MaterialStockFilter.any)), ['Glue', 'Beads', 'Yarn']);
  });

  test('filters by low, promised and archived', () {
    final v = MaterialCatalogueView(materials: materials);
    expect(names(v.apply(MaterialStockFilter.low)), ['Glue']);
    expect(names(v.apply(MaterialStockFilter.promised)), ['Yarn']);
    expect(names(v.apply(MaterialStockFilter.archived)), ['Old ribbon']);
    expect(v.count(MaterialStockFilter.any), 3);
  });

  test('search narrows the list', () {
    final v = MaterialCatalogueView(materials: materials, query: ' yA ');
    expect(names(v.apply(MaterialStockFilter.any)), ['Yarn']);
    expect(v.count(MaterialStockFilter.low), 0);
  });

  test('drops Archived once nothing is archived', () {
    final v = MaterialCatalogueView(
        materials: materials.where((m) => !m.isArchived).toList());
    expect(v.hasArchived, isFalse);
    expect(v.effective(MaterialStockFilter.archived), MaterialStockFilter.any);
    expect(v.effective(MaterialStockFilter.low), MaterialStockFilter.low);
  });
}
