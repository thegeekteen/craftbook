import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/channel.dart';
import '../bloc/channels_bloc.dart';
import '../bloc/channels_event.dart';
import '../bloc/channels_state.dart';
import '../widgets/channel_card.dart';

/// Channels management page
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Channels',
          style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink),
        ),
      ),
      body: BlocConsumer<ChannelsBloc, ChannelsState>(
        listener: (context, state) {
          if (state is ChannelsError) {
            context.showSnackBar(state.message, isError: true);
          }
        },
        builder: (context, state) {
          if (state is ChannelsLoading || state is ChannelsInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ChannelsLoaded) {
            if (state.channels.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.store_outlined,
                        color: AppColors.muted, size: 48),
                    const SizedBox(height: 12),
                    Text(
                      'No channels yet',
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<ChannelsBloc>().add(const LoadChannels());
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.channels.length,
                itemBuilder: (context, index) {
                  final channel = state.channels[index];
                  return ChannelCard(
                    channel: channel,
                    onTap: () => _showEditDialog(context, channel),
                  );
                },
              ),
            );
          }

          if (state is ChannelsError) {
            return Center(
              child: Text(state.message,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.alert)),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _showEditDialog(BuildContext context, Channel channel) {
    final nameController = TextEditingController(text: channel.name);
    final commissionController =
        TextEditingController(text: channel.commissionRate.toString());
    final transactionController =
        TextEditingController(text: channel.transactionFeeRate.toString());
    final flatFeeController =
        TextEditingController(text: channel.flatFee.toString());
    final shippingController =
        TextEditingController(text: channel.shippingPaidByUs.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.paperHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit ${channel.name}',
            style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: commissionController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    const InputDecoration(labelText: 'Commission %'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: transactionController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration:
                    const InputDecoration(labelText: 'Transaction fee %'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: flatFeeController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Flat fee',
                  prefixText: '₱ ',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: shippingController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Shipping (paid by us)',
                  prefixText: '₱ ',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AppColors.muted)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<ChannelsBloc>().add(UpdateChannelEvent(
                    id: channel.id!,
                    name: nameController.text.trim(),
                    commissionRate:
                        double.tryParse(commissionController.text) ??
                            channel.commissionRate,
                    transactionFeeRate:
                        double.tryParse(transactionController.text) ??
                            channel.transactionFeeRate,
                    flatFee:
                        double.tryParse(flatFeeController.text) ??
                            channel.flatFee,
                    shippingPaidByUs:
                        double.tryParse(shippingController.text) ??
                            channel.shippingPaidByUs,
                  ));
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
