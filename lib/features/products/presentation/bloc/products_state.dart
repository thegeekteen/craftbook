import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';

/// Base class for products states
abstract class ProductsState extends Equatable {
  const ProductsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any load
class ProductsInitial extends ProductsState {}

/// Products are being loaded
class ProductsLoading extends ProductsState {}

/// Products loaded successfully
class ProductsLoaded extends ProductsState {
  final List<Product> products;

  /// Cost to make (BOM) or buy (standalone) one piece, by product id.
  final Map<int, double> unitCosts;

  /// Pieces that can be built now (BOM) or are free in stock (standalone).
  final Map<int, int> available;

  const ProductsLoaded(
    this.products, {
    this.unitCosts = const {},
    this.available = const {},
  });

  @override
  List<Object?> get props => [products, unitCosts, available];
}

/// Product was deleted successfully
class ProductDeleted extends ProductsState {}

/// Error occurred while loading/managing products
class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object?> get props => [message];
}
