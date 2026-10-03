import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../products/domain/entities/channel.dart';
import '../../../products/domain/repositories/channel_repository.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_material.dart';
import '../../domain/entities/order_product.dart';
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
  final MaterialRepository materialRepository;
  final ProductRepository productRepository;
  final AdjustMaterialsUsed adjustMaterialsUsed;
  final PackOrder packOrder;
  final ShipOrder shipOrder;
  final DeleteOrder deleteOrder;

  OrderDetailBloc({
    required this.orderRepository,
    required this.channelRepository,
    required this.materialRepository,
    required this.productRepository,
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
    if (state is! OrderDetailLoaded) emit(OrderDetailLoading());

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

    // Current stock for the pack preview. A missing row just means no
    // preview numbers for that line, so failures are not fatal here.
    final materialStock = <int, StockLevel>{};
    for (final m in materials.cast<OrderMaterial>()) {
      final r = await materialRepository.getMaterialById(m.materialId);
      if (r case Success(:final value) when value != null) {
        materialStock[m.materialId] =
            StockLevel(onHand: value.quantityOnHand, alertLevel: value.alertLevel);
      }
    }
    final productStock = <int, StockLevel>{};
    for (final p in products.cast<OrderProduct>()) {
      final r = await productRepository.getProductById(p.productId);
      if (r case Success(:final value) when value != null) {
        productStock[p.productId] =
            StockLevel(onHand: value.quantityOnHand, alertLevel: value.alertLevel);
      }
    }

    if (emit.isDone) return;

    emit(OrderDetailLoaded(
      order: order,
      items: items.cast(),
      materials: materials.cast(),
      products: products.cast(),
      channel: channel,
      materialStock: materialStock,
      productStock: productStock,
    ));
  }

  int _serial = 0;

  /// Runs [action] with the loaded screen kept in place: marks it busy,
  /// reports the outcome as a message, then reloads on success.
  Future<void> _runAction(
    Emitter<OrderDetailState> emit,
    int orderId,
    Future<Result<void>> Function() action,
    String successMessage,
  ) async {
    final loaded = state is OrderDetailLoaded ? state as OrderDetailLoaded : null;
    // One action at a time; a double tap shouldn't pack twice.
    if (loaded?.isBusy ?? false) return;
    if (loaded != null) emit(loaded.copyWith(isBusy: true));
    final result = await action();
    switch (result) {
      case Error(:final failure):
        emit(OrderDetailMessage(failure.message, isError: true, serial: ++_serial));
        if (loaded != null) emit(loaded.copyWith(isBusy: false));
      case Success():
        emit(OrderDetailMessage(successMessage, serial: ++_serial));
        if (loaded != null) emit(loaded.copyWith(isBusy: false));
        await _onLoadOrderDetail(LoadOrderDetail(orderId), emit);
    }
  }

  Future<void> _onAdjustMaterials(
    AdjustMaterials event,
    Emitter<OrderDetailState> emit,
  ) =>
      _runAction(
        emit,
        event.orderId,
        () => adjustMaterialsUsed(event.orderId, event.materials),
        'Materials updated',
      );

  Future<void> _onPackOrder(
    PackOrderDetail event,
    Emitter<OrderDetailState> emit,
  ) =>
      _runAction(emit, event.orderId, () => packOrder(event.orderId), 'Packed. Stock updated.');

  Future<void> _onShipOrder(
    ShipOrderDetail event,
    Emitter<OrderDetailState> emit,
  ) =>
      _runAction(emit, event.orderId, () => shipOrder(event.orderId), 'Marked as shipped');

  Future<void> _onDeleteOrder(
    DeleteOrderEvent event,
    Emitter<OrderDetailState> emit,
  ) async {
    final loaded = state is OrderDetailLoaded ? state as OrderDetailLoaded : null;
    if (loaded != null) emit(loaded.copyWith(isBusy: true));
    final result = await deleteOrder(event.orderId);
    switch (result) {
      case Error(:final failure):
        emit(OrderDetailMessage(failure.message, isError: true, serial: ++_serial));
        if (loaded != null) emit(loaded.copyWith(isBusy: false));
      case Success():
        emit(OrderDeleted());
    }
  }
}
