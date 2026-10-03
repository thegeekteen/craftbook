import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/usecases/get_orders.dart';
import '../../domain/usecases/pack_order.dart';
import '../../domain/usecases/ship_order.dart';
import 'orders_list_event.dart';
import 'orders_list_state.dart';

/// BLoC for managing the orders list
class OrdersListBloc extends Bloc<OrdersListEvent, OrdersListState> {
  final GetOrders getOrders;
  final PackOrder packOrder;
  final ShipOrder shipOrder;

  OrdersListBloc({
    required this.getOrders,
    required this.packOrder,
    required this.shipOrder,
  }) : super(OrdersListInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<PackOrderEvent>(_onPackOrder);
    on<ShipOrderEvent>(_onShipOrder);
  }

  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersListState> emit,
  ) async {
    emit(OrdersListLoading());
    final result = await getOrders(status: event.status);
    switch (result) {
      case Error(:final failure):
        emit(OrdersListError(failure.message));
      case Success(:final value):
        emit(OrdersListLoaded(value));
    }
  }

  Future<void> _onPackOrder(
    PackOrderEvent event,
    Emitter<OrdersListState> emit,
  ) async {
    final result = await packOrder(event.orderId);
    switch (result) {
      case Error(:final failure):
        emit(OrdersListError(failure.message));
      case Success():
        emit(const OrderActionSuccess('Order packed successfully'));
    }
  }

  Future<void> _onShipOrder(
    ShipOrderEvent event,
    Emitter<OrdersListState> emit,
  ) async {
    final result = await shipOrder(event.orderId);
    switch (result) {
      case Error(:final failure):
        emit(OrdersListError(failure.message));
      case Success():
        emit(const OrderActionSuccess('Order shipped successfully'));
    }
  }
}
