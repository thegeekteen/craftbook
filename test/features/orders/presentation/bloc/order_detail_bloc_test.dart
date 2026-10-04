import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/order_fields/domain/entities/order_field.dart';
import 'package:craftbook/features/order_fields/domain/entities/order_field_entry.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/entities/order_material.dart';
import 'package:craftbook/features/orders/domain/entities/order_product.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/adjust_materials_used.dart';
import 'package:craftbook/features/orders/domain/usecases/cancel_order.dart';
import 'package:craftbook/features/orders/domain/usecases/delete_order.dart';
import 'package:craftbook/features/orders/domain/usecases/pack_order.dart';
import 'package:craftbook/features/orders/domain/usecases/restore_order.dart';
import 'package:craftbook/features/orders/domain/usecases/ship_order.dart';
import 'package:craftbook/features/orders/domain/usecases/update_order_note.dart';
import 'package:craftbook/features/orders/presentation/bloc/order_detail_bloc.dart';
import 'package:craftbook/features/orders/presentation/bloc/order_detail_event.dart';
import 'package:craftbook/features/orders/presentation/bloc/order_detail_state.dart';
import 'package:craftbook/features/products/domain/entities/channel.dart';
import 'package:craftbook/features/products/domain/entities/product.dart';
import 'package:craftbook/features/products/domain/repositories/channel_repository.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/stock/domain/entities/material.dart';
import 'package:craftbook/features/stock/domain/repositories/material_repository.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class MockChannelRepository extends Mock implements ChannelRepository {}

class MockMaterialRepository extends Mock implements MaterialRepository {}

class MockProductRepository extends Mock implements ProductRepository {}

class MockAdjustMaterialsUsed extends Mock implements AdjustMaterialsUsed {}

class MockPackOrder extends Mock implements PackOrder {}

class MockShipOrder extends Mock implements ShipOrder {}

class MockCancelOrder extends Mock implements CancelOrder {}

class MockRestoreOrder extends Mock implements RestoreOrder {}

class MockDeleteOrder extends Mock implements DeleteOrder {}

class MockUpdateOrderNote extends Mock implements UpdateOrderNote {}

