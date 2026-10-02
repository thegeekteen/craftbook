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

class _OrdersListView extends StatelessWidget {
  const _OrdersListView();

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
            return TabBarView(
              children: List.generate(_tabs.length, (index) {
                return _OrdersTab(
                  status: _statusForTab(index),
                  state: state,
                );
              }),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => context.push(RouteNames.newOrder),
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

  const _OrdersTab({required this.status, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state is OrdersListLoading || state is OrdersListInitial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is OrdersListLoaded) {
      final loaded = state as OrdersListLoaded;
      final orders = status == null
          ? loaded.orders
          : loaded.orders.where((o) => o.status == status).toList();

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
            return OrderCard(order: orders[index]);
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
