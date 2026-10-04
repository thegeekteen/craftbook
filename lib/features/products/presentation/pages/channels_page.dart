import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/dimens.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/extensions.dart';
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
      appBar: AppBar(title: const Text('Channels & fees')),
      body: BlocConsumer<ChannelsBloc, ChannelsState>(
        listener: (context, state) {
          if (state is ChannelsError) {
            context.showSnackBar(state.message, isError: true);
          }
          if (state is ChannelCreated) {
            context.showSnackBar('Channel added');
            bloc.add(const LoadChannels());
          }
          if (state is ChannelDeleted) context.showSnackBar('Channel deleted');
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
                title: 'No channels yet',
                message:
                    'Add Shopee, TikTok Shop, walk-in… with their fees so profit is accurate.',
                actionLabel: 'Add channel',
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
                    'Examples use a ${CurrencyFormatter.formatShort(ChannelCard.exampleSale)} sale. '
                    'Turned-off channels stay on past orders but are hidden when you create new ones.',
                    style: AppTextStyles.bodySmall
                        .copyWith(color: context.colors.muted),
                  ),
                );
              }
              final ch = channels[i];
              return ChannelCard(
                channel: ch,
                onTap: () => _ChannelSheet.open(context, bloc, channel: ch),
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
        label: const Text('Channel'),
      ),
    );
  }
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
      title: channel == null ? 'New channel' : 'Edit ${channel.name}',
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
      ));
    } else {
      widget.bloc.add(UpdateChannelEvent(
        id: ch.id!,
        name: _name.text.trim(),
        commissionRate: _val(_commission),
        transactionFeeRate: _val(_transaction),
        flatFee: _val(_flat),
        shippingPaidByUs: _val(_shipping),
      ));
    }
    Navigator.pop(context);
  }

  Future<void> _delete() async {
    final ch = widget.channel!;
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Delete ${ch.name}?',
      message:
          "Channels used by orders can't be deleted. Turn them off instead.",
      confirmText: 'Delete',
      isDestructive: true,
    );
    if (!confirmed || !mounted) return;
    widget.bloc.add(DeleteChannelEvent(ch.id!));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
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
            decoration: const InputDecoration(
                labelText: 'Name', hintText: 'e.g. Shopee'),
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Enter a name' : null,
          ),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: field(_commission, 'Commission', suffix: '%')),
            const SizedBox(width: 8),
            Expanded(
                child: field(_transaction, 'Transaction fee', suffix: '%')),
          ]),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: field(_flat, 'Fixed fee', prefix: '₱ ')),
            const SizedBox(width: 8),
            Expanded(child: field(_shipping, 'Shipping you pay', prefix: '₱ ')),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: c.paper, borderRadius: AppRadii.controlAll),
            child: Text.rich(
              TextSpan(children: [
                TextSpan(
                    text:
                        'On a ${CurrencyFormatter.formatShort(sale)} sale you keep '),
                TextSpan(
                  text: CurrencyFormatter.format(keep),
                  style: TextStyle(color: c.go, fontWeight: FontWeight.w600),
                ),
                const TextSpan(text: ' before materials.'),
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
                  child: const Text('Delete'),
                ),
              const Spacer(),
              FilledButton(
                onPressed: _save,
                child: Text(widget.channel == null ? 'Add channel' : 'Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
