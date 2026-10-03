import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../products/domain/entities/channel.dart';
import '../../../products/domain/repositories/channel_repository.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/adjust_materials_used.dart';
import '../../domain/usecases/delete_order.dart';
import '../../domain/usecases/pack_order.dart';
import '../../domain/usecases/ship_order.dart';
import 'order_detail_event.dart';
import 'order_detail_state.dart';

/// BLoC for the order detail screen.
class OrderDetailBloc extends Bloc<OrderDetailEvent, OrderDetailState> {
  final OrderRepository orderRepository;
  final ChannelRepository channelRepository;
  final AdjustMaterialsUsed adjustMaterialsUsed;
  final PackOrder packOrder;
  final ShipOrder shipOrder;
  final DeleteOrder deleteOrder;

  OrderDetailBloc({
    required this.orderRepository,
    required this.channelRepository,
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
    final Order? order;
    switch (orderResult) {
      case Error(:final failure):
        emit(OrderDetailError(failure.message));
        return;
      case Success(:final value):
        order = value;
    }
    if (order == null) {
      emit(const OrderDetailError('Order not found'));
      return;
    }

    // Resolve channel name if channelId is set
    Channel? channel;
    if (order.channelId != null) {
      final channelResult =
          await channelRepository.getChannelById(order.channelId!);
      switch (channelResult) {
        case Success(:final value):
          channel = value;
        case Error():
          break;
      }
    }

    final itemsResult = await orderRepository.getOrderItems(event.orderId);
    final List<dynamic> items;
    switch (itemsResult) {
      case Error(:final failure):
        emit(OrderDetailError(failure.message));
        return;
      case Success(:final value):
        items = value;
    }

    final materialsResult =
        await orderRepository.getOrderMaterials(event.orderId);
    final List<dynamic> materials;
    switch (materialsResult) {
      case Error(:final failure):
        emit(OrderDetailError(failure.message));
        return;
      case Success(:final value):
        materials = value;
    }

    // Load standalone products for this order
    final productsResult =
        await orderRepository.getOrderProducts(event.orderId);
    final List<dynamic> products = switch (productsResult) {
      Success(:final value) => value,
      Error() => <dynamic>[],
    };

    if (emit.isDone) return;

    emit(OrderDetailLoaded(
      order: order,
      items: items.cast(),
      materials: materials.cast(),
      products: products.cast(),
      channel: channel,
    ));
  }

  Future<void> _onAdjustMaterials(
    AdjustMaterials event,
    Emitter<OrderDetailState> emit,
  ) async {
    final result =
        await adjustMaterialsUsed(event.orderId, event.materials);
    switch (result) {
      case Error(:final failure):
        emit(OrderDetailError(failure.message));
      case Success():
        emit(const OrderDetailActionSuccess('Materials adjusted successfully'));
        add(LoadOrderDetail(event.orderId));
    }
  }

  Future<void> _onPackOrder(
    PackOrderDetail event,
    Emitter<OrderDetailState> emit,
  ) async {
    final result = await packOrder(event.orderId);
    switch (result) {
      case Error(:final failure):
        emit(OrderDetailError(failure.message));
      case Success():
        emit(const OrderDetailActionSuccess('Order packed successfully'));
        add(LoadOrderDetail(event.orderId));
    }
  }

  Future<void> _onShipOrder(
    ShipOrderDetail event,
    Emitter<OrderDetailState> emit,
  ) async {
    final result = await shipOrder(event.orderId);
    switch (result) {
      case Error(:final failure):
        emit(OrderDetailError(failure.message));
      case Success():
        emit(const OrderDetailActionSuccess('Order shipped successfully'));
        add(LoadOrderDetail(event.orderId));
    }
  }

  Future<void> _onDeleteOrder(
    DeleteOrderEvent event,
    Emitter<OrderDetailState> emit,
  ) async {
    final result = await deleteOrder(event.orderId);
    switch (result) {
      case Error(:final failure):
        emit(OrderDetailError(failure.message));
      case Success():
        emit(OrderDeleted());
    }
  }
}
