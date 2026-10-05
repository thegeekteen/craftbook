import 'package:equatable/equatable.dart';
import '../../domain/entities/order_discount.dart';

import '../../../order_fields/domain/entities/order_field_entry.dart';
import '../../../products/domain/entities/channel.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/order_material.dart';
import '../../domain/entities/order_product.dart';

/// Current shelf stock for something the order uses.
class StockLevel extends Equatable {
  final int onHand;
  final int alertLevel;

  const StockLevel({required this.onHand, required this.alertLevel});

  @override
  List<Object?> get props => [onHand, alertLevel];
}

/// Base class for order detail states
abstract class OrderDetailState extends Equatable {
  const OrderDetailState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any load
class OrderDetailInitial extends OrderDetailState {}

/// Order detail is being loaded for the first time
class OrderDetailLoading extends OrderDetailState {}

/// Order detail loaded successfully
class OrderDetailLoaded extends OrderDetailState {
  final Order order;
  final List<OrderItem> items;
  final List<OrderMaterial> materials;
  final List<OrderProduct> products;
  final Channel? channel;

  /// Custom field values, archived fields included, in field order.
  final List<OrderFieldEntry> fieldValues;

  /// Current stock keyed by material id, for the pack preview.
  final Map<int, StockLevel> materialStock;

  /// Current stock keyed by standalone product id.
  final Map<int, StockLevel> productStock;

  /// An action (pack, ship, adjust, delete) is running.
  final bool isBusy;

  /// Discount lines with what each took off.
  final List<OrderDiscount> discounts;

  const OrderDetailLoaded({
    required this.order,
    required this.items,
    required this.materials,
    this.products = const [],
    this.channel,
    this.fieldValues = const [],
    this.materialStock = const {},
    this.productStock = const {},
    this.isBusy = false,
    this.discounts = const [],
  });

  OrderDetailLoaded copyWith({bool? isBusy}) => OrderDetailLoaded(
        order: order,
        items: items,
        materials: materials,
        products: products,
        channel: channel,
        fieldValues: fieldValues,
        materialStock: materialStock,
        productStock: productStock,
        isBusy: isBusy ?? this.isBusy,
        discounts: discounts,
      );

  @override
  List<Object?> get props => [
        order,
        items,
        materials,
        products,
        channel,
        fieldValues,
        materialStock,
        productStock,
        isBusy,
        discounts,
      ];
}

/// The order couldn't be loaded
class OrderDetailError extends OrderDetailState {
  final String message;

  const OrderDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

/// One-shot result of an action, shown as a snackbar. The loaded state is
/// re-emitted right after so the screen stays in place.
class OrderDetailMessage extends OrderDetailState {
  final String message;
  final bool isError;

  /// Guarantees two identical messages in a row are both delivered.
  final int serial;

  const OrderDetailMessage(this.message,
      {this.isError = false, this.serial = 0});

  @override
  List<Object?> get props => [message, isError, serial];
}

/// Order was deleted successfully
class OrderDeleted extends OrderDetailState {}
