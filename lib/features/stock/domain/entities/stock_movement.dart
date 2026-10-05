import 'package:equatable/equatable.dart';

enum StockMovementType {
  received,
  deducted,
  adjusted,
  waste;

  String get displayName {
    switch (this) {
      case StockMovementType.received:
        return 'Received';
      case StockMovementType.deducted:
        return 'Deducted';
      case StockMovementType.adjusted:
        return 'Adjusted';
      case StockMovementType.waste:
        return 'Waste';
    }
  }
}

class StockMovement extends Equatable {
  final int? id;
  final int materialId;
  final int? orderId;
  final StockMovementType type;
  final double quantity;
  final double unitCost;
  final DateTime createdAt;
  final String? reference;

  const StockMovement({
    this.id,
    required this.materialId,
    this.orderId,
    required this.type,
    required this.quantity,
    required this.unitCost,
    required this.createdAt,
    this.reference,
  });

  @override
  List<Object?> get props => [
        id,
        materialId,
        orderId,
        type,
        quantity,
        unitCost,
        createdAt,
        reference,
      ];
}
