import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/social_links/domain/entities/social_link.dart';
import 'package:craftbook/features/social_links/domain/repositories/social_link_repository.dart';
import 'package:craftbook/features/social_links/domain/usecases/delete_social_link.dart';
import 'package:craftbook/features/social_links/domain/usecases/get_social_links.dart';
import 'package:craftbook/features/social_links/domain/usecases/reorder_social_links.dart';
import 'package:craftbook/features/social_links/domain/usecases/save_social_link.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRepo extends Mock implements SocialLinkRepository {}

void main() {
  late MockRepo repo;

  setUpAll(() => registerFallbackValue(
      const SocialLink(platform: 'custom', label: 'x', url: 'https://a.b')));
  setUp(() {
    repo = MockRepo();
    when(() => repo.createLink(any()))
        .thenAnswer((_) async => const Success(7));
    when(() => repo.updateLink(any()))
        .thenAnswer((_) async => const Success(null));
  });

  group('SaveSocialLink', () {
    test('adds a preset link, naming it after the site and normalising the url',
        () async {
      final result = await SaveSocialLink(repo)(
          platform: 'facebook', url: 'facebook.com/mycrafts');

      expect(result, const Success(7));
      final saved = verify(() => repo.createLink(captureAny())).captured.single
          as SocialLink;
      expect(saved.label, 'Facebook');
      expect(saved.url, 'https://facebook.com/mycrafts');
      expect(saved.colorValue, isNull);
    });

    test('a custom link keeps its name and colour', () async {
      await SaveSocialLink(repo)(
        platform: 'custom',
        label: '  My blog ',
        url: 'blog.example.com',
        colorValue: 0xFF3B5BDB,
      );

      final saved = verify(() => repo.createLink(captureAny())).captured.single
          as SocialLink;
      expect(saved.label, 'My blog');
      expect(saved.colorValue, 0xFF3B5BDB);
    });

    test('a preset drops any colour it was given', () async {
      await SaveSocialLink(repo)(
          platform: 'tiktok', url: 'tiktok.com/@me', colorValue: 5);

      final saved = verify(() => repo.createLink(captureAny())).captured.single
          as SocialLink;
      expect(saved.colorValue, isNull);
    });

    test('an edit updates and returns the same id', () async {
      final result = await SaveSocialLink(repo)(
          id: 3, platform: 'shopee', url: 'shopee.ph/x');

      expect(result, const Success(3));
      verify(() => repo.updateLink(any())).called(1);
      verifyNever(() => repo.createLink(any()));
    });

    test('an edit that fails in the repository returns that failure', () async {
      when(() => repo.updateLink(any())).thenAnswer(
          (_) async => const Error(NotFoundFailure('Shortcut not found')));

      final result = await SaveSocialLink(repo)(
          id: 9, platform: 'shopee', url: 'shopee.ph/x');

      expect(result, const Error<int>(NotFoundFailure('Shortcut not found')));
    });

    test('a custom link needs a name', () async {
      final result = await SaveSocialLink(repo)(
          platform: 'custom', label: '  ', url: 'a.com');

      expect(result,
          const Error<int>(ValidationFailure('Give the shortcut a name')));
      verifyNever(() => repo.createLink(any()));
    });

    test('refuses an address that is not a website', () async {
      final result =
          await SaveSocialLink(repo)(platform: 'facebook', url: 'not a link');

      expect(result, isA<Error<int>>());
      expect((result as Error<int>).failure, isA<ValidationFailure>());
      verifyNever(() => repo.createLink(any()));
    });

    test('refuses an unknown platform', () async {
      final result =
          await SaveSocialLink(repo)(platform: 'myspace', url: 'myspace.com/x');

      expect((result as Error<int>).failure, isA<ValidationFailure>());
    });
  });

  group('ReorderSocialLinks', () {
    test('passes the order on', () async {
      when(() => repo.reorder(any()))
          .thenAnswer((_) async => const Success(null));

      expect(
          await ReorderSocialLinks(repo)([3, 1, 2]), const Success<void>(null));
      verify(() => repo.reorder([3, 1, 2])).called(1);
    });

    test('refuses a shortcut listed twice', () async {
      final result = await ReorderSocialLinks(repo)([1, 1]);

      expect(result,
          const Error<void>(ValidationFailure('A shortcut appears twice')));
      verifyNever(() => repo.reorder(any()));
    });
  });

  test('GetSocialLinks returns what the repository holds', () async {
    const links = [
      SocialLink(
          id: 1,
          platform: 'facebook',
          label: 'Facebook',
          url: 'https://facebook.com/x')
    ];
    when(() => repo.getLinks()).thenAnswer((_) async => const Success(links));

    expect(await GetSocialLinks(repo)(), const Success(links));
  });

  test('DeleteSocialLink deletes by id', () async {
    when(() => repo.deleteLink(4)).thenAnswer((_) async => const Success(null));

    expect(await DeleteSocialLink(repo)(4), const Success<void>(null));
    verify(() => repo.deleteLink(4)).called(1);
  });
}
