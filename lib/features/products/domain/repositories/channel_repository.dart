import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/channel.dart';

abstract class ChannelRepository {
  Future<Either<Failure, List<Channel>>> getAllChannels();
  Future<Either<Failure, List<Channel>>> getActiveChannels();
  Future<Either<Failure, Channel?>> getChannelById(int id);
  Future<Either<Failure, int>> createChannel({
    required String name,
    required double commissionRate,
    required double transactionFeeRate,
    required double flatFee,
    required double shippingPaidByUs,
  });
  Future<Either<Failure, void>> updateChannel({
    required int id,
    String? name,
    double? commissionRate,
    double? transactionFeeRate,
    double? flatFee,
    double? shippingPaidByUs,
    bool? isActive,
  });
  Future<Either<Failure, void>> deleteChannel(int id);
}
