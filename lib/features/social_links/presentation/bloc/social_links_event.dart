import 'package:equatable/equatable.dart';

abstract class SocialLinksEvent extends Equatable {
  const SocialLinksEvent();

  @override
  List<Object?> get props => [];
}

class LoadSocialLinks extends SocialLinksEvent {
  const LoadSocialLinks();
}

/// Adds a shortcut when [id] is null, otherwise edits it.
class SaveSocialLinkEvent extends SocialLinksEvent {
  final int? id;
  final String platform;
  final String label;
  final String url;
  final int? colorValue;

  const SaveSocialLinkEvent({
    this.id,
    required this.platform,
    this.label = '',
    required this.url,
    this.colorValue,
  });

  @override
  List<Object?> get props => [id, platform, label, url, colorValue];
}

class DeleteSocialLinkEvent extends SocialLinksEvent {
  final int id;

  const DeleteSocialLinkEvent(this.id);

  @override
  List<Object?> get props => [id];
}

/// A drag in the list: [newIndex] is where the shortcut ends up.
class ReorderSocialLinksEvent extends SocialLinksEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderSocialLinksEvent(this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [oldIndex, newIndex];
}
