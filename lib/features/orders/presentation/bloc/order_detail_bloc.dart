import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../order_fields/domain/entities/order_field_entry.dart';
import '../../../products/domain/entities/channel.dart';
import '../../../products/domain/repositories/channel_repository.dart';
import '../../../products/domain/repositories/product_repository.dart';
import '../../../stock/domain/repositories/material_repository.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_material.dart';
import '../../domain/entities/order_product.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/adjust_materials_used.dart';
import '../../domain/usecases/cancel_order.dart';
import '../../domain/usecases/delete_order.dart';
import '../../domain/usecases/pack_order.dart';
import '../../domain/usecases/restore_order.dart';
import '../../domain/usecases/ship_order.dart';
import '../../domain/usecases/update_order_note.dart';
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
  final CancelOrder cancelOrder;
  final RestoreOrder restoreOrder;
  final DeleteOrder deleteOrder;
  final UpdateOrderNote updateOrderNote;

  OrderDetailBloc({
    required this.orderRepository,
    required this.channelRepository,
    required this.materialRepository,
    required this.productRepository,
    required this.adjustMaterialsUsed,
    required this.packOrder,
    required this.shipOrder,
    required this.cancelOrder,
    required this.restoreOrder,
    required this.deleteOrder,
    required this.updateOrderNote,
  }) : super(OrderDetailInitial()) {
    on<LoadOrderDetail>(_onLoadOrderDetail);
    on<AdjustMaterials>(_onAdjustMaterials);
    on<PackOrderDetail>(_onPackOrder);
    on<ShipOrderDetail>(_onShipOrder);
    on<CancelOrderDetail>(_onCancelOrder);
    on<RestoreOrderDetail>(_onRestoreOrder);
    on<SaveOrderNote>(_onSaveNote);
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
        materialStock[m.materialId] = StockLevel(
            onHand: value.quantityOnHand, alertLevel: value.alertLevel);
      }
    }
    final productStock = <int, StockLevel>{};
    for (final p in products.cast<OrderProduct>()) {
      final r = await productRepository.getProductById(p.productId);
      if (r case Success(:final value) when value != null) {
        productStock[p.productId] = StockLevel(
            onHand: value.quantityOnHand, alertLevel: value.alertLevel);
      }
    }

    // Extra details only; the order still shows without them.
    final fieldsResult =
        await orderRepository.getOrderFieldValues(event.orderId);
    final fieldValues = switch (fieldsResult) {
      Success(:final value) => value,
      Error() => const <OrderFieldEntry>[],
    };

    if (emit.isDone) return;

    emit(OrderDetailLoaded(
      order: order,
      items: items.cast(),
      materials: materials.cast(),
      products: products.cast(),
      channel: channel,
      fieldValues: fieldValues,
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
    final loaded =
        state is OrderDetailLoaded ? state as OrderDetailLoaded : null;
    // One action at a time; a double tap shouldn't pack twice.
    if (loaded?.isBusy ?? false) return;
    if (loaded != null) emit(loaded.copyWith(isBusy: true));
    final result = await action();
    switch (result) {
      case Error(:final failure):
        emit(OrderDetailMessage(failure.message,
            isError: true, serial: ++_serial));
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
      _runAction(emit, event.orderId, () => packOrder(event.orderId),
          'Packed. Stock updated.');

  Future<void> _onShipOrder(
    ShipOrderDetail event,
    Emitter<OrderDetailState> emit,
  ) =>
      _runAction(emit, event.orderId, () => shipOrder(event.orderId),
          'Marked as shipped');

  Future<void> _onCancelOrder(
    CancelOrderDetail event,
    Emitter<OrderDetailState> emit,
  ) =>
      _runAction(emit, event.orderId, () => cancelOrder(event.orderId),
          'Order cancelled. Stock returned.');

  Future<void> _onRestoreOrder(
    RestoreOrderDetail event,
    Emitter<OrderDetailState> emit,
  ) =>
      _runAction(emit, event.orderId, () => restoreOrder(event.orderId),
          'Order restored');

  /// Quiet on success: ticking a to-do shouldn't flash a progress bar or a
  /// snackbar. The reload hands the note view back what was stored, which
  /// also undoes the tick on screen if the write failed.
  Future<void> _onSaveNote(
    SaveOrderNote event,
    Emitter<OrderDetailState> emit,
  ) async {
    final loaded =
        state is OrderDetailLoaded ? state as OrderDetailLoaded : null;
    final result = await updateOrderNote(event.orderId, event.note);
    if (result case Error(:final failure)) {
      emit(OrderDetailMessage(failure.message,
          isError: true, serial: ++_serial));
      // Back to the screen before reloading, or the reload shows a spinner.
      if (loaded != null) emit(loaded);
    }
    await _onLoadOrderDetail(LoadOrderDetail(event.orderId), emit);
  }

  Future<void> _onDeleteOrder(
    DeleteOrderEvent event,
    Emitter<OrderDetailState> emit,
  ) async {
    final loaded =
        state is OrderDetailLoaded ? state as OrderDetailLoaded : null;
    if (loaded != null) emit(loaded.copyWith(isBusy: true));
    final result = await deleteOrder(event.orderId);
    switch (result) {
      case Error(:final failure):
        emit(OrderDetailMessage(failure.message,
            isError: true, serial: ++_serial));
        if (loaded != null) emit(loaded.copyWith(isBusy: false));
      case Success():
        emit(OrderDeleted());
    }
  }
}
