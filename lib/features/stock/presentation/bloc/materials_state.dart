import 'package:equatable/equatable.dart';

import '../../domain/entities/buy_list_item.dart';
import '../../domain/entities/material.dart';

/// Base class for materials states
abstract class MaterialsState extends Equatable {
  const MaterialsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any load
class MaterialsInitial extends MaterialsState {}

/// Materials are being loaded
class MaterialsLoading extends MaterialsState {}

/// Materials loaded successfully
class MaterialsLoaded extends MaterialsState {
  final List<Material> materials;

  /// Low resell products, which also land on the Buy list.
  final int lowProductCount;

  const MaterialsLoaded(this.materials, {this.lowProductCount = 0});

  @override
  List<Object?> get props => [materials, lowProductCount];
}

/// Buy list loaded successfully
class BuyListLoaded extends MaterialsState {
  final List<BuyListItem> items;

  const BuyListLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

/// Stock was received successfully
class StockReceived extends MaterialsState {}

/// Material was created successfully
class MaterialCreated extends MaterialsState {}

/// Material was edited successfully
class MaterialUpdated extends MaterialsState {}

/// Material was deleted successfully
class MaterialDeleted extends MaterialsState {}

/// Error occurred while loading/managing materials
class MaterialsError extends MaterialsState {
  final String message;

  const MaterialsError(this.message);

  @override
  List<Object?> get props => [message];
}
