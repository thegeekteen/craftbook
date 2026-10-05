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
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_tag.dart';
import '../../../../core/widgets/bottom_action_bar.dart';
import '../../../../core/widgets/choice_chip_row.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/date_field.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/inline_banner.dart';
import '../../../../core/widgets/money_breakdown.dart';
import '../../../../core/widgets/product_photo.dart';
import '../../../../core/widgets/section_label.dart';
import '../../../../core/widgets/stepper_input.dart';
import '../../../order_fields/domain/entities/order_field.dart';
import '../../../order_fields/domain/order_field_codec.dart';
import '../../../order_fields/domain/usecases/get_order_fields.dart';
import '../../../order_fields/presentation/widgets/order_field_input.dart';
import '../../../products/domain/entities/channel.dart';
import '../../../products/domain/usecases/get_channels.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/usecases/preview_order.dart';
import '../bloc/new_order_bloc.dart';
import '../bloc/new_order_event.dart';
import '../bloc/new_order_state.dart';
import '../widgets/note_field.dart';
import '../widgets/product_picker_sheet.dart';
import '../widgets/order_status_ui.dart';
import '../widgets/order_terms_card.dart';
import '../../domain/entities/order_money.dart';
import '../../../discounts/domain/entities/discount_preset.dart';
import '../../../discounts/domain/repositories/discount_preset_repository.dart';
import '../../../settings/presentation/bloc/tax_settings_cubit.dart';

/// New order: Customer → Items → Review. With [orderId] it edits that order
/// instead: pending orders go through all three steps, packed orders only
/// get the details form (items are locked), shipped orders only the note.
class NewOrderPage extends StatelessWidget {
  final int? orderId;

  const NewOrderPage({super.key, this.orderId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NewOrderBloc>()
        ..add(orderId == null ? ResetOrder() : LoadExistingOrder(orderId!)),
      child: _NewOrderView(orderId: orderId),
    );
  }
}

class _NewOrderView extends StatefulWidget {
  final int? orderId;

  const _NewOrderView({this.orderId});

  @override
  State<_NewOrderView> createState() => _NewOrderViewState();
}

