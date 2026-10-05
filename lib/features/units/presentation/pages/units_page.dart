import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
        appBar: AppBar(title: const Text('Units of measure')),
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
                title: 'No units yet',
                message: 'Add what you count things in, like pc, sheet or kg.',
                actionLabel: 'Add unit',
                onAction: () => _edit(context, bloc),
              ),
            ),
          UnitsLoaded(:final units) => _UnitList(units: units, bloc: bloc),
          _ => const Center(child: CircularProgressIndicator()),
        },
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _edit(context, bloc),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Unit'),
        ),
      ),
    );
  }
}

Future<void> _edit(BuildContext context, UnitsBloc bloc,
    {UnitOfMeasure? unit}) async {
  final label = await showUnitSheet(
    context,
    title: unit == null ? 'New unit' : 'Edit ${unit.label}',
    initial: unit?.label,
    actionLabel: unit == null ? 'Add unit' : 'Save',
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
  final action = await showActionSheet<_UnitAction>(
    context,
    title: unit.label,
    subtitle: unit.isDefault ? 'New items start on this' : null,
    actions: [
      const SheetAction(
          value: _UnitAction.edit,
          icon: Icons.edit_outlined,
          label: 'Edit unit'),
      if (!unit.isDefault)
        const SheetAction(
          value: _UnitAction.makeDefault,
          icon: Icons.push_pin_outlined,
          label: 'Use for new items',
        ),
      const SheetAction(
        value: _UnitAction.delete,
        icon: Icons.delete_outline_rounded,
        label: 'Delete',
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
        title: 'Delete ${unit.label}?',
        message: 'Materials and products counted in it keep their numbers, '
            'so move them to another unit first.',
        confirmText: 'Delete',
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
                        const AppTag('Default', type: AppTagType.ok),
                      ReorderableDragStartListener(
                        index: i,
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.drag_indicator_rounded,
                            size: 20,
                            color: c.muted,
                            semanticLabel: 'Drag to reorder',
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
              'Everything you count is written with one of these: stock, '
              'what a product uses, what an order reserves. Long-press one to '
              'rename it, make it the default for new items, or delete it.',
              style: AppTextStyles.bodySmall.copyWith(color: c.muted),
            ),
          ),
        ),
      ],
    );
  }
}
