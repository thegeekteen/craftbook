import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_discount.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/entities/order_money.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/calculate_order_profit.dart';
import 'package:craftbook/features/orders/domain/usecases/create_order.dart';
import 'package:craftbook/features/orders/domain/usecases/preview_order.dart';
import 'package:craftbook/features/orders/domain/usecases/update_order.dart';
import 'package:craftbook/features/orders/presentation/bloc/new_order_bloc.dart';
import 'package:craftbook/features/orders/presentation/bloc/new_order_event.dart';
import 'package:craftbook/features/orders/presentation/bloc/new_order_state.dart';
import 'package:craftbook/features/order_fields/domain/entities/order_field_entry.dart';
import 'package:craftbook/features/settings/domain/entities/tax_settings.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockCreateOrder extends Mock implements CreateOrder {}

class _MockUpdateOrder extends Mock implements UpdateOrder {}

class _MockOrderRepository extends Mock implements OrderRepository {}

class _MockCalculateOrderProfit extends Mock implements CalculateOrderProfit {}

class _MockPreviewOrder extends Mock implements PreviewOrder {}

/// Discounts, tax and paid status on the new-order flow.
void main() {
  late _MockCreateOrder createOrder;
  late _MockUpdateOrder updateOrder;
  late _MockOrderRepository orders;
  late _MockCalculateOrderProfit calculate;
  late _MockPreviewOrder preview;
  var tax = const TaxSettings();

  final day = DateTime(2026, 9, 1);
  const loyal =
      OrderDiscount(label: 'Loyal', kind: DiscountKind.percent, value: 10);
  const vat = OrderTax(rate: 12, inclusive: true);

  SetCustomerDetails details({bool paidByDefault = true, int channel = 2}) =>
      SetCustomerDetails(
        customerName: 'Ana',
        channelId: channel,
        orderDate: day,
        shipByDate: day,
        channelPaidByDefault: paidByDefault,
      );
  const tulip =
      AddItem(productId: 10, productName: 'Tulip', quantity: 2, unitPrice: 500);

  OrderPreview previewFor(List<OrderDiscount> discounts, OrderTax? t) =>
      OrderPreview(
        money: OrderMoney.compute(
            itemsTotal: 1000, discounts: discounts, tax: t, materials: 100),
        reservations: const [],
      );

  setUpAll(() {
    registerFallbackValue(<OrderItemInput>[]);
    registerFallbackValue(<OrderDiscount>[]);
    registerFallbackValue(const OrderTerms());
    registerFallbackValue(DateTime(2000));
  });

  setUp(() {
    tax = const TaxSettings();
    createOrder = _MockCreateOrder();
    updateOrder = _MockUpdateOrder();
    orders = _MockOrderRepository();
    calculate = _MockCalculateOrderProfit();
    preview = _MockPreviewOrder();
    when(() => preview(
          items: any(named: 'items'),
          channelId: any(named: 'channelId'),
          excludeOrderId: any(named: 'excludeOrderId'),
          discounts: any(named: 'discounts'),
          tax: any(named: 'tax'),
        )).thenAnswer((inv) async => Success(previewFor(
          inv.namedArguments[#discounts] as List<OrderDiscount>,
          inv.namedArguments[#tax] as OrderTax?,
        )));
  });

  NewOrderBloc build() => NewOrderBloc(
        createOrder: createOrder,
        updateOrder: updateOrder,
        orderRepository: orders,
        calculateOrderProfit: calculate,
        previewOrder: preview,
        taxSettings: () => tax,
      );

  OrderTerms termsOf(NewOrderBloc b) =>
      (b.state as NewOrderDetailsFilled).terms;

  group('starting terms', () {
    test('a new order starts paid with no tax when tax is off', () async {
      final bloc = build()..add(details());
      await Future<void>.delayed(Duration.zero);
      expect(termsOf(bloc), const OrderTerms());
      expect((bloc.state as NewOrderDetailsFilled).availableTax, isNull);
      await bloc.close();
    });

    test('a new order gets the shop tax when it is on', () async {
      tax = const TaxSettings(enabled: true);
      final bloc = build()..add(details());
      await Future<void>.delayed(Duration.zero);
      expect(termsOf(bloc).tax, vat);
      await bloc.close();
    });

    test('tax off by default: offered but not on', () async {
      tax = const TaxSettings(enabled: true, onByDefault: false);
      final bloc = build()..add(details());
      await Future<void>.delayed(Duration.zero);
      expect(termsOf(bloc).tax, isNull);
      expect((bloc.state as NewOrderDetailsFilled).availableTax, vat);
      bloc.add(const SetOrderTaxEnabled(true));
      await Future<void>.delayed(Duration.zero);
      expect(termsOf(bloc).tax, vat);
      await bloc.close();
    });

    test('the channel decides paid until the user does', () async {
      final bloc = build()..add(details(paidByDefault: false));
      await Future<void>.delayed(Duration.zero);
      expect(termsOf(bloc).isPaid, isFalse);

      bloc.add(const SetOrderPaidStatus(true));
      bloc.add(details(paidByDefault: false, channel: 3));
      await Future<void>.delayed(Duration.zero);
      expect(termsOf(bloc).isPaid, isTrue,
          reason: 'the user set it, so a channel change leaves it');
      await bloc.close();
    });
  });

  blocTest<NewOrderBloc, NewOrderState>(
    'adding a discount on the review step recomputes the preview',
    build: build,
    act: (b) async {
      b
        ..add(details())
        ..add(tulip)
        ..add(RequestPreview());
      await Future<void>.delayed(Duration.zero);
      b.add(const AddDiscount(loyal));
    },
    verify: (b) {
      final s = b.state as NewOrderDetailsFilled;
      expect(s.terms.discounts, [loyal]);
      expect(s.preview!.money.discount, 100);
      expect(s.isPreviewing, isFalse);
    },
  );

  blocTest<NewOrderBloc, NewOrderState>(
    'removing a discount by position',
    build: build,
    act: (b) => b
      ..add(details())
      ..add(const AddDiscount(loyal))
      ..add(const AddDiscount(
          OrderDiscount(label: 'Promo', kind: DiscountKind.fixed, value: 50)))
      ..add(const RemoveDiscount(0))
      ..add(const RemoveDiscount(5)),
    verify: (b) => expect(termsOf(b).discounts.map((d) => d.label), ['Promo']),
  );

  blocTest<NewOrderBloc, NewOrderState>(
    'tax can be switched off and back on for one order',
    setUp: () => tax = const TaxSettings(enabled: true),
    build: build,
    act: (b) async {
      b
        ..add(details())
        ..add(const SetOrderTaxEnabled(false));
      await Future<void>.delayed(Duration.zero);
      expect(termsOf(b).tax, isNull);
      expect((b.state as NewOrderDetailsFilled).availableTax, vat,
          reason: 'the switch is still offered');
      b.add(const SetOrderTaxEnabled(true));
    },
    verify: (b) => expect(termsOf(b).tax, vat),
  );

  blocTest<NewOrderBloc, NewOrderState>(
    'saving a new order sends the worked-out terms',
    setUp: () {
      when(() => calculate(
            totalSales: any(named: 'totalSales'),
            totalMaterialCost: any(named: 'totalMaterialCost'),
            channelId: any(named: 'channelId'),
            shippingCost: any(named: 'shippingCost'),
            discounts: any(named: 'discounts'),
            tax: any(named: 'tax'),
          )).thenAnswer((_) async => Success(OrderMoney.compute(
            itemsTotal: 1000,
            discounts: const [loyal],
            tax: vat,
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
            terms: any(named: 'terms'),
            discountTotal: any(named: 'discountTotal'),
            taxAmount: any(named: 'taxAmount'),
          )).thenAnswer((_) async => const Success(9));
      tax = const TaxSettings(enabled: true);
    },
    build: build,
    act: (b) => b
      ..add(details(paidByDefault: false))
      ..add(tulip)
      ..add(const AddDiscount(loyal))
      ..add(SaveOrder()),
    verify: (_) {
      final captured = verify(() => createOrder(
            customerName: 'Ana',
            fieldValues: any(named: 'fieldValues'),
            note: any(named: 'note'),
            orderDate: day,
            shipByDate: day,
            channelId: 2,
            totalSales: 1000,
            channelFees: 0,
            shippingCost: 0,
            items: any(named: 'items'),
            terms: captureAny(named: 'terms'),
            discountTotal: 100,
            taxAmount: any(named: 'taxAmount', that: closeTo(96.43, 0.001)),
          )).captured.single as OrderTerms;
      expect(captured.isPaid, isFalse);
      expect(captured.tax, vat);
      expect(captured.discounts.single.amount, 100);
    },
  );

  group('editing', () {
    final existing = Order(
      id: 7,
      customerName: 'Ana',
      orderDate: day,
      shipByDate: day,
      status: OrderStatus.packed,
      channelId: 2,
      totalSales: 1000,
      totalMaterialCost: 0,
      channelFees: 0,
      shippingCost: 0,
      profit: 0,
      discountTotal: 100,
      taxRate: 5,
      taxInclusive: false,
      isPaid: false,
      createdAt: day,
      updatedAt: day,
    );

    setUp(() {
      when(() => orders.getOrderById(7))
          .thenAnswer((_) async => Success(existing));
      when(() => orders.getOrderItems(7))
          .thenAnswer((_) async => const Success([]));
      when(() => orders.getOrderFieldValues(7))
          .thenAnswer((_) async => const Success(<OrderFieldEntry>[]));
      when(() => orders.getOrderDiscounts(7))
          .thenAnswer((_) async => const Success([
                OrderDiscount(
                    label: 'Loyal',
                    kind: DiscountKind.percent,
                    value: 10,
                    amount: 100)
              ]));
    });

    blocTest<NewOrderBloc, NewOrderState>(
      'loads the order own discounts, tax and paid status',
      setUp: () => tax = const TaxSettings(enabled: true, rate: 12),
      build: build,
      act: (b) => b.add(const LoadExistingOrder(7)),
      verify: (b) {
        final s = b.state as NewOrderDetailsFilled;
        expect(s.terms.discounts.single.label, 'Loyal');
        expect(s.terms.tax, const OrderTax(rate: 5, inclusive: false),
            reason: 'its own rate, not the current setting');
        expect(s.terms.isPaid, isFalse);
      },
    );

    blocTest<NewOrderBloc, NewOrderState>(
      'a channel change does not touch an existing order paid status',
      build: build,
      act: (b) async {
        b.add(const LoadExistingOrder(7));
        await Future<void>.delayed(Duration.zero);
        b.add(details(paidByDefault: true));
      },
      verify: (b) => expect(termsOf(b).isPaid, isFalse),
    );
  });
}
