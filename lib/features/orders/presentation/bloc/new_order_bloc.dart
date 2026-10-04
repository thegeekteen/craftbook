import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../order_fields/domain/entities/order_field_entry.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/repositories/order_repository.dart';
import '../../domain/usecases/calculate_order_profit.dart';
import '../../domain/usecases/create_order.dart';
import '../../domain/usecases/preview_order.dart';
import '../../domain/usecases/update_order.dart';
import 'new_order_event.dart';
import 'new_order_state.dart';

/// BLoC for the multi-step new order creation flow.
///
/// Tracks customer details, items list, and computed totals.
/// On [SaveOrder], calls [CreateOrder] with all accumulated data, or
/// [UpdateOrder] after [LoadExistingOrder].
class NewOrderBloc extends Bloc<NewOrderEvent, NewOrderState> {
  final CreateOrder createOrder;
  final UpdateOrder updateOrder;
  final OrderRepository orderRepository;
  final CalculateOrderProfit calculateOrderProfit;
  final PreviewOrder previewOrder;

  // Internal mutable state for building the order
  String _customerName = '';
  Map<int, String> _fieldValues = {};
  int _channelId = 0;
  DateTime _orderDate = DateTime.now();
  DateTime _shipByDate = DateTime.now();
  String? _note;
  List<OrderItemInput> _items = [];
  int? _editingOrderId;
  OrderStatus? _editingStatus;

  NewOrderBloc({
    required this.createOrder,
    required this.updateOrder,
    required this.orderRepository,
    required this.calculateOrderProfit,
    required this.previewOrder,
  }) : super(NewOrderInitial()) {
    on<LoadExistingOrder>(_onLoadExistingOrder);
    on<SetCustomerDetails>(_onSetCustomerDetails);
    on<AddItem>(_onAddItem);
    on<RemoveItem>(_onRemoveItem);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<RequestPreview>(_onRequestPreview);
    on<SaveOrder>(_onSaveOrder);
    on<ResetOrder>(_onResetOrder);
  }

  Future<void> _onLoadExistingOrder(
    LoadExistingOrder event,
    Emitter<NewOrderState> emit,
  ) async {
    final orderResult = await orderRepository.getOrderById(event.orderId);
    final itemsResult = await orderRepository.getOrderItems(event.orderId);
    final fieldsResult =
        await orderRepository.getOrderFieldValues(event.orderId);
    if (orderResult case Error(:final failure)) {
      emit(NewOrderError(failure.message));
      return;
    }
    if (itemsResult case Error(:final failure)) {
      emit(NewOrderError(failure.message));
      return;
    }
    if (fieldsResult case Error(:final failure)) {
      emit(NewOrderError(failure.message));
      return;
    }
    final order = (orderResult as Success<Order?>).value;
    if (order == null) {
      emit(const NewOrderError('Order not found'));
      return;
    }
    _editingOrderId = event.orderId;
    _editingStatus = order.status;
    _customerName = order.customerName;
    // Archived fields aren't on the form, but their values ride along so
    // saving (which replaces the whole set) keeps them.
    _fieldValues = {
      for (final e in (fieldsResult as Success<List<OrderFieldEntry>>).value)
        e.field.id!: e.value,
    };
    _channelId = order.channelId ?? 0;
    _orderDate = order.orderDate;
    _shipByDate = order.shipByDate;
    _note = order.note;
    _items = [
      for (final i in (itemsResult as Success<List<OrderItem>>).value)
        OrderItemInput(
          productId: i.productId,
          productName: i.productName,
          quantity: i.quantity,
          unitPrice: i.unitPrice,
          photo: i.productPhoto,
        ),
    ];
    _emitDetailsFilled(emit);
  }

  void _onSetCustomerDetails(
    SetCustomerDetails event,
    Emitter<NewOrderState> emit,
  ) {
    _customerName = event.customerName;
    _fieldValues = {..._fieldValues, ...event.fieldValues};
    _channelId = event.channelId;
    _orderDate = event.orderDate;
    _shipByDate = event.shipByDate;
    _note = event.note;
    _emitDetailsFilled(emit);
  }

  void _onAddItem(AddItem event, Emitter<NewOrderState> emit) {
    final existingIndex =
        _items.indexWhere((item) => item.productId == event.productId);
    if (existingIndex >= 0) {
      // Update quantity if item already exists
      final existing = _items[existingIndex];
      _items[existingIndex] =
          existing.copyWith(quantity: existing.quantity + event.quantity);
    } else {
      _items = List.from(_items)
        ..add(OrderItemInput(
          productId: event.productId,
          productName: event.productName,
          quantity: event.quantity,
          unitPrice: event.unitPrice,
          photo: event.photo,
        ));
    }
    _emitDetailsFilled(emit);
  }

