import '../utils/quantity.dart';
import '../../features/order_fields/domain/entities/order_field.dart';
import '../../features/orders/domain/entities/order_discount.dart';

/// What a fake item's stock should end up as, once every order has reserved
/// and packed its share.
///
/// These are the states the app treats differently, so the shop must always
/// contain one of each rather than leave it to the dice.
enum StockRole {
  /// Nothing on the shelf and nothing promised. Reports the buy list needs at
  /// least one pack.
  empty,

  /// On hand below the alert level, with open orders waiting on it.
  belowAlertWithOrders,

  /// On hand exactly at the alert level with nothing promised, so the buy
  /// list has to ask for a pack even though nothing is missing.
  exactlyAtAlert,

  /// Comfortably above the alert level.
  healthy,

  /// More promised than on hand: the pips show a shortfall.
  promisedMoreThanHeld,

  /// Enough on hand to stay off the buy list, but every piece is promised —
  /// so the card is critical while the buy list never mentions it.
  criticalOffTheList,

  /// Below the alert level but archived, so it must not reach the buy list.
  archivedWhileLow,
}

/// How an order has travelled. Everything in between is done through the app's
/// own use cases, so the shelf moves the way it does for a shop owner.
enum OrderLifecycle {
  pending,
  packed,
  shipped,
  cancelledWhilePending,
  cancelledAfterPacking,
  cancelledAfterShipping,
  restoredAfterCancel,
}

/// A material the shop will stock. [onHand] is filled in once the generator
/// knows how much the orders will take.
class MaterialPlan {
  final int ref;
  final String name;

  /// Unit label, resolved to the shop's unit id while seeding.
  final String unit;
  final double packSize;
  final double packPrice;
  final double alertLevel;
  final String? supplier;

  /// The state this material's shelf is meant to end up in. The planner sets it
  /// after the orders are known, because a promise only means something next
  /// to what the shelf holds.
  StockRole role;

  /// Archived after the shop stopped using it, while orders still name it.
  bool archiveLater;

  /// Whole packs received after the material is created, so its history has a
  /// purchase in it. The rest of [onHand] is what it started with.
  int receivedPacks;
  int receivedDaysAgo;

  /// Counted by hand after everything else, which logs an adjustment.
  bool countedByHand;

  /// What the shelf should read once every fake order has run through it.
  double onHand;

  /// What to create the material with. The rest arrives as purchases and a
  /// hand count, so the shelf ends on [onHand] however the orders go.
  double startOnHand;

  MaterialPlan({
    required this.ref,
    required this.name,
    required this.unit,
    required this.packSize,
    required this.packPrice,
    required this.alertLevel,
    required this.role,
    this.supplier,
    this.archiveLater = false,
    this.receivedPacks = 0,
    this.receivedDaysAgo = 0,
    this.countedByHand = false,
    this.onHand = 0,
    this.startOnHand = 0,
  });

  /// Pre-rounded to the precision costs are kept at, so the shop's own guess at
  /// what an order will cost and what the app works out afterwards agree.
  double get unitCost => qty(packPrice / packSize);

  /// What [pieces] products of this material cost.
  double costFor(double pieces) => qty(pieces * unitCost);
}

/// One BOM line: [uses] of the material make [makes] products.
class BomPlan {
  final int materialRef;
  final double uses;
  final double makes;

  const BomPlan({
    required this.materialRef,
    required this.uses,
    this.makes = 1,
  });

  /// Exactly what the app would reserve for [products] pieces.
  double piecesFor(double products) => qty(uses * products / makes);
}

class ProductPlan {
  final int ref;
  final String name;
  final String unit;
  final double sellPrice;
  final List<BomPlan> bom;

  /// A bought-in item with its own stock and no recipe.
  final bool isResell;

  /// Weighted-average cost the app keeps for resell products.
  final double unitCost;
  final double alertLevel;

  /// The state this product's own shelf ends up in. Unused for a handmade
  /// product, whose stock is its materials'.
  StockRole role;
  final bool wantPhoto;

