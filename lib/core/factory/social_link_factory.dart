import 'dart:math';

import '../../features/social_links/domain/entities/social_platform.dart';
import 'fake_random.dart';
import 'fake_shop.dart';

/// Every brand tile the app knows, plus one custom link.
///
/// The presets carry their own colour, so the grid shows brand tiles beside a
/// shop-chosen one — and the tile count is the point: a short list and a full
/// one lay out differently.
List<LinkPlan> buildSocialLinks(Random random, String shopHandle) {
  final handle =
      shopHandle.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toLowerCase();
  final plans = <LinkPlan>[];

  for (final platform in SocialPlatform.presets) {
    plans.add(LinkPlan(
      ref: plans.length + 1,
      platform: platform.key,
      label: platform.name,
      url: 'https://${_hostFor(platform, handle)}',
    ));
  }

  plans.add(LinkPlan(
    ref: plans.length + 1,
    platform: SocialPlatform.customKey,
    label: 'The shop page',
    url: 'https://$handle.example.shop',
    colorValue: random.oneOf(SocialPlatform.customColors),
  ));
  return plans;
}

String _hostFor(SocialPlatform platform, String handle) {
  final hint = platform.urlHint;
  return hint.contains('yourshop')
      ? hint.replaceAll('yourshop', handle)
      : '$hint/$handle';
}
