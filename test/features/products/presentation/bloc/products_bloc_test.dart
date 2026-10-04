import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/domain/usecases/calculate_bom_cost.dart';
import 'package:craftbook/features/products/domain/usecases/calculate_buildable_quantity.dart';
import 'package:craftbook/features/products/domain/usecases/create_product.dart';
import 'package:craftbook/features/products/domain/usecases/delete_product.dart';
import 'package:craftbook/features/products/domain/usecases/get_pending_order_counts.dart';
import 'package:craftbook/features/products/domain/usecases/get_products.dart';
import 'package:craftbook/features/products/domain/usecases/update_product.dart';
import 'package:craftbook/features/products/presentation/bloc/products_bloc.dart';
import 'package:craftbook/features/products/presentation/bloc/products_event.dart';
import 'package:craftbook/features/products/presentation/bloc/products_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetProducts extends Mock implements GetProducts {}

class MockCreateProduct extends Mock implements CreateProduct {}

class MockUpdateProduct extends Mock implements UpdateProduct {}

class MockDeleteProduct extends Mock implements DeleteProduct {}

class MockCalculateBomCost extends Mock implements CalculateBomCost {}

class MockCalculateBuildableQuantity extends Mock
    implements CalculateBuildableQuantity {}

class MockGetPendingOrderCounts extends Mock implements GetPendingOrderCounts {}

void main() {
  late MockGetProducts getProducts;
  late MockCalculateBomCost bomCost;
  late MockCalculateBuildableQuantity buildable;
  late MockGetPendingOrderCounts pending;
  final now = DateTime(2026, 1, 1);

  Product product(int id, {bool standalone = false, int onHand = 0}) => Product(
        id: id,
        name: 'P$id',
        sellPrice: 100,
        isActive: true,
        isStandalone: standalone,
        quantityOnHand: onHand,
        createdAt: now,
        updatedAt: now,
      );

  // 1: handmade, buildable 4. 2: handmade, over-promised with an order.
  // 3: handmade, over-promised but no order of its own. 4: resell, 2 free.
  final products = [
    product(1),
    product(2),
    product(3),
    product(4, standalone: true, onHand: 2),
  ];

  setUp(() {
    getProducts = MockGetProducts();
    bomCost = MockCalculateBomCost();
    buildable = MockCalculateBuildableQuantity();
    pending = MockGetPendingOrderCounts();
    when(() => getProducts(activeOnly: any(named: 'activeOnly')))
        .thenAnswer((_) async => Success(products));
    when(() => bomCost(any())).thenAnswer((_) async => const Success(30.0));
    when(() => buildable(1)).thenAnswer((_) async => const Success(4));
    when(() => buildable(2)).thenAnswer((_) async => const Success(-2));
    when(() => buildable(3)).thenAnswer((_) async => const Success(-1));
    when(() => buildable(4)).thenAnswer((_) async => const Success(2));
    when(() => pending()).thenAnswer((_) async => const Success({2: 1}));
  });

  ProductsBloc build() => ProductsBloc(
        getProducts: getProducts,
        createProduct: MockCreateProduct(),
        updateProduct: MockUpdateProduct(),
        deleteProduct: MockDeleteProduct(),
        calculateBomCost: bomCost,
        calculateBuildableQuantity: buildable,
        getPendingOrderCounts: pending,
      );

  blocTest<ProductsBloc, ProductsState>(
    'load emits costs, clamped availability and short products',
    build: build,
    act: (bloc) => bloc.add(const LoadProducts()),
    expect: () => [
      isA<ProductsLoading>(),
      ProductsLoaded(
        products,
        unitCosts: const {1: 30, 2: 30, 3: 30, 4: 30},
        available: const {1: 4, 2: 0, 3: 0, 4: 2},
        shortIds: const {2},
      ),
    ],
  );

  blocTest<ProductsBloc, ProductsState>(
    'a failed order count still loads, with nothing short',
    setUp: () => when(() => pending())
        .thenAnswer((_) async => const Error(DatabaseFailure('boom'))),
    build: build,
    act: (bloc) => bloc.add(const LoadProducts()),
    expect: () => [
      isA<ProductsLoading>(),
      isA<ProductsLoaded>()
          .having((s) => s.shortIds, 'shortIds', isEmpty)
          .having((s) => s.available[1], 'available[1]', 4),
    ],
  );

  blocTest<ProductsBloc, ProductsState>(
    'emits ProductsError when products fail to load',
    setUp: () => when(() => getProducts(activeOnly: any(named: 'activeOnly')))
        .thenAnswer((_) async => const Error(DatabaseFailure('boom'))),
    build: build,
    act: (bloc) => bloc.add(const LoadProducts()),
    expect: () => [isA<ProductsLoading>(), const ProductsError('boom')],
  );
}
