import 'dart:math';

import 'package:flutter/material.dart' show ThemeMode;

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/factory/fake_photo.dart';
import '../../../../core/factory/fake_shop.dart';
import '../../../../core/factory/fake_shop_generator.dart';
import '../../../../core/factory/fake_vocabulary.dart';
import '../../../../core/theme/palettes.dart';
import '../../../../core/utils/currency_setting.dart';
import '../../../../core/utils/quantity.dart';
import '../../../discounts/domain/usecases/discount_preset_usecases.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/domain/repositories/note_repository.dart';
import '../../../order_fields/domain/entities/order_field.dart';
import '../../../order_fields/domain/repositories/order_field_repository.dart';
import '../../../orders/domain/entities/order_discount.dart';
import '../../../orders/domain/entities/order_item.dart';
import '../../../orders/domain/entities/order_material.dart';
import '../../../orders/domain/entities/order_money.dart';
import '../../../orders/domain/repositories/order_repository.dart';
import '../../../orders/domain/usecases/adjust_materials_used.dart';
import '../../../orders/domain/usecases/cancel_order.dart';
import '../../../orders/domain/usecases/create_order.dart';
import '../../../orders/domain/usecases/pack_order.dart';
import '../../../orders/domain/usecases/restore_order.dart';
import '../../../orders/domain/usecases/set_order_paid.dart';
import '../../../orders/domain/usecases/ship_order.dart';
import '../../../products/domain/entities/channel.dart';
import '../../../products/domain/repositories/channel_repository.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../settings/domain/entities/order_amount_shown.dart';
import '../../../settings/domain/entities/tax_settings.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../social_links/domain/entities/social_link.dart';
import '../../../social_links/domain/repositories/social_link_repository.dart';
import '../../../stock/domain/entities/buy_list_item.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../../../stock/domain/usecases/get_buy_list.dart';
import '../../../units/domain/entities/unit_of_measure.dart';
import '../../../units/domain/repositories/unit_repository.dart';
import '../entities/seed_outcome.dart';
import '../repositories/shop_data_repository.dart';
import 'get_coverage_report.dart';

/// Wipes the database and writes a whole fake shop through the app's own use
/// cases, so that seeding an order reserves stock, packing it takes pieces off
/// the shelf, waste lands on the order lines and every number on screen comes
/// from the same arithmetic a shop owner's tap produces.
///
/// Only the timestamps the app can't be told to backdate are written by hand
/// (see [ShopDataRepository]). That is the point: a seed that succeeds is
/// evidence the app's own paths work, and one that trips over a rule fails here
/// instead of showing up later as a screen that looks subtly wrong.
///
/// Afterwards it reads the shop back with [GetCoverageReport] and demands that
/// every option the app offers was used. A gap rolls the whole run back, so a
/// shop that quietly lost its buy list or its cancelled orders can't be written
/// at all.
class SeedFakeShop {
  SeedFakeShop({
    required this.shopData,
    required this.settings,
    required this.units,
    required this.channels,
    required this.materials,
    required this.products,
    required this.fields,
    required this.notes,
    required this.links,
    required this.orders,
    required this.savePreset,
    required this.createOrder,
    required this.packOrder,
    required this.shipOrder,
    required this.cancelOrder,
    required this.restoreOrder,
    required this.adjustMaterialsUsed,
    required this.setOrderPaid,
    required this.getBuyList,
    required this.coverage,
  });

  final ShopDataRepository shopData;
  final SettingsRepository settings;
  final UnitRepository units;
  final ChannelRepository channels;
  final MaterialRepository materials;
  final ProductRepository products;
  final OrderFieldRepository fields;
  final NoteRepository notes;
  final SocialLinkRepository links;
  final OrderRepository orders;
  final SaveDiscountPreset savePreset;
  final CreateOrder createOrder;
  final PackOrder packOrder;
  final ShipOrder shipOrder;
  final CancelOrder cancelOrder;
  final RestoreOrder restoreOrder;
  final AdjustMaterialsUsed adjustMaterialsUsed;
  final SetOrderPaid setOrderPaid;
  final GetBuyList getBuyList;
  final GetCoverageReport coverage;

