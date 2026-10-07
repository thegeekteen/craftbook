import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/error/result.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/inline_banner.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/status_filter_chips.dart';
import '../../../../core/widgets/summary_board.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/domain/usecases/delete_note.dart';
import '../../../notes/domain/usecases/restore_note.dart';
import '../../../notes/domain/usecases/set_note_pinned.dart';
import '../../../notes/presentation/widgets/note_actions.dart';
import '../../../notes/presentation/widgets/note_card.dart';
import '../../../orders/domain/entities/order.dart';
import '../../../orders/domain/entities/order_list_entry.dart';
import '../../../orders/presentation/widgets/order_actions.dart';
import '../../../orders/presentation/widgets/order_card.dart';
import '../../../settings/domain/entities/order_amount_shown.dart';
import '../../../settings/presentation/bloc/order_amount_cubit.dart';
import '../../domain/usecases/get_today_dashboard.dart';
import '../bloc/today_bloc.dart';
import '../bloc/today_event.dart';
import '../bloc/today_state.dart';

/// Today: what to pack, what came in, and what's running out.
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TodayBloc>()..add(const LoadToday()),
      child: const _TodayView(),
    );
  }
}

class _TodayView extends StatefulWidget {
  const _TodayView();

  @override
  State<_TodayView> createState() => _TodayViewState();
}

class _TodayViewState extends State<_TodayView> {
  /// Today is about orders; the rest of the pinned notes are a tap away.
  static const _pinnedNotesShown = 3;

  Set<OrderStatus> _statusFilter = Set.from(StatusFilterChips.dayViewStatuses);

  void _reload() => context.read<TodayBloc>().add(const LoadToday());

  /// Pushes [location] and reloads when the child reports a change.
  Future<void> _open(String location) async {
    final changed = await context.push<bool>(location);
    if (changed == true && mounted) _reload();
  }

  /// The note editor pops with `true` after a save and with the note after a
  /// delete; either way Today's pinned list may have changed.
  Future<void> _openNote(int id) async {
    final result = await context.push<Object?>(RouteNames.notePath(id));
    if (result != null && mounted) _reload();
  }

  Future<void> _openNotes() async {
    await context.push(RouteNames.notes);
    if (mounted) _reload();
  }

  Future<void> _orderActions(Order order) async {
    if (await OrderActions.open(context, order) && mounted) _reload();
  }

  /// The notebook's long-press menu, carried out without the Notes bloc.
  Future<void> _noteActions(Note note) async {
    final action = await NoteActions.pick(context, note);
    if (action == null || !mounted) return;
    switch (action) {
      case NoteAction.togglePin:
        _report(await getIt<SetNotePinned>()(note.id!, !note.isPinned));
      case NoteAction.delete:
        if (!await NoteActions.confirmDelete(context, note) || !mounted) return;
        final deleted = context.l10n.todayNoteDeleted(note.displayTitle);
        _report(await getIt<DeleteNote>()(note.id!),
            message: deleted,
            undo: () async => _report(await getIt<RestoreNote>()(note)));
    }
  }

