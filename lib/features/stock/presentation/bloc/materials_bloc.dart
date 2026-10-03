import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/material_repository.dart';
import '../../domain/usecases/get_buy_list.dart';
import '../../domain/usecases/get_materials.dart';
import '../../domain/usecases/receive_stock.dart';
import 'materials_event.dart';
import 'materials_state.dart';

/// BLoC for managing materials and stock operations
class MaterialsBloc extends Bloc<MaterialsEvent, MaterialsState> {
  final GetMaterials getMaterials;
  final GetBuyList getBuyList;
  final ReceiveStock receiveStock;
  final MaterialRepository materialRepository;

  MaterialsBloc({
    required this.getMaterials,
    required this.getBuyList,
    required this.receiveStock,
    required this.materialRepository,
  }) : super(MaterialsInitial()) {
    on<LoadMaterials>(_onLoadMaterials);
    on<LoadBuyList>(_onLoadBuyList);
    on<ReceiveStockEvent>(_onReceiveStock);
    on<CreateMaterialEvent>(_onCreateMaterial);
  }

  Future<void> _onLoadMaterials(
    LoadMaterials event,
    Emitter<MaterialsState> emit,
  ) async {
    emit(MaterialsLoading());
    final result = await getMaterials(lowStockOnly: event.lowStockOnly);
    result.fold(
      (failure) => emit(MaterialsError(failure.message)),
      (materials) => emit(MaterialsLoaded(materials)),
    );
  }

  Future<void> _onLoadBuyList(
    LoadBuyList event,
    Emitter<MaterialsState> emit,
  ) async {
    emit(MaterialsLoading());
    final result = await getBuyList();
    result.fold(
      (failure) => emit(MaterialsError(failure.message)),
      (items) => emit(BuyListLoaded(items)),
    );
  }

  Future<void> _onReceiveStock(
    ReceiveStockEvent event,
    Emitter<MaterialsState> emit,
  ) async {
    final result = await receiveStock(
      materialId: event.materialId,
      packsReceived: event.packsReceived,
      pricePerPack: event.pricePerPack,
    );
    result.fold(
      (failure) => emit(MaterialsError(failure.message)),
      (_) {
        emit(StockReceived());
        // Re-load materials after receiving stock
        add(const LoadMaterials());
      },
    );
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
    result.fold(
      (failure) => emit(MaterialsError(failure.message)),
      (_) {
        emit(MaterialCreated());
        add(const LoadMaterials());
      },
    );
  }
}
