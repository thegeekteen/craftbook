import 'dart:math';

import '../utils/quantity.dart';
import 'catalogue_factory.dart';
import 'channel_factory.dart';
import 'discount_factory.dart';
import 'fake_random.dart';
import 'fake_shop.dart';
import 'note_factory.dart';
import 'order_factory.dart';
import 'order_field_factory.dart';
import 'settings_factory.dart';
import 'social_link_factory.dart';

/// Builds the fake shop.
///
/// The same [seed] always builds the same shop — same names, same quantities,
/// same dates — so two builds can be compared piece for piece and a number
/// that moves is a bug rather than the dice. [now] is the one thing that
/// differs, because "overdue" and "due today" have to mean something on the
/// day you seed.
///
/// Pass a different seed to see another shop. It is printed in the Debug row's
/// result so a oddity you spot can be handed to someone else to reproduce.
class FakeShopGenerator {
  /// The standard shop: what "Seed fake data" writes with no seed typed in.
  static const standardSeed = 20261007;

  /// The handle the social shortcuts point at.
  static const shopHandle = 'lorna.crafts';

  /// Units the app seeds itself, so a shop only adds the ones missing here.
  static const seededUnits = {
    'pc',
    'sheet',
    'm',
    'cm',
    'g',
    'kg',
    'ml',
    'pack'
  };

  FakeShopGenerator({int? seed, DateTime? now})
      : seed = seed ?? standardSeed,
        now = now ?? DateTime.now();

  final int seed;
  final DateTime now;

  FakeShop build() {
    final random = Random(seed);
    final today = DateTime(now.year, now.month, now.day, 10);

    final settings = buildSettings(random);
    final channels = buildChannels(random);
    final presets = buildDiscountPresets(random);
    final fields = buildOrderFields(random);
    final catalogue = buildCatalogue(random);
    final orders = buildOrders(
      random,
      today: today,
      catalogue: catalogue,
      channels: channels,
      presets: presets,
      fields: fields,
    );

    _StockPlanner(random, catalogue, orders).assign();

    return FakeShop(
      seed: seed,
      now: now,
      settings: settings,
      channels: channels,
      presets: presets,
      fields: fields,
      materials: catalogue.materials,
      products: catalogue.products,
      extraUnits: catalogue.extraUnits,
      orders: orders,
      notes: buildNotes(random),
      links: buildSocialLinks(random, shopHandle),
    );
  }
}

/// Works out what each shelf has to hold so the finished shop shows every state
/// the app treats differently.
///
/// The orders come first, because a promise is only interesting next to what
/// the shelf holds: the planner adds up what the orders will reserve and take,
/// then sets stock to land on the state it wants. That is why a seeded shop has
/// a buy list, an over-promised pip strip and a critical card that the buy list
/// never mentions, on every seed and with no luck involved.
class _StockPlanner {
  _StockPlanner(this.random, this.catalogue, this.orders);

  final Random random;
  final CataloguePlan catalogue;
  final List<OrderPlan> orders;

  /// Material ref → pieces promised by open orders, and pieces the packed and
  /// shipped orders really took.
  final _reserved = <int, double>{};
  final _used = <int, double>{};
  final _productReserved = <int, double>{};
  final _productUsed = <int, double>{};

  double _reservedFor(int ref) => _reserved[ref] ?? 0;
  double _usedFor(int ref) => _used[ref] ?? 0;

  void assign() {
    for (final order in orders) {
      if (order.reserves) {
        _add(_reserved, reservedPieces(catalogue, order));
        _add(_productReserved, reservedProducts(catalogue, order));
      }
      if (order.tookStock) {
        _add(_used, usedPieces(catalogue, order));
        _add(_productUsed, reservedProducts(catalogue, order));
      }
    }

    _assignMaterials();
    _assignProducts();
  }

