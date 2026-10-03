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

  const CreateProductEvent({
    required this.name,
    this.description,
    required this.sellPrice,
  });

  @override
  List<Object?> get props => [name, description, sellPrice];
}

/// Update an existing product
class UpdateProductEvent extends ProductsEvent {
  final int id;
  final String? name;
  final String? description;
  final double? sellPrice;
  final bool? isActive;

  const UpdateProductEvent({
    required this.id,
    this.name,
    this.description,
    this.sellPrice,
    this.isActive,
  });

  @override
  List<Object?> get props => [id, name, description, sellPrice, isActive];
}

/// Delete a product
class DeleteProductEvent extends ProductsEvent {
  final int productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}
