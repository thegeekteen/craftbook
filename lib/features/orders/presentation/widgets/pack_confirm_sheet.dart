import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/utils/quantity_formatter.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/inline_banner.dart';
import '../../../../core/widgets/pip_strip.dart';
import '../../domain/entities/order_material.dart';
import '../../domain/entities/order_product.dart';
import '../bloc/order_detail_state.dart';

/// One shelf item that packing will draw down.
class PackLine {
  final String name;

  /// What [quantity] and the stock counts are measured in.
  final String unit;
  final double quantity;
  final StockLevel? stock;

  const PackLine({
    required this.name,
    this.unit = '',
    required this.quantity,
    this.stock,
  });

  double get before => stock?.onHand ?? 0;

  /// Stock never goes below zero (the repository clamps it).
  double get after => math.max(0, before - quantity);
  bool get isShort => stock != null && quantity > before;
  bool get endsLow => stock != null && after <= stock!.alertLevel;
}

/// Bottom sheet that confirms packing and shows each line's stock before
/// and after, as numbers and pips.
class PackConfirmSheet extends StatelessWidget {
  final List<PackLine> lines;

  const PackConfirmSheet({super.key, required this.lines});

  static Future<bool> show(
    BuildContext context, {
    required List<OrderMaterial> materials,
    required List<OrderProduct> products,
    required Map<int, StockLevel> materialStock,
    required Map<int, StockLevel> productStock,
  }) async {
    final lines = [
      for (final m in materials)
        PackLine(
          name: m.materialName,
          unit: m.materialUnit,
          quantity: m.actualQuantity,
          stock: materialStock[m.materialId],
        ),
      for (final p in products)
        PackLine(
          name: p.productName,
          unit: p.productUnit,
          quantity: p.quantity,
          stock: productStock[p.productId],
        ),
    ];
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => PackConfirmSheet(lines: lines),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final short = lines.where((l) => l.isShort).toList();
    return ConstrainedBox(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Text(
              context.l10n.ordersPackTitle,
              style: AppTextStyles.displaySmall.copyWith(color: c.ink),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Text(
              lines.isEmpty
                  ? context.l10n.ordersPackNothing
                  : context.l10n.ordersPackIntro,
              style: AppTextStyles.bodyMedium.copyWith(color: c.muted),
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: lines.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, i) => _PackLineRow(line: lines[i]),
            ),
          ),
          if (short.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: InlineBanner(
                icon: Icons.warning_amber_rounded,
                title: context.l10n
                    .ordersPackShort(short.map((l) => l.name).join(', ')),
                message: context.l10n.ordersPackShortMessage,
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(foregroundColor: c.muted),
                    child: Text(context.l10n.commonCancel),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.inventory_2_rounded, size: 18),
                      label: Text(context.l10n.ordersPackConfirm),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PackLineRow extends StatelessWidget {
  final PackLine line;

  const _PackLineRow({required this.line});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final numbers = AppTextStyles.bodySmall.copyWith(
      fontFamily: AppTextStyles.mono,
      fontSize: 12,
      color: line.isShort ? c.alert : c.muted,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    line.name,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: c.ink, fontWeight: FontWeight.w600),
                  ),
                  if (line.endsLow) const AppTag.low(),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (line.stock == null)
              Text('−${QuantityFormatter.withUnit(line.quantity, line.unit)}',
                  style: numbers)
            else
              Text.rich(
                TextSpan(children: [
                  TextSpan(text: '${QuantityFormatter.format(line.before)} → '),
                  TextSpan(
                    text: QuantityFormatter.withUnit(line.after, line.unit),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: line.isShort || line.endsLow ? c.alert : c.ink,
                    ),
                  ),
                ]),
                style: numbers,
              ),
          ],
        ),
        if (line.stock != null) ...[
          const SizedBox(height: 6),
          PipStrip(
            total: line.before,
            free: line.after,
            promised: 0,
            removed: line.before - line.after,
            alertLevel: line.stock!.alertLevel,
            unit: line.unit,
            isLow: line.endsLow,
          ),
        ],
      ],
    );
  }
}
