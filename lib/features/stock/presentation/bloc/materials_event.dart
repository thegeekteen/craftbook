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

  const ReceiveStockEvent({
    required this.materialId,
    required this.packsReceived,
    required this.pricePerPack,
  });

  @override
  List<Object?> get props => [materialId, packsReceived, pricePerPack];
}