  void _assignMaterials() {
    final recipeRefs = usedMaterialRefs(catalogue);
    final idle = [
      for (final m in catalogue.materials)
        if (!recipeRefs.contains(m.ref)) m.ref,
    ];
    if (idle.length < 2) {
      throw StateError(
          'The fake shop needs at least two materials no recipe uses, got '
          '${idle.length}. Give catalogue_factory more slack materials.');
    }

    // Nothing ordered it and nothing on the shelf.
    _set(idle[0], StockRole.empty, 0);
    // Exactly at the reorder level, so the buy list still asks for a pack.
    _set(idle[1], StockRole.exactlyAtAlert, _alertOf(idle[1]));

    // Archived while low, and used by orders that already went out: it must
    // stay off the buy list while its history keeps showing.
    final shipped = _candidates(
        (m) => !recipeRefs.contains(m.ref) ? false : _usedFor(m.ref) > 0);
    if (shipped.isNotEmpty) {
      final m = shipped.first;
      _set(
          m.ref, StockRole.archivedWhileLow, qty(max(0, _alertOf(m.ref) * 0.4)),
          archive: true);
    }

    // Promised more than held: the pip strip has to show a shortfall, and the
    // buy list has to ask for more than one pack. The material whose promise
    // is biggest next to its pack size is the one that can do both.
    final overPromised = _candidates((m) => _reservedFor(m.ref) >= 1);
    if (overPromised.isNotEmpty) {
      final m = overPromised.reduce((a, b) =>
          _reservedFor(a.ref) / a.packSize >= _reservedFor(b.ref) / b.packSize
              ? a
              : b);
      final reserved = _reservedFor(m.ref);
      _set(m.ref, StockRole.promisedMoreThanHeld,
          qty(max(0, min(_alertOf(m.ref), reserved - m.packSize))));
    }

    // Enough on the shelf to stay off the buy list, every piece of it promised.
    final critical = _candidates((m) =>
        m.role == StockRole.healthy &&
        _reservedFor(m.ref) > _alertOf(m.ref) + 1 &&
        _reservedFor(m.ref) >= 2);
    if (critical.isNotEmpty) {
      final m = critical.first;
      final margin = _reservedFor(m.ref) - _alertOf(m.ref);
      _set(m.ref, StockRole.criticalOffTheList,
          qty(_alertOf(m.ref) + margin / 2));
    }

    // Below the level with orders waiting on it, so the buy list can name
    // which product is stuck.
    final blocking = _candidates(
        (m) => m.role == StockRole.healthy && _reservedFor(m.ref) >= 1);
    if (blocking.isNotEmpty) {
      final m = blocking.first;
      _set(m.ref, StockRole.belowAlertWithOrders,
          qty(max(0, min(_alertOf(m.ref), _reservedFor(m.ref)) * 0.5)));
    }

    // Everything left is simply well stocked.
    for (final m in catalogue.materials) {
      if (_claimed.contains(m.ref)) continue;
      _set(m.ref, StockRole.healthy, _healthyTarget(m), allowFraction: true);
    }
  }

  /// Comfortably above the level, with enough free for what's already promised.
  double _healthyTarget(MaterialPlan m) => qty(max(_alertOf(m.ref), 1) +
      m.packSize * random.intBetween(1, 3) +
      _reservedFor(m.ref) * 1.5);

  double _alertOf(int ref) => catalogue.byRef(ref).alertLevel;

  /// Materials in ref order that [test] accepts and that no role has claimed.
  List<MaterialPlan> _candidates(bool Function(MaterialPlan) test) => [
        for (final m in catalogue.materials)
          if (!_claimed.contains(m.ref) && test(m)) m,
      ];

  final _claimed = <int>{};

  void _set(int ref, StockRole role, double target,
      {bool archive = false, bool allowFraction = false}) {
    final m = catalogue.byRef(ref);
    m.role = role;
    if (archive) m.archiveLater = true;
    var finalTarget = qty(max(0, target));
    // Stock you can count in halves is how a metre of wrap behaves on screen.
    if (allowFraction && finalTarget > 1 && _isMeasured(m.unit)) {
      finalTarget = qty(finalTarget + 0.5);
    }
    _settleMaterial(m, finalTarget);
    _claimed.add(ref);
  }

