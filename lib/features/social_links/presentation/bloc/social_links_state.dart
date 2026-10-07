import 'package:equatable/equatable.dart';

import '../../domain/entities/social_link.dart';

abstract class SocialLinksState extends Equatable {
  const SocialLinksState();

  @override
  List<Object?> get props => [];
}

/// What a shortcut action did, so the page can say it in the user's language.
enum SocialOutcome { added, saved, removed }

class SocialLinksInitial extends SocialLinksState {}

class SocialLinksLoading extends SocialLinksState {}

class SocialLinksLoaded extends SocialLinksState {
  final List<SocialLink> links;

  /// Outcome of the last action, shown once. [serial] changes with every
  /// message so the same text twice still shows twice. A success sets
  /// [outcome] and [subject] (the shortcut's name, null when unknown); a
  /// failure sets [message] and [isError].
  final String? message;
  final SocialOutcome? outcome;
  final String? subject;
  final bool isError;
  final int serial;

  const SocialLinksLoaded({
    required this.links,
    this.message,
    this.outcome,
    this.subject,
    this.isError = false,
    this.serial = 0,
  });

  /// Whether there is something to tell the user.
  bool get hasNotice => message != null || outcome != null;

  SocialLinksLoaded withError(String message, int serial) => SocialLinksLoaded(
        links: links,
        message: message,
        isError: true,
        serial: serial,
      );

  SocialLinksLoaded withOutcome(
          SocialOutcome outcome, String? subject, int serial) =>
      SocialLinksLoaded(
        links: links,
        outcome: outcome,
        subject: subject,
        serial: serial,
      );

  @override
  List<Object?> get props =>
      [links, message, outcome, subject, isError, serial];
}

/// The list couldn't be loaded.
class SocialLinksError extends SocialLinksState {
  final String message;

  const SocialLinksError(this.message);

  @override
  List<Object?> get props => [message];
}
