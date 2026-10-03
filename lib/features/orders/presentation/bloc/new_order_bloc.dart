import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/usecases/calculate_order_profit.dart';
import '../../domain/usecases/create_order.dart';
import 'new_order_event.dart';
import 'new_order_state.dart';

/// BLoC for the multi-step new order creation flow.
///
/// Tracks customer details, items list, and computed totals.
/// On [SaveOrder], calls [CreateOrder] with all accumulated data.
class NewOrderBloc extends Bloc<NewOrderEvent, NewOrderState> {
  final CreateOrder createOrder;
  final CalculateOrderProfit calculateOrderProfit;

  // Internal mutable state for building the order
  String _customerName = '';
  String _customerAddress = '';
  int _channelId = 0;
  DateTime _orderDate = DateTime.now();
  DateTime _shipByDate = DateTime.now();
  String? _note;
  List<OrderItemInput> _items = [];

  NewOrderBloc({
    required this.createOrder,
    required this.calculateOrderProfit,
  }) : super(NewOrderInitial()) {
    on<SetCustomerDetails>(_onSetCustomerDetails);
    on<AddItem>(_onAddItem);
    on<RemoveItem>(_onRemoveItem);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<SaveOrder>(_onSaveOrder);
    on<ResetOrder>(_onResetOrder);
  }

  void _onSetCustomerDetails(
    SetCustomerDetails event,
    Emitter<NewOrderState> emit,
  ) {
    _customerName = event.customerName;
    _customerAddress = event.customerAddress;
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
      _items[existingIndex] = OrderItemInput(
        productId: existing.productId,
        productName: existing.productName,
        quantity: existing.quantity + event.quantity,
        unitPrice: existing.unitPrice,
      );
    } else {
      _items = List.from(_items)..add(OrderItemInput(
            productId: event.productId,
            productName: event.productName,
            quantity: event.quantity,
            unitPrice: event.unitPrice,
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
      _items[index] = OrderItemInput(
        productId: existing.productId,
        productName: existing.productName,
        quantity: event.quantity,
        unitPrice: existing.unitPrice,
      );
    }
    _emitDetailsFilled(emit);
  }

  Future<void> _onSaveOrder(
    SaveOrder event,
    Emitter<NewOrderState> emit,
  ) async {
    final totalSales = _items.fold(0.0, (sum, item) => sum + item.subtotal);

    // Calculate profit breakdown
    const totalMaterialCost = 0.0; // Will be computed inside CreateOrder
    final profitResult = await calculateOrderProfit(
      totalSales: totalSales,
      totalMaterialCost: totalMaterialCost,
      channelId: _channelId,
      shippingCost: 0.0,
    );

    final channelFees = switch (profitResult) {
      Success(:final value) => value.channelFees,
      Error() => 0.0,
    };
    final shippingCost = switch (profitResult) {
      Success(:final value) => value.shippingCost,
      Error() => 0.0,
    };

    final result = await createOrder(
      customerName: _customerName,
      customerAddress: _customerAddress,
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
        emit(NewOrderError(failure.message));
      case Success(:final value):
        emit(NewOrderSaved(value));
    }
  }

  void _onResetOrder(
    ResetOrder event,
    Emitter<NewOrderState> emit,
  ) {
    _customerName = '';
    _customerAddress = '';
    _channelId = 0;
    _orderDate = DateTime.now();
    _shipByDate = DateTime.now();
    _note = null;
    _items = [];
    emit(NewOrderInitial());
  }

  void _emitDetailsFilled(Emitter<NewOrderState> emit) {
    final totalSales = _items.fold(0.0, (sum, item) => sum + item.subtotal);
    emit(NewOrderDetailsFilled(
      customerName: _customerName,
      customerAddress: _customerAddress,
      channelId: _channelId,
      orderDate: _orderDate,
      shipByDate: _shipByDate,
      note: _note,
      items: List.unmodifiable(_items),
      totalSales: totalSales,
    ));
  }
}
