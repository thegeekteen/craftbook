import 'package:equatable/equatable.dart';

import '../../domain/entities/social_link.dart';

abstract class SocialLinksState extends Equatable {
  const SocialLinksState();

  @override
  List<Object?> get props => [];
}

class SocialLinksInitial extends SocialLinksState {}

class SocialLinksLoading extends SocialLinksState {}

class SocialLinksLoaded extends SocialLinksState {
  final List<SocialLink> links;

  /// Outcome of the last action, shown once. [serial] changes with every
  /// message so the same text twice still shows twice.
  final String? message;
  final bool isError;
  final int serial;

  const SocialLinksLoaded({
    required this.links,
    this.message,
    this.isError = false,
    this.serial = 0,
  });

  SocialLinksLoaded withMessage(String message, int serial,
          {bool isError = false}) =>
      SocialLinksLoaded(
        links: links,
        message: message,
        isError: isError,
        serial: serial,
      );

  @override
  List<Object?> get props => [links, message, isError, serial];
}

/// The list couldn't be loaded.
class SocialLinksError extends SocialLinksState {
  final String message;

  const SocialLinksError(this.message);

  @override
  List<Object?> get props => [message];
}
