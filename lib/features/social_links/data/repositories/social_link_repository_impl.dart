import 'package:drift/drift.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/social_link_dao.dart';
import '../../domain/entities/social_link.dart';
import '../../domain/repositories/social_link_repository.dart';

class SocialLinkRepositoryImpl implements SocialLinkRepository {
  final SocialLinkDao dao;

  SocialLinkRepositoryImpl(this.dao);

  @override
  Future<Result<List<SocialLink>>> getLinks() async {
    try {
      final rows = await dao.getAll();
      return Success([for (final row in rows) _toEntity(row)]);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<int>> createLink(SocialLink link) async {
    try {
      final id = await dao.transaction(() async {
        return dao.insertLink(db.SocialLinksCompanion.insert(
          platform: link.platform,
          label: link.label,
          url: link.url,
          colorValue: Value(link.colorValue),
          position: Value(await dao.nextPosition()),
        ));
      });
      return Success(id);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateLink(SocialLink link) async {
    try {
      final updated = await dao.updateLink(
        link.id!,
        db.SocialLinksCompanion(
          platform: Value(link.platform),
          label: Value(link.label),
          url: Value(link.url),
          colorValue: Value(link.colorValue),
        ),
      );
      if (updated == 0) {
        return const Error(NotFoundFailure('Shortcut not found'));
      }
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteLink(int id) async {
    try {
      await dao.deleteLink(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> reorder(List<int> ids) async {
    try {
      await dao.setPositions(ids);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  static SocialLink _toEntity(db.SocialLink row) {
    return SocialLink(
      id: row.id,
      platform: row.platform,
      label: row.label,
      url: row.url,
      colorValue: row.colorValue,
      position: row.position,
    );
  }
}
