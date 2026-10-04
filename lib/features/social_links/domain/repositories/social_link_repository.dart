import '../../../../core/error/result.dart';
import '../entities/social_link.dart';

abstract class SocialLinkRepository {
  /// Links by position.
  Future<Result<List<SocialLink>>> getLinks();

  /// Adds [link] at the end of the list; returns the new id.
  Future<Result<int>> createLink(SocialLink link);

  /// Rewrites platform, label, url and colour; position has its own method.
  Future<Result<void>> updateLink(SocialLink link);
  Future<Result<void>> deleteLink(int id);

  /// Gives [ids] positions 0..n in list order.
  Future<Result<void>> reorder(List<int> ids);
}
