import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../orders/presentation/widgets/order_status_ui.dart';
import '../../domain/entities/product_history_entry.dart';
import '../../domain/entities/product_stock_movement.dart';

/// One row in a product's history: a stock change or an order it was in.
class ProductHistoryRow extends StatelessWidget {
  final ProductHistoryEntry entry;

  /// Opens the order behind a sale row. Stock rows ignore it.
  final ValueChanged<int>? onOrderTap;

  const ProductHistoryRow({super.key, required this.entry, this.onOrderTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final when = DateFormat('MMM d, y').format(entry.date);
    switch (entry) {
      case StockHistoryEntry(:final movement):
        final mv = movement;
        final adds = mv.type == ProductStockMovementType.received ||
            (mv.type == ProductStockMovementType.adjusted && mv.quantity > 0);
        final color = adds ? c.go : c.alert;
        final title = switch (mv.type) {
          ProductStockMovementType.received => switch (mv.reference) {
              'Initial stock' => 'Initial stock',
              final r? when r.contains('Restored') => 'Returned from deleted order',
              _ => 'Received',
            },
          ProductStockMovementType.deducted => 'Used in an order',
          ProductStockMovementType.adjusted => 'Counted',
        };
        return CardRow(
          leading: _Badge(
            icon: adds ? Icons.south_west_rounded : Icons.north_east_rounded,
            color: color,
            background: adds ? c.goSoft : c.alertSoft,
          ),
          title: Text(title),
          subtitle: Text(
            mv.type == ProductStockMovementType.received && mv.unitCost > 0
                ? '$when · ${CurrencyFormatter.format(mv.unitCost)}/pc'
                : when,
          ),
          trailing: Text(
            '${adds ? '+' : '−'}${mv.quantity.abs()}',
            style: AppTextStyles.amount.copyWith(color: color, fontSize: 15),
          ),
        );
      case SaleHistoryEntry(:final sale):
        return CardRow(
          onTap: onOrderTap == null ? null : () => onOrderTap!(sale.orderId),
          leading: _Badge(icon: Icons.receipt_long_outlined, color: c.coin, background: c.coinSoft),
          title: Text('#${sale.orderId} · ${sale.customerName}', maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text(
            '$when · ${sale.quantity} × ${CurrencyFormatter.formatShort(sale.unitPrice)}',
          ),
          trailing: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              CurrencyText(
                amount: sale.subtotal,
                short: true,
                style: AppTextStyles.amount.copyWith(color: c.ink, fontSize: 15),
              ),
              const SizedBox(height: 4),
              OrderStatusPill(status: sale.status),
            ],
          ),
        );
    }
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color background;

  const _Badge({required this.icon, required this.color, required this.background});

  @override
  Widget build(BuildContext context) => Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: 16, color: color),
      );
}
