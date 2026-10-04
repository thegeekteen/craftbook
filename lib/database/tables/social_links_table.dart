import 'package:drift/drift.dart';

/// The shop's own pages on selling and social sites, shown as shortcuts.
class SocialLinks extends Table {
  IntColumn get id => integer().autoIncrement()();

  /// A preset key (`facebook`, `shopee`…) or `custom`.
  TextColumn get platform => text()();
  TextColumn get label => text()();
  TextColumn get url => text()();

  /// ARGB tile colour, only for `custom` links; presets carry their own.
  IntColumn get colorValue => integer().nullable()();
  IntColumn get position => integer().withDefault(const Constant(0))();
}
