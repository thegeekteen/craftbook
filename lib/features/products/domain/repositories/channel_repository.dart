import 'package:craftbook/core/error/result.dart';

import '../entities/channel.dart';

abstract class ChannelRepository {
  Future<Result<List<Channel>>> getAllChannels();
  Future<Result<List<Channel>>> getActiveChannels();
  Future<Result<Channel?>> getChannelById(int id);
  Future<Result<int>> createChannel({
    required String name,
    required double commissionRate,
    required double transactionFeeRate,
    required double flatFee,
    required double shippingPaidByUs,
  });
  Future<Result<void>> updateChannel({
    required int id,
    String? name,
    double? commissionRate,
    double? transactionFeeRate,
    double? flatFee,
    double? shippingPaidByUs,
    bool? isActive,
  });
  Future<Result<void>> deleteChannel(int id);
}
