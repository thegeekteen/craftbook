import 'package:bloc_test/bloc_test.dart';
import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/social_links/domain/entities/social_link.dart';
import 'package:craftbook/features/social_links/domain/usecases/delete_social_link.dart';
import 'package:craftbook/features/social_links/domain/usecases/get_social_links.dart';
import 'package:craftbook/features/social_links/domain/usecases/reorder_social_links.dart';
import 'package:craftbook/features/social_links/domain/usecases/save_social_link.dart';
import 'package:craftbook/features/social_links/presentation/bloc/social_links_bloc.dart';
import 'package:craftbook/features/social_links/presentation/bloc/social_links_event.dart';
import 'package:craftbook/features/social_links/presentation/bloc/social_links_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGet extends Mock implements GetSocialLinks {}

class MockSave extends Mock implements SaveSocialLink {}

class MockDelete extends Mock implements DeleteSocialLink {}

class MockReorder extends Mock implements ReorderSocialLinks {}

void main() {
  late MockGet get;
  late MockSave save;
  late MockDelete delete;
  late MockReorder reorder;

  const facebook = SocialLink(
      id: 1,
      platform: 'facebook',
      label: 'Facebook',
      url: 'https://facebook.com/x');
  const shopee = SocialLink(
      id: 2,
      platform: 'shopee',
      label: 'Shopee',
      url: 'https://shopee.ph/x',
      position: 1);
  const tiktok = SocialLink(
      id: 3,
      platform: 'tiktok',
      label: 'TikTok',
      url: 'https://tiktok.com/@x',
      position: 2);

  setUp(() {
    get = MockGet();
    save = MockSave();
    delete = MockDelete();
    reorder = MockReorder();
    when(() => get())
        .thenAnswer((_) async => const Success([facebook, shopee, tiktok]));
  });

  SocialLinksBloc build() => SocialLinksBloc(
        getSocialLinks: get,
        saveSocialLink: save,
        deleteSocialLink: delete,
        reorderSocialLinks: reorder,
      );

  void stubSave(Result<int> result) => when(() => save(
        id: any(named: 'id'),
        platform: any(named: 'platform'),
        label: any(named: 'label'),
        url: any(named: 'url'),
        colorValue: any(named: 'colorValue'),
      )).thenAnswer((_) async => result);

  test('starts as SocialLinksInitial', () {
    expect(build().state, isA<SocialLinksInitial>());
  });

  group('LoadSocialLinks', () {
    blocTest<SocialLinksBloc, SocialLinksState>(
      'loads the links',
      build: build,
      act: (b) => b.add(const LoadSocialLinks()),
      expect: () => [
        isA<SocialLinksLoading>(),
        const SocialLinksLoaded(links: [facebook, shopee, tiktok]),
      ],
    );

    blocTest<SocialLinksBloc, SocialLinksState>(
      'reports a failure',
      setUp: () => when(() => get())
          .thenAnswer((_) async => const Error(DatabaseFailure('disk'))),
      build: build,
      act: (b) => b.add(const LoadSocialLinks()),
      expect: () => [isA<SocialLinksLoading>(), const SocialLinksError('disk')],
    );
  });

  group('SaveSocialLinkEvent', () {
    blocTest<SocialLinksBloc, SocialLinksState>(
      'adds, reloads and says so',
      setUp: () => stubSave(const Success(4)),
      build: build,
      act: (b) => b.add(const SaveSocialLinkEvent(
          platform: 'lazada', url: 'lazada.com.ph/x')),
      expect: () => [
        const SocialLinksLoaded(
            links: [facebook, shopee, tiktok],
            outcome: SocialOutcome.added,
            subject: 'Lazada',
            serial: 1),
      ],
    );

    blocTest<SocialLinksBloc, SocialLinksState>(
      'names a custom link by its label, and says saved on an edit',
      setUp: () => stubSave(const Success(1)),
      build: build,
      act: (b) => b.add(const SaveSocialLinkEvent(
        id: 1,
        platform: 'custom',
        label: ' My blog ',
        url: 'blog.example.com',
      )),
      expect: () => [
        const SocialLinksLoaded(
            links: [facebook, shopee, tiktok],
            outcome: SocialOutcome.saved,
            subject: 'My blog',
            serial: 1),
      ],
    );

    blocTest<SocialLinksBloc, SocialLinksState>(
      'keeps the list and shows the error when validation fails',
      setUp: () =>
          stubSave(const Error(ValidationFailure('Enter a web address'))),
      build: build,
      seed: () => const SocialLinksLoaded(links: [facebook]),
      act: (b) =>
          b.add(const SaveSocialLinkEvent(platform: 'facebook', url: 'nope')),
      expect: () => [
        const SocialLinksLoaded(
          links: [facebook],
          message: 'Enter a web address',
          isError: true,
          serial: 1,
        ),
      ],
    );
  });

  group('DeleteSocialLinkEvent', () {
    blocTest<SocialLinksBloc, SocialLinksState>(
      'removes, reloads and names the shortcut',
      setUp: () =>
          when(() => delete(2)).thenAnswer((_) async => const Success(null)),
      build: build,
      seed: () => const SocialLinksLoaded(links: [facebook, shopee]),
      act: (b) => b.add(const DeleteSocialLinkEvent(2)),
      expect: () => [
        const SocialLinksLoaded(
            links: [facebook, shopee, tiktok],
            outcome: SocialOutcome.removed,
            subject: 'Shopee',
            serial: 1),
      ],
    );

    blocTest<SocialLinksBloc, SocialLinksState>(
      'shows the error when deleting fails',
      setUp: () => when(() => delete(2))
          .thenAnswer((_) async => const Error(DatabaseFailure('locked'))),
      build: build,
      seed: () => const SocialLinksLoaded(links: [facebook, shopee]),
      act: (b) => b.add(const DeleteSocialLinkEvent(2)),
      expect: () => [
        const SocialLinksLoaded(
            links: [facebook, shopee],
            message: 'locked',
            isError: true,
            serial: 1),
      ],
    );
  });

  group('ReorderSocialLinksEvent', () {
    blocTest<SocialLinksBloc, SocialLinksState>(
      'moves at once and saves the order',
      setUp: () => when(() => reorder(any()))
          .thenAnswer((_) async => const Success(null)),
      build: build,
      seed: () => const SocialLinksLoaded(links: [facebook, shopee, tiktok]),
      act: (b) => b.add(const ReorderSocialLinksEvent(0, 2)),
      expect: () => [
        const SocialLinksLoaded(links: [shopee, tiktok, facebook]),
      ],
      verify: (_) => verify(() => reorder([2, 3, 1])).called(1),
    );

    blocTest<SocialLinksBloc, SocialLinksState>(
      'puts the list back when saving fails',
      setUp: () => when(() => reorder(any()))
          .thenAnswer((_) async => const Error(DatabaseFailure('locked'))),
      build: build,
      seed: () => const SocialLinksLoaded(links: [facebook, shopee]),
      act: (b) => b.add(const ReorderSocialLinksEvent(0, 1)),
      expect: () => [
        const SocialLinksLoaded(links: [shopee, facebook]),
        const SocialLinksLoaded(
            links: [facebook, shopee],
            message: 'locked',
            isError: true,
            serial: 1),
      ],
    );

    blocTest<SocialLinksBloc, SocialLinksState>(
      'ignores a drag before the list has loaded',
      build: build,
      act: (b) => b.add(const ReorderSocialLinksEvent(0, 1)),
      expect: () => <SocialLinksState>[],
    );
  });
}