void main() {
  late MockOrderRepository orderRepository;
  late MockChannelRepository channelRepository;
  late MockMaterialRepository materialRepository;
  late MockProductRepository productRepository;
  late MockAdjustMaterialsUsed adjustMaterialsUsed;
  late MockPackOrder packOrder;
  late MockShipOrder shipOrder;
  late MockCancelOrder cancelOrder;
  late MockRestoreOrder restoreOrder;
  late MockDeleteOrder deleteOrder;
  late MockUpdateOrderNote updateOrderNote;

  const orderId = 7;
  final now = DateTime(2026, 9, 1);

  Order order({OrderStatus status = OrderStatus.pending, String? note}) =>
      Order(
        id: orderId,
        customerName: 'Jessa Ramos',
        note: note,
        orderDate: now,
        shipByDate: now.add(const Duration(days: 2)),
        status: status,
        channelId: 1,
        totalSales: 485,
        totalMaterialCost: 120,
        channelFees: 40,
        shippingCost: 40,
        profit: 285,
        createdAt: now,
        updatedAt: now,
      );

  final channel = Channel(
    id: 1,
    name: 'Shopee',
    commissionRate: 8,
    transactionFeeRate: 2,
    flatFee: 5,
    shippingPaidByUs: 40,
    isActive: true,
    createdAt: now,
  );

  const items = [
    OrderItem(
      id: 1,
      orderId: orderId,
      productId: 10,
      productName: 'Tulip bouquet',
      quantity: 1,
      unitPrice: 450,
      subtotal: 450,
    ),
  ];

  final materials = [
    OrderMaterial(
      id: 1,
      orderId: orderId,
      materialId: 100,
      materialName: 'Yarn',
      plannedQuantity: 3,
      actualQuantity: 3,
      wasteQuantity: 0,
      unitCost: 18,
      createdAt: now,
    ),
    OrderMaterial(
      id: 2,
      orderId: orderId,
      materialId: 101,
      materialName: 'Wire',
      plannedQuantity: 7,
      actualQuantity: 7,
      wasteQuantity: 0,
      unitCost: 4,
      createdAt: now,
    ),
  ];

  const products = [
    OrderProduct(
      id: 1,
      orderId: orderId,
      productId: 20,
      productName: 'Gift box',
      quantity: 1,
      unitCost: 28,
    ),
  ];

  final yarn = Material(
    id: 100,
    name: 'Yarn',
    packSize: 10,
    packPrice: 180,
    unitCost: 18,
    quantityOnHand: 40,
    quantityPromised: 3,
    alertLevel: 8,
    createdAt: now,
    updatedAt: now,
  );

  final giftBox = Product(
    id: 20,
    name: 'Gift box',
    sellPrice: 35,
    isStandalone: true,
    quantityOnHand: 6,
    alertLevel: 3,
    createdAt: now,
    updatedAt: now,
  );

  OrderDetailLoaded loaded({
    OrderStatus status = OrderStatus.pending,
    bool isBusy = false,
    String? note,
  }) =>
      OrderDetailLoaded(
        order: order(status: status, note: note),
        items: items,
        materials: materials,
        products: products,
        channel: channel,
        materialStock: const {100: StockLevel(onHand: 40, alertLevel: 8)},
        productStock: const {20: StockLevel(onHand: 6, alertLevel: 3)},
        isBusy: isBusy,
      );

  setUpAll(() {
    registerFallbackValue(<OrderMaterialInput>[]);
  });

  setUp(() {
    orderRepository = MockOrderRepository();
    channelRepository = MockChannelRepository();
    materialRepository = MockMaterialRepository();
    productRepository = MockProductRepository();
    adjustMaterialsUsed = MockAdjustMaterialsUsed();
    packOrder = MockPackOrder();
    shipOrder = MockShipOrder();
    cancelOrder = MockCancelOrder();
    restoreOrder = MockRestoreOrder();
    deleteOrder = MockDeleteOrder();
    updateOrderNote = MockUpdateOrderNote();
  });

  OrderDetailBloc build() => OrderDetailBloc(
        orderRepository: orderRepository,
        channelRepository: channelRepository,
        materialRepository: materialRepository,
        productRepository: productRepository,
        adjustMaterialsUsed: adjustMaterialsUsed,
        packOrder: packOrder,
        shipOrder: shipOrder,
        cancelOrder: cancelOrder,
        restoreOrder: restoreOrder,
        deleteOrder: deleteOrder,
        updateOrderNote: updateOrderNote,
      );

  /// Stubs a full successful load. Material 101 has no row, so it must be
  /// left out of materialStock without failing the load.
  void stubLoad({OrderStatus status = OrderStatus.pending, String? note}) {
    when(() => orderRepository.getOrderById(orderId))
        .thenAnswer((_) async => Success(order(status: status, note: note)));
    when(() => channelRepository.getChannelById(1))
        .thenAnswer((_) async => Success(channel));
    when(() => orderRepository.getOrderItems(orderId))
        .thenAnswer((_) async => const Success(items));
    when(() => orderRepository.getOrderMaterials(orderId))
        .thenAnswer((_) async => Success(materials));
    when(() => orderRepository.getOrderProducts(orderId))
        .thenAnswer((_) async => const Success(products));
    when(() => materialRepository.getMaterialById(100))
        .thenAnswer((_) async => Success(yarn));
    when(() => materialRepository.getMaterialById(101))
        .thenAnswer((_) async => const Success(null));
    when(() => productRepository.getProductById(20))
        .thenAnswer((_) async => Success(giftBox));
    when(() => orderRepository.getOrderFieldValues(orderId))
        .thenAnswer((_) async => const Success([]));
  }

  test('initial state is OrderDetailInitial', () {
    expect(build().state, isA<OrderDetailInitial>());
  });

  group('LoadOrderDetail', () {
    blocTest<OrderDetailBloc, OrderDetailState>(
      'emits [Loading, Loaded] with channel and stock maps',
      setUp: stubLoad,
      build: build,
      act: (bloc) => bloc.add(const LoadOrderDetail(orderId)),
      expect: () => [isA<OrderDetailLoading>(), loaded()],
      verify: (_) {
        verify(() => materialRepository.getMaterialById(100)).called(1);
        verify(() => materialRepository.getMaterialById(101)).called(1);
        verify(() => productRepository.getProductById(20)).called(1);
      },
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'channel and products failures are not fatal',
      setUp: () {
        stubLoad();
        when(() => channelRepository.getChannelById(1)).thenAnswer(
            (_) async => const Error(DatabaseFailure('no channel')));
        when(() => orderRepository.getOrderProducts(orderId)).thenAnswer(
            (_) async => const Error(DatabaseFailure('no products')));
        when(() => materialRepository.getMaterialById(100)).thenAnswer(
            (_) async => const Error(DatabaseFailure('no material')));
      },
      build: build,
      act: (bloc) => bloc.add(const LoadOrderDetail(orderId)),
      expect: () => [
        isA<OrderDetailLoading>(),
        isA<OrderDetailLoaded>()
            .having((s) => s.channel, 'channel', isNull)
            .having((s) => s.products, 'products', isEmpty)
            .having((s) => s.materialStock, 'materialStock', isEmpty)
            .having((s) => s.productStock, 'productStock', isEmpty)
            .having((s) => s.materials, 'materials', materials),
      ],
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'loads the order\'s field values',
      setUp: () {
        stubLoad();
        when(() => orderRepository.getOrderFieldValues(orderId))
            .thenAnswer((_) async => const Success([
                  OrderFieldEntry(
                    field: OrderField(
                        id: 1, name: 'Address', type: OrderFieldType.text),
                    value: 'Cebu City',
                  ),
                ]));
      },
      build: build,
      act: (bloc) => bloc.add(const LoadOrderDetail(orderId)),
      expect: () => [
        isA<OrderDetailLoading>(),
        isA<OrderDetailLoaded>()
            .having((s) => s.fieldValues.single.value, 'value', 'Cebu City'),
      ],
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'a field values failure is not fatal',
      setUp: () {
        stubLoad();
        when(() => orderRepository.getOrderFieldValues(orderId))
            .thenAnswer((_) async => const Error(DatabaseFailure('no fields')));
      },
      build: build,
      act: (bloc) => bloc.add(const LoadOrderDetail(orderId)),
      expect: () => [isA<OrderDetailLoading>(), loaded()],
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'reload while loaded does not emit Loading',
      setUp: () => stubLoad(status: OrderStatus.packed),
      build: build,
      seed: () => loaded(),
      act: (bloc) => bloc.add(const LoadOrderDetail(orderId)),
      expect: () => [loaded(status: OrderStatus.packed)],
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'emits Error when getOrderById fails',
      setUp: () => when(() => orderRepository.getOrderById(orderId))
          .thenAnswer((_) async => const Error(DatabaseFailure('db error'))),
      build: build,
      act: (bloc) => bloc.add(const LoadOrderDetail(orderId)),
      expect: () =>
          [isA<OrderDetailLoading>(), const OrderDetailError('db error')],
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'emits Error when the order does not exist',
      setUp: () => when(() => orderRepository.getOrderById(orderId))
          .thenAnswer((_) async => const Success(null)),
      build: build,
      act: (bloc) => bloc.add(const LoadOrderDetail(orderId)),
      expect: () => [
        isA<OrderDetailLoading>(),
        const OrderDetailError('Order not found')
      ],
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'emits Error when items fail to load',
      setUp: () {
        stubLoad();
        when(() => orderRepository.getOrderItems(orderId)).thenAnswer(
            (_) async => const Error(DatabaseFailure('items failed')));
      },
      build: build,
      act: (bloc) => bloc.add(const LoadOrderDetail(orderId)),
      expect: () =>
          [isA<OrderDetailLoading>(), const OrderDetailError('items failed')],
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'emits Error when materials fail to load',
      setUp: () {
        stubLoad();
        when(() => orderRepository.getOrderMaterials(orderId)).thenAnswer(
            (_) async => const Error(DatabaseFailure('materials failed')));
      },
      build: build,
      act: (bloc) => bloc.add(const LoadOrderDetail(orderId)),
      expect: () => [
        isA<OrderDetailLoading>(),
        const OrderDetailError('materials failed')
      ],
    );
  });

  group('PackOrderDetail', () {
    blocTest<OrderDetailBloc, OrderDetailState>(
      'success: busy, message, idle, then reloaded state',
      setUp: () {
        stubLoad(status: OrderStatus.packed);
        when(() => packOrder(orderId))
            .thenAnswer((_) async => const Success(null));
      },
      build: build,
      seed: () => loaded(),
      act: (bloc) => bloc.add(const PackOrderDetail(orderId)),
      expect: () => [
        loaded(isBusy: true),
        isA<OrderDetailMessage>()
            .having((m) => m.message, 'message', 'Packed. Stock updated.')
            .having((m) => m.isError, 'isError', false),
        loaded(isBusy: false),
        loaded(status: OrderStatus.packed),
      ],
      verify: (_) {
        verify(() => packOrder(orderId)).called(1);
        verify(() => orderRepository.getOrderById(orderId)).called(1);
      },
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'failure: busy, error message, idle; no reload',
      setUp: () => when(() => packOrder(orderId)).thenAnswer(
          (_) async => const Error(ValidationFailure('Not enough yarn'))),
      build: build,
      seed: () => loaded(),
      act: (bloc) => bloc.add(const PackOrderDetail(orderId)),
      expect: () => [
        loaded(isBusy: true),
        isA<OrderDetailMessage>()
            .having((m) => m.message, 'message', 'Not enough yarn')
            .having((m) => m.isError, 'isError', true),
        loaded(isBusy: false),
      ],
      verify: (_) => verifyNever(() => orderRepository.getOrderById(any())),
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'two identical failures in a row are both delivered (serial differs)',
      setUp: () => when(() => packOrder(orderId)).thenAnswer(
          (_) async => const Error(ValidationFailure('Not enough yarn'))),
      build: build,
      seed: () => loaded(),
      act: (bloc) async {
        bloc.add(const PackOrderDetail(orderId));
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const PackOrderDetail(orderId));
      },
      expect: () => [
        loaded(isBusy: true),
        isA<OrderDetailMessage>().having((m) => m.serial, 'serial', 1),
        loaded(),
        loaded(isBusy: true),
        isA<OrderDetailMessage>().having((m) => m.serial, 'serial', 2),
        loaded(),
      ],
    );
  });

  blocTest<OrderDetailBloc, OrderDetailState>(
    'ignores a second action while one is running',
    build: build,
    seed: () => loaded(isBusy: true),
    act: (bloc) => bloc.add(const PackOrderDetail(orderId)),
    expect: () => <OrderDetailState>[],
    verify: (_) => verifyNever(() => packOrder(any())),
  );

  group('ShipOrderDetail', () {
    blocTest<OrderDetailBloc, OrderDetailState>(
      'success: busy, message, idle, then reloaded state',
      setUp: () {
        stubLoad(status: OrderStatus.shipped);
        when(() => shipOrder(orderId))
            .thenAnswer((_) async => const Success(null));
      },
      build: build,
      seed: () => loaded(status: OrderStatus.packed),
      act: (bloc) => bloc.add(const ShipOrderDetail(orderId)),
      expect: () => [
        loaded(status: OrderStatus.packed, isBusy: true),
        isA<OrderDetailMessage>()
            .having((m) => m.message, 'message', 'Marked as shipped')
            .having((m) => m.isError, 'isError', false),
        loaded(status: OrderStatus.packed),
        loaded(status: OrderStatus.shipped),
      ],
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'failure: busy, error message, idle',
      setUp: () => when(() => shipOrder(orderId)).thenAnswer(
          (_) async => const Error(ValidationFailure('Not packed yet'))),
      build: build,
      seed: () => loaded(),
      act: (bloc) => bloc.add(const ShipOrderDetail(orderId)),
      expect: () => [
        loaded(isBusy: true),
        isA<OrderDetailMessage>()
            .having((m) => m.message, 'message', 'Not packed yet')
            .having((m) => m.isError, 'isError', true),
        loaded(),
      ],
    );
  });

  group('CancelOrderDetail', () {
    blocTest<OrderDetailBloc, OrderDetailState>(
      'success: busy, message, idle, then reloaded as cancelled',
      setUp: () {
        stubLoad(status: OrderStatus.cancelled);
        when(() => cancelOrder(orderId))
            .thenAnswer((_) async => const Success(null));
      },
      build: build,
      seed: () => loaded(),
      act: (bloc) => bloc.add(const CancelOrderDetail(orderId)),
      expect: () => [
        loaded(isBusy: true),
        isA<OrderDetailMessage>()
            .having(
                (m) => m.message, 'message', 'Order cancelled. Stock returned.')
            .having((m) => m.isError, 'isError', false),
        loaded(),
        loaded(status: OrderStatus.cancelled),
      ],
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'failure: busy, error message, idle',
      setUp: () => when(() => cancelOrder(orderId)).thenAnswer((_) async =>
          const Error(ValidationFailure('Shipped orders cannot be cancelled'))),
      build: build,
      seed: () => loaded(status: OrderStatus.shipped),
      act: (bloc) => bloc.add(const CancelOrderDetail(orderId)),
      expect: () => [
        loaded(status: OrderStatus.shipped, isBusy: true),
        isA<OrderDetailMessage>()
            .having((m) => m.message, 'message',
                'Shipped orders cannot be cancelled')
            .having((m) => m.isError, 'isError', true),
        loaded(status: OrderStatus.shipped),
      ],
    );
  });

  group('RestoreOrderDetail', () {
    blocTest<OrderDetailBloc, OrderDetailState>(
      'success: busy, message, idle, then reloaded as to pack',
      setUp: () {
        stubLoad();
        when(() => restoreOrder(orderId))
            .thenAnswer((_) async => const Success(null));
      },
      build: build,
      seed: () => loaded(status: OrderStatus.cancelled),
      act: (bloc) => bloc.add(const RestoreOrderDetail(orderId)),
      expect: () => [
        loaded(status: OrderStatus.cancelled, isBusy: true),
        isA<OrderDetailMessage>()
            .having((m) => m.message, 'message', 'Order restored')
            .having((m) => m.isError, 'isError', false),
        loaded(status: OrderStatus.cancelled),
        loaded(),
      ],
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'failure: busy, error message, idle',
      setUp: () => when(() => restoreOrder(orderId)).thenAnswer((_) async =>
          const Error(
              ValidationFailure('Only cancelled orders can be restored'))),
      build: build,
      seed: () => loaded(),
      act: (bloc) => bloc.add(const RestoreOrderDetail(orderId)),
      expect: () => [
        loaded(isBusy: true),
        isA<OrderDetailMessage>()
            .having((m) => m.message, 'message',
                'Only cancelled orders can be restored')
            .having((m) => m.isError, 'isError', true),
        loaded(),
      ],
    );
  });

  group('SaveOrderNote', () {
    blocTest<OrderDetailBloc, OrderDetailState>(
      'success: saves quietly, then shows the stored note',
      setUp: () {
        stubLoad(status: OrderStatus.shipped, note: 'Ring twice');
        when(() => updateOrderNote(orderId, 'Ring twice'))
            .thenAnswer((_) async => const Success(null));
      },
      build: build,
      seed: () => loaded(status: OrderStatus.shipped),
      act: (bloc) =>
          bloc.add(const SaveOrderNote(orderId: orderId, note: 'Ring twice')),
      // No busy flag and no snackbar: ticking a to-do should feel instant.
      expect: () => [loaded(status: OrderStatus.shipped, note: 'Ring twice')],
      verify: (_) =>
          verify(() => updateOrderNote(orderId, 'Ring twice')).called(1),
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'failure: error message, then the note as it was stored',
      setUp: () {
        stubLoad(note: 'Ring twice');
        when(() => updateOrderNote(orderId, any()))
            .thenAnswer((_) async => const Error(DatabaseFailure('disk full')));
      },
      build: build,
      seed: () => loaded(note: 'Ring twice'),
      act: (bloc) =>
          bloc.add(const SaveOrderNote(orderId: orderId, note: 'Changed')),
      expect: () => [
        isA<OrderDetailMessage>()
            .having((m) => m.message, 'message', 'disk full')
            .having((m) => m.isError, 'isError', true),
        loaded(note: 'Ring twice'),
      ],
    );
  });

  group('AdjustMaterials', () {
    const inputs = [
      OrderMaterialInput(
        materialId: 100,
        materialName: 'Yarn',
        plannedQuantity: 3,
        actualQuantity: 4,
        wasteQuantity: 1,
        unitCost: 18,
      ),
    ];

    blocTest<OrderDetailBloc, OrderDetailState>(
      'success: busy, message, idle, then reloaded state',
      setUp: () {
        stubLoad(status: OrderStatus.packed);
        when(() => adjustMaterialsUsed(orderId, any()))
            .thenAnswer((_) async => const Success(null));
      },
      build: build,
      seed: () => loaded(),
      act: (bloc) =>
          bloc.add(const AdjustMaterials(orderId: orderId, materials: inputs)),
      expect: () => [
        loaded(isBusy: true),
        isA<OrderDetailMessage>()
            .having((m) => m.message, 'message', 'Materials updated'),
        loaded(),
        loaded(status: OrderStatus.packed),
      ],
      verify: (_) =>
          verify(() => adjustMaterialsUsed(orderId, inputs)).called(1),
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'failure: busy, error message, idle',
      setUp: () => when(() => adjustMaterialsUsed(orderId, any())).thenAnswer(
          (_) async => const Error(DatabaseFailure('write failed'))),
      build: build,
      seed: () => loaded(),
      act: (bloc) =>
          bloc.add(const AdjustMaterials(orderId: orderId, materials: inputs)),
      expect: () => [
        loaded(isBusy: true),
        isA<OrderDetailMessage>().having((m) => m.isError, 'isError', true),
        loaded(),
      ],
    );
  });

  group('DeleteOrderEvent', () {
    blocTest<OrderDetailBloc, OrderDetailState>(
      'success: busy then OrderDeleted',
      setUp: () => when(() => deleteOrder(orderId))
          .thenAnswer((_) async => const Success(null)),
      build: build,
      seed: () => loaded(),
      act: (bloc) => bloc.add(const DeleteOrderEvent(orderId)),
      expect: () => [loaded(isBusy: true), isA<OrderDeleted>()],
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'failure: busy, error message, idle',
      setUp: () => when(() => deleteOrder(orderId)).thenAnswer((_) async =>
          const Error(ValidationFailure('Shipped orders cannot be deleted'))),
      build: build,
      seed: () => loaded(status: OrderStatus.shipped),
      act: (bloc) => bloc.add(const DeleteOrderEvent(orderId)),
      expect: () => [
        loaded(status: OrderStatus.shipped, isBusy: true),
        isA<OrderDetailMessage>()
            .having(
                (m) => m.message, 'message', 'Shipped orders cannot be deleted')
            .having((m) => m.isError, 'isError', true),
        loaded(status: OrderStatus.shipped),
      ],
    );

    blocTest<OrderDetailBloc, OrderDetailState>(
      'from a non-loaded state emits OrderDeleted only',
      setUp: () => when(() => deleteOrder(orderId))
          .thenAnswer((_) async => const Success(null)),
      build: build,
      act: (bloc) => bloc.add(const DeleteOrderEvent(orderId)),
      expect: () => [isA<OrderDeleted>()],
    );
  });
}
