import 'package:flutter_bloc/flutter_bloc.dart';

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
    result.fold(
      (failure) => emit(OrdersListError(failure.message)),
      (orders) => emit(OrdersListLoaded(orders)),
    );
  }

  Future<void> _onPackOrder(
    PackOrderEvent event,
    Emitter<OrdersListState> emit,
  ) async {
    final result = await packOrder(event.orderId);
    result.fold(
      (failure) => emit(OrdersListError(failure.message)),
      (_) => emit(const OrderActionSuccess('Order packed successfully')),
    );
  }

  Future<void> _onShipOrder(
    ShipOrderEvent event,
    Emitter<OrdersListState> emit,
  ) async {
    final result = await shipOrder(event.orderId);
    result.fold(
      (failure) => emit(OrdersListError(failure.message)),
      (_) => emit(const OrderActionSuccess('Order shipped successfully')),
    );
  }
}
