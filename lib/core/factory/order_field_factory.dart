import 'dart:math';

import '../../features/order_fields/domain/entities/order_field.dart';
import 'fake_shop.dart';
import 'fake_vocabulary.dart';

/// The shop's own extra details, one of every type the app can ask for.
///
/// One is archived after the orders have answered it, which is what an
/// archived field is for: it stops being asked for and keeps showing on the
/// orders that used it. One is never answered, so the empty case is on screen
/// too.
List<OrderFieldPlan> buildOrderFields(Random random) {
  final picked = takeSome(random, fieldTemplates, 4, fieldTemplates.length);
  final plans = <OrderFieldPlan>[];

  for (final (index, template) in picked.indexed) {
    final (name, typeName, multiline) = template;
    plans.add(OrderFieldPlan(
      ref: index + 1,
      name: name,
      type: OrderFieldType.values.firstWhere((t) => t.name == typeName),
      isMultiline: multiline,
      options: choiceOptions[name] ?? const [],
      // A field the shop dropped but that stays on past orders.
      archiveLater: index == picked.length - 1 && picked.length > 4,
    ));
  }

  // Every type has to be asked for at least once, whatever the draw gave.
  for (final type in OrderFieldType.values) {
    if (plans.any((p) => p.type == type)) continue;
    final template = fieldTemplates.firstWhere((t) => t.$2 == type.name);
    plans.add(OrderFieldPlan(
      ref: plans.length + 1,
      name: template.$1,
      type: type,
      isMultiline: template.$3,
      options: choiceOptions[template.$1] ?? const [],
    ));
  }

  // One field always ends up retired. Orders answer every field, so the last
  // one has values behind it when it goes — which is the only reason an
  // archived field is interesting to look at.
  plans.last.archiveLater = true;
  return plans;
}
