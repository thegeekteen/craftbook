import 'package:equatable/equatable.dart';

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

  const SetCustomerDetails({
    required this.customerName,
    this.fieldValues = const {},
    required this.channelId,
    required this.orderDate,
    required this.shipByDate,
    this.note,
  });

  @override
  List<Object?> get props => [
        customerName,
        fieldValues,
        channelId,
        orderDate,
        shipByDate,
        note,
      ];
}

/// Add an item to the order
class AddItem extends NewOrderEvent {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;

  const AddItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  @override
  List<Object?> get props => [productId, productName, quantity, unitPrice];
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

/// Work out profit and reservations for the review step.
class RequestPreview extends NewOrderEvent {}

/// Save the order to the database
class SaveOrder extends NewOrderEvent {}

/// Reset the order form to initial state
class ResetOrder extends NewOrderEvent {}