  Future<Result<SeedOutcome>> call({int? seed}) async {
    final shop = FakeShopGenerator(seed: seed).build();
    try {
      return Success(await shopData.inTransaction(() => _write(shop)));
    } on Object catch (e) {
      return Error(DatabaseFailure('Seed failed, nothing was written: $e'));
    }
  }

  Future<SeedOutcome> _write(FakeShop shop) async {
    switch (await shopData.wipeAll()) {
      case Error(:final failure):
        throw StateError(failure.message);
      case Success():
        break;
    }

    await _writeSettings(shop.settings);
    final fieldIds = await _writeFields(shop.fields);
    final (channelIds, channelPlans) = await _writeChannels(shop.channels);
    await _writePresets(shop.presets);
    final unitOf = await _writeUnits(shop.extraUnits);
    final materialIds = await _writeMaterials(shop, unitOf);
    final productIds = await _writeProducts(shop, unitOf, materialIds);

    for (final plan in shop.orders) {
      await _writeOrder(
        plan,
        shop: shop,
        fieldIds: fieldIds,
        channelIds: channelIds,
        channelPlans: channelPlans,
        materialIds: materialIds,
        productIds: productIds,
      );
    }

    await _writeNotes(shop.notes);
    await _writeLinks(shop.links);
    await _archive(shop, materialIds, productIds, fieldIds);

    final buyList = _ok(await getBuyList());
    _requireBuyListShapes(buyList);
    final report = _ok(await coverage());
    if (!report.isComplete) {
      throw StateError('the shop never exercised: ${report.gaps.join(', ')}');
    }

    return SeedOutcome(
      seed: shop.seed,
      orders: shop.orders.length,
      materials: shop.materials.length,
      products: shop.products.length,
      buyListLines: buyList.length,
      coverage: report,
    );
  }

  Future<void> _writeSettings(SettingsPlan plan) async {
    final currency = CurrencySetting.preset(plan.currencyCode) ??
        CurrencySetting(
          code: plan.currencyCode,
          symbol: plan.currencySymbol,
          decimals: plan.currencyDecimals,
        );
    _ok(await settings.setCurrency(currency));
    _ok(await settings.setTaxSettings(TaxSettings(
      enabled: plan.taxEnabled,
      onByDefault: plan.taxOnByDefault,
      rate: plan.taxRate,
      inclusive: plan.taxInclusive,
      label: plan.taxLabel,
    )));
    _ok(await settings.setThemeMode(ThemeMode.values.byName(plan.themeMode)));
    _ok(await settings.setPalette(AppPalette.values.byName(plan.palette)));
    _ok(await settings.setOrderAmountShown(
        OrderAmountShown.values.byName(plan.orderAmountShown)));
  }

  Future<Map<int, int>> _writeFields(List<OrderFieldPlan> plans) async {
    final ids = <int, int>{};
    for (final plan in plans) {
      ids[plan.ref] = _ok(await fields.createField(OrderField(
        name: plan.name,
        type: plan.type,
        isMultiline: plan.isMultiline,
        options: plan.options,
      )));
    }
    return ids;
  }

  Future<(Map<int, int>, Map<int, ChannelPlan>)> _writeChannels(
      List<ChannelPlan> plans) async {
    final ids = <int, int>{};
    for (final plan in plans) {
      final id = _ok(await channels.createChannel(
        name: plan.name,
        commissionRate: plan.commissionRate,
        transactionFeeRate: plan.transactionFeeRate,
        flatFee: plan.flatFee,
        shippingPaidByUs: plan.shippingPaidByUs,
        paidByDefault: plan.paidByDefault,
      ));
      ids[plan.ref] = id;
      // Pausing goes through the same update the shop's own toggle does.
      if (!plan.isActive) {
        _ok(await channels.updateChannel(id: id, isActive: false));
      }
    }
    return (ids, {for (final p in plans) p.ref: p});
  }

