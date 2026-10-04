import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/social_link.dart';
import '../entities/social_platform.dart';
import '../repositories/social_link_repository.dart';
import '../social_url.dart';

/// Adds a shortcut (when [id] is null) or edits one. Returns its id.
class SaveSocialLink {
  final SocialLinkRepository repository;

  SaveSocialLink(this.repository);

  Future<Result<int>> call({
    int? id,
    required String platform,
    String label = '',
    required String url,
    int? colorValue,
  }) async {
    final preset = SocialPlatform.byKey(platform);
    if (preset == null && platform != SocialPlatform.customKey) {
      return Error(ValidationFailure('Unknown platform $platform'));
    }

    // A preset needs no name of its own; a custom link does.
    final trimmed = label.trim();
    final name = trimmed.isEmpty ? preset?.name ?? '' : trimmed;
    if (name.isEmpty) {
      return const Error(ValidationFailure('Give the shortcut a name'));
    }

    final normalized = normalizeSocialUrl(url);
    if (normalized == null) {
      return const Error(ValidationFailure(
        'Enter a web address like facebook.com/yourshop',
      ));
    }

    final link = SocialLink(
      id: id,
      platform: platform,
      label: name,
      url: normalized,
      colorValue: preset == null ? colorValue : null,
    );

    if (id == null) return repository.createLink(link);

    final result = await repository.updateLink(link);
    return switch (result) {
      Success() => Success(id),
      Error(:final failure) => Error(failure),
    };
  }
}