  /// Reloads after a note change, or says why it failed.
  void _report(Result<void> result, {String? message, VoidCallback? undo}) {
    if (!mounted) return;
    switch (result) {
      case Error(:final failure):
        context.showSnackBar(failure.message, isError: true);
      case Success():
        _reload();
        if (message != null) context.showSnackBar(message, onAction: undo);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final now = DateTime.now();
    final locale = Localizations.localeOf(context).toString();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DateFormat('EEEE', locale).format(now).toUpperCase(),
              style: AppTextStyles.monoLabel.copyWith(color: c.muted),
            ),
            Text(DateFormat('MMMM d', locale).format(now)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: context.l10n.todayCalendar,
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () => _open(RouteNames.calendarWeek),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: BlocConsumer<TodayBloc, TodayState>(
        listener: (context, state) {
          if (state is TodayError) {
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return switch (state) {
            TodayLoaded(:final dashboard, :final pinnedNotes) =>
              _buildDashboard(dashboard, pinnedNotes),
            TodayError(:final message) =>
              Center(child: ErrorState(message: message, onRetry: _reload)),
            _ => const Center(child: CircularProgressIndicator()),
          };
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _open(RouteNames.newOrder),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.ordersNewOrder),
      ),
    );
  }

  Widget _buildDashboard(TodayDashboard d, List<Note> pinnedNotes) {
    final c = context.colors;
    bool shown(OrderListEntry e) => _statusFilter.contains(e.order.status);
    final due = d.due.where(shown).toList();
    final placed = d.placedToday.where(shown).toList();

    final counts = <OrderStatus, int>{};
    final seen = <int?>{};
    for (final e in [...d.due, ...d.placedToday]) {
      if (seen.add(e.order.id)) {
        counts[e.order.status] = (counts[e.order.status] ?? 0) + 1;
      }
    }

    final alerts = d.alerts;
    final names = alerts.names.take(2).join(', ');
    final more = alerts.names.length > 2 ? '…' : '';

    return RefreshIndicator(
      onRefresh: () {
        final done = Completer<void>();
        context.read<TodayBloc>().add(LoadToday(done: done));
        return done.future;
      },
      child: ListView(
        padding: AppSpacing.page.copyWith(bottom: AppSpacing.fabClearance),
        children: [
          SummaryBoard(
            label: context.l10n.todayToPackToday,
            value: '${d.toPackCount}',
            stats: [
              BoardStat(
                  label: context.l10n.todayNewToday,
                  value: '${d.placedToday.length}'),
              BoardStat(
                label: context.l10n.ordersOverdue,
                value: '${d.overdueCount}',
                labelColor: d.overdueCount > 0 ? c.alert : null,
              ),
              BoardStat(
                label: context.l10n.todayWeekProfit,
                value: CurrencyFormatter.formatCompact(d.weekProfit),
              ),
            ],
            onTap: () => context.go(RouteNames.orders),
          ),
          if (alerts.hasAlerts) ...[
            const SizedBox(height: 12),
            InlineBanner(
              icon: Icons.warning_amber_rounded,
              title: context.l10n.todayLowStock(alerts.lowStockCount),
              message: '$names$more',
              actionLabel: context.l10n.todayBuyList,
              onTap: () => _open(RouteNames.buyList),
            ),
          ],
          if (pinnedNotes.isNotEmpty) ...[
            const SizedBox(height: 8),
            SectionLabel(
              context.l10n.todayPinnedNotes(pinnedNotes.length),
              trailing: SectionAction(
                  label: context.l10n.todayAllNotes, onTap: _openNotes),
            ),
            const SizedBox(height: 8),
            for (final note in pinnedNotes.take(_pinnedNotesShown))
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: NoteCard(
                    note: note,
                    compact: true,
                    onTap: () => _openNote(note.id!),
                    onLongPress: () => _noteActions(note)),
              ),
          ],
          const SizedBox(height: 16),
          StatusFilterChips(
            selected: _statusFilter,
            counts: counts,
            onChanged: (s) => setState(() => _statusFilter = s),
          ),
          if (due.isNotEmpty) ...[
            const SizedBox(height: 8),
            SectionLabel(context.l10n.todayShipsToday(due.length)),
            const SizedBox(height: 8),
            ..._cards(due),
          ],
          if (placed.isNotEmpty) ...[
            const SizedBox(height: 8),
            SectionLabel(context.l10n.todayNewTodaySection(placed.length)),
            const SizedBox(height: 8),
            ..._cards(placed),
          ],
          if (due.isEmpty && placed.isEmpty)
            EmptyState(
              icon: Icons.local_florist_outlined,
              title: d.due.isEmpty && d.placedToday.isEmpty
                  ? context.l10n.todayAllClear
                  : context.l10n.todayNoFilterMatch,
              message: d.due.isEmpty && d.placedToday.isEmpty
                  ? context.l10n.todayAllClearMessage
                  : context.l10n.todayPickAnotherStatus,
            ),
        ],
      ),
    );
  }

  List<Widget> _cards(List<OrderListEntry> entries) => [
        for (final e in entries)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: BlocBuilder<OrderAmountCubit, OrderAmountShown>(
              bloc: getIt(),
              builder: (context, shown) => OrderCard(
                entry: e,
                amountShown: shown,
                onTap: () => _open(RouteNames.orderPath(e.order.id!)),
                onLongPress: () => _orderActions(e.order),
              ),
            ),
          ),
      ];
}