  Future<void> _writePresets(List<DiscountPresetPlan> plans) async {
    for (final plan in plans) {
      _ok(await savePreset(
          label: plan.label, kind: plan.kind, value: plan.value));
    }
  }

  /// The shop's unit vocabulary, including whatever the fake shop invented.
  Future<int Function(String)> _writeUnits(List<String> extraUnits) async {
    for (final label in extraUnits) {
      _ok(await units.createUnit(UnitOfMeasure(label: label)));
    }
    final all = _ok(await units.getUnits());
    return (String label) {
      for (final unit in all) {
        if (unit.label == label) return unit.id!;
      }
      for (final unit in all) {
        if (unit.isDefault) return unit.id!;
      }
      return all.first.id!;
    };
  }

  Future<Map<int, int>> _writeMaterials(
      FakeShop shop, int Function(String) unitOf) async {
    final ids = <int, int>{};
    for (final plan in shop.materials) {
      final id = _ok(await materials.createMaterial(
        name: plan.name,
        unitId: unitOf(plan.unit),
        packSize: plan.packSize,
        packPrice: plan.packPrice,
        unitCost: plan.unitCost,
        quantityOnHand: plan.startOnHand,
        alertLevel: plan.alertLevel,
        supplier: plan.supplier,
      ));
      ids[plan.ref] = id;

      if (plan.receivedPacks > 0) {
        // At the price the shelf already pays, so the weighted average stays
        // where the planner put it. Resell products are where the re-averaging
        // itself gets exercised.
        _ok(await materials.receiveStock(
          materialId: id,
          packsReceived: plan.receivedPacks,
          pricePerPack: plan.packPrice,
          supplier: plan.supplier,
        ));
      }
      if (plan.countedByHand) {
        _ok(await materials.adjustStock(id, _countedQuantity(plan)));
      }
      if (plan.receivedPacks > 0 || plan.countedByHand) {
        _ok(await shopData.backdateStockHistory(
            materialId: id, days: max(1, plan.receivedDaysAgo)));
      }
    }
    return ids;
  }

  /// What the shelf read after the count that found one more pack.
  double _countedQuantity(MaterialPlan plan) => qty(
      plan.startOnHand + plan.receivedPacks * plan.packSize + plan.packSize);

  Future<Map<int, int>> _writeProducts(
    FakeShop shop,
    int Function(String) unitOf,
    Map<int, int> materialIds,
  ) async {
    final ids = <int, int>{};
    var photoIndex = 0;
    for (final plan in shop.products) {
      final id = _ok(await products.createProduct(
        name: plan.name,
        sellPrice: plan.sellPrice,
        unitId: unitOf(plan.unit),
        isStandalone: plan.isResell,
        initialQuantity: plan.isResell ? plan.startOnHand : 0,
        initialUnitCost: plan.isResell ? plan.unitCost : 0,
      ));
      ids[plan.ref] = id;

      if (plan.bom.isNotEmpty) {
        _ok(await products.saveBomItems(id, [
          for (final line in plan.bom)
            BomItemInput(
              materialId: materialIds[line.materialRef]!,
              quantityRequired: line.uses,
              makes: line.makes,
            ),
        ]));
      }

      if (plan.isResell) {
        _ok(await products.updateProduct(id: id, alertLevel: plan.alertLevel));
        if (plan.receivedQuantity > 0) {
          _ok(await products.receiveProductStock(
            productId: id,
            quantity: plan.receivedQuantity,
            pricePerUnit: plan.receivedPricePerUnit,
          ));
        }
        if (plan.countedByHand) {
          _ok(await products.adjustProductStock(
              productId: id,
              newQuantityOnHand:
                  qty(plan.startOnHand + plan.receivedQuantity + 1)));
        }
        if (plan.receivedQuantity > 0 || plan.countedByHand) {
          _ok(await shopData.backdateStockHistory(
              productId: id, days: max(1, plan.receivedDaysAgo)));
        }
      }

      if (plan.wantPhoto) {
        _ok(await products.setProductPhoto(
            id, await drawFakePhoto(seed: shop.seed, index: photoIndex++)));
      }
    }
    return ids;
  }