  /// Archived after the shop stopped making it, while orders still name it.
  bool archiveLater;

  /// What the shelf holds once the fake orders have run through it. Always
  /// zero for a handmade product, whose stock is the materials' own.
  double onHand;

  /// What to create the product with; the rest arrives as a purchase and
  /// possibly a hand count, so the shelf lands on [onHand].
  double startOnHand;
  double receivedQuantity;

  /// What the restock was paid for, which is usually not what the first one
  /// cost — that difference is what the weighted average has to survive.
  double receivedPricePerUnit;
  int receivedDaysAgo;
  bool countedByHand;

  ProductPlan({
    required this.ref,
    required this.name,
    required this.unit,
    required this.sellPrice,
    required this.role,
    this.bom = const [],
    this.isResell = false,
    this.unitCost = 0,
    this.alertLevel = 0,
    this.wantPhoto = false,
    this.archiveLater = false,
    this.onHand = 0,
    this.startOnHand = 0,
    this.receivedQuantity = 0,
    this.receivedPricePerUnit = 0,
    this.receivedDaysAgo = 0,
    this.countedByHand = false,
  });

  bool get isHandmade => !isResell;
}

class ChannelPlan {
  final int ref;
  final String name;
  final double commissionRate;
  final double transactionFeeRate;
  final double flatFee;
  final double shippingPaidByUs;
  final bool paidByDefault;

  /// False once the shop stops selling there; past orders still name it.
  final bool isActive;

  const ChannelPlan({
    required this.ref,
    required this.name,
    this.commissionRate = 0,
    this.transactionFeeRate = 0,
    this.flatFee = 0,
    this.shippingPaidByUs = 0,
    this.paidByDefault = true,
    this.isActive = true,
  });

  /// The fee shape the app's own [Channel.calculateFees] would charge.
  double feesOn(double whatTheCustomerPays) {
    final commission = whatTheCustomerPays * (commissionRate / 100);
    final transaction = whatTheCustomerPays * (transactionFeeRate / 100);
    final total = commission + transaction + flatFee;
    return (total * 100).roundToDouble() / 100;
  }
}

class DiscountPresetPlan {
  final int ref;
  final String label;
  final DiscountKind kind;
  final double value;

  /// Whether any fake order copied it. An unused preset proves deleting or
  /// editing one never touches the orders that did use it.
  final bool used;

  const DiscountPresetPlan({
    required this.ref,
    required this.label,
    required this.kind,
    required this.value,
    this.used = true,
  });

  OrderDiscount asLine() =>
      OrderDiscount(label: label, kind: kind, value: value);
}

class OrderFieldPlan {
  final int ref;
  final String name;
  final OrderFieldType type;
  final bool isMultiline;
  final List<String> options;

  /// Archived after orders have answered it, so its value keeps showing.
  bool archiveLater;

  OrderFieldPlan({
    required this.ref,
    required this.name,
    required this.type,
    this.isMultiline = false,
    this.options = const [],
    this.archiveLater = false,
  });
}

class ItemPlan {
  final int productRef;
  final double quantity;

  /// Overrides the product's own price, which is how a sale ends up at a loss.
  final double? price;

  const ItemPlan({
    required this.productRef,
    required this.quantity,
    this.price,
  });
}

class OrderPlan {
  final int ref;

  /// What this order exists to prove, shown in test failures.
  final String scenario;
  final String customer;
  final int channelRef;
  final List<ItemPlan> items;
  final OrderLifecycle lifecycle;
  final DateTime placed;
  final DateTime due;

  /// When the order was packed and left, for a lifecycle that got that far.
  final DateTime? packedAt;
  final DateTime? shippedAt;
  final List<OrderDiscount> discounts;
  final OrderTax? tax;
  final bool paid;

  /// Shipping the shop paid out of its own pocket.
  final double shipping;

  /// Fees the channel took. Null means "work it out from the channel", which
  /// is what every real order does; a value is how the break-even order gets
  /// a fee that lands its profit exactly on nothing.
  final double? feesOverride;
  final Map<int, String> answers;
  final String? note;

