import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/update_product.dart';
import 'products_event.dart';
import 'products_state.dart';

/// BLoC for managing products list
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetProducts getProducts;
  final CreateProduct createProduct;
  final UpdateProduct updateProduct;

  ProductsBloc({
    required this.getProducts,
    required this.createProduct,
    required this.updateProduct,
  }) : super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());
    final result = await getProducts(activeOnly: event.activeOnly);
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (products) => emit(ProductsLoaded(products)),
    );
  }

  Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<ProductsState> emit,
  ) async {
    final result = await createProduct(
      name: event.name,
      description: event.description,
      sellPrice: event.sellPrice,
    );
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (_) {
        // Re-load products after successful creation
        add(const LoadProducts());
      },
    );
  }

  Future<void> _onUpdateProduct(
    UpdateProductEvent event,
    Emitter<ProductsState> emit,
  ) async {
    final result = await updateProduct(
      id: event.id,
      name: event.name,
      description: event.description,
      sellPrice: event.sellPrice,
      isActive: event.isActive,
    );
    result.fold(
      (failure) => emit(ProductsError(failure.message)),
      (_) {
        // Re-load products after successful update
        add(const LoadProducts());
      },
    );
  }
}