  Future<void> _writeOrder(
    OrderPlan plan, {
    required FakeShop shop,
    required Map<int, int> fieldIds,
    required Map<int, int> channelIds,
    required Map<int, ChannelPlan> channelPlans,
    required Map<int, int> materialIds,
    required Map<int, int> productIds,
  }) async {
    final items = [
      for (final item in plan.items)
        OrderItemInput(
          productId: productIds[item.productRef]!,
          productName: shop.productByRef(item.productRef).name,
          quantity: item.quantity,
          unitPrice: item.price ?? shop.productByRef(item.productRef).sellPrice,
        ),
    ];
    final sales = items.fold<double>(0, (sum, item) => sum + item.subtotal);
    final shape = channelPlans[plan.channelRef]!;
    final channel = Channel(
      id: channelIds[plan.channelRef],
      name: shape.name,
      commissionRate: shape.commissionRate,
      transactionFeeRate: shape.transactionFeeRate,
      flatFee: shape.flatFee,
      shippingPaidByUs: shape.shippingPaidByUs,
      isActive: shape.isActive,
      paidByDefault: shape.paidByDefault,
      createdAt: shop.now,
    );
    final money = OrderMoney.compute(
      itemsTotal: sales,
      discounts: plan.discounts,
      tax: plan.tax,
      channel: channel,
    );

    var fees = plan.feesOverride ?? money.fees;
    if (plan.breakEven) {
      // The cost comes off the shelf as the app just stored it, so the fee that
      // leaves exactly nothing behind is that number rather than a guess at it.
      final item = plan.items.first;
      final live =
          _ok(await products.getProductById(productIds[item.productRef]!));
      final materials = qty((live?.unitCost ?? 0) * item.quantity);
      fees = qty(money.customerPays - money.tax - materials - plan.shipping);
    }

    final id = _ok(await createOrder(
      customerName: plan.customer,
      note: plan.note,
      orderDate: plan.placed,
      shipByDate: plan.due,
      channelId: channelIds[plan.channelRef]!,
      totalSales: sales,
      channelFees: fees,
      shippingCost: plan.shipping,
      items: items,
      fieldValues: {
        for (final answer in plan.answers.entries)
          fieldIds[answer.key]!: answer.value,
      },
      terms: OrderTerms(
          discounts: money.discounts, tax: plan.tax, isPaid: plan.paid),
      discountTotal: money.discount,
      taxAmount: money.tax,
    ));

    if (plan.usedMore.isNotEmpty || plan.usedLess.isNotEmpty) {
      await _recordWhatWasUsed(id, plan, materialIds);
    }
    await _advance(plan, id);

    if (plan.packedAt != null || plan.shippedAt != null) {
      _ok(await shopData.backdateOrder(
          orderId: id, packedAt: plan.packedAt, shippedAt: plan.shippedAt));
    }
  }

  Future<void> _advance(OrderPlan plan, int orderId) async {
    if (plan.lifecycle == OrderLifecycle.restoredAfterCancel) {
      _ok(await cancelOrder(orderId));
      _ok(await restoreOrder(orderId));
      // Marked paid through its own use case, so the paid stamp is real.
      _ok(await setOrderPaid(orderId, plan.paid));
      return;
    }
    final wasPacked = plan.lifecycle == OrderLifecycle.packed ||
        plan.lifecycle == OrderLifecycle.shipped ||
        plan.lifecycle == OrderLifecycle.cancelledAfterPacking ||
        plan.lifecycle == OrderLifecycle.cancelledAfterShipping;
    final wasShipped = plan.lifecycle == OrderLifecycle.shipped ||
        plan.lifecycle == OrderLifecycle.cancelledAfterShipping;
    if (wasPacked) _ok(await packOrder(orderId));
    if (wasShipped) _ok(await shipOrder(orderId));
    if (plan.isCancelled) _ok(await cancelOrder(orderId));
  }

