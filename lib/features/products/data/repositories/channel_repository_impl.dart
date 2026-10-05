import 'package:craftbook/core/error/result.dart';
import 'package:drift/drift.dart' hide Column;

import '../../../../core/error/failures.dart';
import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/channel_dao.dart';
import '../../domain/entities/channel.dart';
import '../../domain/repositories/channel_repository.dart';

class ChannelRepositoryImpl implements ChannelRepository {
  final ChannelDao dao;

  ChannelRepositoryImpl(this.dao);

  @override
  Future<Result<List<Channel>>> getAllChannels() async {
    try {
      final rows = await dao.getAllChannels();
      return Success(rows.map(_toEntity).toList());
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<Channel>>> getActiveChannels() async {
    try {
      final rows = await dao.getActiveChannels();
      return Success(rows.map(_toEntity).toList());
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<Channel?>> getChannelById(int id) async {
    try {
      final row = await dao.getChannelById(id);
      return Success(row != null ? _toEntity(row) : null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> createChannel({
    required String name,
    required double commissionRate,
    required double transactionFeeRate,
    required double flatFee,
    required double shippingPaidByUs,
    bool paidByDefault = true,
  }) async {
    try {
      final id = await dao.createChannel(db.ChannelsCompanion(
        name: Value(name),
        commissionRate: Value(commissionRate),
        transactionFeeRate: Value(transactionFeeRate),
        flatFee: Value(flatFee),
        shippingPaidByUs: Value(shippingPaidByUs),
        paidByDefault: Value(paidByDefault),
      ));
      return Success(id);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateChannel({
    required int id,
    String? name,
    double? commissionRate,
    double? transactionFeeRate,
    double? flatFee,
    double? shippingPaidByUs,
    bool? isActive,
    bool? paidByDefault,
  }) async {
    try {
      final existing = await dao.getChannelById(id);
      if (existing == null) {
        return const Error(NotFoundFailure('Channel not found'));
      }

      await dao.updateChannel(db.Channel(
        id: existing.id,
        name: name ?? existing.name,
        commissionRate: commissionRate ?? existing.commissionRate,
        transactionFeeRate: transactionFeeRate ?? existing.transactionFeeRate,
        flatFee: flatFee ?? existing.flatFee,
        shippingPaidByUs: shippingPaidByUs ?? existing.shippingPaidByUs,
        isActive: isActive ?? existing.isActive,
        paidByDefault: paidByDefault ?? existing.paidByDefault,
        createdAt: existing.createdAt,
      ));
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteChannel(int id) async {
    try {
      await dao.deleteChannel(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  static Channel _toEntity(db.Channel row) => Channel(
        id: row.id,
        name: row.name,
        commissionRate: row.commissionRate,
        transactionFeeRate: row.transactionFeeRate,
        flatFee: row.flatFee,
        shippingPaidByUs: row.shippingPaidByUs,
        isActive: row.isActive,
        paidByDefault: row.paidByDefault,
        createdAt: row.createdAt,
      );
}
