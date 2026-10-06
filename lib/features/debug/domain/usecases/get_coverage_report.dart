import 'dart:math';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/factory/coverage.dart';
import '../../../../core/utils/note_codec.dart';
import '../../../../core/utils/quantity.dart';
import '../../../discounts/domain/repositories/discount_preset_repository.dart';
import '../../../notes/domain/repositories/note_repository.dart';
import '../../../order_fields/domain/repositories/order_field_repository.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_money.dart';
import '../../../orders/domain/repositories/order_repository.dart';
import '../../../products/domain/repositories/channel_repository.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../social_links/domain/repositories/social_link_repository.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../../../stock/domain/usecases/get_buy_list.dart';

/// Reads the shop back through the app's own read path and counts which of the
/// app's options it actually used.
///
/// Deliberately not a report of what the factory *meant* to write: it asks the
/// repositories, so a plan that the database disagrees with — a reservation
/// that was clamped, a status that never landed — shows up as a gap.
class GetCoverageReport {
  GetCoverageReport({
    required this.orders,
    required this.materials,
    required this.products,
    required this.channels,
    required this.fields,
    required this.notes,
    required this.links,
    required this.presets,
    required this.settings,
    required this.getBuyList,
  });

  final OrderRepository orders;
  final MaterialRepository materials;
  final ProductRepository products;
  final ChannelRepository channels;
  final OrderFieldRepository fields;
  final NoteRepository notes;
  final SocialLinkRepository links;
  final DiscountPresetRepository presets;
  final SettingsRepository settings;
  final GetBuyList getBuyList;

  final Map<String, Map<String, int>> _counts = {};

  void _bump(String domain, String option) {
    final byOption = _counts.putIfAbsent(domain, () => {});
    byOption[option] = (byOption[option] ?? 0) + 1;
  }