  /// Records what was really used, before packing takes it off the shelf — the
  /// order the Adjust sheet works in.
  Future<void> _recordWhatWasUsed(
      int orderId, OrderPlan plan, Map<int, int> materialIds) async {
    final more = {
      for (final entry in plan.usedMore.entries)
        materialIds[entry.key]!: entry.value,
    };
    final less = {
      for (final entry in plan.usedLess.entries)
        materialIds[entry.key]!: entry.value,
    };
    final reason = wasteReasons[plan.ref % wasteReasons.length];
    final lines = _ok(await orders.getOrderMaterials(orderId));
    _ok(await adjustMaterialsUsed(orderId, [
      for (final line in lines)
        OrderMaterialInput(
          materialId: line.materialId,
          materialName: line.materialName,
          plannedQuantity: line.plannedQuantity,
          actualQuantity: qty(line.plannedQuantity +
              (more[line.materialId] ?? 0) -
              (less[line.materialId] ?? 0)),
          wasteQuantity: qty(more[line.materialId] ?? 0),
          wasteReason: (more[line.materialId] ?? 0) > 0 ? reason : null,
          unitCost: line.unitCost,
        ),
    ]));
  }

  Future<void> _writeNotes(List<NotePlan> plans) async {
    for (final plan in plans) {
      _ok(await notes.createNote(
          Note(title: plan.title, body: plan.body, isPinned: plan.pinned)));
    }
  }

  Future<void> _writeLinks(List<LinkPlan> plans) async {
    for (final plan in plans) {
      _ok(await links.createLink(SocialLink(
        platform: plan.platform,
        label: plan.label,
        url: plan.url,
        colorValue: plan.colorValue,
      )));
    }
  }

  /// Archived last, because that is the order it happens in: things get used,
  /// and only later does the shop stop using them.
  Future<void> _archive(FakeShop shop, Map<int, int> materialIds,
      Map<int, int> productIds, Map<int, int> fieldIds) async {
    for (final plan in shop.materials.where((m) => m.archiveLater)) {
      _ok(await materials.setMaterialArchived(materialIds[plan.ref]!, true));
    }
    for (final plan in shop.products.where((p) => p.archiveLater)) {
      _ok(await products.updateProduct(
          id: productIds[plan.ref]!, isArchived: true));
    }
    for (final plan in shop.fields.where((f) => f.archiveLater)) {
      _ok(await fields.setArchived(fieldIds[plan.ref]!, true));
    }
  }

  /// The buy-list states a seeded shop has to contain, in words that name what
  /// went wrong when one of them is missing.
  void _requireBuyListShapes(List<BuyListItem> buyList) {
    if (buyList.isEmpty) {
      throw StateError('the buy list came out empty, so the restock screen '
          'would never have been looked at');
    }
    if (!buyList.any((i) => i.kind == BuyListKind.product)) {
      throw StateError('no resell product reached the buy list');
    }
    final pieces = buyList.where((i) => i.kind == BuyListKind.material);
    if (pieces.isEmpty) throw StateError('no material reached the buy list');
    if (pieces.every((i) => i.packsToOrder < 2)) {
      throw StateError('nothing on the buy list needs more than one pack');
    }
    if (buyList.every((i) => i.blockingOrders == 0)) {
      throw StateError('nothing on the buy list has an order waiting on it');
    }
    if (buyList.every(
        (i) => sameQty(i.quantityOnHand, i.quantityOnHand.roundToDouble()))) {
      throw StateError('every buy-list number came out whole, so the '
          'fractional ones were never drawn');
    }
    if (pieces.every((i) => !sameQty(i.quantityOnHand, i.alertLevel))) {
      throw StateError('nothing sat exactly at its reorder level, which is the '
          'one case that still asks for a pack');
    }
  }

  T _ok<T>(Result<T> result) => switch (result) {
        Success(:final value) => value,
        Error(:final failure) => throw StateError(failure.message),
      };
}
