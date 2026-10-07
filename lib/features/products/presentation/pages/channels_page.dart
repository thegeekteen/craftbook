import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/l10n_extension.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/action_sheet.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/confirm_dialog.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../domain/entities/channel.dart';
import '../bloc/channels_bloc.dart';
import '../bloc/channels_event.dart';
import '../bloc/channels_state.dart';
import '../widgets/channel_card.dart';

/// Where you sell and what each place charges.
class ChannelsPage extends StatelessWidget {
  const ChannelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<ChannelsBloc>()..add(const LoadChannels()),
      child: const _ChannelsView(),
    );
  }
}

class _ChannelsView extends StatelessWidget {
  const _ChannelsView();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<ChannelsBloc>();
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.productsChannelsTitle)),
      body: BlocConsumer<ChannelsBloc, ChannelsState>(
        listener: (context, state) {
          if (state is ChannelsError) {
            context.showSnackBar(state.message, isError: true);
          }
          if (state is ChannelCreated) {
            context.showSnackBar(context.l10n.productsChannelAdded);
            bloc.add(const LoadChannels());
          }
          if (state is ChannelDeleted) {
            context.showSnackBar(context.l10n.productsChannelDeleted);
          }
        },
        buildWhen: (_, s) =>
            s is ChannelsLoaded || s is ChannelsLoading || s is ChannelsInitial,
        builder: (context, state) {
          if (state is! ChannelsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.channels.isEmpty) {
            return Center(
              child: EmptyState(
                icon: Icons.storefront_outlined,
                title: context.l10n.productsChannelsEmptyTitle,
                message: context.l10n.productsChannelsEmptyMessage,
                actionLabel: context.l10n.productsChannelAddButton,
                onAction: () => _ChannelSheet.open(context, bloc),
              ),
            );
          }
          final channels = [...state.channels]..sort((a, b) {
              if (a.isActive != b.isActive) return a.isActive ? -1 : 1;
              return a.name.toLowerCase().compareTo(b.name.toLowerCase());
            });
          return ListView.separated(
            padding:
                const EdgeInsets.fromLTRB(16, 4, 16, AppSpacing.fabClearance),
            itemCount: channels.length + 1,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              if (i == channels.length) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
                  child: Text(
                    context.l10n.productsChannelsNote(
                        CurrencyFormatter.formatShort(ChannelCard.exampleSale)),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: context.colors.muted),
                  ),
                );
              }
              final ch = channels[i];
              return ChannelCard(
                channel: ch,
                onTap: () => _ChannelSheet.open(context, bloc, channel: ch),
                onLongPress: () => _channelActions(context, bloc, ch),
                onActiveChanged: (v) =>
                    bloc.add(UpdateChannelEvent(id: ch.id!, isActive: v)),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _ChannelSheet.open(context, bloc),
        icon: const Icon(Icons.add_rounded),
        label: Text(context.l10n.productsChannelFab),
      ),
    );
  }
}

enum _ChannelAction { edit, toggleActive, delete }

/// The long-press menu on a channel.
Future<void> _channelActions(
    BuildContext context, ChannelsBloc bloc, Channel ch) async {
  final l10n = context.l10n;
  final action = await showActionSheet<_ChannelAction>(
    context,
    title: ch.name,
    actions: [
      SheetAction(
          value: _ChannelAction.edit,
          icon: Icons.edit_outlined,
          label: l10n.productsChannelEdit),
      SheetAction(
        value: _ChannelAction.toggleActive,
        icon:
            ch.isActive ? Icons.toggle_off_outlined : Icons.toggle_on_outlined,
        label: ch.isActive
            ? l10n.productsChannelTurnOff
            : l10n.productsChannelTurnOn,
      ),
      SheetAction(
          value: _ChannelAction.delete,
          icon: Icons.delete_outline_rounded,
          label: l10n.productsChannelDelete,
          destructive: true),
    ],
  );
  if (action == null || !context.mounted) return;
  switch (action) {
    case _ChannelAction.edit:
      await _ChannelSheet.open(context, bloc, channel: ch);
    case _ChannelAction.toggleActive:
      bloc.add(UpdateChannelEvent(id: ch.id!, isActive: !ch.isActive));
    case _ChannelAction.delete:
      if (await _confirmDelete(context, ch)) {
        bloc.add(DeleteChannelEvent(ch.id!));
      }
  }
}

Future<bool> _confirmDelete(BuildContext context, Channel ch) {
  return ConfirmDialog.show(
    context,
    title: context.l10n.productsChannelDeleteTitle(ch.name),
    message: context.l10n.productsChannelDeleteMessage,
    confirmText: context.l10n.commonDelete,
    isDestructive: true,
  );
}

/// Create/edit form in a bottom sheet.
class _ChannelSheet extends StatefulWidget {
  final Channel? channel;
  final ChannelsBloc bloc;

  const _ChannelSheet({this.channel, required this.bloc});

  static Future<void> open(BuildContext context, ChannelsBloc bloc,
      {Channel? channel}) {
    return showAppSheet(
      context: context,
      title: channel == null
          ? context.l10n.productsChannelNew
          : context.l10n.productsChannelEditTitle(channel.name),
      builder: (_) => _ChannelSheet(channel: channel, bloc: bloc),
    );
  }

