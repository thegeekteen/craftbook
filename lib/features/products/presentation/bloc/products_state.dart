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

  const ProductsLoaded(this.products);

  @override
  List<Object?> get props => [products];
}

/// Error occurred while loading/managing products
class ProductsError extends ProductsState {
  final String message;

  const ProductsError(this.message);

  @override
  List<Object?> get props => [message];
}
