import 'dart:math';

import '../../features/order_fields/domain/entities/order_field.dart';
import '../../features/order_fields/domain/order_field_codec.dart';
import '../../features/orders/domain/entities/order_discount.dart';
import '../utils/quantity.dart';
import 'catalogue_factory.dart';
import 'fake_random.dart';
import 'fake_shop.dart';
import 'fake_vocabulary.dart';

/// The orders, written as a table of things the app must be able to show.
///
/// Each one exists to prove something — a status, a fee shape, a tax mode, a
/// layout extreme — and its comment says which. After the table come the
/// ordinary past orders that give Reports something to aggregate.
List<OrderPlan> buildOrders(
  Random random, {
  required DateTime today,
  required CataloguePlan catalogue,
  required List<ChannelPlan> channels,
  required List<DiscountPresetPlan> presets,
  required List<OrderFieldPlan> fields,
}) {
  final plans = <OrderPlan>[];
  final handmade = [
    for (final p in catalogue.products)
      if (p.isHandmade) p,
  ];
  final resell = [
    for (final p in catalogue.products)
      if (p.isResell) p,
  ];

  ProductPlan named(String name) => catalogue.products.firstWhere(
        (p) => p.name == name,
        orElse: () => handmade.first,
      );

  final tulip = named('Crochet tulip bouquet');
  final bookmark = named('Pressed flower bookmark');
  final hamper = named('Custom gift hamper');
  final coaster = named('Beaded coaster set');
  final strap = handmade.lastWhere((p) => p != tulip && p != bookmark);
  final marketplace = channels.first; // commission + transaction + flat
  final flatFee = channels.length > 2 ? channels[2] : channels.first;
  final walkIn =
      channels.firstWhere((c) => !c.paidByDefault, orElse: () => channels.last);
  final paused = channels.last; // the channel the shop stopped using
  final percentPreset =
      presets.firstWhere((p) => p.kind == DiscountKind.percent && p.used);
  final fixedPreset =
      presets.firstWhere((p) => p.kind == DiscountKind.fixed && p.used);
  final shopTax =
      OrderTax(rate: 12, inclusive: random.oneOf(const [true, false]));

  ItemPlan line(ProductPlan product, [double quantity = 1, double? price]) =>
      ItemPlan(productRef: product.ref, quantity: quantity, price: price);

  void add({
    required String scenario,
    String? customer,
    required int channelRef,
    required List<ItemPlan> items,
    OrderLifecycle lifecycle = OrderLifecycle.pending,
    int placedDaysAgo = 0,
    int dueInDays = 2,
    int? packedDaysAgo,
    int? shippedDaysAgo,
    List<OrderDiscount> discounts = const [],
    OrderTax? tax,
    bool? paid,
    double shipping = 0,
    double? feesOverride,
    Map<int, String> answers = const {},
    String? note,
    Map<int, double> usedMore = const {},
    Map<int, double> usedLess = const {},
    bool breakEven = false,
  }) {
    // A break-even order needs a fee solved against the cost the app will
    // really store, so the seeder works that one out from the shelf price it
    // just wrote. Everything else charges what its channel takes.
    final fees = feesOverride;
    plans.add(OrderPlan(
      ref: plans.length + 1,
      scenario: scenario,
      customer: customer ?? random.oneOf(customerNames),
      channelRef: channelRef,
      items: items,
      lifecycle: lifecycle,
      placed: today.subtract(Duration(days: placedDaysAgo)),
      due: today.add(Duration(days: dueInDays)),
      packedAt: packedDaysAgo == null
          ? null
          : today.subtract(Duration(days: packedDaysAgo)),
      shippedAt: shippedDaysAgo == null
          ? null
          : today.subtract(Duration(days: shippedDaysAgo)),
      discounts: discounts,
      tax: tax,
      // A walk-in order starts out owing money, which is what the channel's
      // "paid when placed" switch is for.
      paid: paid ?? walkIn.ref != channelRef,
      shipping: shipping,
      feesOverride: fees,
      answers: answers,
      note: note,
      usedMore: usedMore,
      usedLess: usedLess,
      breakEven: breakEven,
    ));
  }

  // Every status, each in a date position the app colours differently:
  // overdue, due today, due later.
  add(
    scenario: 'pending, three weeks overdue, both discounts, every field type',
    customer: awkwardCustomerNames.first,
    channelRef: marketplace.ref,
    items: [line(tulip, 2), line(bookmark, 6)],
    placedDaysAgo: 24,
    dueInDays: -21,
    discounts: [percentPreset.asLine(), fixedPreset.asLine()],
    tax: shopTax,
    paid: false,
    shipping: 40,
    answers: _allAnswers(fields, random, today),
    note: 'Long-overdue anniversary piece, the client keeps asking.',
  );
  add(
    scenario: 'pending, overdue by a day, walk-in and unpaid',
    channelRef: walkIn.ref,
    items: [line(strap, 3)],
    placedDaysAgo: 3,
    dueInDays: -1,
    answers: {_oneField(fields, random).ref: 'Cash on pickup'},
  );
  add(
    scenario: 'pending, due today, flat-fee channel, tax the other way round',
    channelRef: flatFee.ref,
    items: [line(tulip), line(resell.first)],
    placedDaysAgo: 1,
    dueInDays: 0,
    tax: OrderTax(rate: shopTax.rate, inclusive: !shopTax.inclusive),
    paid: true,
  );
  add(
    scenario: 'pending, due next week, a fractional resell line',
    channelRef: marketplace.ref,
    items: [line(resell.first, 2.5), line(bookmark, 12)],
    placedDaysAgo: 0,
    dueInDays: 7,
    discounts: [fixedPreset.asLine()],
    paid: false,
    shipping: 30,
  );
  // A bulk order of the product that eats beads by the forty. Beads come in
  // packs of fifty, so this is what puts a line needing several packs on the
  // buy list rather than one pack for everything.
  add(
    scenario: 'a bulk order waiting on more than one pack of beads',
    channelRef: marketplace.ref,
    items: [line(coaster, 5), line(strap, 3)],
    placedDaysAgo: 2,
    dueInDays: 6,
    paid: true,
    shipping: 60,
  );
  add(
    scenario: 'packed today, paid, with waste both ways',
    channelRef: marketplace.ref,
    items: [line(tulip, 3), line(strap, 2), line(bookmark, 9)],
    lifecycle: OrderLifecycle.packed,
    placedDaysAgo: 4,
    dueInDays: 0,
    packedDaysAgo: 0,
    paid: true,
    shipping: 40,
    // Two extra stems of yarn is cutting waste; half a sheet less is a print
    // made on card left over from an earlier order.
    usedMore: {catalogue.bomMaterial(tulip, 0).materialRef: 2},
    usedLess: {catalogue.bomMaterial(bookmark, 0).materialRef: 0.5},
  );
  add(
    scenario: 'packed two days ago and still unpaid',
    channelRef: walkIn.ref,
    items: [line(bookmark, 9)],
    lifecycle: OrderLifecycle.packed,
    placedDaysAgo: 6,
    dueInDays: -2,
    packedDaysAgo: 2,
    paid: false,
  );
  add(
    scenario: 'shipped yesterday, discounted and taxed',
    channelRef: marketplace.ref,
    items: [line(hamper)],
    lifecycle: OrderLifecycle.shipped,
    placedDaysAgo: 5,
    dueInDays: -1,
    packedDaysAgo: 2,
    shippedDaysAgo: 1,
    discounts: [percentPreset.asLine()],
    tax: shopTax,
    paid: true,
    shipping: 60,
  );
  add(
    scenario: 'shipped on the paused channel, undiscounted and unpaid',
    channelRef: paused.ref,
    items: [
      line(strap, 2),
      line(resell.length > 1 ? resell[1] : resell.first),
    ],
    lifecycle: OrderLifecycle.shipped,
    placedDaysAgo: 9,
    dueInDays: -5,
    packedDaysAgo: 6,
    shippedDaysAgo: 5,
    paid: false,
  );
  add(
    scenario: 'cancelled while still to pack, so nothing left the shelf',
    channelRef: flatFee.ref,
    items: [line(tulip), line(bookmark, 3)],
    lifecycle: OrderLifecycle.cancelledWhilePending,
    placedDaysAgo: 7,
    dueInDays: 3,
    paid: false,
  );
  add(
    scenario: 'cancelled after packing, the pieces went back',
    channelRef: marketplace.ref,
    items: [line(strap, 4)],
    lifecycle: OrderLifecycle.cancelledAfterPacking,
    placedDaysAgo: 10,
    dueInDays: -2,
    packedDaysAgo: 3,
    paid: true,
  );
  add(
    scenario: 'cancelled after shipping, the parcel came back',
    channelRef: walkIn.ref,
    items: [line(hamper), line(resell.last)],
    lifecycle: OrderLifecycle.cancelledAfterShipping,
    placedDaysAgo: 14,
    dueInDays: -6,
    packedDaysAgo: 8,
    shippedDaysAgo: 7,
    paid: true,
  );
  add(
    scenario: 'restored after a cancel, reserving its pieces again',
    channelRef: marketplace.ref,
    items: [line(bookmark, 18)],
    lifecycle: OrderLifecycle.restoredAfterCancel,
    placedDaysAgo: 12,
    dueInDays: 1,
    paid: true,
    note: 'Back on, she changed her mind.',
  );

  // The layout and arithmetic extremes: one shop has to stretch every card.
  add(
    scenario: 'six lines at once, with a note that never breaks',
    channelRef: marketplace.ref,
    items: [
      line(tulip, 2),
      line(strap, 3),
      line(bookmark, 9),
      line(resell.first),
      line(resell.length > 2 ? resell[2] : resell.first, 2),
      line(handmade.last),
    ],
    placedDaysAgo: 2,
    dueInDays: 4,
    tax: shopTax,
    paid: true,
    shipping: 120,
    note: longSingleLineNote,
  );
  add(
    scenario: 'the order over ten thousand pesos',
    customer: awkwardCustomerNames[1 % awkwardCustomerNames.length],
    channelRef: marketplace.ref,
    items: [line(hamper), line(tulip, 4)],
    placedDaysAgo: 1,
    dueInDays: 14,
    paid: true,
    shipping: 350,
  );
  add(
    scenario: 'sold below cost, discounts capped at what the order is worth',
    channelRef: flatFee.ref,
    items: [
      line(hamper, 1, qty(catalogue.costOf(hamper) * 0.4)),
      line(bookmark, 4, 1),
    ],
    placedDaysAgo: 3,
    dueInDays: 0,
    discounts: const [
      // Percent and fixed together take more than the items are worth, which
      // is the cap: the customer pays nothing and the materials still cost.
      OrderDiscount(
          label: 'Everything on the house',
          kind: DiscountKind.percent,
          value: 100),
      OrderDiscount(
          label: 'And a little more', kind: DiscountKind.fixed, value: 500),
    ],
    tax: shopTax,
    paid: false,
  );
  add(
    scenario: 'sold at cost, with the fee solved so profit lands on nothing',
    channelRef: walkIn.ref,
    // A resold box, because its cost is one stored number: a six-peso margin
    // on two of them, which the fee then eats entirely. Not how a shop wants to
    // trade — just the one number every money screen has to agree on.
    items: [
      line(resell.first, 2, qty(catalogue.costOf(resell.first) * 1.06)),
    ],
    placedDaysAgo: 8,
    dueInDays: -4,
    breakEven: true,
    paid: false,
  );
  add(
    scenario: 'a field nobody answered',
    channelRef: marketplace.ref,
    items: [line(bookmark, 5)],
    placedDaysAgo: 1,
    dueInDays: 5,
  );

  // Ordinary trading, far enough back that every Reports period — including
  // last year — has something in it.
  for (final daysAgo in pastOrderDays) {
    final count = random.intBetween(1, 3);
    final channel = channels[random.intBetween(0, channels.length - 2)];
    add(
      scenario: 'past order, $daysAgo days ago',
      channelRef: channel.ref,
      items: [
        for (var i = 0; i < count; i++)
          line(
            random.oneOf([...handmade, ...resell]),
            random.oneOf(const [1.0, 1.0, 2.0, 3.0, 1.5]),
          ),
      ],
      lifecycle: OrderLifecycle.shipped,
      placedDaysAgo: daysAgo + 3,
      dueInDays: -daysAgo,
      packedDaysAgo: daysAgo + 1,
      shippedDaysAgo: daysAgo,
      discounts: random.oneIn(3) ? [percentPreset.asLine()] : const [],
      tax: random.oneIn(2) ? shopTax : null,
      paid: !random.oneIn(5),
      shipping: random.oneOf(const [0.0, 30.0, 40.0, 60.0]),
      answers: random.oneIn(3)
          ? {_oneField(fields, random).ref: random.oneOf(addresses)}
          : const {},
    );
  }

  return plans;
}

/// A plausible answer for every field type, so one order shows them all.
Map<int, String> _allAnswers(
    List<OrderFieldPlan> fields, Random random, DateTime today) {
  return {
    for (final field in fields)
      field.ref: switch (field.type) {
        OrderFieldType.text =>
          field.isMultiline ? random.oneOf(addresses) : 'Leave it at the gate',
        OrderFieldType.number =>
          OrderFieldCodec.encodeNumber('${random.intBetween(2, 24)}.50')!,
        OrderFieldType.date => OrderFieldCodec.encodeDate(
            today.add(Duration(days: random.intBetween(1, 30)))),
        OrderFieldType.choice => random.oneOf(field.options.isEmpty
            ? choiceOptions[field.name] ?? ['Kraft']
            : field.options),
      },
  };
}

/// A field picked at random, for the orders that answer one or none.
OrderFieldPlan _oneField(List<OrderFieldPlan> fields, Random random) =>
    fields.firstWhere((f) => !f.archiveLater, orElse: () => fields.first);
