import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/order_fields/domain/entities/order_field.dart';
import 'package:craftbook/features/order_fields/domain/entities/order_field_entry.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/update_order.dart';
import 'package:craftbook/features/orders/domain/usecases/calculate_order_profit.dart';
import 'package:craftbook/features/orders/domain/usecases/create_order.dart';
import 'package:craftbook/features/orders/domain/usecases/preview_order.dart';
import 'package:craftbook/features/orders/presentation/bloc/new_order_bloc.dart';
import 'package:craftbook/features/orders/presentation/bloc/new_order_event.dart';
import 'package:craftbook/features/orders/presentation/bloc/new_order_state.dart';

class MockCreateOrder extends Mock implements CreateOrder {}

class MockUpdateOrder extends Mock implements UpdateOrder {}

class MockOrderRepository extends Mock implements OrderRepository {}

class MockCalculateOrderProfit extends Mock implements CalculateOrderProfit {}

class MockPreviewOrder extends Mock implements PreviewOrder {}

void main() {
  late MockCreateOrder createOrder;
  late MockCalculateOrderProfit calculateOrderProfit;
  late MockPreviewOrder previewOrder;
  late MockUpdateOrder updateOrder;
  late MockOrderRepository orderRepository;

  final orderDate = DateTime(2026, 9, 1);
  final shipBy = DateTime(2026, 9, 3);

  final details = SetCustomerDetails(
    customerName: 'Jessa Ramos',
    channelId: 2,
    orderDate: orderDate,
    shipByDate: shipBy,
    note: 'Gift wrap',
  );

  const tulip = AddItem(productId: 10, productName: 'Tulip', quantity: 2, unitPrice: 450);
  const strap = AddItem(productId: 11, productName: 'Strap', quantity: 1, unitPrice: 180);

  const preview = OrderPreview(
    sales: 1080,
    materialCost: 200,
    channelFees: 100,
    shippingCost: 40,
    reservations: [ReservationLine(name: 'Yarn', quantity: 6, available: 40)],
  );

  setUpAll(() {
    registerFallbackValue(DateTime(2000));
    registerFallbackValue(<OrderItemInput>[]);
  });

  setUp(() {
    createOrder = MockCreateOrder();
    calculateOrderProfit = MockCalculateOrderProfit();
    previewOrder = MockPreviewOrder();
    updateOrder = MockUpdateOrder();
    orderRepository = MockOrderRepository();
  });

  NewOrderBloc build() => NewOrderBloc(
        createOrder: createOrder,
        updateOrder: updateOrder,
        orderRepository: orderRepository,
        calculateOrderProfit: calculateOrderProfit,
        previewOrder: previewOrder,
      );

  NewOrderDetailsFilled filled({
    List<OrderItemInput> items = const [],
    OrderPreview? preview,
    bool isPreviewing = false,
    String? previewError,
    bool isSaving = false,
  }) =>
      NewOrderDetailsFilled(
        customerName: 'Jessa Ramos',
        channelId: 2,
        orderDate: orderDate,
        shipByDate: shipBy,
        note: 'Gift wrap',
        items: items,
        totalSales: items.fold(0.0, (s, i) => s + i.subtotal),
        preview: preview,
        isPreviewing: isPreviewing,
        previewError: previewError,
        isSaving: isSaving,
      );

  const tulipInput = OrderItemInput(productId: 10, productName: 'Tulip', quantity: 2, unitPrice: 450);
  const strapInput = OrderItemInput(productId: 11, productName: 'Strap', quantity: 1, unitPrice: 180);

  void stubCreate(Result<int> result) {
    when(() => calculateOrderProfit(
          totalSales: any(named: 'totalSales'),
          totalMaterialCost: any(named: 'totalMaterialCost'),
          channelId: any(named: 'channelId'),
          shippingCost: any(named: 'shippingCost'),
        )).thenAnswer((_) async => const Success(OrderProfitBreakdown(
          totalSales: 1080,
          totalMaterialCost: 0,
          channelFees: 100,
          shippingCost: 40,
          profit: 940,
        )));
    when(() => createOrder(
          customerName: any(named: 'customerName'),
          fieldValues: any(named: 'fieldValues'),
          note: any(named: 'note'),
          orderDate: any(named: 'orderDate'),
          shipByDate: any(named: 'shipByDate'),
          channelId: any(named: 'channelId'),
          totalSales: any(named: 'totalSales'),
          channelFees: any(named: 'channelFees'),
          shippingCost: any(named: 'shippingCost'),
          items: any(named: 'items'),
        )).thenAnswer((_) async => result);
  }

  test('initial state is NewOrderInitial', () {
    expect(build().state, isA<NewOrderInitial>());
  });

  blocTest<NewOrderBloc, NewOrderState>(
    'SetCustomerDetails emits DetailsFilled with the details',
    build: build,
    act: (bloc) => bloc.add(details),
    expect: () => [filled()],
  );

  blocTest<NewOrderBloc, NewOrderState>(
    'AddItem adds a new line and updates totalSales',
    build: build,
    act: (bloc) => bloc
      ..add(details)
      ..add(tulip)
      ..add(strap),
    skip: 1,
    expect: () => [
      filled(items: const [tulipInput]),
      filled(items: const [tulipInput, strapInput]),
    ],
    verify: (bloc) {
      expect((bloc.state as NewOrderDetailsFilled).totalSales, 1080);
      expect((bloc.state as NewOrderDetailsFilled).totalItemCount, 3);
    },
  );

  blocTest<NewOrderBloc, NewOrderState>(
    'AddItem for an existing product merges quantity',
    build: build,
    act: (bloc) => bloc
      ..add(details)
      ..add(tulip)
      ..add(const AddItem(productId: 10, productName: 'Tulip', quantity: 3, unitPrice: 999)),
    skip: 2,
    expect: () => [
      filled(items: const [
        OrderItemInput(productId: 10, productName: 'Tulip', quantity: 5, unitPrice: 450),
      ]),
    ],
  );

  blocTest<NewOrderBloc, NewOrderState>(
    'UpdateItemQuantity replaces the quantity',
    build: build,
    act: (bloc) => bloc
      ..add(details)
      ..add(tulip)
      ..add(const UpdateItemQuantity(productId: 10, quantity: 4)),
    skip: 2,
    expect: () => [
      filled(items: const [
        OrderItemInput(productId: 10, productName: 'Tulip', quantity: 4, unitPrice: 450),
      ]),
    ],
  );

  blocTest<NewOrderBloc, NewOrderState>(
    'UpdateItemQuantity for an unknown product leaves items unchanged',
    build: build,
    act: (bloc) => bloc
      ..add(details)
      ..add(tulip)
      ..add(const UpdateItemQuantity(productId: 99, quantity: 4)),
    skip: 1,
    // Same state re-emitted is de-duplicated, so only one emission shows.
    expect: () => [filled(items: const [tulipInput])],
  );

  blocTest<NewOrderBloc, NewOrderState>(
    'RemoveItem removes the line',
    build: build,
    act: (bloc) => bloc
      ..add(details)
      ..add(tulip)
      ..add(strap)
      ..add(const RemoveItem(10)),
    skip: 3,
    expect: () => [filled(items: const [strapInput])],
  );

  group('RequestPreview', () {
    blocTest<NewOrderBloc, NewOrderState>(
      'success emits previewing then state carrying the preview',
      setUp: () => when(() => previewOrder(
            items: any(named: 'items'),
            channelId: any(named: 'channelId'),
            excludeOrderId: any(named: 'excludeOrderId'),
          )).thenAnswer((_) async => const Success(preview)),
      build: build,
      act: (bloc) => bloc
        ..add(details)
        ..add(tulip)
        ..add(RequestPreview()),
      skip: 2,
      expect: () => [
        filled(items: const [tulipInput], isPreviewing: true),
        filled(items: const [tulipInput], preview: preview),
      ],
      verify: (_) => verify(() => previewOrder(items: [tulipInput], channelId: 2, excludeOrderId: null)).called(1),
    );

    blocTest<NewOrderBloc, NewOrderState>(
      'failure sets previewError and no preview',
      setUp: () => when(() => previewOrder(
            items: any(named: 'items'),
            channelId: any(named: 'channelId'),
            excludeOrderId: any(named: 'excludeOrderId'),
          )).thenAnswer((_) async => const Error(NotFoundFailure('Channel not found'))),
      build: build,
      act: (bloc) => bloc
        ..add(details)
        ..add(tulip)
        ..add(RequestPreview()),
      skip: 2,
      expect: () => [
        filled(items: const [tulipInput], isPreviewing: true),
        isA<NewOrderDetailsFilled>()
            .having((s) => s.isPreviewing, 'isPreviewing', false)
            .having((s) => s.preview, 'preview', isNull)
            .having((s) => s.previewError, 'previewError', 'Channel not found'),
      ],
    );

    blocTest<NewOrderBloc, NewOrderState>(
      'a failed save keeps the preview on the review step',
      setUp: () {
        when(() => previewOrder(
              items: any(named: 'items'),
              channelId: any(named: 'channelId'),
              excludeOrderId: any(named: 'excludeOrderId'),
            )).thenAnswer((_) async => const Success(preview));
        stubCreate(const Error(DatabaseFailure('disk full')));
      },
      build: build,
      act: (bloc) async {
        bloc
          ..add(details)
          ..add(tulip)
          ..add(RequestPreview());
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(SaveOrder());
      },
      skip: 5,
      expect: () => [
        const NewOrderError('disk full'),
        isA<NewOrderDetailsFilled>()
            .having((s) => s.preview, 'preview', preview)
            .having((s) => s.isSaving, 'isSaving', false),
      ],
    );

    blocTest<NewOrderBloc, NewOrderState>(
      'changing items after a preview clears it',
      setUp: () => when(() => previewOrder(
            items: any(named: 'items'),
            channelId: any(named: 'channelId'),
            excludeOrderId: any(named: 'excludeOrderId'),
          )).thenAnswer((_) async => const Success(preview)),
      build: build,
      act: (bloc) async {
        bloc
          ..add(details)
          ..add(tulip)
          ..add(RequestPreview());
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(strap);
      },
      skip: 4,
      expect: () => [filled(items: const [tulipInput, strapInput])],
    );
  });

  group('SaveOrder', () {
    blocTest<NewOrderBloc, NewOrderState>(
      'success emits saving then NewOrderSaved with the new id',
      setUp: () => stubCreate(const Success(42)),
      build: build,
      act: (bloc) => bloc
        ..add(details)
        ..add(tulip)
        ..add(strap)
        ..add(SaveOrder()),
      skip: 3,
      expect: () => [
        filled(items: const [tulipInput, strapInput], isSaving: true),
        const NewOrderSaved(42),
      ],
      verify: (_) {
        verify(() => calculateOrderProfit(
              totalSales: 1080,
              totalMaterialCost: 0,
              channelId: 2,
              shippingCost: 0,
            )).called(1);
        verify(() => createOrder(
              customerName: 'Jessa Ramos',
              note: 'Gift wrap',
              orderDate: orderDate,
              shipByDate: shipBy,
              channelId: 2,
              totalSales: 1080,
              channelFees: 100,
              shippingCost: 40,
              items: [tulipInput, strapInput],
            )).called(1);
      },
    );

    blocTest<NewOrderBloc, NewOrderState>(
      'passes the form\'s field values to CreateOrder',
      setUp: () => stubCreate(const Success(42)),
      build: build,
      act: (bloc) => bloc
        ..add(SetCustomerDetails(
          customerName: 'Jessa Ramos',
          fieldValues: const {1: 'Cebu City', 3: 'Floral'},
          channelId: 2,
          orderDate: orderDate,
          shipByDate: shipBy,
        ))
        ..add(tulip)
        ..add(SaveOrder()),
      verify: (_) => verify(() => createOrder(
            customerName: 'Jessa Ramos',
            fieldValues: const {1: 'Cebu City', 3: 'Floral'},
            note: any(named: 'note'),
            orderDate: any(named: 'orderDate'),
            shipByDate: any(named: 'shipByDate'),
            channelId: any(named: 'channelId'),
            totalSales: any(named: 'totalSales'),
            channelFees: any(named: 'channelFees'),
            shippingCost: any(named: 'shippingCost'),
            items: any(named: 'items'),
          )).called(1),
    );

    blocTest<NewOrderBloc, NewOrderState>(
      'SetCustomerDetails carries field values into the state',
      build: build,
      act: (bloc) => bloc.add(SetCustomerDetails(
        customerName: 'Jessa Ramos',
        fieldValues: const {1: 'Cebu City'},
        channelId: 2,
        orderDate: orderDate,
        shipByDate: shipBy,
      )),
      expect: () => [
        isA<NewOrderDetailsFilled>().having((s) => s.fieldValues, 'fieldValues', {1: 'Cebu City'}),
      ],
    );

    blocTest<NewOrderBloc, NewOrderState>(
      'failure emits NewOrderError then returns to DetailsFilled',
      setUp: () => stubCreate(const Error(ValidationFailure('At least one item is required'))),
      build: build,
      act: (bloc) => bloc
        ..add(details)
        ..add(SaveOrder()),
      skip: 1,
      expect: () => [
        filled(isSaving: true),
        const NewOrderError('At least one item is required'),
        filled(),
      ],
    );

    blocTest<NewOrderBloc, NewOrderState>(
      'profit lookup failure stops the save and shows the error',
      setUp: () {
        stubCreate(const Success(5));
        when(() => calculateOrderProfit(
              totalSales: any(named: 'totalSales'),
              totalMaterialCost: any(named: 'totalMaterialCost'),
              channelId: any(named: 'channelId'),
              shippingCost: any(named: 'shippingCost'),
            )).thenAnswer((_) async => const Error(NotFoundFailure('Channel not found')));
      },
      build: build,
      act: (bloc) => bloc
        ..add(details)
        ..add(tulip)
        ..add(SaveOrder()),
      skip: 3,
      expect: () => [
        const NewOrderError('Channel not found'),
        isA<NewOrderDetailsFilled>().having((s) => s.isSaving, 'isSaving', false),
      ],
      verify: (_) => verifyNever(() => createOrder(
            customerName: any(named: 'customerName'),
            fieldValues: any(named: 'fieldValues'),
            note: any(named: 'note'),
            orderDate: any(named: 'orderDate'),
            shipByDate: any(named: 'shipByDate'),
            channelId: any(named: 'channelId'),
            totalSales: any(named: 'totalSales'),
            channelFees: any(named: 'channelFees'),
            shippingCost: any(named: 'shippingCost'),
            items: any(named: 'items'),
          )),
    );
  });

  blocTest<NewOrderBloc, NewOrderState>(
    'ResetOrder clears everything back to NewOrderInitial',
    build: build,
    act: (bloc) async {
      bloc
        ..add(details)
        ..add(tulip)
        ..add(ResetOrder());
      await Future<void>.delayed(Duration.zero);
      // After reset, the next change starts from empty details.
      bloc.add(strap);
    },
    skip: 2,
    expect: () => [
      isA<NewOrderInitial>(),
      isA<NewOrderDetailsFilled>()
          .having((s) => s.customerName, 'customerName', '')
          .having((s) => s.channelId, 'channelId', 0)
          .having((s) => s.note, 'note', isNull)
          .having((s) => s.items, 'items', const [strapInput]),
    ],
  );
  group('editing an existing order', () {
    final existing = Order(
      id: 7,
      customerName: 'Jessa Ramos',
      note: 'Gift wrap',
      orderDate: orderDate,
      shipByDate: shipBy,
      status: OrderStatus.pending,
      channelId: 2,
      totalSales: 1080,
      totalMaterialCost: 200,
      channelFees: 100,
      shippingCost: 40,
      profit: 740,
      createdAt: orderDate,
      updatedAt: orderDate,
    );
    final lines = [
      const OrderItem(
        orderId: 7,
        productId: 10,
        productName: 'Tulip',
        quantity: 2,
        unitPrice: 450,
        subtotal: 900,
      ),
    ];

    const address = OrderField(id: 1, name: 'Address', type: OrderFieldType.text);
    const card = OrderField(id: 2, name: 'Card', type: OrderFieldType.text, isArchived: true);

    void stubLoad({
      Order? order,
      Result<List<OrderItem>>? items,
      List<OrderFieldEntry> fields = const [],
    }) {
      when(() => orderRepository.getOrderById(7)).thenAnswer((_) async => Success(order ?? existing));
      when(() => orderRepository.getOrderItems(7)).thenAnswer((_) async => items ?? Success(lines));
      when(() => orderRepository.getOrderFieldValues(7)).thenAnswer((_) async => Success(fields));
    }

    void stubUpdate() => when(() => updateOrder(
          orderId: any(named: 'orderId'),
          customerName: any(named: 'customerName'),
          fieldValues: any(named: 'fieldValues'),
          note: any(named: 'note'),
          orderDate: any(named: 'orderDate'),
          shipByDate: any(named: 'shipByDate'),
          channelId: any(named: 'channelId'),
          items: any(named: 'items'),
        )).thenAnswer((_) async => const Success(null));

    blocTest<NewOrderBloc, NewOrderState>(
      'LoadExistingOrder fills field values, archived ones included',
      setUp: () => stubLoad(fields: const [
        OrderFieldEntry(field: address, value: 'Cebu City'),
        OrderFieldEntry(field: card, value: 'Happy birthday'),
      ]),
      build: build,
      act: (bloc) => bloc.add(const LoadExistingOrder(7)),
      expect: () => [
        isA<NewOrderDetailsFilled>()
            .having((s) => s.fieldValues, 'fieldValues', {1: 'Cebu City', 2: 'Happy birthday'}),
      ],
    );

    blocTest<NewOrderBloc, NewOrderState>(
      'LoadExistingOrder emits an error when field values fail to load',
      setUp: () {
        stubLoad();
        when(() => orderRepository.getOrderFieldValues(7))
            .thenAnswer((_) async => const Error(DatabaseFailure('disk')));
      },
      build: build,
      act: (bloc) => bloc.add(const LoadExistingOrder(7)),
      expect: () => [const NewOrderError('disk')],
    );

    blocTest<NewOrderBloc, NewOrderState>(
      'saving keeps archived values the form does not show',
      setUp: () {
        stubLoad(fields: const [
          OrderFieldEntry(field: address, value: 'Cebu City'),
          OrderFieldEntry(field: card, value: 'Happy birthday'),
        ]);
        stubUpdate();
      },
      build: build,
      act: (bloc) async {
        bloc.add(const LoadExistingOrder(7));
        await Future<void>.delayed(Duration.zero);
        // The form only knows the active Address field; it was cleared.
        bloc.add(SetCustomerDetails(
          customerName: 'Jessa Ramos',
          fieldValues: const {1: ''},
          channelId: 2,
          orderDate: orderDate,
          shipByDate: shipBy,
          note: 'Gift wrap',
        ));
        bloc.add(SaveOrder());
      },
      verify: (_) => verify(() => updateOrder(
            orderId: 7,
            customerName: 'Jessa Ramos',
            fieldValues: const {1: '', 2: 'Happy birthday'},
            note: 'Gift wrap',
            orderDate: orderDate,
            shipByDate: shipBy,
            channelId: 2,
            items: any(named: 'items'),
          )).called(1),
    );

    blocTest<NewOrderBloc, NewOrderState>(
      'LoadExistingOrder fills the form from the order and its items',
      setUp: stubLoad,
      build: build,
      act: (bloc) => bloc.add(const LoadExistingOrder(7)),
      expect: () => [
        isA<NewOrderDetailsFilled>()
            .having((s) => s.editingOrderId, 'editingOrderId', 7)
            .having((s) => s.editingStatus, 'editingStatus', OrderStatus.pending)
            .having((s) => s.customerName, 'customerName', 'Jessa Ramos')
            .having((s) => s.channelId, 'channelId', 2)
            .having((s) => s.note, 'note', 'Gift wrap')
            .having((s) => s.items, 'items', const [
              OrderItemInput(productId: 10, productName: 'Tulip', quantity: 2, unitPrice: 450),
            ])
            .having((s) => s.totalSales, 'totalSales', 900),
      ],
    );

    blocTest<NewOrderBloc, NewOrderState>(
      'LoadExistingOrder emits an error when the order is missing',
      setUp: () {
        when(() => orderRepository.getOrderById(7)).thenAnswer((_) async => const Success(null));
        when(() => orderRepository.getOrderItems(7)).thenAnswer((_) async => const Success([]));
        when(() => orderRepository.getOrderFieldValues(7)).thenAnswer((_) async => const Success([]));
      },
      build: build,
      act: (bloc) => bloc.add(const LoadExistingOrder(7)),
      expect: () => [const NewOrderError('Order not found')],
    );

    blocTest<NewOrderBloc, NewOrderState>(
      'SaveOrder while editing calls UpdateOrder, not CreateOrder',
      setUp: () {
        stubLoad();
        when(() => updateOrder(
              orderId: any(named: 'orderId'),
              customerName: any(named: 'customerName'),
              fieldValues: any(named: 'fieldValues'),
              note: any(named: 'note'),
              orderDate: any(named: 'orderDate'),
              shipByDate: any(named: 'shipByDate'),
              channelId: any(named: 'channelId'),
              items: any(named: 'items'),
            )).thenAnswer((_) async => const Success(null));
      },
      build: build,
      act: (bloc) async {
        bloc.add(const LoadExistingOrder(7));
        await Future<void>.delayed(Duration.zero);
        bloc.add(SaveOrder());
      },
      skip: 2,
      expect: () => [const NewOrderSaved(7)],
      verify: (_) {
        verify(() => updateOrder(
              orderId: 7,
              customerName: 'Jessa Ramos',
              fieldValues: const {},
              note: 'Gift wrap',
              orderDate: orderDate,
              shipByDate: shipBy,
              channelId: 2,
              items: const [
                OrderItemInput(productId: 10, productName: 'Tulip', quantity: 2, unitPrice: 450),
              ],
            )).called(1);
        verifyNever(() => createOrder(
              customerName: any(named: 'customerName'),
              fieldValues: any(named: 'fieldValues'),
              note: any(named: 'note'),
              orderDate: any(named: 'orderDate'),
              shipByDate: any(named: 'shipByDate'),
              channelId: any(named: 'channelId'),
              totalSales: any(named: 'totalSales'),
              channelFees: any(named: 'channelFees'),
              shippingCost: any(named: 'shippingCost'),
              items: any(named: 'items'),
            ));
      },
    );

    blocTest<NewOrderBloc, NewOrderState>(
      'a failed update returns to the form still in edit mode',
      setUp: () {
        stubLoad();
        when(() => updateOrder(
              orderId: any(named: 'orderId'),
              customerName: any(named: 'customerName'),
              fieldValues: any(named: 'fieldValues'),
              note: any(named: 'note'),
              orderDate: any(named: 'orderDate'),
              shipByDate: any(named: 'shipByDate'),
              channelId: any(named: 'channelId'),
              items: any(named: 'items'),
            )).thenAnswer((_) async => const Error(ValidationFailure('Customer name is required')));
      },
      build: build,
      act: (bloc) async {
        bloc.add(const LoadExistingOrder(7));
        await Future<void>.delayed(Duration.zero);
        bloc.add(SaveOrder());
      },
      skip: 1,
      expect: () => [
        isA<NewOrderDetailsFilled>().having((s) => s.isSaving, 'isSaving', true),
        const NewOrderError('Customer name is required'),
        isA<NewOrderDetailsFilled>()
            .having((s) => s.isSaving, 'isSaving', false)
            .having((s) => s.editingOrderId, 'editingOrderId', 7),
      ],
    );

    blocTest<NewOrderBloc, NewOrderState>(
      'preview while editing excludes the order\'s own reservation',
      setUp: () {
        stubLoad();
        when(() => previewOrder(
              items: any(named: 'items'),
              channelId: any(named: 'channelId'),
              excludeOrderId: any(named: 'excludeOrderId'),
            )).thenAnswer((_) async => const Success(preview));
      },
      build: build,
      act: (bloc) async {
        bloc.add(const LoadExistingOrder(7));
        await Future<void>.delayed(Duration.zero);
        bloc.add(RequestPreview());
      },
      verify: (_) => verify(() => previewOrder(
            items: any(named: 'items'),
            channelId: 2,
            excludeOrderId: 7,
          )).called(1),
    );
  });
}
