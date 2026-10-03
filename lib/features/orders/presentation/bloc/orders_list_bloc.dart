import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/usecases/get_order_list_entries.dart';
import '../../domain/usecases/get_orders.dart';
import 'orders_list_event.dart';
import 'orders_list_state.dart';

/// BLoC for the orders list.
class OrdersListBloc extends Bloc<OrdersListEvent, OrdersListState> {
  final GetOrders getOrders;
  final GetOrderListEntries getOrderListEntries;

  OrdersListBloc({
    required this.getOrders,
    required this.getOrderListEntries,
  }) : super(OrdersListInitial()) {
    on<LoadOrders>(_onLoadOrders);
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersListState> emit,
  ) async {
    if (state is! OrdersListLoaded) emit(OrdersListLoading());
    final result = await getOrders();
    switch (result) {
      case Error(:final failure):
        emit(OrdersListError(failure.message));
      case Success(:final value):
        final entries = await getOrderListEntries(value);
        switch (entries) {
          case Error(:final failure):
            emit(OrdersListError(failure.message));
          case Success(:final value):
            emit(OrdersListLoaded(value));
        }
    }
    event.done?.complete();
  }
}
