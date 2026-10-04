import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../products/domain/usecases/get_low_stock_products.dart';
import '../../domain/repositories/material_repository.dart';
import '../../domain/usecases/delete_material.dart';
import '../../domain/usecases/get_buy_list.dart';
import '../../domain/usecases/get_materials.dart';
import '../../domain/usecases/receive_stock.dart';
import '../../domain/usecases/update_material.dart';
import 'materials_event.dart';
import 'materials_state.dart';

/// BLoC for managing materials and stock operations
class MaterialsBloc extends Bloc<MaterialsEvent, MaterialsState> {
  final GetMaterials getMaterials;
  final GetBuyList getBuyList;
  final ReceiveStock receiveStock;
  final DeleteMaterial deleteMaterial;
  final UpdateMaterial updateMaterial;
  final MaterialRepository materialRepository;
  final GetLowStockProducts getLowStockProducts;

  MaterialsBloc({
    required this.getMaterials,
    required this.getBuyList,
    required this.receiveStock,
    required this.deleteMaterial,
    required this.updateMaterial,
    required this.materialRepository,
    required this.getLowStockProducts,
  }) : super(MaterialsInitial()) {
    on<LoadMaterials>(_onLoadMaterials);
    on<LoadBuyList>(_onLoadBuyList);
    on<ReceiveStockEvent>(_onReceiveStock);
    on<CreateMaterialEvent>(_onCreateMaterial);
    on<UpdateMaterialEvent>(_onUpdateMaterial);
    on<DeleteMaterialEvent>(_onDeleteMaterial);
  }

  Future<void> _onLoadMaterials(
    LoadMaterials event,
    Emitter<MaterialsState> emit,
  ) async {
    if (state is! MaterialsLoaded) emit(MaterialsLoading());
    final result = await getMaterials(lowStockOnly: event.lowStockOnly);
    switch (result) {
      case Error(:final failure):
        emit(MaterialsError(failure.message));
      case Success(:final value):
        // A failed count only drops resell from the Buy list badge.
        final lowProducts = switch (await getLowStockProducts()) {
          Success(:final value) => value.length,
          Error() => 0,
        };
        emit(MaterialsLoaded(value, lowProductCount: lowProducts));
    }
  }

  Future<void> _onLoadBuyList(
    LoadBuyList event,
    Emitter<MaterialsState> emit,
  ) async {
    emit(MaterialsLoading());
    final result = await getBuyList();
    switch (result) {
      case Error(:final failure):
        emit(MaterialsError(failure.message));
      case Success(value: final items):
        emit(BuyListLoaded(items));
    }
  }

  Future<void> _onReceiveStock(
    ReceiveStockEvent event,
    Emitter<MaterialsState> emit,
  ) async {
    final result = await receiveStock(
      materialId: event.materialId,
      packsReceived: event.packsReceived,
      pricePerPack: event.pricePerPack,
      supplier: event.supplier,
    );
    switch (result) {
      case Error(:final failure):
        emit(MaterialsError(failure.message));
      case Success():
        emit(StockReceived());
        // Re-load materials after receiving stock
        add(const LoadMaterials());
    }
  }

  Future<void> _onCreateMaterial(
    CreateMaterialEvent event,
    Emitter<MaterialsState> emit,
  ) async {
    final unitCost =
        event.packSize > 0 ? event.packPrice / event.packSize : 0.0;
    final result = await materialRepository.createMaterial(
      name: event.name,
      packSize: event.packSize,
      packPrice: event.packPrice,
      unitCost: unitCost,
      quantityOnHand: event.initialQuantity,
      alertLevel: event.alertLevel,
      supplier: event.supplier,
    );
    switch (result) {
      case Error(:final failure):
        emit(MaterialsError(failure.message));
      case Success():
        emit(MaterialCreated());
        add(const LoadMaterials());
    }
  }

  Future<void> _onUpdateMaterial(
    UpdateMaterialEvent event,
    Emitter<MaterialsState> emit,
  ) async {
    final result = await updateMaterial(
      id: event.id,
      name: event.name,
      packSize: event.packSize,
      packPrice: event.packPrice,
      alertLevel: event.alertLevel,
      supplier: event.supplier,
    );
    switch (result) {
      case Error(:final failure):
        emit(MaterialsError(failure.message));
      case Success():
        emit(MaterialUpdated());
        add(const LoadMaterials());
    }
  }

  Future<void> _onDeleteMaterial(
    DeleteMaterialEvent event,
    Emitter<MaterialsState> emit,
  ) async {
    final result = await deleteMaterial(event.materialId);
    switch (result) {
      case Error(:final failure):
        emit(MaterialsError(failure.message));
      case Success():
        emit(MaterialDeleted());
        add(const LoadMaterials());
    }
  }
}
