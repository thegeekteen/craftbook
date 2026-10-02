import 'package:equatable/equatable.dart';

import '../../domain/entities/order_item.dart';

/// Base class for new order states
abstract class NewOrderState extends Equatable {
  const NewOrderState();

  @override
  List<Object?> get props => [];
}

/// Initial state — no data entered
class NewOrderInitial extends NewOrderState {}

/// Customer details and items are being filled in
class NewOrderDetailsFilled extends NewOrderState {
  final String customerName;
  final String customerAddress;
  final int channelId;
  final DateTime orderDate;
  final DateTime shipByDate;
  final String? note;
  final List<OrderItemInput> items;
  final double totalSales;

  const NewOrderDetailsFilled({
    required this.customerName,
    required this.customerAddress,
    required this.channelId,
    required this.orderDate,
    required this.shipByDate,
    this.note,
    required this.items,
    required this.totalSales,
  });

  double get totalItemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
        customerName,
        customerAddress,
        channelId,
        orderDate,
        shipByDate,
        note,
        items,
        totalSales,
      ];

  NewOrderDetailsFilled copyWith({
    String? customerName,
    String? customerAddress,
    int? channelId,
    DateTime? orderDate,
    DateTime? shipByDate,
    String? note,
    List<OrderItemInput>? items,
    double? totalSales,
    bool clearNote = false,
  }) {
    return NewOrderDetailsFilled(
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      channelId: channelId ?? this.channelId,
      orderDate: orderDate ?? this.orderDate,
      shipByDate: shipByDate ?? this.shipByDate,
      note: clearNote ? null : (note ?? this.note),
      items: items ?? this.items,
      totalSales: totalSales ?? this.totalSales,
    );
  }
}

/// Order was saved successfully, carrying the new order ID
class NewOrderSaved extends NewOrderState {
  final int orderId;

  const NewOrderSaved(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Error occurred while creating the order
class NewOrderError extends NewOrderState {
  final String message;

  const NewOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
