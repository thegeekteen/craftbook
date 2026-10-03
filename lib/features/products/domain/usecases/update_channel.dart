import 'package:craftbook/core/error/result.dart';

import '../repositories/channel_repository.dart';

class UpdateChannel {
  final ChannelRepository repository;

  UpdateChannel(this.repository);

  Future<Result<void>> call({
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
