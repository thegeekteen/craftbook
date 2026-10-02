import 'package:equatable/equatable.dart';

import '../../domain/entities/channel.dart';

/// Base class for channels states
abstract class ChannelsState extends Equatable {
  const ChannelsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any load
class ChannelsInitial extends ChannelsState {}

/// Channels are being loaded
class ChannelsLoading extends ChannelsState {}

/// Channels loaded successfully
class ChannelsLoaded extends ChannelsState {
  final List<Channel> channels;

  const ChannelsLoaded(this.channels);

  @override
  List<Object?> get props => [channels];
}

/// Error occurred while loading/managing channels
class ChannelsError extends ChannelsState {
  final String message;

  const ChannelsError(this.message);

  @override
  List<Object?> get props => [message];
}
