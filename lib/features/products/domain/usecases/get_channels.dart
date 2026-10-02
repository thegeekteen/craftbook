import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/channel.dart';
import '../repositories/channel_repository.dart';

class GetChannels {
  final ChannelRepository repository;

  GetChannels(this.repository);

  Future<Either<Failure, List<Channel>>> call({bool activeOnly = false}) async {
    if (activeOnly) {
      return repository.getActiveChannels();
    }
    return repository.getAllChannels();
  }
}
