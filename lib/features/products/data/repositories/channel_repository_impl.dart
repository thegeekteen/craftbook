import 'package:dartz/dartz.dart';
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
  Future<Either<Failure, List<Channel>>> getAllChannels() async {
    try {
      final rows = await dao.getAllChannels();
      return Right(rows.map(_toEntity).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Channel>>> getActiveChannels() async {
    try {
      final rows = await dao.getActiveChannels();
      return Right(rows.map(_toEntity).toList());
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Channel?>> getChannelById(int id) async {
    try {
      final row = await dao.getChannelById(id);
      return Right(row != null ? _toEntity(row) : null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> createChannel({
    required String name,
    required double commissionRate,
    required double transactionFeeRate,
    required double flatFee,
    required double shippingPaidByUs,
  }) async {
    try {
      final id = await dao.createChannel(db.ChannelsCompanion(
        name: Value(name),
        commissionRate: Value(commissionRate),
        transactionFeeRate: Value(transactionFeeRate),
        flatFee: Value(flatFee),
        shippingPaidByUs: Value(shippingPaidByUs),
      ));
      return Right(id);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateChannel({
    required int id,
    String? name,
    double? commissionRate,
    double? transactionFeeRate,
    double? flatFee,
    double? shippingPaidByUs,
    bool? isActive,
  }) async {
    try {
      final existing = await dao.getChannelById(id);
      if (existing == null) return Left(NotFoundFailure('Channel not found'));

      await dao.updateChannel(db.Channel(
        id: existing.id,
        name: name ?? existing.name,
        commissionRate: commissionRate ?? existing.commissionRate,
        transactionFeeRate: transactionFeeRate ?? existing.transactionFeeRate,
        flatFee: flatFee ?? existing.flatFee,
        shippingPaidByUs: shippingPaidByUs ?? existing.shippingPaidByUs,
        isActive: isActive ?? existing.isActive,
        createdAt: existing.createdAt,
      ));
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteChannel(int id) async {
    try {
      await dao.deleteChannel(id);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
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
        createdAt: row.createdAt,
      );
}
