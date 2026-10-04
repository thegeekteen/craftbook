import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/orders_table.dart';

part 'channel_dao.g.dart';

/// Data Access Object for channels
@DriftAccessor(tables: [Channels])
class ChannelDao extends DatabaseAccessor<AppDatabase> with _$ChannelDaoMixin {
  ChannelDao(super.db);

  /// Get all channels
  Future<List<Channel>> getAllChannels() {
    return select(channels).get();
  }

  /// Get active channels
  Future<List<Channel>> getActiveChannels() {
    return (select(channels)..where((t) => t.isActive.equals(true))).get();
  }

  /// Get channel by ID
  Future<Channel?> getChannelById(int id) {
    return (select(channels)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Create new channel
  Future<int> createChannel(ChannelsCompanion channel) {
    return into(channels).insert(channel);
  }

  /// Update channel
  Future<bool> updateChannel(Channel channel) {
    return update(channels).replace(channel);
  }

  /// Delete channel
  Future<int> deleteChannel(int id) {
    return (delete(channels)..where((t) => t.id.equals(id))).go();
  }

  /// Calculate fees for order
  Future<double> calculateFees(int channelId, double salesAmount) async {
    final channel = await getChannelById(channelId);
    if (channel == null) return 0.0;

    final commission = salesAmount * (channel.commissionRate / 100);
    final transactionFee = salesAmount * (channel.transactionFeeRate / 100);
    final totalFees = commission + transactionFee + channel.flatFee;

    return totalFees;
  }
}
