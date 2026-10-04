import '../../../../core/error/result.dart';
import '../repositories/social_link_repository.dart';

class DeleteSocialLink {
  final SocialLinkRepository repository;

  DeleteSocialLink(this.repository);

  Future<Result<void>> call(int id) => repository.deleteLink(id);
}
