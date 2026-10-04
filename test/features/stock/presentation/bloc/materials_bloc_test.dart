import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/domain/usecases/get_low_stock_products.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';
import 'package:craftbook/features/stock/domain/usecases/delete_material.dart';
import 'package:craftbook/features/stock/domain/usecases/get_buy_list.dart';
import 'package:craftbook/features/stock/domain/usecases/get_materials.dart';
import 'package:craftbook/features/stock/domain/usecases/receive_stock.dart';
import 'package:craftbook/features/stock/domain/usecases/update_material.dart';
import 'package:craftbook/features/stock/presentation/bloc/materials_bloc.dart';
import 'package:craftbook/features/stock/presentation/bloc/materials_event.dart';
import 'package:craftbook/features/stock/presentation/bloc/materials_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetMaterials extends Mock implements GetMaterials {}

class MockGetBuyList extends Mock implements GetBuyList {}

class MockReceiveStock extends Mock implements ReceiveStock {}

class MockDeleteMaterial extends Mock implements DeleteMaterial {}

class MockUpdateMaterial extends Mock implements UpdateMaterial {}

class MockMaterialRepository extends Mock implements MaterialRepository {}

class MockGetLowStockProducts extends Mock implements GetLowStockProducts {}

void main() {
  late MockGetMaterials getMaterials;
  late MockUpdateMaterial updateMaterial;
  late MockGetLowStockProducts getLowStockProducts;

  setUp(() {
    getMaterials = MockGetMaterials();
    updateMaterial = MockUpdateMaterial();
    getLowStockProducts = MockGetLowStockProducts();
    when(() => getLowStockProducts())
        .thenAnswer((_) async => const Success(<Product>[]));
    when(() => getMaterials(lowStockOnly: any(named: 'lowStockOnly')))
        .thenAnswer((_) async => const Success([]));
  });

  MaterialsBloc build() => MaterialsBloc(
        getMaterials: getMaterials,
        getBuyList: MockGetBuyList(),
        receiveStock: MockReceiveStock(),
        deleteMaterial: MockDeleteMaterial(),
        updateMaterial: updateMaterial,
        materialRepository: MockMaterialRepository(),
        getLowStockProducts: getLowStockProducts,
      );

  final now = DateTime(2026, 1, 1);
  final lowBox = Product(
    id: 4,
    name: 'Gift box',
    sellPrice: 60,
    isStandalone: true,
    quantityOnHand: 1,
    alertLevel: 3,
    createdAt: now,
    updatedAt: now,
  );

  blocTest<MaterialsBloc, MaterialsState>(
    'LoadMaterials counts low resell products for the Buy list badge',
    setUp: () => when(() => getLowStockProducts())
        .thenAnswer((_) async => Success([lowBox])),
    build: build,
    act: (bloc) => bloc.add(const LoadMaterials()),
    expect: () => [
      isA<MaterialsLoading>(),
      const MaterialsLoaded([], lowProductCount: 1),
    ],
  );

  blocTest<MaterialsBloc, MaterialsState>(
    'LoadMaterials still loads when the low product count fails',
    setUp: () => when(() => getLowStockProducts())
        .thenAnswer((_) async => const Error(DatabaseFailure('boom'))),
    build: build,
    act: (bloc) => bloc.add(const LoadMaterials()),
    expect: () => [
      isA<MaterialsLoading>(),
      const MaterialsLoaded([]),
    ],
  );

  const event = UpdateMaterialEvent(
    id: 1,
    name: 'Beads',
    packSize: 100,
    packPrice: 50,
    alertLevel: 10,
  );

  void stubUpdate(Result<void> result) {
    when(() => updateMaterial(
          id: any(named: 'id'),
          name: any(named: 'name'),
          packSize: any(named: 'packSize'),
          packPrice: any(named: 'packPrice'),
          alertLevel: any(named: 'alertLevel'),
          supplier: any(named: 'supplier'),
        )).thenAnswer((_) async => result);
  }

  blocTest<MaterialsBloc, MaterialsState>(
    'UpdateMaterialEvent emits MaterialUpdated then reloads',
    setUp: () => stubUpdate(const Success(null)),
    build: build,
    act: (bloc) => bloc.add(event),
    expect: () => [
      isA<MaterialUpdated>(),
      isA<MaterialsLoading>(),
      isA<MaterialsLoaded>(),
    ],
  );

  blocTest<MaterialsBloc, MaterialsState>(
    'UpdateMaterialEvent emits MaterialsError on failure',
    setUp: () => stubUpdate(const Error(ValidationFailure('Enter a name'))),
    build: build,
    act: (bloc) => bloc.add(event),
    expect: () => [const MaterialsError('Enter a name')],
  );
}