  Future<Result<CoverageReport>> call() async {
    _counts.clear();
    try {
      final allOrders = await _value(orders.getAllOrders());
      await _countOrders(allOrders);
      await _countCatalogue();
      await _countChannels();
      await _countFields(allOrders);
      await _countPresets();
      await _countNotes();
      await _countLinks();
      await _countBuyList();
      await _countSettings();
      return Success(CoverageReport(_counts));
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  Future<void> _countOrders(List<Order> all) async {
    final today = DateTime.now();
    final startOfToday = DateTime(today.year, today.month, today.day);
    final endOfToday = startOfToday.add(const Duration(days: 1));

    for (final order in all) {
      _bump('status', order.status.name);
      if (order.status != OrderStatus.cancelled) {
        _bump(
          'dates',
          order.shipByDate.isBefore(startOfToday)
              ? 'overdue'
              : order.shipByDate.isBefore(endOfToday)
                  ? 'due today'
                  : 'due later',
        );
      }
      _bump('paid', order.isPaid ? 'paid' : 'unpaid');
      _bump(
          'tax',
          order.taxRate == null || order.taxRate == 0
              ? 'no tax'
              : order.taxInclusive
                  ? 'in price'
                  : 'added on top');

      final profit = OrderMoney.fromOrder(order).profit;
      _bump(
          'profit',
          sameQty(profit, 0)
              ? 'broke even'
              : profit > 0
                  ? 'made money'
                  : 'lost money');

      final lines = await _value(orders.getOrderItems(order.id!));
      final resell = await _value(orders.getOrderProducts(order.id!));
      final discounts = await _value(orders.getOrderDiscounts(order.id!));
      _bump(
          'discounts',
          discounts.isEmpty
              ? 'none'
              : discounts.length > 1
                  ? 'several lines'
                  : discounts.first.kind.name);
      _bump('items', lines.length > 1 ? 'several lines' : 'single line');
      if (resell.isNotEmpty) _bump('items', 'resell line');
      if (lines.any((line) => !sameQty(line.quantity, line.quantity.round()))) {
        _bump('items', 'fractional line');
      }

      if (order.customerName.length >= 32) {
        _bump('hard cases', 'long customer name');
      }
      if (lines.length >= 6) {
        _bump('hard cases', 'many order lines');
      }
      if (order.totalSales >= 10000) {
        _bump('hard cases', 'order over ten thousand');
      }
      if (lines.any((line) => !sameQty(line.quantity, line.quantity.round()))) {
        _bump('hard cases', 'fractional quantity');
      }
      final note = order.note;
      if (note != null &&
          !note.startsWith('{"ops"') &&
          note.length > 150 &&
          !note.contains('\n')) {
        _bump('hard cases', 'note with no line break');
      }

      final used = await _value(orders.getOrderMaterials(order.id!));
      for (final line in used) {
        if (line.wasteQuantity > 0 && line.wasteReason != null) {
          _bump('waste', 'more than planned');
        } else if (line.actualQuantity > line.plannedQuantity) {
          _bump('waste', 'more than planned');
        } else if (line.actualQuantity < line.plannedQuantity) {
          _bump('waste', 'less than planned');
        } else {
          _bump('waste', 'exactly planned');
        }
      }
    }
  }

  Future<void> _countCatalogue() async {
    final every = await _value(materials.getAllMaterials());
    for (final material in every) {
      _bump('archived', material.isArchived ? 'archived' : 'live');
      _bump(
        'stock',
        material.quantityOnHand == 0
            ? 'empty'
            : material.isLowStock
                ? 'at or below the alert level'
                : 'healthy',
      );
      if (material.quantityPromised > material.quantityOnHand) {
        _bump('stock', 'promised more than held');
      }
      if (material.isArchived &&
          await _value(materials.isUsedInOrders(material.id!))) {
        _bump('hard cases', 'archived item still on past orders');
      }
      for (final movement
          in await _value(materials.getStockMovements(material.id!))) {
        _bump('movements', movement.type.name);
      }
    }

    final products_ = await _value(products.getAllProducts());
    for (final product in products_) {
      _bump('archived', product.isArchived ? 'archived' : 'live');
      _bump('product types', product.isStandalone ? 'resell' : 'handmade');
      if (product.isStandalone) {
        for (final movement
            in await _value(products.getProductStockMovements(product.id!))) {
          _bump('movements', movement.type.name);
        }
      }
      for (final line in await _value(products.getBomItems(product.id!))) {
        _bump(
            'bom', line.makes > 1 ? 'many products per piece' : 'whole piece');
        if (!sameQty(line.quantityRequired, line.quantityRequired.round())) {
          _bump('bom', 'fractional use');
        }
      }
    }
  }

  Future<void> _countChannels() async {
    for (final channel in await _value(channels.getAllChannels())) {
      _bump('channel state', channel.isActive ? 'open' : 'paused');
      final commission = channel.commissionRate > 0;
      final transaction = channel.transactionFeeRate > 0;
      final flat = channel.flatFee > 0;
      _bump(
        'channel fees',
        commission && transaction && flat
            ? 'all three'
            : commission
                ? 'commission only'
                : flat
                    ? 'flat fee only'
                    : 'nothing',
      );
    }
  }

  Future<void> _countFields(List<Order> allOrders) async {
    final open =
        allOrders.where((o) => o.status != OrderStatus.cancelled).length;
    for (final field in await _value(fields.getFields())) {
      _bump('field types', field.type.name);
      _bump('field states', field.isArchived ? 'archived' : 'in use');
      if (!field.isArchived && field.usageCount < max(1, open)) {
        _bump('field states', 'answer left blank');
      }
    }
  }

  Future<void> _countPresets() async {
    final saved = await _value(presets.getPresets());
    if (saved.isEmpty) return;
    final labels = <String>{};
    for (final order in await _value(orders.getAllOrders())) {
      for (final line in await _value(orders.getOrderDiscounts(order.id!))) {
        labels.add(line.label);
      }
    }
    for (final preset in saved) {
      _bump('presets', preset.kind.name);
      _bump('presets',
          labels.contains(preset.label) ? 'used on an order' : 'left unused');
    }
  }

  Future<void> _countNotes() async {
    for (final note in await _value(notes.getNotes())) {
      if (note.isPinned) _bump('notes', 'pinned');
      final body = note.body;
      if (body == null) continue;
      _bump('notes', _isFormatted(body) ? 'formatted' : 'plain text');
    }
  }

  bool _isFormatted(String body) {
    for (final op in NoteCodec.decode(body).toList()) {
      final attributes = op.attributes;
      if (attributes != null && attributes.isNotEmpty) return true;
    }
    return false;
  }

  Future<void> _countLinks() async {
    for (final link in await _value(links.getLinks())) {
      _bump('platforms', link.platform);
    }
  }

  Future<void> _countBuyList() async {
    for (final item in await _value(getBuyList())) {
      _bump('buy list', item.kind.name);
    }
  }

  Future<void> _countSettings() async {
    _bump('currency', (await settings.getCurrency()).code);
    _bump('theme', (await settings.getThemeMode()).name);
    _bump('palette', (await settings.getPalette()).name);
    _bump('order amount', (await settings.getOrderAmountShown()).name);
  }

  /// Unwraps a read, throwing so a database that can't be read fails the
  /// report instead of quietly counting nothing.
  Future<T> _value<T>(Future<Result<T>> result) async => switch (await result) {
        Success(:final value) => value,
        Error(:final failure) => throw failure,
      };
}