class _NewOrderViewState extends State<_NewOrderView> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  int _step = 0;

  final _nameController = TextEditingController();

  /// Active custom fields, asked for after the customer name.
  List<OrderField> _fields = [];

  /// Values typed into [_fields], by field id. Blank means cleared.
  final Map<int, String> _fieldValues = {};

  /// Stored note (Quill Delta JSON, or legacy plain text); edited on its own
  /// page, so it needs no controller here.
  String? _note;
  DateTime _orderDate = DateUtils.dateOnly(DateTime.now());
  DateTime _shipByDate =
      DateUtils.dateOnly(DateTime.now()).add(const Duration(days: 2));
  int? _channelId;
  List<Channel> _channels = [];
  bool _channelsLoaded = false;

  /// True once the form has been filled from the order being edited.
  bool _seeded = false;
  OrderStatus? _editingStatus;

  bool get _isEditing => widget.orderId != null;

  /// Packed and shipped orders have had their stock deducted, so items stay.
  bool get _itemsLocked =>
      _editingStatus == OrderStatus.packed ||
      _editingStatus == OrderStatus.shipped;

  /// Shipped orders are history; only the note can change.
  bool get _noteOnly => _editingStatus == OrderStatus.shipped;

  List<String> get _stepNames =>
      _itemsLocked ? const ['Details'] : const ['Customer', 'Items', 'Review'];

  /// Inactive channels are hidden, except the one this order already uses.
  List<Channel> get _visibleChannels => [
        for (final ch in _channels)
          if (ch.isActive || ch.id == _channelId) ch,
      ];

  @override
  void initState() {
    super.initState();
    _loadChannels();
    _loadFields();
    _loadPresets();
  }

  List<DiscountPreset> _presets = [];

  Future<void> _loadPresets() async {
    final result = await getIt<DiscountPresetRepository>().getPresets();
    if (!mounted) return;
    switch (result) {
      case Success(:final value):
        setState(() => _presets = value);
      case Error(:final failure):
        context.showSnackBar(failure.message, isError: true);
    }
  }

  /// Discounts, tax and paid, wired to the bloc.
  Widget _termsCard(NewOrderDetailsFilled d) {
    final bloc = context.read<NewOrderBloc>();
    return OrderTermsCard(
      itemsTotal: d.totalSales,
      terms: d.terms,
      availableTax: d.availableTax,
      taxLabel: getIt<TaxSettingsCubit>().state.label,
      presets: _presets,
      onAddDiscount: (discount) => bloc.add(AddDiscount(discount)),
      onRemoveDiscount: (i) => bloc.add(RemoveDiscount(i)),
      onTaxChanged: (on) => bloc.add(SetOrderTaxEnabled(on)),
      onPaidChanged: (paid) => bloc.add(SetOrderPaidStatus(paid)),
      onManagePresets: () async {
        await context.push(RouteNames.discounts);
        if (mounted) _loadPresets();
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadChannels() async {
    final result = await getIt<GetChannels>()(activeOnly: !_isEditing);
    if (!mounted) return;
    setState(() {
      _channelsLoaded = true;
      if (result case Success(:final value)) {
        _channels = value;
        if (_channelId == null && value.isNotEmpty) {
          _channelId = value.where((c) => c.isActive).firstOrNull?.id;
        }
      }
    });
    if (result case Error(:final failure)) {
      context.showSnackBar(failure.message, isError: true);
    }
  }

  Future<void> _loadFields() async {
    final result = await getIt<GetOrderFields>()(includeArchived: false);
    if (!mounted) return;
    switch (result) {
      case Success(:final value):
        setState(() => _fields = value);
      case Error(:final failure):
        context.showSnackBar(failure.message, isError: true);
    }
  }

  /// Every shown field, so one emptied on the form is cleared on save.
  Map<int, String> get _formFieldValues => {
        for (final f in _fields) f.id!: _fieldValues[f.id] ?? '',
      };

  Channel? get _channel =>
      _visibleChannels.where((c) => c.id == _channelId).firstOrNull;

  void _goTo(int step) {
    FocusScope.of(context).unfocus();
    setState(() => _step = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
    if (step == 2) context.read<NewOrderBloc>().add(RequestPreview());
  }

  void _submitDetails() {
    if (!_formKey.currentState!.validate()) return;
    if (_channelId == null) {
      context.showSnackBar('Pick a sales channel', isError: true);
      return;
    }
    context.read<NewOrderBloc>().add(SetCustomerDetails(
          customerName: _nameController.text.trim(),
          fieldValues: _formFieldValues,
          channelId: _channelId!,
          orderDate: _orderDate,
          shipByDate: _shipByDate,
          note: _note,
          channelPaidByDefault: _channel?.paidByDefault ?? true,
        ));
    _goTo(1);
  }

  void _seed(NewOrderDetailsFilled d) {
    _seeded = true;
    _editingStatus = d.editingStatus;
    _nameController.text = d.customerName;
    _fieldValues
      ..clear()
      ..addAll(d.fieldValues);
    _note = d.note;
    _orderDate = DateUtils.dateOnly(d.orderDate);
    _shipByDate = DateUtils.dateOnly(d.shipByDate);
    _channelId = d.channelId == 0 ? _channelId : d.channelId;
  }

  /// Packed and shipped orders have no later steps, so the details form saves
  /// straight away.
  void _saveDetailsOnly() {
    if (!_formKey.currentState!.validate()) return;
    if (_channelId == null) {
      context.showSnackBar('Pick a sales channel', isError: true);
      return;
    }
    final bloc = context.read<NewOrderBloc>();
    bloc.add(SetCustomerDetails(
      customerName: _nameController.text.trim(),
      fieldValues: _formFieldValues,
      channelId: _channelId!,
      orderDate: _orderDate,
      shipByDate: _shipByDate,
      note: _note,
      channelPaidByDefault: _channel?.paidByDefault ?? true,
    ));
    bloc.add(SaveOrder());
  }

  Future<bool> _confirmDiscard(List<OrderItemInput> items) async {
    final dirty = _isEditing ||
        _nameController.text.trim().isNotEmpty ||
        _note != null ||
        _fieldValues.values.any((v) => v.isNotEmpty) ||
        items.isNotEmpty;
    if (!dirty) return true;
    return ConfirmDialog.show(
      context,
      title: _isEditing ? 'Discard your changes?' : 'Discard this order?',
      message: _isEditing
          ? 'The order stays as it was.'
          : "What you've entered so far will be lost.",
      confirmText: 'Discard',
      cancelText: 'Keep editing',
      isDestructive: true,
    );
  }

  Future<void> _handleBack(List<OrderItemInput> items) async {
    if (_step > 0) {
      _goTo(_step - 1);
      return;
    }
    if (await _confirmDiscard(items) && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewOrderBloc, NewOrderState>(
      listener: (context, state) {
        if (state is NewOrderDetailsFilled && _isEditing && !_seeded) {
          setState(() => _seed(state));
        }
        if (state is NewOrderSaved) {
          context.showSnackBar(_isEditing
              ? 'Order #${state.orderId} updated'
              : 'Order #${state.orderId} saved');
          context.pop(true);
        }
        if (state is NewOrderError) {
          context.showSnackBar(state.message, isError: true);
          // Couldn't even load the order to edit; nothing to show.
          if (_isEditing && !_seeded) context.pop();
        }
      },
      buildWhen: (_, s) => s is! NewOrderError,
      builder: (context, state) {
        final details = state is NewOrderDetailsFilled ? state : null;
        final items = details?.items ?? const <OrderItemInput>[];

        if (_isEditing && !_seeded) {
          return Scaffold(
            appBar: AppBar(title: const Text('Edit order')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _handleBack(items);
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                tooltip: _step == 0 ? 'Close' : 'Back',
                icon: Icon(_step == 0
                    ? Icons.close_rounded
                    : Icons.arrow_back_rounded),
                onPressed: () => _handleBack(items),
              ),
              title: Text(
                  _isEditing ? 'Edit order #${widget.orderId}' : 'New order'),
              bottom: _itemsLocked
                  ? null
                  : PreferredSize(
                      preferredSize: const Size.fromHeight(40),
                      child: _StepHeader(names: _stepNames, current: _step),
                    ),
            ),
            body: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildCustomerStep(details),
                if (!_itemsLocked) ...[
                  _buildItemsStep(items),
                  _buildReviewStep(details),
                ],
              ],
            ),
            bottomNavigationBar: _itemsLocked
                ? _buildDetailsOnlyBar(details)
                : _buildBottomBar(details, items),
          ),
        );
      },
    );
  }

  // ── Step 1 ───────────────────────────────────────────────────────────

  Widget _buildCustomerStep(NewOrderDetailsFilled? details) {
    return Form(
      key: _formKey,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: AppSpacing.page.copyWith(top: 12, bottom: 0),
            sliver: SliverList.list(
              children: [
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  enabled: !_noteOnly,
                  decoration: const InputDecoration(labelText: 'Customer name'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Enter the customer name'
                      : null,
                ),
                for (final field in _fields) ...[
                  const SizedBox(height: 12),
                  _lockedField(OrderFieldInput(
                    key: ValueKey(field.id),
                    field: field,
                    value: _fieldValues[field.id],
                    enabled: !_noteOnly,
                    onChanged: (v) =>
                        setState(() => _fieldValues[field.id!] = v),
                  )),
                ],
                if (_fields.isEmpty && !_isEditing)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: TextButton.icon(
                      icon: const Icon(Icons.add_rounded, size: 18),
                      label: const Text('Add order fields (address, size…)'),
                      onPressed: () async {
                        await context.push(RouteNames.orderFields);
                        if (mounted) _loadFields();
                      },
                    ),
                  )
                else
                  const SizedBox(height: 8),
                const SectionLabel('Channel'),
                const SizedBox(height: 8),
                if (!_channelsLoaded)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: LinearProgressIndicator(),
                  )
                else if (_visibleChannels.isEmpty)
                  InlineBanner(
                    icon: Icons.storefront_outlined,
                    tone: BannerTone.warn,
                    title: 'No sales channels yet.',
                    message: 'Add one to work out fees.',
                    actionLabel: 'Add',
                    onTap: () async {
                      await context.push(RouteNames.channels);
                      if (mounted) _loadChannels();
                    },
                  )
                else
                  _locked(ChoiceChipRow<int?>.single(
                    wrap: true,
                    selected: _channelId,
                    onSelected: (id) => setState(() => _channelId = id),
                    options: [
                      for (final ch in _visibleChannels)
                        ChipOption(ch.id, ch.name)
                    ],
                  )),
                const SizedBox(height: 16),
                _locked(Row(
                  children: [
                    Expanded(
                      child: DateField(
                        label: 'Order date',
                        value: _orderDate,
                        onChanged: (d) => setState(() {
                          _orderDate = d;
                          if (_shipByDate.isBefore(d)) _shipByDate = d;
                        }),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: DateField(
                        label: 'Ship by',
                        value: _shipByDate,
                        firstDate: _orderDate,
                        onChanged: (d) => setState(() => _shipByDate = d),
                      ),
                    ),
                  ],
                )),
                // Packed orders have no review step, but their money can
                // still change.
                if (_editingStatus == OrderStatus.packed &&
                    details != null) ...[
                  const SizedBox(height: 16),
                  _termsCard(details),
                ],
              ],
            ),
          ),
          // The note takes whatever height the fields above leave, so a long
          // checklist reads in full and a short form isn't half empty.
          SliverFillRemaining(
            hasScrollBody: false,
            child: Padding(
              padding: AppSpacing.page.copyWith(top: 12),
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 140),
                child: NoteField(
                  note: _note,
                  onChanged: (value) => setState(() => _note = value),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dims and blocks [child] when only the note may change.
  Widget _locked(Widget child) => _noteOnly
      ? IgnorePointer(child: Opacity(opacity: 0.5, child: child))
      : child;

  /// Text boxes grey themselves out when disabled; dates and chips need
  /// [_locked] to look and act the same.
  Widget _lockedField(OrderFieldInput input) => switch (input.field.type) {
        OrderFieldType.text || OrderFieldType.number => input,
        OrderFieldType.date || OrderFieldType.choice => _locked(input),
      };

  // ── Step 2 ───────────────────────────────────────────────────────────

  void _openPicker(List<OrderItemInput> items) {
    final bloc = context.read<NewOrderBloc>();
    ProductPickerSheet.show(
      context,
      addedProductIds: [for (final i in items) i.productId],
      onSelected: (item) => bloc.add(AddItem(
        productId: item.productId,
        productName: item.productName,
        quantity: item.quantity,
        unitPrice: item.unitPrice,
        photo: item.photo,
      )),
    );
  }

  Widget _buildItemsStep(List<OrderItemInput> items) {
    final c = context.colors;
    if (items.isEmpty) {
      return Center(
        child: EmptyState(
          icon: Icons.add_shopping_cart_rounded,
          title: 'No items yet',
          message: 'Add the products this customer ordered.',
          actionLabel: 'Add product',
          onAction: () => _openPicker(items),
        ),
      );
    }
    return ListView(
      padding: AppSpacing.page.copyWith(top: 12),
      children: [
        AppCard.flush(
          child: CardList(
            children: [
              for (final item in items)
                CardRow(
                  leading:
                      ProductPhoto(bytes: item.photo, name: item.productName),
                  title: Text(item.productName),
                  subtitle: Text(
                    '${CurrencyFormatter.formatShort(item.unitPrice)} each · '
                    '${CurrencyFormatter.formatShort(item.subtotal)}',
                  ),
                  trailing: StepperInput(
                    value: item.quantity,
                    min: 0,
                    onChanged: (v) {
                      final bloc = context.read<NewOrderBloc>();
                      if (v.toInt() == 0) {
                        bloc.add(RemoveItem(item.productId));
                      } else {
                        bloc.add(UpdateItemQuantity(
                          productId: item.productId,
                          quantity: v.toInt(),
                        ));
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: () => _openPicker(items),
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text('Add product'),
        ),
        const SizedBox(height: 10),
        Text(
          'Set a quantity to 0 to remove it.',
          textAlign: TextAlign.center,
          style: AppTextStyles.bodySmall.copyWith(color: c.muted),
        ),
      ],
    );
  }

  // ── Step 3 ───────────────────────────────────────────────────────────

  Widget _buildReviewStep(NewOrderDetailsFilled? d) {
    final c = context.colors;
    if (d == null) return const SizedBox.shrink();
    final pieces = d.items.fold<int>(0, (s, i) => s + i.quantity);
    final preview = d.preview;

    return ListView(
      padding: AppSpacing.page.copyWith(top: 12),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      d.customerName,
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: c.ink, fontSize: 16),
                    ),
                  ),
                  if (_channel != null)
                    AppTag(_channel!.name, type: AppTagType.outline),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Ships by ${DateFormat('EEE, MMM d').format(d.shipByDate)} · '
                '$pieces ${pieces == 1 ? 'item' : 'items'}',
                style: AppTextStyles.bodySmall.copyWith(color: c.muted),
              ),
              for (final field in _fields)
                if (d.fieldValues[field.id]?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 2),
                  Text(
                    '${field.name}: ${OrderFieldCodec.display(field, d.fieldValues[field.id]!)}',
                    style: AppTextStyles.bodySmall.copyWith(color: c.muted),
                  ),
                ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        _termsCard(d),
        const SizedBox(height: 12),
        if (d.isPreviewing || (preview == null && d.previewError == null))
          const AppCard(
            child: SizedBox(
              height: 120,
              child: Center(child: CircularProgressIndicator()),
            ),
          )
        else if (d.previewError != null)
          ErrorState(
            message: d.previewError!,
            onRetry: () => context.read<NewOrderBloc>().add(RequestPreview()),
          )
        else ...[
          _MoneyPreviewCard(preview: preview!, channelName: _channel?.name),
          const SizedBox(height: 12),
          if (preview.reservations.any((r) => r.isShort)) ...[
            const InlineBanner(
              icon: Icons.warning_amber_rounded,
              title: 'Not enough stock for some pieces.',
              message:
                  'You can still save; the buy list will show what to get.',
            ),
            const SizedBox(height: 12),
          ],
          if (preview.reservations.isNotEmpty)
            _ReservationsCard(lines: preview.reservations),
        ],
      ],
    );
  }

  // ── Bottom bar ───────────────────────────────────────────────────────

  Widget _buildDetailsOnlyBar(NewOrderDetailsFilled? d) {
    final saving = d?.isSaving ?? false;
    return BottomActionBar(children: [
      Expanded(
        child: FilledButton(
          onPressed: saving ? null : _saveDetailsOnly,
          child: Text(saving ? 'Saving…' : 'Save changes'),
        ),
      ),
    ]);
  }

  Widget _buildBottomBar(NewOrderDetailsFilled? d, List<OrderItemInput> items) {
    final total =
        CurrencyFormatter.formatShort(d?.preview?.money.customerPays ??
            (d == null
                ? 0
                : OrderMoney.compute(
                    itemsTotal: d.totalSales,
                    discounts: d.terms.discounts,
                    tax: d.terms.tax,
                  ).customerPays));
    switch (_step) {
      case 0:
        return BottomActionBar(children: [
          Expanded(
            child: FilledButton(
              onPressed: _submitDetails,
              child: const Text('Next: add items'),
            ),
          ),
        ]);
      case 1:
        return BottomActionBar(children: [
          BarTotal(label: 'Total', value: total),
          FilledButton(
            onPressed: items.isEmpty ? null : () => _goTo(2),
            child: const Text('Review'),
          ),
        ]);
      default:
        final saving = d?.isSaving ?? false;
        return BottomActionBar(children: [
          BarTotal(label: 'Total', value: total),
          FilledButton.icon(
            onPressed: saving || d?.preview == null
                ? null
                : () => context.read<NewOrderBloc>().add(SaveOrder()),
            icon: saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check_rounded, size: 20),
            label: Text(_isEditing ? 'Save changes' : 'Save order'),
          ),
        ]);
    }
  }
}

/// Labelled progress bars under the app bar.
class _StepHeader extends StatelessWidget {
  final List<String> names;
  final int current;

  const _StepHeader({required this.names, required this.current});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          for (var i = 0; i < names.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: 4,
                    decoration: BoxDecoration(
                      color: i <= current ? c.go : c.hair,
                      borderRadius: AppRadii.pillAll,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${i + 1}  ${names[i]}',
                    style: AppTextStyles.bodySmall.copyWith(
                      fontSize: 12,
                      color: i == current ? c.ink : c.muted,
                      fontWeight:
                          i == current ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MoneyPreviewCard extends StatelessWidget {
  final OrderPreview preview;
  final String? channelName;

  const _MoneyPreviewCard({required this.preview, this.channelName});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final parts = preview.money.parts;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'ORDER TOTAL',
            style: AppTextStyles.monoLabel.copyWith(color: c.muted),
          ),
          const SizedBox(height: 4),
          Text(
            CurrencyFormatter.format(preview.money.customerPays),
            style: AppTextStyles.displayMedium.copyWith(color: c.ink),
          ),
          const SizedBox(height: 12),
          MoneyBreakdown(
            parts: parts,
            feesLabel:
                channelName == null ? 'Channel fees' : '$channelName fees',
            taxLabel: getIt<TaxSettingsCubit>().state.label,
          ),
          ProfitRow(parts: parts),
        ],
      ),
    );
  }
}

class _ReservationsCard extends StatelessWidget {
  final List<ReservationLine> lines;

  const _ReservationsCard({required this.lines});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'RESERVES FROM STOCK',
            style: AppTextStyles.monoLabel.copyWith(color: c.muted),
          ),
          const SizedBox(height: 6),
          for (final r in lines)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      r.name,
                      style: AppTextStyles.bodyMedium.copyWith(color: c.ink),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    r.isShort
                        ? '${r.quantity} · only ${r.available < 0 ? 0 : r.available} free'
                        : r.usesLast
                            ? '${r.quantity} · last ${r.quantity == 1 ? 'one' : 'ones'}'
                            : '${r.quantity} pcs',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: r.isShort || r.usesLast ? c.alert : c.ink,
                      fontWeight: FontWeight.w600,
                      fontFeatures: AppTextStyles.tabular.fontFeatures,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
