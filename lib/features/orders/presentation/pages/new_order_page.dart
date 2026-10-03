import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/currency_text.dart';
import '../../../../core/widgets/stepper_input.dart';
import '../../../products/domain/entities/channel.dart';
import '../../../products/domain/usecases/get_channels.dart';
import '../../domain/entities/order_item.dart';
import '../bloc/new_order_bloc.dart';
import '../bloc/new_order_event.dart';
import '../bloc/new_order_state.dart';
import '../widgets/product_picker_sheet.dart';

/// New order page — 3-step wizard
class NewOrderPage extends StatelessWidget {
  const NewOrderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<NewOrderBloc>()..add(ResetOrder()),
      child: const _NewOrderView(),
    );
  }
}

class _NewOrderView extends StatefulWidget {
  const _NewOrderView();

  @override
  State<_NewOrderView> createState() => _NewOrderViewState();
}

class _NewOrderViewState extends State<_NewOrderView> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Step 1 form controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  DateTime _orderDate = DateTime.now();
  DateTime _shipByDate = DateTime.now().add(const Duration(days: 1));
  int? _selectedChannelId;
  List<Channel> _channels = [];

  @override
  void initState() {
    super.initState();
    _loadChannels();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadChannels() async {
    final result = await getIt<GetChannels>()(activeOnly: true);
    result.fold(
      (_) {},
      (channels) {
        if (mounted) {
          setState(() {
            _channels = channels;
            if (channels.isNotEmpty) {
              _selectedChannelId = channels.first.id;
            }
          });
        }
      },
    );
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  void _submitDetails() {
    if (_nameController.text.trim().isEmpty) {
      context.showSnackBar('Customer name is required', isError: true);
      return;
    }
    if (_selectedChannelId == null) {
      context.showSnackBar('Select a channel', isError: true);
      return;
    }

    context.read<NewOrderBloc>().add(SetCustomerDetails(
          customerName: _nameController.text.trim(),
          customerAddress: _addressController.text.trim(),
          channelId: _selectedChannelId!,
          orderDate: _orderDate,
          shipByDate: _shipByDate,
          note: _noteController.text.trim().isEmpty
              ? null
              : _noteController.text.trim(),
        ));
    _goToStep(1);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<NewOrderBloc, NewOrderState>(
      listener: (context, state) {
        if (state is NewOrderSaved) {
          context.showSnackBar('Order created!');
          context.pop(true);
        }
        if (state is NewOrderError) {
          context.showSnackBar(state.message, isError: true);
        }
      },
      builder: (context, state) {
        final items = state is NewOrderDetailsFilled ? state.items : <OrderItemInput>[];
        final totalSales = state is NewOrderDetailsFilled ? state.totalSales : 0.0;

        return Scaffold(
          appBar: AppBar(
            title: const Text('New order'),
            leading: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => context.pop(),
            ),
          ),
          body: Column(
            children: [
              // Step indicator
              _StepIndicator(currentStep: _currentStep, totalSteps: 3),

              // Pages
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildDetailsStep(),
                    _buildItemsStep(items, totalSales),
                    _ReviewStep(onBack: () => _goToStep(1)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailsStep() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('DETAILS', style: AppTextStyles.monoSection),
        const SizedBox(height: 12),

        // Customer name
        TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Customer name'),
        ),
        const SizedBox(height: 12),

        // Address
        TextField(
          controller: _addressController,
          decoration: const InputDecoration(labelText: 'Address'),
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        // Channel chips
        Text('CHANNEL', style: AppTextStyles.monoSection),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: _channels.map((ch) {
            final isSelected = ch.id == _selectedChannelId;
            return GestureDetector(
              onTap: () => setState(() => _selectedChannelId = ch.id),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.success : AppColors.paperHigh,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? AppColors.success : AppColors.hair,
                  ),
                ),
                child: Text(
                  ch.name.toUpperCase(),
                  style: AppTextStyles.monoLabel.copyWith(
                    color: isSelected ? Colors.white : AppColors.ink,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Date pickers
        Row(
          children: [
            Expanded(
              child: _DatePicker(
                label: 'Order date',
                date: _orderDate,
                onPicked: (d) => setState(() => _orderDate = d),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _DatePicker(
                label: 'Ship by',
                date: _shipByDate,
                onPicked: (d) => setState(() => _shipByDate = d),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Note
        TextField(
          controller: _noteController,
          decoration: const InputDecoration(labelText: 'Note (optional)'),
          maxLines: 2,
        ),
        const SizedBox(height: 24),

        // Next button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _submitDetails,
            child: const Text('Next'),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsStep(List<OrderItemInput> items, double totalSales) {
    return Column(
      children: [
        Expanded(
          child: items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inventory_2_outlined,
                          color: AppColors.muted, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        'No items added yet',
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.muted),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.paperHigh,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.hair),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.productName,
                                  style: AppTextStyles.bodyLarge
                                      .copyWith(color: AppColors.ink),
                                ),
                                const SizedBox(height: 4),
                                CurrencyText(
                                  amount: item.unitPrice,
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.muted),
                                ),
                              ],
                            ),
                          ),
                          StepperInput(
                            value: item.quantity,
                            min: 0,
                            max: 999,
                            onChanged: (qty) {
                              final q = qty.toInt();
                              if (q == 0) {
                                context
                                    .read<NewOrderBloc>()
                                    .add(RemoveItem(item.productId));
                              } else {
                                context.read<NewOrderBloc>().add(
                                    UpdateItemQuantity(
                                        productId: item.productId,
                                        quantity: q));
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),

        // Bottom bar: back + total + add button + review
        Container(
          padding: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: AppColors.paperHigh,
            border: Border(top: BorderSide(color: AppColors.hair)),
          ),
          child: SafeArea(
            child: Row(
              children: [
                TextButton(
                  onPressed: () => _goToStep(0),
                  child: const Text('Back'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('TOTAL', style: AppTextStyles.monoSection),
                      const SizedBox(height: 2),
                      CurrencyText(
                        amount: totalSales,
                        style: AppTextStyles.displaySmall
                            .copyWith(color: AppColors.ink),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    final bloc = context.read<NewOrderBloc>();
                    final currentItems = bloc.state is NewOrderDetailsFilled
                        ? (bloc.state as NewOrderDetailsFilled).items
                        : <OrderItemInput>[];
                    ProductPickerSheet.show(
                      context,
                      addedProductIds:
                          currentItems.map((i) => i.productId).toList(),
                      onSelected: (item) => bloc.add(AddItem(
                        productId: item.productId,
                        productName: item.productName,
                        quantity: item.quantity,
                        unitPrice: item.unitPrice,
                      )),
                    );
                  },
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Add'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: items.isEmpty ? null : () => _goToStep(2),
                  child: const Text('Review'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewStep extends StatelessWidget {
  final VoidCallback onBack;

  const _ReviewStep({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NewOrderBloc, NewOrderState>(
      builder: (context, state) {
        if (state is! NewOrderDetailsFilled) {
          return const Center(child: Text('No order data'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('REVIEW', style: AppTextStyles.monoSection),
            const SizedBox(height: 12),

            // Order summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.paperHigh,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.hair),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.customerName,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.ink),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.items.length} items · ${state.totalItemCount.toInt()} pcs',
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        'Total: ',
                        style: AppTextStyles.bodySmall,
                      ),
                      CurrencyText(
                        amount: state.totalSales,
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.success),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Back + Save buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      context.read<NewOrderBloc>().add(SaveOrder());
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Save order'),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: List.generate(totalSteps, (index) {
          final isActive = index <= currentStep;
          return Expanded(
            child: Container(
              height: 3,
              margin: EdgeInsets.only(right: index < totalSteps - 1 ? 4 : 0),
              decoration: BoxDecoration(
                color: isActive ? AppColors.success : AppColors.hair,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _DatePicker extends StatelessWidget {
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPicked;

  const _DatePicker({
    required this.label,
    required this.date,
    required this.onPicked,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime.now().subtract(const Duration(days: 30)),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onPicked(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.hair),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: AppTextStyles.monoSection),
            const SizedBox(height: 4),
            Text(
              '${date.month}/${date.day}/${date.year}',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.ink),
            ),
          ],
        ),
      ),
    );
  }
}
