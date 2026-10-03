import 'package:equatable/equatable.dart';

/// Base class for products events
abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

/// Load all products from the database
class LoadProducts extends ProductsEvent {
  final bool activeOnly;

  const LoadProducts({this.activeOnly = false});

  @override
  List<Object?> get props => [activeOnly];
}

/// Create a new product
class CreateProductEvent extends ProductsEvent {
  final String name;
  final String? description;
  final double sellPrice;
  final bool isStandalone;
  final int initialQuantity;
  final double initialUnitCost;

  const CreateProductEvent({
    required this.name,
    this.description,
    required this.sellPrice,
    this.isStandalone = false,
    this.initialQuantity = 0,
    this.initialUnitCost = 0,
  });

  @override
  List<Object?> get props => [name, description, sellPrice, isStandalone, initialQuantity, initialUnitCost];
}

/// Update an existing product
class UpdateProductEvent extends ProductsEvent {
  final int id;
  final String? name;
  final String? description;
  final double? sellPrice;
  final double? unitCost;
  final bool? isActive;
  final bool? isStandalone;
  final int? alertLevel;

  const UpdateProductEvent({
    required this.id,
    this.name,
    this.description,
    this.sellPrice,
    this.unitCost,
    this.isActive,
    this.isStandalone,
    this.alertLevel,
  });

  @override
  List<Object?> get props =>
      [id, name, description, sellPrice, unitCost, isActive, isStandalone, alertLevel];
}

/// Delete a product
class DeleteProductEvent extends ProductsEvent {
  final int productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}
