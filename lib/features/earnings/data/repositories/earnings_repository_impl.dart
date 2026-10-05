import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/earnings_dao.dart';
import '../../../orders/data/repositories/order_repository_impl.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_money.dart';
import '../../domain/entities/earnings_summary.dart';
import '../../domain/entities/product_earnings.dart';
import '../../domain/entities/profit_trend.dart';
import '../../domain/entities/report_filter.dart';
import '../../domain/repositories/earnings_repository.dart';

/// One completed order in a report, with its items and money worked out.
class _Completed {
  final Order order;
  final DateTime completedAt;
  final List<db.OrderItem> items;
  final OrderMoney money;

  _Completed(this.order, this.completedAt, this.items)
      : money = OrderMoney.fromOrder(order);

  /// The item's share of the order's profit, split by its share of sales
  /// so discounts and tax land where the sales were.
  double profitOf(db.OrderItem item) => order.totalSales > 0
      ? money.profit * item.subtotal / order.totalSales
      : 0;
}

class EarningsRepositoryImpl implements EarningsRepository {
  final EarningsDao dao;

  EarningsRepositoryImpl(this.dao);

  /// Completed orders in the range that pass [filter], oldest first.
  Future<List<_Completed>> _orders(
      DateTime start, DateTime end, ReportFilter filter) async {
    final rows = await dao.getCompletedOrders(start, end);
    final items = await dao.getItemsForOrders(rows.map((o) => o.id));
    final result = <_Completed>[];
    for (final row in rows) {
      final order = OrderRepositoryImpl.toEntity(row);
      final lines = items[row.id] ?? const <db.OrderItem>[];
      if (!filter.matches(order, {for (final i in lines) i.productId})) {
        continue;
      }
      result.add(_Completed(order, EarningsDao.completedAt(row)!, lines));
    }
    result.sort((a, b) => a.completedAt.compareTo(b.completedAt));
    return result;
  }

  @override
  Future<Result<EarningsSummary>> getEarningsSummary(
    DateTime startDate,
    DateTime endDate, {
    ReportFilter filter = ReportFilter.none,
  }) async {
    try {
      final orders = await _orders(startDate, endDate, filter);
      double sum(double Function(OrderMoney m) f) =>
          orders.fold(0, (s, o) => s + f(o.money));
      final unpaid = orders.where((o) => !o.order.isPaid).toList();
      return Success(EarningsSummary(
        totalSales: sum((m) => m.itemsTotal),
        totalMaterialCost: sum((m) => m.materials),
        totalChannelFees: sum((m) => m.fees),
        totalShippingCost: sum((m) => m.shipping),
        totalProfit: sum((m) => m.profit),
        orderCount: orders.length,
        totalDiscount: sum((m) => m.discount),
        totalIncludedTax: sum((m) => m.includedTax),
        totalAddedTax: sum((m) => m.addedTax),
        unpaidTotal: unpaid.fold(0, (s, o) => s + o.money.customerPays),
        unpaidCount: unpaid.length,
      ));
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<ProductEarnings>>> getProductEarnings(
    DateTime startDate,
    DateTime endDate, {
    ReportFilter filter = ReportFilter.none,
  }) async {
    try {
      final orders = await _orders(startDate, endDate, filter);
      final info = await dao.getProductInfo(
          [for (final o in orders) ...o.items.map((i) => i.productId)]);
      final byProduct = <int, ({int qty, double sales, double profit})>{};
      for (final o in orders) {
        for (final item in o.items) {
          final prev =
              byProduct[item.productId] ?? (qty: 0, sales: 0.0, profit: 0.0);
          byProduct[item.productId] = (
            qty: prev.qty + item.quantity,
            sales: prev.sales + item.subtotal,
            profit: prev.profit + o.profitOf(item),
          );
        }
      }
      return Success([
        for (final MapEntry(key: id, value: v) in byProduct.entries)
          ProductEarnings(
            productId: id,
            productName: info[id]?.name ?? '',
            unit: info[id]?.unit ?? '',
            quantitySold: v.qty,
            totalSales: v.sales,
            totalProfit: v.profit,
          ),
      ]);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<WasteSummary>> getWasteSummary(
    DateTime startDate,
    DateTime endDate, {
    ReportFilter filter = ReportFilter.none,
  }) async {
    try {
      final orders = await _orders(startDate, endDate, filter);
      // Waste belongs to the period the order was completed in, like its
      // sales and profit.
      final lines =
          await dao.getMaterialsForOrders(orders.map((o) => o.order.id!));
      final byMaterial = <int, ({int qty, double cost})>{};
      for (final m in lines) {
        if (m.wasteQuantity <= 0) continue;
        final prev = byMaterial[m.materialId] ?? (qty: 0, cost: 0.0);
        byMaterial[m.materialId] = (
          qty: prev.qty + m.wasteQuantity,
          cost: prev.cost + m.wasteQuantity * m.unitCost,
        );
      }
      final info = await dao.getMaterialInfo(byMaterial.keys);
      final items = [
        for (final MapEntry(key: id, value: v) in byMaterial.entries)
          WasteItem(
              materialName: info[id]?.name ?? 'Unknown',
              unit: info[id]?.unit ?? '',
              quantity: v.qty,
              cost: v.cost),
      ]..sort((a, b) => b.cost.compareTo(a.cost));
      return Success(WasteSummary(
        totalWasteQuantity: items.fold(0, (s, w) => s + w.quantity),
        totalWasteCost: items.fold(0, (s, w) => s + w.cost),
        items: items,
      ));
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<ProfitPoint>>> getCompletedOrderProfits(
    DateTime startDate,
    DateTime endDate, {
    ReportFilter filter = ReportFilter.none,
  }) async {
    try {
      final orders = await _orders(startDate, endDate, filter);
      return Success([
        for (final o in orders)
          ProfitPoint(completedAt: o.completedAt, profit: o.money.profit),
      ]);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<ProductOrderLine>>> getProductOrderLines(
    int productId,
    DateTime startDate,
    DateTime endDate, {
    ReportFilter filter = ReportFilter.none,
  }) async {
    try {
      final orders = await _orders(startDate, endDate, filter);
      final unit =
          (await dao.getProductInfo([productId]))[productId]?.unit ?? '';
      final lines = [
        for (final o in orders)
          for (final item in o.items)
            if (item.productId == productId)
              ProductOrderLine(
                orderId: o.order.id!,
                customerName: o.order.customerName,
                unit: unit,
                quantity: item.quantity,
                sales: item.subtotal,
                profit: o.profitOf(item),
                completedAt: o.completedAt,
              ),
      ]..sort((a, b) => b.completedAt.compareTo(a.completedAt));
      return Success(lines);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }
}
