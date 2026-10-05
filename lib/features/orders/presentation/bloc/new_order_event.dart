import 'dart:typed_data';

import 'package:equatable/equatable.dart';

import '../../domain/entities/order_discount.dart';

/// Base class for new order events
abstract class NewOrderEvent extends Equatable {
  const NewOrderEvent();

  @override
  List<Object?> get props => [];
}

/// Set customer details for the new order
class SetCustomerDetails extends NewOrderEvent {
  final String customerName;

  /// Values for the fields shown on the form, by field id. Blank clears.
  final Map<int, String> fieldValues;
  final int channelId;
  final DateTime orderDate;
  final DateTime shipByDate;
  final String? note;

  /// The chosen channel's "paid when placed" default. Sets the order's paid
  /// status unless the user has already set it themselves.
  final bool channelPaidByDefault;

  const SetCustomerDetails({
    required this.customerName,
    this.fieldValues = const {},
    required this.channelId,
    required this.orderDate,
    required this.shipByDate,
    this.note,
    this.channelPaidByDefault = true,
  });

  @override
  List<Object?> get props => [
        customerName,
        fieldValues,
        channelId,
        orderDate,
        shipByDate,
        note,
        channelPaidByDefault,
      ];
}

/// Add an item to the order
class AddItem extends NewOrderEvent {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final Uint8List? photo;

  const AddItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.photo,
  });

  @override
  List<Object?> get props =>
      [productId, productName, quantity, unitPrice, photo];
}

/// Remove an item from the order by product ID
class RemoveItem extends NewOrderEvent {
  final int productId;

  const RemoveItem(this.productId);

  @override
  List<Object?> get props => [productId];
}

/// Update the quantity of an existing item
class UpdateItemQuantity extends NewOrderEvent {
  final int productId;
  final int quantity;

  const UpdateItemQuantity({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}

/// Start editing an existing order: loads its details and items.
class LoadExistingOrder extends NewOrderEvent {
  final int orderId;

  const LoadExistingOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Add a discount line (from a preset or typed in).
class AddDiscount extends NewOrderEvent {
  final OrderDiscount discount;

  const AddDiscount(this.discount);

  @override
  List<Object?> get props => [discount];
}

/// Remove the discount line at [index].
class RemoveDiscount extends NewOrderEvent {
  final int index;

  const RemoveDiscount(this.index);

  @override
  List<Object?> get props => [index];
}

/// Turn tax on or off for this order only.
class SetOrderTaxEnabled extends NewOrderEvent {
  final bool enabled;

  const SetOrderTaxEnabled(this.enabled);

  @override
  List<Object?> get props => [enabled];
}

/// Mark the order paid or unpaid.
class SetOrderPaidStatus extends NewOrderEvent {
  final bool paid;

  const SetOrderPaidStatus(this.paid);

  @override
  List<Object?> get props => [paid];
}

/// Work out profit and reservations for the review step.
class RequestPreview extends NewOrderEvent {}

/// Save the order to the database
class SaveOrder extends NewOrderEvent {}

/// Reset the order form to initial state
class ResetOrder extends NewOrderEvent {}
