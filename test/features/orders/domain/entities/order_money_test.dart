import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_discount.dart';
import 'package:craftbook/features/orders/domain/entities/order_money.dart';
import 'package:craftbook/features/products/domain/entities/channel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 10% commission, ₱5 fixed fee, ₱40 shipping.
  final shopee = Channel(
    name: 'Shopee',
    commissionRate: 10,
    transactionFeeRate: 0,
    flatFee: 5,
    shippingPaidByUs: 40,
    isActive: true,
    createdAt: DateTime(2026),
  );

  const tenPercent =
      OrderDiscount(label: 'Loyal', kind: DiscountKind.percent, value: 10);
  const fiftyOff =
      OrderDiscount(label: 'Promo', kind: DiscountKind.fixed, value: 50);

  test('no discount and no tax is the original formula', () {
    final m =
        OrderMoney.compute(itemsTotal: 1000, channel: shopee, materials: 300);
    expect(m.customerPays, 1000);
    expect(m.fees, 105);
    expect(m.shipping, 40);
    expect(m.profit, 1000 - 300 - 105 - 40);
  });

  test('a percent discount comes off the items total, fees after it', () {
    final m = OrderMoney.compute(
        itemsTotal: 1000,
        discounts: [tenPercent],
        channel: shopee,
        materials: 300);
    expect(m.discount, 100);
    expect(m.discounts.single.amount, 100);
    expect(m.customerPays, 900);
    expect(m.fees, 95); // 10% of 900 + 5
    expect(m.profit, 900 - 300 - 95 - 40);
  });

  test('discount lines stack and never take more than the total', () {
    final m = OrderMoney.compute(
      itemsTotal: 80,
      discounts: [fiftyOff, fiftyOff, tenPercent],
    );
    expect(m.discounts.map((d) => d.amount), [50, 30, 0]);
    expect(m.discount, 80);
    expect(m.customerPays, 0);
  });

  test('tax included in prices comes out of the sale', () {
    final m = OrderMoney.compute(
      itemsTotal: 1120,
      tax: const OrderTax(rate: 12, inclusive: true),
      materials: 200,
    );
    expect(m.tax, 120);
    expect(m.customerPays, 1120);
    expect(m.revenue, 1000);
    expect(m.includedTax, 120);
    expect(m.addedTax, 0);
    expect(m.profit, 800);
  });

  test('tax added on top is paid by the customer and passed on', () {
    final m = OrderMoney.compute(
      itemsTotal: 1000,
      tax: const OrderTax(rate: 12, inclusive: false),
      channel: shopee,
      materials: 200,
    );
    expect(m.tax, 120);
    expect(m.customerPays, 1120);
    expect(m.addedTax, 120);
    // Fees are on what the customer paid: 10% of 1120 + 5.
    expect(m.fees, closeTo(117, 0.001));
    expect(m.profit, closeTo(1000 - 200 - 117 - 40, 0.001));
  });

  test('tax is on the amount after discount', () {
    final m = OrderMoney.compute(
      itemsTotal: 1000,
      discounts: [tenPercent],
      tax: const OrderTax(rate: 10, inclusive: false),
    );
    expect(m.tax, 90);
    expect(m.customerPays, 990);
  });

  test('reads a saved order the same way it was computed', () {
    final computed = OrderMoney.compute(
      itemsTotal: 1000,
      discounts: [tenPercent],
      tax: const OrderTax(rate: 12, inclusive: true),
      channel: shopee,
      materials: 300,
    );
    final order = Order(
      customerName: 'A',
      orderDate: DateTime(2026),
      shipByDate: DateTime(2026),
      status: OrderStatus.packed,
      totalSales: 1000,
      totalMaterialCost: 300,
      channelFees: computed.fees,
      shippingCost: computed.shipping,
      profit: 0, // stale on purpose
      discountTotal: computed.discount,
      taxRate: 12,
      taxAmount: computed.tax,
      taxInclusive: true,
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    );
    expect(OrderMoney.fromOrder(order).profit, closeTo(computed.profit, 1e-9));
  });

  test('withMaterials changes only the material cost', () {
    final m = OrderMoney.compute(itemsTotal: 500, materials: 100);
    expect(m.withMaterials(150).profit, m.profit - 50);
  });
}
