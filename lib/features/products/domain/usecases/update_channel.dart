import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../repositories/channel_repository.dart';

class UpdateChannel {
  final ChannelRepository repository;

  UpdateChannel(this.repository);

  Future<Either<Failure, void>> call({
    required int id,
    String? name,
    double? commissionRate,
    double? transactionFeeRate,
    double? flatFee,
    double? shippingPaidByUs,
    bool? isActive,
  }) {
    return repository.updateChannel(
      id: id,
      name: name,
      commissionRate: commissionRate,
      transactionFeeRate: transactionFeeRate,
      flatFee: flatFee,
      shippingPaidByUs: shippingPaidByUs,
      isActive: isActive,
    );
  }
}
