import 'package:flutter/material.dart' show ThemeMode;

import '../theme/palettes.dart';
import '../utils/currency_setting.dart';
import '../../features/order_fields/domain/entities/order_field.dart';
import '../../features/orders/domain/entities/order.dart';
import '../../features/settings/domain/entities/order_amount_shown.dart';
import '../../features/social_links/domain/entities/social_platform.dart';
import '../../features/stock/domain/entities/buy_list_item.dart';

/// One thing the fake data can prove it exercised: a name, the options it has,
/// and whether a seeded shop must cover all of them or just report them.
///
/// The option sets are read from the enums and constant lists the app itself
/// uses, so adding a status, a field type or a social platform makes
/// [CoverageDomain.gapsFor] report a gap until the factory covers it too.
class CoverageDomain {
  CoverageDomain(
    this.key,
    this.label, {
    required this.options,
    this.required = true,
  });

  final String key;

  /// Shown on the Debug → Database page.
  final String label;
  final Set<String> options;

  /// False for settings that hold one value per shop (currency, palette…),
  /// where a seed can only show what it picked.
  final bool required;

  /// Which options [counts] never used.
  List<String> gapsFor(Set<String> used) =>
      options.difference(used).toList()..sort();
}

/// Order status, straight from the entity.
final orderStatuses = CoverageDomain(
  'status',
  'Order status',
  options: OrderStatus.values.map((s) => s.name).toSet(),
);

final orderDates = CoverageDomain(
  'dates',
  'Order dates',
  options: {'overdue', 'due today', 'due later'},
);

final paidStates = CoverageDomain(
  'paid',
  'Paid',
  options: {'paid', 'unpaid'},
);

final taxShapes = CoverageDomain(
  'tax',
  'Tax',
  options: {'no tax', 'in price', 'added on top'},
);

final discountShapes = CoverageDomain(
  'discounts',
  'Discounts on an order',
  options: {'none', 'percent', 'fixed', 'several lines'},
);

final itemShapes = CoverageDomain(
  'items',
  'Order lines',
  options: {'single line', 'several lines', 'resell line', 'fractional line'},
);

final channelFeeShapes = CoverageDomain(
  'channel fees',
  'Channel fees',
  options: {'all three', 'commission only', 'flat fee only', 'nothing'},
);

final channelStates = CoverageDomain(
  'channel state',
  'Channels',
  options: {'open', 'paused'},
);

final presetShapes = CoverageDomain(
  'presets',
  'Discount presets',
  options: {'percent', 'fixed', 'used on an order', 'left unused'},
);

final fieldTypes = CoverageDomain(
  'field types',
  'Order field types',
  options: OrderFieldType.values.map((t) => t.name).toSet(),
);

final fieldStates = CoverageDomain(
  'field states',
  'Order fields',
  options: {'in use', 'archived', 'answer left blank'},
);

final productTypes = CoverageDomain(
  'product types',
  'Products',
  options: {'handmade', 'resell'},
);

final archiveStates = CoverageDomain(
  'archived',
  'Catalogue',
  options: {'live', 'archived'},
);

final bomShapes = CoverageDomain(
  'bom',
  'BOM lines',
  options: {'whole piece', 'fractional use', 'many products per piece'},
);

final stockStates = CoverageDomain(
  'stock',
  'Stock levels',
  options: {
    'empty',
    'at or below the alert level',
    'healthy',
    'promised more than held'
  },
);

/// `StockMovementType.waste` exists and is parsed back for display, but no
/// write path stores it, so a seeded shop can only cover these three.
final movementTypes = CoverageDomain(
  'movements',
  'Stock history',
  options: {'received', 'deducted', 'adjusted'},
);

final wasteShapes = CoverageDomain(
  'waste',
  'Used vs planned',
  options: {'more than planned', 'less than planned', 'exactly planned'},
);

final buyListKinds = CoverageDomain(
  'buy list',
  'Buy list',
  options: BuyListKind.values.map((k) => k.name).toSet(),
);

final profitShapes = CoverageDomain(
  'profit',
  'Profit',
  options: {'made money', 'broke even', 'lost money'},
);

final noteShapes = CoverageDomain(
  'notes',
  'Notes',
  options: {'plain text', 'formatted', 'pinned'},
);

final linkPlatforms = CoverageDomain(
  'platforms',
  'Social platforms',
  options: {
    ...SocialPlatform.presets.map((p) => p.key),
    SocialPlatform.customKey
  },
);

/// The extremes a fixed shop has to carry on purpose. A deterministic shop
/// only sees each of these once per seed, so they're required rather than
/// left to the dice: without them, one shop would exercise one name length
/// and one order width forever.
final hardCases = CoverageDomain(
  'hard cases',
  'Hard cases',
  options: {
    'long customer name',
    'many order lines',
    'order over ten thousand',
    'fractional quantity',
    'archived item still on past orders',
    'note with no line break',
  },
);

/// A shop's looks and money display: one value per run, so these are reported
/// rather than required.
final appearanceDomains = [
  CoverageDomain(
    'currency',
    'Currency',
    options: CurrencySetting.presets.map((c) => c.code).toSet(),
    required: false,
  ),
  CoverageDomain(
    'theme',
    'Dark mode',
    options: ThemeMode.values.map((m) => m.name).toSet(),
    required: false,
  ),
  CoverageDomain(
    'palette',
    'Colour scheme',
    options: AppPalette.values.map((p) => p.name).toSet(),
    required: false,
  ),
  CoverageDomain(
    'order amount',
    'Order cards show',
    options: OrderAmountShown.values.map((a) => a.name).toSet(),
    required: false,
  ),
];

/// Everything a seeded shop is measured against.
final coverageDomains = [
  orderStatuses,
  orderDates,
  paidStates,
  taxShapes,
  discountShapes,
  itemShapes,
  channelFeeShapes,
  channelStates,
  presetShapes,
  fieldTypes,
  fieldStates,
  productTypes,
  archiveStates,
  bomShapes,
  stockStates,
  movementTypes,
  wasteShapes,
  buyListKinds,
  profitShapes,
  noteShapes,
  linkPlatforms,
  hardCases,
  ...appearanceDomains,
];

/// How many times each option showed up in a database, and what is missing.
class CoverageReport {
  /// Domain key → option → count.
  final Map<String, Map<String, int>> counts;

  const CoverageReport(this.counts);

  CoverageDomain? domain(String key) {
    for (final d in coverageDomains) {
      if (d.key == key) return d;
    }
    return null;
  }

  Set<String> used(String key) => counts[key]?.keys.toSet() ?? {};

  /// `domain · option` for every option no required domain used. Empty when
  /// the seeded shop covered the whole app.
  List<String> get gaps {
    final missing = <String>[];
    for (final d in coverageDomains) {
      if (!d.required) continue;
      for (final option in d.gapsFor(used(d.key))) {
        missing.add('${d.label} · $option');
      }
    }
    return missing..sort();
  }

  bool get isComplete => gaps.isEmpty;

  /// Options of [key] that carry a count, in the order the contract lists
  /// them, so the page doesn't jump between seeds.
  List<MapEntry<String, int>> ranked(String key) {
    final d = domain(key);
    final got = counts[key] ?? const {};
    if (d == null) {
      return got.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    }
    return [
      for (final option in d.options)
        if (got[option] != null) MapEntry(option, got[option]!),
    ];
  }
}
