import 'package:equatable/equatable.dart';

import '../../domain/entities/order.dart';
import '../../domain/entities/order_discount.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/usecases/preview_order.dart';

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

  /// Custom field values by field id, archived fields included.
  final Map<int, String> fieldValues;
  final int channelId;
  final DateTime orderDate;
  final DateTime shipByDate;
  final String? note;
  final List<OrderItemInput> items;
  final double totalSales;

  /// Discounts, tax and paid status.
  final OrderTerms terms;

  /// The tax this order gets if it's switched on; null when there's no rate
  /// to use, so the switch isn't offered.
  final OrderTax? availableTax;

  /// Filled on the review step; cleared whenever details or items change.
  final OrderPreview? preview;
  final bool isPreviewing;
  final String? previewError;
  final bool isSaving;

  /// Set when editing an existing order; null for a new one.
  final int? editingOrderId;
  final OrderStatus? editingStatus;

  const NewOrderDetailsFilled({
    required this.customerName,
    this.fieldValues = const {},
    required this.channelId,
    required this.orderDate,
    required this.shipByDate,
    this.note,
    required this.items,
    required this.totalSales,
    this.terms = const OrderTerms(),
    this.availableTax,
    this.preview,
    this.isPreviewing = false,
    this.previewError,
    this.isSaving = false,
    this.editingOrderId,
    this.editingStatus,
  });

  bool get isEditing => editingOrderId != null;

  double get totalItemCount =>
      items.fold(0, (sum, item) => sum + item.quantity);

  @override
  List<Object?> get props => [
        customerName,
        fieldValues,
        channelId,
        orderDate,
        shipByDate,
        note,
        items,
        totalSales,
        terms,
        availableTax,
        preview,
        isPreviewing,
        previewError,
        isSaving,
        editingOrderId,
        editingStatus,
      ];

  NewOrderDetailsFilled copyWith({
    String? customerName,
    Map<int, String>? fieldValues,
    int? channelId,
    DateTime? orderDate,
    DateTime? shipByDate,
    String? note,
    List<OrderItemInput>? items,
    double? totalSales,
    bool clearNote = false,
    OrderPreview? preview,
    bool clearPreview = false,
    bool? isPreviewing,
    String? previewError,
    bool? isSaving,
  }) {
    return NewOrderDetailsFilled(
      customerName: customerName ?? this.customerName,
      fieldValues: fieldValues ?? this.fieldValues,
      channelId: channelId ?? this.channelId,
      orderDate: orderDate ?? this.orderDate,
      shipByDate: shipByDate ?? this.shipByDate,
      note: clearNote ? null : (note ?? this.note),
      items: items ?? this.items,
      totalSales: totalSales ?? this.totalSales,
      terms: terms,
      availableTax: availableTax,
      preview: clearPreview ? null : (preview ?? this.preview),
      isPreviewing: isPreviewing ?? this.isPreviewing,
      previewError: previewError,
      isSaving: isSaving ?? this.isSaving,
      editingOrderId: editingOrderId,
      editingStatus: editingStatus,
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
