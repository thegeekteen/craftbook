import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/action_sheet.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../orders/domain/entities/order_discount.dart';
import '../../domain/entities/discount_preset.dart';
import '../bloc/discount_presets_bloc.dart';
import '../widgets/discount_sheet.dart';

/// Discounts the shop gives often, one tap away on the order's review step.
class DiscountsPage extends StatelessWidget {
  const DiscountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          getIt<DiscountPresetsBloc>()..add(const LoadDiscountPresets()),
      child: const _DiscountsView(),
    );
  }
}

class _DiscountsView extends StatelessWidget {
  const _DiscountsView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DiscountPresetsBloc>();
    return BlocConsumer<DiscountPresetsBloc, DiscountPresetsState>(
      listenWhen: (prev, s) =>
          s is DiscountPresetsLoaded &&
          s.message != null &&
          (prev is! DiscountPresetsLoaded || prev.serial != s.serial),
      listener: (context, state) {
        final s = state as DiscountPresetsLoaded;
        context.showSnackBar(s.message!, isError: s.isError);
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.discountsTitle)),
        body: switch (state) {
          DiscountPresetsError(:final message) => Center(
              child: ErrorState(
                message: message,
                onRetry: () => bloc.add(const LoadDiscountPresets()),
              ),
            ),
          DiscountPresetsLoaded(presets: final p) when p.isEmpty => Center(
              child: EmptyState(
                icon: Icons.local_offer_outlined,
                title: context.l10n.discountsEmptyTitle,
                message: context.l10n.discountsEmptyMessage,
                actionLabel: context.l10n.discountsAddButton,
                onAction: () => _edit(context, bloc),
              ),
            ),
          DiscountPresetsLoaded(:final presets) =>
            _PresetList(presets: presets, bloc: bloc),
          _ => const Center(child: CircularProgressIndicator()),
        },
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(context, bloc),
          icon: const Icon(Icons.add_rounded),
          label: Text(context.l10n.discountsFab),
        ),
      ),
    );
  }
}

Future<void> _edit(BuildContext context, DiscountPresetsBloc bloc,
    {DiscountPreset? preset}) async {
  final result = await showDiscountSheet(
    context,
    title: preset == null
        ? context.l10n.discountsNew
        : context.l10n.discountsEditTitle(preset.label),
    initial: preset?.toDiscount(),
    actionLabel: preset == null
        ? context.l10n.discountsAddButton
        : context.l10n.commonSave,
  );
  if (result == null) return;
  bloc.add(SaveDiscountPresetEvent(
    id: preset?.id,
    label: result.label,
    kind: result.kind,
    value: result.value,
  ));
}

enum _PresetAction { edit, delete }

/// The long-press menu on a preset.
Future<void> _presetActions(BuildContext context, DiscountPresetsBloc bloc,
    DiscountPreset preset) async {
  final l10n = context.l10n;
  final action = await showActionSheet<_PresetAction>(
    context,
    title: preset.label,
    subtitle: discountValueLabel(preset.kind, preset.value),
    actions: [
      SheetAction(
          value: _PresetAction.edit,
          icon: Icons.edit_outlined,
          label: l10n.discountsActionEdit),
      SheetAction(
          value: _PresetAction.delete,
          icon: Icons.delete_outline_rounded,
          label: l10n.commonDelete,
          destructive: true),
    ],
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case _PresetAction.edit:
      await _edit(context, bloc, preset: preset);
    case _PresetAction.delete:
      final confirmed = await ConfirmDialog.show(
        context,
        title: l10n.discountsDeleteTitle(preset.label),
        message: l10n.discountsDeleteMessage,
        confirmText: l10n.commonDelete,
        isDestructive: true,
      );
      if (confirmed) bloc.add(DeleteDiscountPresetEvent(preset.id!));
  }
}

/// Presets in the order they show on an order, draggable.
class _PresetList extends StatelessWidget {
  final List<DiscountPreset> presets;
  final DiscountPresetsBloc bloc;

  const _PresetList({required this.presets, required this.bloc});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter, AppSpacing.xs, AppSpacing.gutter, 0),
          sliver: SliverReorderableList(
            itemCount: presets.length,
            onReorderItem: (from, to) =>
                bloc.add(ReorderDiscountPresetsEvent(from, to)),
            proxyDecorator: (child, _, __) => Material(
              color: Colors.transparent,
              elevation: 4,
              borderRadius: AppRadii.cardAll,
              child: child,
            ),
            itemBuilder: (context, i) {
              final p = presets[i];
              return Padding(
                key: ValueKey(p.id),
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  onTap: () => _edit(context, bloc, preset: p),
                  onLongPress: () => _presetActions(context, bloc, p),
                  padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                  child: Row(
                    children: [
                      Icon(
                        p.kind == DiscountKind.percent
                            ? Icons.percent_rounded
                            : Icons.sell_outlined,
                        size: 20,
                        color: c.go,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          p.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyLarge.copyWith(
                              color: c.ink, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Text(
                        '−${discountValueLabel(p.kind, p.value)}',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: c.go,
                          fontWeight: FontWeight.w600,
                          fontFeatures: AppTextStyles.tabular.fontFeatures,
                        ),
                      ),
                      ReorderableDragStartListener(
                        index: i,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.drag_indicator_rounded,
                            size: 20,
                            color: c.muted,
                            semanticLabel: context.l10n.discountsDragToReorder,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SliverPadding(
          padding:
              const EdgeInsets.fromLTRB(20, 8, 20, AppSpacing.fabClearance),
          sliver: SliverToBoxAdapter(
            child: Text(
              context.l10n.discountsFooter,
              style: AppTextStyles.bodySmall.copyWith(color: c.muted),
            ),
          ),
        ),
      ],
    );
  }
}
