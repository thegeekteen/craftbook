import '../../../../core/error/result.dart';
import '../entities/social_link.dart';
import '../repositories/social_link_repository.dart';

class GetSocialLinks {
  final SocialLinkRepository repository;

  GetSocialLinks(this.repository);

  Future<Result<List<SocialLink>>> call() => repository.getLinks();
}
