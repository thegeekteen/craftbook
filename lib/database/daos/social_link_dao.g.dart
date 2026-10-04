// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_link_dao.dart';

// ignore_for_file: type=lint
mixin _$SocialLinkDaoMixin on DatabaseAccessor<AppDatabase> {
  $SocialLinksTable get socialLinks => attachedDatabase.socialLinks;
  SocialLinkDaoManager get managers => SocialLinkDaoManager(this);
}

class SocialLinkDaoManager {
  final _$SocialLinkDaoMixin _db;
  SocialLinkDaoManager(this._db);
  $$SocialLinksTableTableManager get socialLinks =>
      $$SocialLinksTableTableManager(_db.attachedDatabase, _db.socialLinks);
}
