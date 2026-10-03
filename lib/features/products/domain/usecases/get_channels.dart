import 'package:craftbook/core/error/result.dart';

import '../entities/channel.dart';
import '../repositories/channel_repository.dart';

class GetChannels {
  final ChannelRepository repository;

  GetChannels(this.repository);

  Future<Result<List<Channel>>> call({bool activeOnly = false}) async {
    if (activeOnly) {
      return repository.getActiveChannels();
    }
    return repository.getAllChannels();
  }
}
