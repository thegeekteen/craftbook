import 'package:equatable/equatable.dart';

import '../../../../core/error/result.dart';
import '../entities/order.dart';
import '../entities/order_list_entry.dart';
import '../entities/order_money.dart';
import '../repositories/order_repository.dart';
import 'get_order_list_entries.dart';

/// One customer's unpaid orders.
class ReceivableGroup extends Equatable {
  final String customerName;

  /// Oldest first.
  final List<OrderListEntry> entries;

  const ReceivableGroup({required this.customerName, required this.entries});

  double get total =>
      entries.fold(0, (s, e) => s + OrderMoney.fromOrder(e.order).customerPays);

  @override
  List<Object?> get props => [customerName, entries];
}

/// Everything customers still owe: accounts receivable.
class Receivables extends Equatable {
  /// Biggest debt first.
  final List<ReceivableGroup> groups;

  const Receivables(this.groups);

  static const empty = Receivables([]);

  double get total => groups.fold(0, (s, g) => s + g.total);

  int get orderCount => groups.fold(0, (s, g) => s + g.entries.length);

  bool get isEmpty => groups.isEmpty;

  @override
  List<Object?> get props => [groups];
}

/// Unpaid orders, whenever they were placed, grouped by customer.
class GetReceivables {
  final OrderRepository orderRepository;
  final GetOrderListEntries getOrderListEntries;

  GetReceivables({
    required this.orderRepository,
    required this.getOrderListEntries,
  });

  Future<Result<Receivables>> call() async {
    final unpaid = await orderRepository.getUnpaidOrders();
    final List<Order> orders;
    switch (unpaid) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        orders = value;
    }
    final entries = await getOrderListEntries(orders);
    switch (entries) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        // "Ana" and "ana " are the same customer.
        final byName = <String, List<OrderListEntry>>{};
        for (final e in value) {
          byName
              .putIfAbsent(e.order.customerName.trim().toLowerCase(), () => [])
              .add(e);
        }
        final groups = [
          for (final list in byName.values)
            ReceivableGroup(
              customerName: list.first.order.customerName.trim(),
              entries: list,
            ),
        ]..sort((a, b) => b.total.compareTo(a.total));
        return Success(Receivables(groups));
    }
  }
}