  void _onRemoveItem(RemoveItem event, Emitter<NewOrderState> emit) {
    _items = _items.where((item) => item.productId != event.productId).toList();
    _emitDetailsFilled(emit);
  }

  void _onUpdateItemQuantity(
    UpdateItemQuantity event,
    Emitter<NewOrderState> emit,
  ) {
    final index =
        _items.indexWhere((item) => item.productId == event.productId);
    if (index >= 0) {
      final existing = _items[index];
      _items[index] = existing.copyWith(quantity: event.quantity);
    }
    _emitDetailsFilled(emit);
  }

  Future<void> _onRequestPreview(
    RequestPreview event,
    Emitter<NewOrderState> emit,
  ) async {
    final current = _detailsState();
    emit(current.copyWith(isPreviewing: true, clearPreview: true));
    final result = await previewOrder(
      items: _items,
      channelId: _channelId,
      excludeOrderId: _editingOrderId,
    );
    switch (result) {
      case Error(:final failure):
        emit(current.copyWith(
            isPreviewing: false, previewError: failure.message));
      case Success(:final value):
        emit(current.copyWith(isPreviewing: false, preview: value));
    }
  }

  Future<void> _onSaveOrder(
    SaveOrder event,
    Emitter<NewOrderState> emit,
  ) async {
    // Kept so a failed save returns to the same review screen, preview
    // included.
    final before = state is NewOrderDetailsFilled
        ? state as NewOrderDetailsFilled
        : _detailsState();
    emit(before.copyWith(isSaving: true));

    void fail(String message) {
      emit(NewOrderError(message));
      emit(before.copyWith(isSaving: false, preview: before.preview));
    }

    final editingId = _editingOrderId;
    if (editingId != null) {
      final updated = await updateOrder(
        orderId: editingId,
        customerName: _customerName,
        fieldValues: _fieldValues,
        note: _note,
        orderDate: _orderDate,
        shipByDate: _shipByDate,
        channelId: _channelId,
        items: _items,
      );
      switch (updated) {
        case Error(:final failure):
          fail(failure.message);
        case Success():
          emit(NewOrderSaved(editingId));
      }
      return;
    }

    final totalSales = _items.fold(0.0, (sum, item) => sum + item.subtotal);

    // Calculate profit breakdown
    const totalMaterialCost = 0.0; // Will be computed inside CreateOrder
    final profitResult = await calculateOrderProfit(
      totalSales: totalSales,
      totalMaterialCost: totalMaterialCost,
      channelId: _channelId,
      shippingCost: 0.0,
    );

    // Saving with zero fees would store a wrong profit, so stop instead.
    final OrderProfitBreakdown breakdown;
    switch (profitResult) {
      case Error(:final failure):
        fail(failure.message);
        return;
      case Success(:final value):
        breakdown = value;
    }
    final channelFees = breakdown.channelFees;
    final shippingCost = breakdown.shippingCost;

    final result = await createOrder(
      customerName: _customerName,
      fieldValues: _fieldValues,
      note: _note,
      orderDate: _orderDate,
      shipByDate: _shipByDate,
      channelId: _channelId,
      totalSales: totalSales,
      channelFees: channelFees,
      shippingCost: shippingCost,
      items: _items,
    );

    switch (result) {
      case Error(:final failure):
        fail(failure.message);
      case Success(:final value):
        emit(NewOrderSaved(value));
    }
  }

  void _onResetOrder(
    ResetOrder event,
    Emitter<NewOrderState> emit,
  ) {
    _customerName = '';
    _fieldValues = {};
    _channelId = 0;
    _orderDate = DateTime.now();
    _shipByDate = DateTime.now();
    _note = null;
    _items = [];
    _editingOrderId = null;
    _editingStatus = null;
    emit(NewOrderInitial());
  }

  void _emitDetailsFilled(Emitter<NewOrderState> emit) {
    emit(_detailsState());
  }

  NewOrderDetailsFilled _detailsState() {
    final totalSales = _items.fold(0.0, (sum, item) => sum + item.subtotal);
    return NewOrderDetailsFilled(
      customerName: _customerName,
      fieldValues: Map.unmodifiable(_fieldValues),
      channelId: _channelId,
      orderDate: _orderDate,
      shipByDate: _shipByDate,
      note: _note,
      items: List.unmodifiable(_items),
      totalSales: totalSales,
      editingOrderId: _editingOrderId,
      editingStatus: _editingStatus,
    );
  }
}
