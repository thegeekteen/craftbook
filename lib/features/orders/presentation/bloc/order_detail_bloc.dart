import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/adjust_materials_used.dart';
import '../../domain/usecases/delete_order.dart';
import '../../domain/usecases/pack_order.dart';
import '../../domain/usecases/ship_order.dart';
import 'order_detail_event.dart';
import 'order_detail_state.dart';

/// BLoC for the order detail screen.
///
/// Uses [OrderRepository] directly for reading order/items/materials,
/// and dedicated use cases for mutations (adjust, pack, ship, delete).
class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final OrderRepository orderRepository;
  final AdjustMaterialsUsed adjustMaterialsUsed;
  final PackOrder packOrder;
  final ShipOrder shipOrder;
  final DeleteOrder deleteOrder;

  OrderDetailBloc({
    required this.orderRepository,
    required this.adjustMaterialsUsed,
    required this.packOrder,
    required this.shipOrder,
    required this.deleteOrder,
  }) : super(OrderDetailInitial()) {
    on<LoadOrderDetail>(_onLoadOrderDetail);
    on<AdjustMaterials>(_onAdjustMaterials);
    on<PackOrderDetail>(_onPackOrder);
    on<ShipOrderDetail>(_onShipOrder);
    on<DeleteOrderEvent>(_onDeleteOrder);
  }

  Future<void> _onLoadOrderDetail(
    LoadOrderDetail event,
    Emitter<OrderDetailState> emit,
  ) async {
    emit(OrderDetailLoading());

    final orderResult = await orderRepository.getOrderById(event.orderId);
    final itemsResult = await orderRepository.getOrderItems(event.orderId);
    final materialsResult =
        await orderRepository.getOrderMaterials(event.orderId);

    // Chain fold calls to handle failures at each step
    orderResult.fold<void>(
      (failure) => emit(OrderDetailError(failure.message)),
      (Order? maybeOrder) {
        if (maybeOrder == null) {
          emit(const OrderDetailError('Order not found'));
          return;
        }
        final order = maybeOrder;
        itemsResult.fold<void>(
          (failure) => emit(OrderDetailError(failure.message)),
          (items) => materialsResult.fold<void>(
            (failure) => emit(OrderDetailError(failure.message)),
            (materials) => emit(OrderDetailLoaded(
              order: order,
              items: items,
              materials: materials,
            )),
          ),
        );
      },
    );
  }

  Future<void> _onAdjustMaterials(
    AdjustMaterials event,
    Emitter<OrderDetailState> emit,
  ) async {
    final result =
        await adjustMaterialsUsed(event.orderId, event.materials);
    result.fold(
      (failure) => emit(OrderDetailError(failure.message)),
      (_) {
        emit(const OrderDetailActionSuccess('Materials adjusted successfully'));
        // Re-load order detail after adjustment
        add(LoadOrderDetail(event.orderId));
      },
    );
  }

  Future<void> _onPackOrder(
    PackOrderDetail event,
    Emitter<OrderDetailState> emit,
  ) async {
    final result = await packOrder(event.orderId);
    result.fold(
      (failure) => emit(OrderDetailError(failure.message)),
      (_) {
        emit(const OrderDetailActionSuccess('Order packed successfully'));
        // Re-load order detail after packing
        add(LoadOrderDetail(event.orderId));
      },
    );
  }

  Future<void> _onShipOrder(
    ShipOrderDetail event,
    Emitter<OrderDetailState> emit,
  ) async {
    final result = await shipOrder(event.orderId);
    result.fold(
      (failure) => emit(OrderDetailError(failure.message)),
      (_) {
        emit(const OrderDetailActionSuccess('Order shipped successfully'));
        // Re-load order detail after shipping
        add(LoadOrderDetail(event.orderId));
      },
    );
  }

  Future<void> _onDeleteOrder(
    DeleteOrderEvent event,
    Emitter<OrderDetailState> emit,
  ) async {
    final result = await deleteOrder(event.orderId);
    result.fold(
      (failure) => emit(OrderDetailError(failure.message)),
      (_) => emit(OrderDeleted()),
    );
  }
}
