import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/action_sheet.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/choice_chip_row.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/section_label.dart';
import '../../domain/entities/order_field.dart';
import '../bloc/order_fields_bloc.dart';
import '../bloc/order_fields_event.dart';
import '../bloc/order_fields_state.dart';
import '../widgets/order_field_tile.dart';
import '../../../../core/utils/l10n_extension.dart';
import '../../../../l10n/gen/app_localizations.dart';
import '../order_field_labels.dart';

/// The extra details asked for on every order: address, size, wrap…
class OrderFieldsPage extends StatelessWidget {
  const OrderFieldsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrderFieldsBloc>()..add(const LoadOrderFields()),
      child: const _OrderFieldsView(),
    );
  }
}

class _OrderFieldsView extends StatelessWidget {
  const _OrderFieldsView();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final bloc = context.read<OrderFieldsBloc>();
    return Scaffold(
      appBar: AppBar(title: Text(l10n.orderFieldsTitle)),
      body: BlocConsumer<OrderFieldsBloc, OrderFieldsState>(
        listenWhen: (prev, s) =>
            s is OrderFieldsError ||
            (s is OrderFieldsLoaded &&
                s.hasNotice &&
                (prev is! OrderFieldsLoaded || prev.serial != s.serial)),
        listener: (context, state) {
          if (state is OrderFieldsError) {
            context.showSnackBar(state.message, isError: true);
          }
          if (state is OrderFieldsLoaded) {
            context.showSnackBar(orderFieldNotice(l10n, state),
                isError: state.isError);
          }
        },
        builder: (context, state) {
          if (state is OrderFieldsError) {
            return Center(
              child: ErrorState(
                message: state.message,
                onRetry: () => bloc.add(const LoadOrderFields()),
              ),
            );
          }
          if (state is! OrderFieldsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.isEmpty) {
            return Center(
              child: EmptyState(
                icon: Icons.dashboard_customize_outlined,
                title: l10n.orderFieldsEmptyTitle,
                message: l10n.orderFieldsEmptyMessage,
                actionLabel: l10n.orderFieldsAddField,
                onAction: () => _OrderFieldSheet.open(context, bloc),
              ),
            );
          }
          return _FieldList(state: state, bloc: bloc);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _OrderFieldSheet.open(context, bloc),
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.orderFieldsFab),
      ),
    );
  }
}

/// The snackbar text for the last action in [state].
String orderFieldNotice(AppLocalizations l10n, OrderFieldsLoaded state) {
  final name = state.subject ?? l10n.orderFieldsFallbackName;
  return switch (state.outcome) {
    OrderFieldOutcome.added => l10n.orderFieldsOutcomeAdded(name),
    OrderFieldOutcome.saved => l10n.orderFieldsOutcomeSaved(name),
    OrderFieldOutcome.archived => l10n.orderFieldsOutcomeArchived(name),
    OrderFieldOutcome.deleted => l10n.orderFieldsOutcomeDeleted(name),
    OrderFieldOutcome.restored => l10n.orderFieldsOutcomeRestored(name),
    null => state.message ?? '',
  };
}

class _FieldList extends StatelessWidget {
  final OrderFieldsLoaded state;
  final OrderFieldsBloc bloc;

