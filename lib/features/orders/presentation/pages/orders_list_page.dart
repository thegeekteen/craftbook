import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/route_names.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../domain/entities/order.dart';
import '../bloc/orders_list_bloc.dart';
import '../bloc/orders_list_event.dart';
import '../bloc/orders_list_state.dart';
import '../../../today/presentation/widgets/order_card.dart';

/// Orders list page — Flow 2: Order management
class OrdersListPage extends StatelessWidget {
  const OrdersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<OrdersListBloc>()..add(const LoadOrders()),
      child: const _OrdersListView(),
    );
  }
}

class _OrdersListView extends StatefulWidget {
  const _OrdersListView();

  @override
  State<_OrdersListView> createState() => _OrdersListViewState();
}

class _OrdersListViewState extends State<_OrdersListView> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  static const _tabs = ['All', 'To Pack', 'Packed', 'Shipped'];

  OrderStatus? _statusForTab(int index) {
    switch (index) {
      case 1:
        return OrderStatus.pending;
      case 2:
        return OrderStatus.packed;
      case 3:
        return OrderStatus.shipped;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Orders',
            style: AppTextStyles.displaySmall.copyWith(color: AppColors.ink),
          ),
          bottom: TabBar(
            labelColor: AppColors.success,
            unselectedLabelColor: AppColors.muted,
            indicatorColor: AppColors.success,
            labelStyle: AppTextStyles.monoLabel,
            tabs: _tabs.map((t) => Tab(text: t.toUpperCase())).toList(),
          ),
        ),
        body: BlocConsumer<OrdersListBloc, OrdersListState>(
          listener: (context, state) {
            if (state is OrderActionSuccess) {
              context.showSnackBar(state.message);
            }
            if (state is OrdersListError) {
              context.showSnackBar(state.message, isError: true);
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search orders...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      isDense: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: List.generate(_tabs.length, (index) {
                      return _OrdersTab(
                        status: _statusForTab(index),
                        state: state,
                        searchQuery: _searchController.text,
                      );
                    }),
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await context.push<bool>(RouteNames.newOrder);
            if (result == true && context.mounted) {
              context.read<OrdersListBloc>().add(const LoadOrders());
            }
          },
          backgroundColor: AppColors.success,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

class _OrdersTab extends StatelessWidget {
  final OrderStatus? status;
  final OrdersListState state;
  final String searchQuery;

  const _OrdersTab({
    required this.status,
    required this.state,
    required this.searchQuery,
  });

  @override
  Widget build(BuildContext context) {
    if (state is OrdersListLoading || state is OrdersListInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is OrdersListLoaded) {
      final loaded = state as OrdersListLoaded;
      var orders = status == null
          ? loaded.orders
          : loaded.orders.where((o) => o.status == status).toList();

      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        orders = orders.where((o) =>
            o.customerName.toLowerCase().contains(q) ||
            '#${o.id}'.contains(q)).toList();
      }

      if (orders.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox_outlined, color: AppColors.muted, size: 48),
              const SizedBox(height: 12),
              Text(
                'No orders here',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.muted),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          context.read<OrdersListBloc>().add(LoadOrders(status: status));
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            return OrderCard(
              order: orders[index],
              onTap: () async {
                final result = await context.push<bool>(
                  RouteNames.orderDetail
                      .replaceFirst(':id', '${orders[index].id}'),
                );
                if (result == true && context.mounted) {
                  context.read<OrdersListBloc>().add(LoadOrders(status: status));
                }
              },
            );
          },
        ),
      );
    }

    if (state is OrdersListError) {
      return Center(
        child: Text(
          (state as OrdersListError).message,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.alert),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
