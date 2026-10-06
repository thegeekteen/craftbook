import 'package:equatable/equatable.dart';

/// Base class for products events
abstract class ProductsEvent extends Equatable {
  const ProductsEvent();

  @override
  List<Object?> get props => [];
}

/// Load products from the database, archived ones too unless
/// [includeArchived] is false
class LoadProducts extends ProductsEvent {
  final bool includeArchived;

  const LoadProducts({this.includeArchived = true});

  @override
  List<Object?> get props => [includeArchived];
}

/// Create a new product
class CreateProductEvent extends ProductsEvent {
  final String name;
  final String? description;
  final double sellPrice;

  /// What it's sold and counted in; null leaves it on the shop's default.
  final int? unitId;
  final bool isStandalone;
  final int initialQuantity;
  final double initialUnitCost;

  const CreateProductEvent({
    required this.name,
    this.description,
    required this.sellPrice,
    this.unitId,
    this.isStandalone = false,
    this.initialQuantity = 0,
    this.initialUnitCost = 0,
  });

  @override
  List<Object?> get props => [
        name,
        description,
        sellPrice,
        unitId,
        isStandalone,
        initialQuantity,
        initialUnitCost
      ];
}

/// Update an existing product
class UpdateProductEvent extends ProductsEvent {
  final int id;
  final String? name;
  final String? description;
  final double? sellPrice;
  final double? unitCost;
  final int? unitId;
  final bool? isArchived;
  final bool? isStandalone;
  final int? alertLevel;

  const UpdateProductEvent({
    required this.id,
    this.name,
    this.description,
    this.sellPrice,
    this.unitCost,
    this.unitId,
    this.isArchived,
    this.isStandalone,
    this.alertLevel,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        sellPrice,
        unitCost,
        unitId,
        isArchived,
        isStandalone,
        alertLevel
      ];
}

/// Delete a product
class DeleteProductEvent extends ProductsEvent {
  final int productId;

  const DeleteProductEvent(this.productId);

  @override
  List<Object?> get props => [productId];
}
