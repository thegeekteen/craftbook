import 'dart:math';

import '../../features/orders/domain/entities/order_discount.dart';
import 'fake_random.dart';
import 'fake_shop.dart';
import 'fake_vocabulary.dart';

/// The discounts the shop gives often enough to have saved.
///
/// Both kinds, and at least one that no order ever copied: presets are copied
/// onto orders rather than referenced, so an unused one proves editing or
/// deleting it can't reach back into the books.
List<DiscountPresetPlan> buildDiscountPresets(Random random) {
  final labels = takeSome(random, discountLabels, 5, discountLabels.length);
  final plans = <DiscountPresetPlan>[];

  for (final (index, label) in labels.indexed) {
    final percent = index.isEven;
    plans.add(DiscountPresetPlan(
      ref: index + 1,
      label: label,
      kind: percent ? DiscountKind.percent : DiscountKind.fixed,
      value: percent
          ? random.intBetween(5, 20).toDouble()
          : random.money(30, 200).roundToDouble(),
      // One fixed preset is left alone on purpose.
      used: !(index == labels.length - 1 && !percent),
    ));
  }
  // Guarantee both kinds exist even when the draw came out lopsided.
  if (plans.every((p) => p.kind == DiscountKind.percent)) {
    plans.add(DiscountPresetPlan(
      ref: plans.length + 1,
      label: random.oneOf(discountLabels),
      kind: DiscountKind.fixed,
      value: 50,
    ));
  } else if (plans.every((p) => p.kind == DiscountKind.fixed)) {
    plans.add(DiscountPresetPlan(
      ref: plans.length + 1,
      label: random.oneOf(discountLabels),
      kind: DiscountKind.percent,
      value: 10,
    ));
  }
  return plans;
}
