import 'package:equatable/equatable.dart';

/// Base class for materials events
abstract class MaterialsEvent extends Equatable {
  const MaterialsEvent();

  @override
  List<Object?> get props => [];
}

/// Load materials list, optionally filtering to low-stock only
class LoadMaterials extends MaterialsEvent {
  final bool lowStockOnly;

  const LoadMaterials({this.lowStockOnly = false});

  @override
  List<Object?> get props => [lowStockOnly];
}

/// Load the buy list (materials that need to be reordered)
class LoadBuyList extends MaterialsEvent {}

/// Receive stock for a material
class ReceiveStockEvent extends MaterialsEvent {
  final int materialId;
  final int packsReceived;
  final double pricePerPack;
  final String? supplier;

  const ReceiveStockEvent({
    required this.materialId,
    required this.packsReceived,
    required this.pricePerPack,
    this.supplier,
  });

  @override
  List<Object?> get props => [materialId, packsReceived, pricePerPack, supplier];
}

/// Create a new material
class CreateMaterialEvent extends MaterialsEvent {
  final String name;
  final int packSize;
  final double packPrice;
  final int alertLevel;
  final String? supplier;
  final int initialQuantity;

  const CreateMaterialEvent({
    required this.name,
    required this.packSize,
    required this.packPrice,
    required this.alertLevel,
    this.supplier,
    this.initialQuantity = 0,
  });

  @override
  List<Object?> get props =>
      [name, packSize, packPrice, alertLevel, supplier, initialQuantity];
}

/// Edit a material's name, pack, supplier and reorder level
class UpdateMaterialEvent extends MaterialsEvent {
  final int id;
  final String name;
  final int packSize;
  final double packPrice;
  final int alertLevel;
  final String? supplier;

  const UpdateMaterialEvent({
    required this.id,
    required this.name,
    required this.packSize,
    required this.packPrice,
    required this.alertLevel,
    this.supplier,
  });

  @override
  List<Object?> get props =>
      [id, name, packSize, packPrice, alertLevel, supplier];
}

/// Delete a material
class DeleteMaterialEvent extends MaterialsEvent {
  final int materialId;

  const DeleteMaterialEvent(this.materialId);

  @override
  List<Object?> get props => [materialId];
}