  @override
  State<_ChannelSheet> createState() => _ChannelSheetState();
}

class _ChannelSheetState extends State<_ChannelSheet> {
  final _formKey = GlobalKey<FormState>();
  late final _name = TextEditingController(text: widget.channel?.name ?? '');
  late final _commission =
      TextEditingController(text: _num(widget.channel?.commissionRate));
  late final _transaction =
      TextEditingController(text: _num(widget.channel?.transactionFeeRate));
  late final _flat = TextEditingController(text: _num(widget.channel?.flatFee));
  late final _shipping =
      TextEditingController(text: _num(widget.channel?.shippingPaidByUs));
  late bool _paidByDefault = widget.channel?.paidByDefault ?? true;

  static String _num(double? v) {
    if (v == null || v == 0) return '';
    return v == v.roundToDouble() ? v.toStringAsFixed(0) : '$v';
  }

  double _val(TextEditingController c) => double.tryParse(c.text) ?? 0;

  @override
  void initState() {
    super.initState();
    for (final ctrl in [_commission, _transaction, _flat, _shipping]) {
      ctrl.addListener(() => setState(() {}));
    }
  }

  @override
  void dispose() {
    for (final ctrl in [_name, _commission, _transaction, _flat, _shipping]) {
      ctrl.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final ch = widget.channel;
    if (ch == null) {
      widget.bloc.add(CreateChannelEvent(
        name: _name.text.trim(),
        commissionRate: _val(_commission),
        transactionFeeRate: _val(_transaction),
        flatFee: _val(_flat),
        shippingPaidByUs: _val(_shipping),
        paidByDefault: _paidByDefault,
      ));
    } else {
      widget.bloc.add(UpdateChannelEvent(
        id: ch.id!,
        name: _name.text.trim(),
        commissionRate: _val(_commission),
        transactionFeeRate: _val(_transaction),
        flatFee: _val(_flat),
        shippingPaidByUs: _val(_shipping),
        paidByDefault: _paidByDefault,
      ));
    }
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ch = widget.channel!;
    if (!await _confirmDelete(context, ch) || !mounted) return;
    widget.bloc.add(DeleteChannelEvent(ch.id!));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final l10n = context.l10n;
    final money = [
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
    ];
    final preview = Channel(
      name: '',
      commissionRate: _val(_commission),
      transactionFeeRate: _val(_transaction),
      flatFee: _val(_flat),
      shippingPaidByUs: _val(_shipping),
      isActive: true,
      createdAt: DateTime.now(),
    );
    const sale = ChannelCard.exampleSale;
    final keep = sale - preview.calculateFees(sale) - preview.shippingPaidByUs;

    Widget field(TextEditingController ctrl, String label,
            {String? prefix, String? suffix}) =>
        TextFormField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: money,
          decoration: InputDecoration(
              labelText: label, prefixText: prefix, suffixText: suffix),
        );

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _name,
            autofocus: widget.channel == null,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
                labelText: l10n.commonName,
                hintText: l10n.productsChannelNameHint),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? l10n.productsEnterName : null,
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: field(_commission, l10n.productsChannelCommission,
                    suffix: '%')),
            const SizedBox(width: 8),
            Expanded(
                child: field(_transaction, l10n.productsChannelTransactionFee,
                    suffix: '%')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: field(_flat, l10n.productsChannelFixedFee,
                    prefix: '${CurrencyFormatter.symbol} ')),
            const SizedBox(width: 8),
            Expanded(
                child: field(_shipping, l10n.productsChannelShippingYouPay,
                    prefix: '${CurrencyFormatter.symbol} ')),
          ]),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: _paidByDefault,
            onChanged: (v) => setState(() => _paidByDefault = v),
            title: Text(l10n.productsChannelPaidWhenPlaced,
                style: AppTextStyles.bodyMedium.copyWith(color: c.ink)),
            subtitle: Text(
              _paidByDefault
                  ? l10n.productsChannelPaidUpfront
                  : l10n.productsChannelUnpaidStart,
              style: AppTextStyles.bodySmall.copyWith(color: c.muted),
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: c.paper, borderRadius: AppRadii.controlAll),
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                    text:
                        '${l10n.productsChannelYouKeep(CurrencyFormatter.formatShort(sale))} '),
                TextSpan(
                  text: CurrencyFormatter.format(keep),
                  style: TextStyle(color: c.go, fontWeight: FontWeight.w600),
                ),
                TextSpan(text: ' ${l10n.productsChannelBeforeMaterials}'),
              ]),
              style: AppTextStyles.bodySmall
                  .copyWith(color: c.muted, fontSize: 13),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              if (widget.channel != null)
                TextButton(
                  onPressed: _delete,
                  style: TextButton.styleFrom(foregroundColor: c.alert),
                  child: Text(l10n.commonDelete),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _save,
                child: Text(widget.channel == null
                    ? l10n.productsChannelAddButton
                    : l10n.commonSave),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