  /// Splits [target] into what the material starts with, what arrives as
  /// purchases and what a hand count fixes, so that after the fake orders have
  /// taken their share the shelf reads exactly [target].
  void _settleMaterial(MaterialPlan m, double target) {
    final preOrder = qty(target + _usedFor(m.ref));
    var packs = preOrder > m.packSize
        ? min(3, (preOrder / m.packSize).floorToDouble()).toInt()
        : 0;
    var counted = false;
    var start = qty(preOrder - packs * m.packSize);
    if (packs > 0 && start > m.packSize * 2 && random.oneIn(4)) {
      // Leave the last pack for the count to find, so the adjustment row in
      // its history has a real difference behind it.
      counted = true;
      start = qty(start - m.packSize);
    }
    if (start < 0) {
      packs = 0;
      counted = false;
      start = preOrder;
    }
    m.onHand = target;
    m.startOnHand = qty(max(0, start));
    m.receivedPacks = packs;
    m.receivedDaysAgo = random.intBetween(5, 70);
    m.countedByHand = counted;
  }

  void _assignProducts() {
    final resell = [
      for (final p in catalogue.products)
        if (p.isResell) p,
    ];
    if (resell.isEmpty) return;

    // Low with open orders on it, so it reaches the buy list on its own.
    final waiting = resell
        .where((p) => (_productReserved[p.ref] ?? 0) >= 1 && p.alertLevel > 0)
        .toList();
    if (waiting.isNotEmpty) {
      final p = waiting.first;
      p.role = StockRole.belowAlertWithOrders;
      _settleProduct(p,
          qty(max(0, min(p.alertLevel, (_productReserved[p.ref] ?? 0) * 0.5))));
    }

    // One resell item that is simply gone, so its card reads "empty" and the
    // buy list asks for a whole restock.
    final spare = resell
        .where((p) => p.role == StockRole.healthy && p != resell.first)
        .toList();
    if (spare.isNotEmpty) {
      spare.first.role = StockRole.empty;
      _settleProduct(spare.first, 0);
    }

    for (final p in resell) {
      if (p.role == StockRole.healthy) {
        _settleProduct(p, qty(p.alertLevel + random.intBetween(2, 9)));
      }
    }

    for (final p in catalogue.products) {
      if (p.isResell) continue;
      // A handmade product's shelf is the materials', not its own.
      p.onHand = 0;
      p.startOnHand = 0;
      p.receivedQuantity = 0;
    }
  }

  void _settleProduct(ProductPlan p, double target) {
    final preOrder = qty(target + (_productUsed[p.ref] ?? 0));
    var received = preOrder > 2 ? (preOrder / 2).floorToDouble() : 0.0;
    var counted = false;
    var start = qty(preOrder - received);
    if (received > 0 && start > 3 && random.oneIn(4)) {
      counted = true;
      start = qty(start - 1);
    }
    if (start < 0) {
      received = 0;
      counted = false;
      start = preOrder;
    }
    p.onHand = target;
    p.startOnHand = qty(max(0, start));
    p.receivedQuantity = received;
    // Bought in cheaper or dearer than the first batch, which is what the
    // weighted average on its card is supposed to survive.
    p.receivedPricePerUnit = qty(p.unitCost * random.intBetween(80, 118) / 100);
    p.receivedDaysAgo = random.intBetween(4, 60);
    p.countedByHand = counted;
  }

  bool _isMeasured(String unit) =>
      const {'m', 'cm', 'g', 'kg', 'ml'}.contains(unit);

  void _add(Map<int, double> total, Map<int, double> part) {
    for (final entry in part.entries) {
      total[entry.key] = qty((total[entry.key] ?? 0) + entry.value);
    }
  }
}
