import 'package:craftbook/core/factory/catalogue_factory.dart';
import 'package:craftbook/core/factory/fake_shop.dart';
import 'package:craftbook/core/factory/fake_shop_generator.dart';
import 'package:craftbook/core/utils/quantity.dart';
import 'package:flutter_test/flutter_test.dart';

/// A one-line description of everything a seed decides, so two builds can be
/// compared piece by piece.
String _fingerprint(FakeShop shop) => [
      'settings ${shop.settings.currencyCode} ${shop.settings.taxRate} '
          '${shop.settings.taxInclusive} ${shop.settings.themeMode} '
          '${shop.settings.palette} ${shop.settings.orderAmountShown}',
      for (final c in shop.channels) 'channel ${c.name} ${c.feesOn(1000)}',
      for (final m in shop.materials)
        'material ${m.name} ${m.unit} ${m.packSize} ${m.packPrice} '
            '${m.alertLevel} ${m.onHand} ${m.startOnHand} ${m.receivedPacks} '
            '${m.countedByHand} ${m.role.name}',
      for (final p in shop.products)
        'product ${p.name} ${p.sellPrice} ${p.onHand} ${p.startOnHand} '
            '${p.receivedQuantity} ${p.role.name}',
      for (final o in shop.orders)
        'order ${o.ref} ${o.customer} ${o.scenario} ${o.lifecycle.name} '
            '${o.placed.toIso8601String()} ${o.due.toIso8601String()} '
            '${o.items.map((i) => '${i.productRef}x${i.quantity}').join()}',
      for (final n in shop.notes) 'note ${n.title} ${n.pinned}',
      for (final l in shop.links) 'link ${l.platform} ${l.url}',
    ].join('\n');

CataloguePlan _catalogueOf(FakeShop shop) => CataloguePlan(
      materials: shop.materials,
      products: shop.products,
      extraUnits: shop.extraUnits,
    );

/// What the planner promised the shelf would read once the orders had taken
/// their share.
double _usedTotal(FakeShop shop, int materialRef) {
  final catalogue = _catalogueOf(shop);
  var total = 0.0;
  for (final order in shop.orders) {
    if (!order.tookStock) continue;
    total += usedPieces(catalogue, order)[materialRef] ?? 0;
  }
  return qty(total);
}

void main() {
  group('FakeShopGenerator', () {
    test('the same seed builds the same shop', () {
      final first =
          FakeShopGenerator(seed: 4242, now: DateTime(2026, 10, 7, 9)).build();
      final second =
          FakeShopGenerator(seed: 4242, now: DateTime(2026, 10, 7, 9)).build();
      expect(_fingerprint(first), _fingerprint(second));
    });

    test('another seed builds a different shop', () {
      final standard = FakeShopGenerator(now: DateTime(2026, 10, 7, 9)).build();
      final other =
          FakeShopGenerator(seed: 11, now: DateTime(2026, 10, 7, 9)).build();
      expect(_fingerprint(standard), isNot(_fingerprint(other)));
    });

    test('the standard shop is the same on every run', () {
      final first = FakeShopGenerator(seed: 77).build();
      final second = FakeShopGenerator(seed: 77).build();
      expect(first.channels.length, second.channels.length);
      expect(first.materials.map((m) => m.name).toList(),
          second.materials.map((m) => m.name).toList());
    });

    test('every recipe names a material the shop stocks', () {
      final shop = FakeShopGenerator(seed: 5).build();
      final refs = shop.materials.map((m) => m.ref).toSet();
      for (final product in shop.products) {
        for (final line in product.bom) {
          expect(refs, contains(line.materialRef),
              reason: '${product.name} uses a material that does not exist');
        }
      }
    });

    test('every order line names a product the shop sells', () {
      final shop = FakeShopGenerator(seed: 6).build();
      final refs = shop.products.map((p) => p.ref).toSet();
      final channels = shop.channels.map((c) => c.ref).toSet();
      for (final order in shop.orders) {
        expect(channels, contains(order.channelRef));
        for (final item in order.items) {
          expect(refs, contains(item.productRef),
              reason: '${order.scenario} sells a product that does not exist');
        }
      }
    });

    test('stock arithmetic lands every shelf on its planned number', () {
      final shop = FakeShopGenerator(seed: 9).build();
      for (final material in shop.materials) {
        final arrived = qty(
          material.startOnHand +
              material.receivedPacks * material.packSize +
              (material.countedByHand ? material.packSize : 0),
        );
        final expected = qty(material.onHand + _usedTotal(shop, material.ref));
        expect(arrived, expected,
            reason: '${material.name}: starts at ${material.startOnHand}, '
                'buys ${material.receivedPacks} x ${material.packSize}, '
                '${material.countedByHand ? 'and is' : 'is not'} counted, '
                'but ${material.onHand} was planned with '
                '${_usedTotal(shop, material.ref)} already gone');
      }
    });

    test('no quantity carries float noise', () {
      final shop = FakeShopGenerator(seed: 10).build();
      for (final material in shop.materials) {
        for (final value in [
          material.packSize,
          material.packPrice,
          material.alertLevel,
          material.onHand,
          material.startOnHand,
        ]) {
          expect(value, qty(value), reason: '${material.name} is $value');
        }
      }
      for (final order in shop.orders) {
        for (final item in order.items) {
          expect(item.quantity, qty(item.quantity));
        }
      }
    });

    test('every role the shop is supposed to show is on a material', () {
      final shop = FakeShopGenerator(seed: 11).build();
      final roles = shop.materials.map((m) => m.role).toSet();
      expect(
          roles,
          containsAll(<StockRole>{
            StockRole.empty,
            StockRole.exactlyAtAlert,
            StockRole.archivedWhileLow,
            StockRole.belowAlertWithOrders,
          }));
      expect(shop.products.any((p) => p.isResell && p.role == StockRole.empty),
          isTrue);
    });

    test('orders cover all four statuses and each date position', () {
      final shop = FakeShopGenerator(seed: 12).build();
      final today = DateTime(shop.now.year, shop.now.month, shop.now.day);
      expect(shop.orders.map((o) => o.lifecycle).toSet(), {
        ...OrderLifecycle.values,
      });
      final due = shop.orders.where((o) => !o.isCancelled).map((o) {
        if (o.due.isBefore(today)) return 'overdue';
        if (o.due.isAfter(today.add(const Duration(days: 1)))) return 'later';
        return 'today';
      }).toSet();
      expect(due, containsAll(<String>['overdue', 'today', 'later']));
    });

    test('one order answers every field type and one answers none', () {
      final shop = FakeShopGenerator(seed: 13).build();
      final answered = shop.orders.map((o) => o.answers.keys.toSet()).toList();
      expect(answered.any((a) => a.length == shop.fields.length), isTrue);
      expect(answered.any((a) => a.isEmpty), isTrue);
    });

    test('the shop reaches past a year back for the reports year view', () {
      final shop = FakeShopGenerator(seed: 14).build();
      final oldest = shop.orders
          .map((o) => o.shippedAt ?? o.packedAt ?? o.placed)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      expect(shop.now.difference(oldest).inDays, greaterThan(365),
          reason: 'a year view with nothing behind it looks like a broken '
              'query rather than a quiet shop');
    });
  });
}
