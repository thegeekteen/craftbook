import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/summary_board.dart';
import '../../domain/usecases/get_receivables.dart';
import '../bloc/receivables_cubit.dart';
import '../widgets/order_actions.dart';
import '../widgets/order_card.dart';

/// Accounts receivable: every unpaid order, grouped by customer.
class ReceivablesPage extends StatelessWidget {
  const ReceivablesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ReceivablesCubit>()..load(),
      child: const _ReceivablesView(),
    );
  }
}

class _ReceivablesView extends StatelessWidget {
  const _ReceivablesView();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ReceivablesCubit>();
    return Scaffold(
      appBar: AppBar(title: const Text('Waiting for payment')),
      body: BlocBuilder<ReceivablesCubit, ReceivablesState>(
        builder: (context, state) => switch (state) {
          ReceivablesError(:final message) =>
            Center(child: ErrorState(message: message, onRetry: cubit.load)),
          ReceivablesLoaded(:final receivables) when receivables.isEmpty =>
            const Center(
              child: EmptyState(
                icon: Icons.check_circle_outline_rounded,
                title: 'Everyone has paid',
                message: 'Orders marked unpaid will show up here.',
              ),
            ),
          ReceivablesLoaded(:final receivables) =>
            _List(receivables: receivables, onChanged: cubit.load),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _List extends StatelessWidget {
  final Receivables receivables;
  final Future<void> Function() onChanged;

  const _List({required this.receivables, required this.onChanged});

  Future<void> _open(BuildContext context, int orderId) async {
    final changed = await context.push<bool>(RouteNames.orderPath(orderId));
    if (changed == true) await onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final count = receivables.orderCount;
    return RefreshIndicator(
      onRefresh: onChanged,
      child: ListView(
        padding: AppSpacing.page.copyWith(top: 4),
        children: [
          SummaryBoard(
            label: 'Owed to you · $count ${count == 1 ? 'order' : 'orders'}',
            value: CurrencyFormatter.formatShort(receivables.total),
          ),
          const SizedBox(height: 12),
          for (final g in receivables.groups) ...[
            SectionLabel(
                '${g.customerName} · ${CurrencyFormatter.formatShort(g.total)}'),
            const SizedBox(height: 8),
            for (final e in g.entries)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: OrderCard(
                  entry: e,
                  onTap: () => _open(context, e.order.id!),
                  onLongPress: () async {
                    if (await OrderActions.open(context, e.order)) {
                      await onChanged();
                    }
                  },
                ),
              ),
            const SizedBox(height: 4),
          ],
          Text(
            'Mark an order paid from its page or by long-pressing it.',
            style: AppTextStyles.bodySmall.copyWith(color: c.muted),
          ),
        ],
      ),
    );
  }
}