  const _FieldList({required this.state, required this.bloc});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          sliver: SliverReorderableList(
            itemCount: state.active.length,
            onReorderItem: (from, to) =>
                bloc.add(ReorderOrderFieldsEvent(from, to)),
            proxyDecorator: (child, _, __) => Material(
              color: Colors.transparent,
              elevation: 4,
              borderRadius: AppRadii.cardAll,
              child: child,
            ),
            itemBuilder: (context, i) {
              final field = state.active[i];
              return Padding(
                key: ValueKey(field.id),
                padding: const EdgeInsets.only(bottom: 8),
                child: OrderFieldTile(
                  field: field,
                  onTap: () =>
                      _OrderFieldSheet.open(context, bloc, field: field),
                  onLongPress: () => _fieldActions(context, bloc, field),
                  leading: ReorderableDragStartListener(
                    index: i,
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        size: 20,
                        color: c.muted,
                        semanticLabel: l10n.orderFieldsDragReorder,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SliverPadding(
          padding:
              const EdgeInsets.fromLTRB(16, 0, 16, AppSpacing.fabClearance),
          sliver: SliverList.list(
            children: [
              if (state.archived.isNotEmpty) ...[
                SectionLabel(l10n.orderFieldsArchivedHeader),
                const SizedBox(height: 8),
                for (final field in state.archived) ...[
                  OrderFieldTile(
                    field: field,
                    onLongPress: () => _fieldActions(context, bloc, field),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (!field.isUsed)
                          IconButton(
                            tooltip: l10n.orderFieldsDeleteNamed(field.name),
                            onPressed: () =>
                                _confirmRemove(context, bloc, field),
                            icon: Icon(Icons.delete_outline_rounded,
                                size: 20, color: c.muted),
                          ),
                        TextButton(
                          onPressed: () =>
                              bloc.add(RestoreOrderFieldEvent(field.id!)),
                          child: Text(l10n.commonRestore),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ],
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                child: Text(
                  l10n.orderFieldsFooter,
                  style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _FieldAction { edit, restore, remove }

/// The long-press menu: active fields edit or go, archived ones come back.
Future<void> _fieldActions(
    BuildContext context, OrderFieldsBloc bloc, OrderField field) async {
  final l10n = context.l10n;
  final archived = field.isArchived;
  final action = await showActionSheet<_FieldAction>(
    context,
    title: field.name,
    actions: [
      if (!archived)
        SheetAction(
            value: _FieldAction.edit,
            icon: Icons.edit_outlined,
            label: l10n.orderFieldsEditField),
      if (archived)
        SheetAction(
            value: _FieldAction.restore,
            icon: Icons.unarchive_outlined,
            label: l10n.commonRestore),
      if (!archived || !field.isUsed)
        SheetAction(
          value: _FieldAction.remove,
          icon: field.isUsed
              ? Icons.archive_outlined
              : Icons.delete_outline_rounded,
          label: field.isUsed ? l10n.commonArchive : l10n.commonDelete,
          destructive: true,
        ),
    ],
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case _FieldAction.edit:
      await _OrderFieldSheet.open(context, bloc, field: field);
    case _FieldAction.restore:
      bloc.add(RestoreOrderFieldEvent(field.id!));
    case _FieldAction.remove:
      await _confirmRemove(context, bloc, field);
  }
}

/// Deletes an unused field, or archives a used one, after asking.
Future<bool> _confirmRemove(
  BuildContext context,
  OrderFieldsBloc bloc,
  OrderField field,
) async {
  final l10n = context.l10n;
  final used = field.usageCount;
  final confirmed = await ConfirmDialog.show(
    context,
    title: used > 0
        ? l10n.orderFieldsArchiveTitle(field.name)
        : l10n.orderFieldsDeleteTitle(field.name),
    message: used > 0
        ? l10n.orderFieldsArchiveMessage(used)
        : l10n.orderFieldsDeleteMessage,
    confirmText: used > 0 ? l10n.commonArchive : l10n.commonDelete,
    isDestructive: true,
  );
  if (confirmed) bloc.add(RemoveOrderFieldEvent(field.id!));
  return confirmed;
}

/// Add/edit form in a bottom sheet.
class _OrderFieldSheet extends StatefulWidget {
  final OrderField? field;
  final OrderFieldsBloc bloc;

  const _OrderFieldSheet({this.field, required this.bloc});

  static Future<void> open(BuildContext context, OrderFieldsBloc bloc,
      {OrderField? field}) {
    return showAppSheet(
      context: context,
      title: field == null
          ? context.l10n.orderFieldsNewField
          : context.l10n.orderFieldsEditNamed(field.name),
      builder: (_) => _OrderFieldSheet(field: field, bloc: bloc),
    );
  }

  @override
  State<_OrderFieldSheet> createState() => _OrderFieldSheetState();
}

class _OrderFieldSheetState extends State<_OrderFieldSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.field?.name ?? '');
  late OrderFieldType _type = widget.field?.type ?? OrderFieldType.text;
  late bool _multiline = widget.field?.isMultiline ?? false;
  late final List<TextEditingController> _options = [
    for (final o in widget.field?.options ?? const <String>[])
      TextEditingController(text: o),
    if (widget.field?.options.isEmpty ?? true) TextEditingController(),
  ];

  /// Stored values are encoded for the type, so it's fixed once used.
  bool get _typeLocked => widget.field?.isUsed ?? false;

  @override
  void dispose() {
    _name.dispose();
    for (final o in _options) {
      o.dispose();
    }
    super.dispose();
  }

  void _addOption() => setState(() => _options.add(TextEditingController()));

  void _removeOption(int i) => setState(() => _options.removeAt(i).dispose());

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    widget.bloc.add(SaveOrderFieldEvent(
      id: widget.field?.id,
      name: _name.text,
      type: _type,
      isMultiline: _multiline,
      options: [for (final o in _options) o.text],
    ));
    Navigator.pop(context);
  }

  Future<void> _remove() async {
    if (await _confirmRemove(context, widget.bloc, widget.field!) && mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final field = widget.field;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            autofocus: field == null,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
                labelText: l10n.commonName, hintText: l10n.orderFieldsNameHint),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? l10n.orderFieldsNameRequired
                : null,
          ),
          const SizedBox(height: 4),
          SectionLabel(l10n.orderFieldsTypeLabel),
          const SizedBox(height: 8),
          IgnorePointer(
            ignoring: _typeLocked,
            child: Opacity(
              opacity: _typeLocked ? 0.5 : 1,
              child: ChoiceChipRow<OrderFieldType>.single(
                wrap: true,
                selected: _type,
                onSelected: (t) => setState(() => _type = t),
                options: [
                  for (final t in OrderFieldType.values)
                    ChipOption(t, t.localized(l10n))
                ],
              ),
            ),
          ),
          if (_typeLocked || _type == OrderFieldType.number) ...[
            const SizedBox(height: 6),
            Text(
              _typeLocked
                  ? l10n.orderFieldsTypeLocked
                  : l10n.orderFieldsNumberNote,
              style: AppTextStyles.bodySmall.copyWith(color: c.muted),
            ),
          ],
          if (_type == OrderFieldType.text) ...[
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.orderFieldsMultiline),
              subtitle: Text(l10n.orderFieldsMultilineHint),
              value: _multiline,
              onChanged: (v) => setState(() => _multiline = v),
            ),
          ],
          if (_type == OrderFieldType.choice) ...[
            const SizedBox(height: 4),
            SectionLabel(l10n.orderFieldsChoices),
            const SizedBox(height: 8),
            for (var i = 0; i < _options.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _options[i],
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                            hintText: l10n.orderFieldsChoiceHint(i + 1)),
                        validator: (_) => i == 0 &&
                                _options.every((o) => o.text.trim().isEmpty)
                            ? l10n.orderFieldsChoiceRequired
                            : null,
                      ),
                    ),
                    IconButton(
                      tooltip: l10n.orderFieldsRemoveChoice,
                      onPressed:
                          _options.length > 1 ? () => _removeOption(i) : null,
                      icon: const Icon(Icons.remove_circle_outline_rounded,
                          size: 20),
                    ),
                  ],
                ),
              ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: _addOption,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(l10n.orderFieldsAddChoice),
              ),
            ),
            if (field?.isUsed ?? false)
              Text(
                l10n.orderFieldsChoicesKept,
                style: AppTextStyles.bodySmall.copyWith(color: c.muted),
              ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              if (field != null)
                TextButton(
                  onPressed: _remove,
                  style: TextButton.styleFrom(foregroundColor: c.alert),
                  child: Text(
                      field.isUsed ? l10n.commonArchive : l10n.commonDelete),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _save,
                child: Text(
                    field == null ? l10n.orderFieldsAddField : l10n.commonSave),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
