import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/database/app_database.dart' show AppDatabase;
import 'package:craftbook/database/daos/social_link_dao.dart';
import 'package:craftbook/features/social_links/data/repositories/social_link_repository_impl.dart';
import 'package:craftbook/features/social_links/domain/entities/social_link.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

T ok<T>(Result<T> r) => switch (r) {
      Success(:final value) => value,
      Error(:final failure) => throw StateError(failure.message),
    };

/// Shortcuts against a real (in-memory) database.
void main() {
  late AppDatabase db;
  late SocialLinkRepositoryImpl repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = SocialLinkRepositoryImpl(SocialLinkDao(db));
  });
  tearDown(() => db.close());

  Future<int> add(String label,
          {String platform = 'custom', int? color}) async =>
      ok(
        await repo.createLink(SocialLink(
          platform: platform,
          label: label,
          url: 'https://$label.example.com',
          colorValue: color,
        )),
      );

  Future<List<String>> labels() async =>
      [for (final l in ok(await repo.getLinks())) l.label];

  test('starts empty', () async {
    expect(ok(await repo.getLinks()), isEmpty);
  });

  test('new links go to the end of the list', () async {
    await add('a');
    await add('b');
    await add('c');

    expect(await labels(), ['a', 'b', 'c']);
    expect([for (final l in ok(await repo.getLinks())) l.position], [0, 1, 2]);
  });

  test('keeps every field', () async {
    await add('blog', color: 0xFF123456);

    final link = ok(await repo.getLinks()).single;
    expect(link.platform, 'custom');
    expect(link.url, 'https://blog.example.com');
    expect(link.colorValue, 0xFF123456);
  });

  test('reorder rewrites positions', () async {
    final a = await add('a');
    final b = await add('b');
    final c = await add('c');

    ok(await repo.reorder([c, a, b]));

    expect(await labels(), ['c', 'a', 'b']);
  });

  test('update changes the fields but not the position', () async {
    await add('a');
    final b = await add('b');

    ok(await repo.updateLink(SocialLink(
      id: b,
      platform: 'shopee',
      label: 'Shopee',
      url: 'https://shopee.ph/x',
    )));

    final links = ok(await repo.getLinks());
    expect(links.map((l) => l.label), ['a', 'Shopee']);
    expect(links.last.position, 1);
    expect(links.last.platform, 'shopee');
  });

  test('updating a missing link is a not-found error', () async {
    final result = await repo.updateLink(
      const SocialLink(
          id: 99, platform: 'custom', label: 'x', url: 'https://x.com'),
    );

    expect(result, isA<Error<void>>());
  });

  test('delete removes the link and a new one takes the next position',
      () async {
    final a = await add('a');
    await add('b');

    ok(await repo.deleteLink(a));
    await add('c');

    expect(await labels(), ['b', 'c']);
  });
}