  /// Material ref → extra pieces used, and pieces not used. Recorded before
  /// packing, the way the app's Adjust sheet does it.
  final Map<int, double> usedMore;
  final Map<int, double> usedLess;

  /// True for the order whose fees are set so the profit lands exactly on
  /// nothing.
  final bool breakEven;

  const OrderPlan({
    required this.ref,
    required this.scenario,
    required this.customer,
    required this.channelRef,
    required this.items,
    required this.lifecycle,
    required this.placed,
    required this.due,
    this.packedAt,
    this.shippedAt,
    this.discounts = const [],
    this.tax,
    this.paid = true,
    this.shipping = 0,
    this.feesOverride,
    this.answers = const {},
    this.note,
    this.usedMore = const {},
    this.usedLess = const {},
    this.breakEven = false,
  });

  bool get isCancelled => switch (lifecycle) {
        OrderLifecycle.cancelledWhilePending ||
        OrderLifecycle.cancelledAfterPacking ||
        OrderLifecycle.cancelledAfterShipping =>
          true,
        _ => false,
      };

  /// Packed or shipped and still on the books, so its stock really left the
  /// shelf and it counts in reports.
  bool get tookStock =>
      !isCancelled &&
      switch (lifecycle) {
        OrderLifecycle.packed || OrderLifecycle.shipped => true,
        _ => false,
      };

  /// Still holding pieces for itself: to pack, which includes a restored one.
  bool get reserves =>
      !isCancelled &&
      lifecycle != OrderLifecycle.packed &&
      lifecycle != OrderLifecycle.shipped;
}

class NotePlan {
  final int ref;
  final String title;

  /// Delta JSON, already encoded, or plain text for a note written before the
  /// notebook could format.
  final String? body;
  final bool pinned;

  const NotePlan({
    required this.ref,
    required this.title,
    this.body,
    this.pinned = false,
  });
}

class LinkPlan {
  final int ref;
  final String platform;
  final String label;
  final String url;
  final int? colorValue;

  const LinkPlan({
    required this.ref,
    required this.platform,
    required this.label,
    required this.url,
    this.colorValue,
  });
}

/// The shop's own settings, written so every money screen has known numbers.
class SettingsPlan {
  final String currencyCode;
  final String currencySymbol;
  final int currencyDecimals;
  final bool taxEnabled;
  final bool taxOnByDefault;
  final double taxRate;
  final bool taxInclusive;
  final String taxLabel;
  final String themeMode;
  final String palette;
  final String orderAmountShown;

  const SettingsPlan({
    required this.currencyCode,
    required this.currencySymbol,
    required this.currencyDecimals,
    required this.taxEnabled,
    required this.taxOnByDefault,
    required this.taxRate,
    required this.taxInclusive,
    required this.taxLabel,
    required this.themeMode,
    required this.palette,
    required this.orderAmountShown,
  });
}

/// A whole shop, ready to write. References between plans use each plan's own
/// [ref], which the seeder turns into database ids as it goes.
class FakeShop {
  final int seed;
  final DateTime now;
  final SettingsPlan settings;
  final List<String> extraUnits;
  final List<ChannelPlan> channels;
  final List<DiscountPresetPlan> presets;
  final List<OrderFieldPlan> fields;
  final List<MaterialPlan> materials;
  final List<ProductPlan> products;
  final List<OrderPlan> orders;
  final List<NotePlan> notes;
  final List<LinkPlan> links;

  const FakeShop({
    required this.seed,
    required this.now,
    required this.settings,
    required this.channels,
    required this.presets,
    required this.fields,
    required this.materials,
    required this.products,
    required this.orders,
    required this.notes,
    required this.links,
    this.extraUnits = const [],
  });

  MaterialPlan materialByRef(int ref) =>
      materials.firstWhere((m) => m.ref == ref);

  ProductPlan productByRef(int ref) => products.firstWhere((p) => p.ref == ref);

  ChannelPlan channelByRef(int ref) => channels.firstWhere((c) => c.ref == ref);
}
