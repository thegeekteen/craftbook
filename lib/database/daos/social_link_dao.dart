import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/social_links_table.dart';

part 'social_link_dao.g.dart';

/// Data Access Object for social shortcuts
@DriftAccessor(tables: [SocialLinks])
class SocialLinkDao extends DatabaseAccessor<AppDatabase>
    with _$SocialLinkDaoMixin {
  SocialLinkDao(super.db);

  Future<List<SocialLink>> getAll() {
    return (select(socialLinks)
          ..orderBy([
            (t) => OrderingTerm.asc(t.position),
            (t) => OrderingTerm.asc(t.id)
          ]))
        .get();
  }

  Future<int> nextPosition() async {
    final max = socialLinks.position.max();
    final query = selectOnly(socialLinks)..addColumns([max]);
    final current = (await query.getSingle()).read(max);
    return current == null ? 0 : current + 1;
  }

  Future<int> insertLink(SocialLinksCompanion link) =>
      into(socialLinks).insert(link);

  Future<int> updateLink(int id, SocialLinksCompanion link) {
    return (update(socialLinks)..where((t) => t.id.equals(id))).write(link);
  }

  Future<int> deleteLink(int id) =>
      (delete(socialLinks)..where((t) => t.id.equals(id))).go();

  /// Writes positions in list order, in one transaction.
  Future<void> setPositions(List<int> ids) {
    return transaction(() async {
      for (var i = 0; i < ids.length; i++) {
        await updateLink(ids[i], SocialLinksCompanion(position: Value(i)));
      }
    });
  }
}
