import 'package:craftbook/features/earnings/domain/entities/report_filter.dart';
import 'package:craftbook/features/earnings/presentation/widgets/report_filter_sheet.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Order order({
    int channel = 1,
    OrderStatus status = OrderStatus.shipped,
    bool paid = true,
    double discount = 0,
    double? taxRate,
    double sales = 1000,
  }) =>
      Order(
        id: 1,
        customerName: 'Ana',
        orderDate: DateTime(2026),
        shipByDate: DateTime(2026),
        status: status,
        channelId: channel,
        totalSales: sales,
        totalMaterialCost: 0,
        channelFees: 0,
        shippingCost: 0,
        profit: 0,
        discountTotal: discount,
        taxRate: taxRate,
        taxAmount: taxRate == null ? 0 : (sales - discount) * taxRate / 100,
        taxInclusive: false,
        isPaid: paid,
        createdAt: DateTime(2026),
        updatedAt: DateTime(2026),
      );

  test('no filter matches everything', () {
    expect(ReportFilter.none.isEmpty, isTrue);
    expect(ReportFilter.none.matches(order(), const {}), isTrue);
  });

  test('channel', () {
    const f = ReportFilter(channelIds: {2});
    expect(f.matches(order(channel: 2), const {}), isTrue);
    expect(f.matches(order(channel: 1), const {}), isFalse);
  });

  test('products: any of them', () {
    const f = ReportFilter(productIds: {5, 6});
    expect(f.matches(order(), {1, 6}), isTrue);
    expect(f.matches(order(), {1, 2}), isFalse);
  });

  test('status', () {
    const f = ReportFilter(statuses: {OrderStatus.packed});
    expect(f.matches(order(status: OrderStatus.packed), const {}), isTrue);
    expect(f.matches(order(), const {}), isFalse);
  });

  test('payment', () {
    const unpaid = ReportFilter(payment: PaymentFilter.unpaid);
    const paid = ReportFilter(payment: PaymentFilter.paid);
    expect(unpaid.matches(order(paid: false), const {}), isTrue);
    expect(unpaid.matches(order(), const {}), isFalse);
    expect(paid.matches(order(), const {}), isTrue);
  });

  test('discount and tax, with or without', () {
    const withDiscount = ReportFilter(discount: Presence.with_);
    const noTax = ReportFilter(tax: Presence.without);
    expect(withDiscount.matches(order(discount: 50), const {}), isTrue);
    expect(withDiscount.matches(order(), const {}), isFalse);
    expect(noTax.matches(order(), const {}), isTrue);
    expect(noTax.matches(order(taxRate: 12), const {}), isFalse);
  });

  test('order total is what the customer paid, bounds included', () {
    // 1000 − 100 discount + 12% on top = 1008.
    final o = order(discount: 100, taxRate: 12);
    expect(const ReportFilter(minTotal: 1008).matches(o, const {}), isTrue);
    expect(const ReportFilter(maxTotal: 1008).matches(o, const {}), isTrue);
    expect(const ReportFilter(maxTotal: 1000).matches(o, const {}), isFalse);
    expect(const ReportFilter(minTotal: 1009).matches(o, const {}), isFalse);
  });

  test('every condition must hold', () {
    const f = ReportFilter(channelIds: {1}, payment: PaymentFilter.unpaid);
    expect(f.activeCount, 2);
    expect(f.matches(order(paid: false), const {}), isTrue);
    expect(f.matches(order(channel: 2, paid: false), const {}), isFalse);
  });

  test('describeFilter names each part and how to drop it', () {
    const f = ReportFilter(
      channelIds: {1},
      productIds: {5, 6},
      payment: PaymentFilter.unpaid,
      minTotal: 500,
    );
    final parts = describeFilter(f,
        channelNames: const {1: 'Shopee'}, productNames: const {});
    expect(parts.map((p) => p.$1),
        ['Shopee', '2 products', 'Unpaid', '₱500 and up']);
    expect(parts.first.$2, f.copyWith(channelIds: const {}));
    expect(parts.last.$2.minTotal, isNull);
  });
}
