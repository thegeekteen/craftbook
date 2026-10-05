import 'package:craftbook/core/error/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_product.dart';
import '../../domain/usecases/calculate_bom_cost.dart';
import '../../domain/usecases/calculate_buildable_quantity.dart';
import '../../domain/usecases/delete_product.dart';
import '../../domain/product_stock_status.dart';
import '../../domain/usecases/get_pending_order_counts.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/update_product.dart';
import 'products_event.dart';
import 'products_state.dart';

/// BLoC for managing products list
class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final GetProducts getProducts;
  final CreateProduct createProduct;
  final UpdateProduct updateProduct;
  final DeleteProduct deleteProduct;
  final CalculateBomCost calculateBomCost;
  final CalculateBuildableQuantity calculateBuildableQuantity;
  final GetPendingOrderCounts getPendingOrderCounts;

  ProductsBloc({
    required this.getProducts,
    required this.createProduct,
    required this.updateProduct,
    required this.deleteProduct,
    required this.calculateBomCost,
    required this.calculateBuildableQuantity,
    required this.getPendingOrderCounts,
  }) : super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<CreateProductEvent>(_onCreateProduct);
    on<UpdateProductEvent>(_onUpdateProduct);
    on<DeleteProductEvent>(_onDeleteProduct);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is! ProductsLoaded) emit(ProductsLoading());
    final result = await getProducts(includeArchived: event.includeArchived);
    switch (result) {
      case Error(:final failure):
        emit(ProductsError(failure.message));
      case Success(:final value):
        final costs = <int, double>{};
        final available = <int, int>{};
        final shortIds = <int>{};
        // A failed count only hides the Short tag; the list still loads.
        final pending = switch (await getPendingOrderCounts()) {
          Success(:final value) => value,
          Error() => const <int, int>{},
        };
        for (final p in value) {
          if (p.id == null) continue;
          if (await calculateBomCost(p.id!) case Success(value: final cost)) {
            costs[p.id!] = cost;
          }
          if (await calculateBuildableQuantity(p.id!)
              case Success(value: final n)) {
            available[p.id!] = n < 0 ? 0 : n;
            if (isProductShort(p,
                rawBuildable: n, pendingOrders: pending[p.id!] ?? 0)) {
              shortIds.add(p.id!);
            }
          }
        }
        emit(ProductsLoaded(value,
            unitCosts: costs, available: available, shortIds: shortIds));
    }
  }

  Future<void> _onCreateProduct(
    CreateProductEvent event,
    Emitter<ProductsState> emit,
  ) async {
    final result = await createProduct(
      name: event.name,
      description: event.description,
      sellPrice: event.sellPrice,
      unitId: event.unitId,
      isStandalone: event.isStandalone,
      initialQuantity: event.initialQuantity,
      initialUnitCost: event.initialUnitCost,
    );
    switch (result) {
      case Error(:final failure):
        emit(ProductsError(failure.message));
      case Success():
        // Re-load products after successful creation
        add(const LoadProducts());
    }
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
      unitCost: event.unitCost,
      unitId: event.unitId,
      isArchived: event.isArchived,
      isStandalone: event.isStandalone,
      alertLevel: event.alertLevel,
    );
    switch (result) {
      case Error(:final failure):
        emit(ProductsError(failure.message));
      case Success():
        // Re-load products after successful update
        add(const LoadProducts());
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProductEvent event,
    Emitter<ProductsState> emit,
  ) async {
    final result = await deleteProduct(event.productId);
    switch (result) {
      case Error(:final failure):
        emit(ProductsError(failure.message));
      case Success():
        emit(ProductDeleted());
        add(const LoadProducts());
    }
  }
}
