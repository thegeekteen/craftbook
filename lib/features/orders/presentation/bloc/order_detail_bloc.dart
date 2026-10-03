import 'package:flutter_bloc/flutter_bloc.dart';

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
    if (orderResult.isLeft()) {
      orderResult.fold((f) => emit(OrderDetailError(f.message)), (_) {});
      return;
    }

    final order = orderResult.fold<Order?>((_) => null, (o) => o);
    if (order == null) {
      emit(const OrderDetailError('Order not found'));
      return;
    }

    // Resolve channel name if channelId is set
    Channel? channel;
    if (order.channelId != null) {
      final channelResult =
          await channelRepository.getChannelById(order.channelId!);
      channelResult.fold((_) {}, (c) => channel = c);
    }

    final itemsResult = await orderRepository.getOrderItems(event.orderId);
    if (itemsResult.isLeft()) {
      itemsResult.fold((f) => emit(OrderDetailError(f.message)), (_) {});
      return;
    }
    final items = itemsResult.fold<List<dynamic>>(
        (_) => [], (list) => list);

    final materialsResult =
        await orderRepository.getOrderMaterials(event.orderId);
    if (materialsResult.isLeft()) {
      materialsResult.fold(
          (f) => emit(OrderDetailError(f.message)), (_) {});
      return;
    }
    final materials = materialsResult.fold<List<dynamic>>(
        (_) => [], (list) => list);

    // Load standalone products for this order
    final productsResult =
        await orderRepository.getOrderProducts(event.orderId);
    final products = productsResult.fold<List<dynamic>>(
        (_) => [], (list) => list);

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
    result.fold(
      (failure) => emit(OrderDetailError(failure.message)),
      (_) {
        emit(const OrderDetailActionSuccess('Materials adjusted successfully'));
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
