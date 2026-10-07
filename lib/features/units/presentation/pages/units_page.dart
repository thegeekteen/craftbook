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
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/unit_of_measure.dart';
import '../bloc/units_bloc.dart';
import '../widgets/unit_sheet.dart';

/// What materials and products are counted in: "pc", "sheet", "kg".
///
/// The list is the vocabulary every quantity in the app is written with, so
/// renaming a unit here updates the items using it and the past orders that
/// show them.
class UnitsPage extends StatelessWidget {
  const UnitsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<UnitsBloc>()..add(const LoadUnits()),
      child: const _UnitsView(),
    );
  }
}

class _UnitsView extends StatelessWidget {
  const _UnitsView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UnitsBloc>();
    return BlocConsumer<UnitsBloc, UnitsState>(
      listenWhen: (prev, s) =>
          s is UnitsLoaded &&
          s.message != null &&
          (prev is! UnitsLoaded || prev.serial != s.serial),
      listener: (context, state) {
        final s = state as UnitsLoaded;
        context.showSnackBar(s.message!, isError: s.isError);
      },
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: Text(context.l10n.unitsTitle)),
        body: switch (state) {
          UnitsError(:final message) => Center(
              child: ErrorState(
                message: message,
                onRetry: () => bloc.add(const LoadUnits()),
              ),
            ),
          UnitsLoaded(units: final u) when u.isEmpty => Center(
              child: EmptyState(
                icon: Icons.square_foot_outlined,
                title: context.l10n.unitsEmptyTitle,
                message: context.l10n.unitsEmptyMessage,
                actionLabel: context.l10n.unitsAddButton,
                onAction: () => _edit(context, bloc),
              ),
            ),
          UnitsLoaded(:final units) => _UnitList(units: units, bloc: bloc),
          _ => const Center(child: CircularProgressIndicator()),
        },
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(context, bloc),
          icon: const Icon(Icons.add_rounded),
          label: Text(context.l10n.unitsFab),
        ),
      ),
    );
  }
}

Future<void> _edit(BuildContext context, UnitsBloc bloc,
    {UnitOfMeasure? unit}) async {
  final label = await showUnitSheet(
    context,
    title: unit == null
        ? context.l10n.unitsNew
        : context.l10n.unitsEditTitle(unit.label),
    initial: unit?.label,
    actionLabel:
        unit == null ? context.l10n.unitsAddButton : context.l10n.commonSave,
  );
  if (label == null) return;
  bloc.add(SaveUnitEvent(id: unit?.id, label: label));
}

enum _UnitAction { edit, makeDefault, delete }

/// The long-press menu on a unit.
Future<void> _unitActions(
  BuildContext context,
  UnitsBloc bloc,
  UnitOfMeasure unit,
) async {
  final l10n = context.l10n;
  final action = await showActionSheet<_UnitAction>(
    context,
    title: unit.label,
    subtitle: unit.isDefault ? l10n.unitsDefaultNote : null,
    actions: [
      SheetAction(
          value: _UnitAction.edit,
          icon: Icons.edit_outlined,
          label: l10n.unitsActionEdit),
      if (!unit.isDefault)
        SheetAction(
          value: _UnitAction.makeDefault,
          icon: Icons.push_pin_outlined,
          label: l10n.unitsActionUseForNew,
        ),
      SheetAction(
        value: _UnitAction.delete,
        icon: Icons.delete_outline_rounded,
        label: l10n.commonDelete,
        destructive: true,
      ),
    ],
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case _UnitAction.edit:
      await _edit(context, bloc, unit: unit);
    case _UnitAction.makeDefault:
      bloc.add(SetDefaultUnitEvent(unit.id!));
    case _UnitAction.delete:
      final confirmed = await ConfirmDialog.show(
        context,
        title: l10n.unitsDeleteTitle(unit.label),
        message: l10n.unitsDeleteMessage,
        confirmText: l10n.commonDelete,
        isDestructive: true,
      );
      if (confirmed) bloc.add(DeleteUnitEvent(unit.id!));
  }
}

/// Units in the order they're offered in the pickers, draggable.
class _UnitList extends StatelessWidget {
  final List<UnitOfMeasure> units;
  final UnitsBloc bloc;

  const _UnitList({required this.units, required this.bloc});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.gutter, AppSpacing.xs, AppSpacing.gutter, 0),
          sliver: SliverReorderableList(
            itemCount: units.length,
            onReorderItem: (from, to) => bloc.add(ReorderUnitsEvent(from, to)),
            proxyDecorator: (child, _, __) => Material(
              color: Colors.transparent,
              elevation: 4,
              borderRadius: AppRadii.cardAll,
              child: child,
            ),
            itemBuilder: (context, i) {
              final unit = units[i];
              return Padding(
                key: ValueKey(unit.id),
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  onTap: () => _edit(context, bloc, unit: unit),
                  onLongPress: () => _unitActions(context, bloc, unit),
                  padding: const EdgeInsets.fromLTRB(14, 10, 6, 10),
                  child: Row(
                    children: [
                      Icon(
                        Icons.square_foot_outlined,
                        size: 20,
                        color: unit.isDefault ? c.go : c.muted,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          unit.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyLarge.copyWith(
                              color: c.ink, fontWeight: FontWeight.w600),
                        ),
                      ),
                      if (unit.isDefault)
                        AppTag(context.l10n.unitsDefaultTag,
                            type: AppTagType.ok),
                      ReorderableDragStartListener(
                        index: i,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.drag_indicator_rounded,
                            size: 20,
                            color: c.muted,
                            semanticLabel: context.l10n.unitsDragToReorder,
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
              context.l10n.unitsFooter,
              style: AppTextStyles.bodySmall.copyWith(color: c.muted),
            ),
          ),
        ),
      ],
    );
  }
}
