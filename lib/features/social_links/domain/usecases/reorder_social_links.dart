import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../repositories/social_link_repository.dart';

/// Sets the order the shortcuts are shown in.
class ReorderSocialLinks {
  final SocialLinkRepository repository;

  ReorderSocialLinks(this.repository);

  Future<Result<void>> call(List<int> orderedIds) async {
    if (orderedIds.toSet().length != orderedIds.length) {
      return const Error(ValidationFailure('A shortcut appears twice'));
    }
    return repository.reorder(orderedIds);
  }
}
