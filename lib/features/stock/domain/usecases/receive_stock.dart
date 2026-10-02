import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/material_repository.dart';

class ReceiveStock {
  final MaterialRepository repository;

  ReceiveStock(this.repository);

  Future<Either<Failure, void>> call({
    required int materialId,
    required int packsReceived,
    required double pricePerPack,
    DateTime? receivedAt,
    String? supplier,
  }) async {
    if (packsReceived <= 0) {
      return Left(const ValidationFailure('Packs received must be greater than 0'));
    }
    if (pricePerPack < 0) {
      return Left(const ValidationFailure('Price per pack cannot be negative'));
    }
    return repository.receiveStock(
      materialId: materialId,
      packsReceived: packsReceived,
      pricePerPack: pricePerPack,
      receivedAt: receivedAt,
      supplier: supplier,
    );
  }
}
