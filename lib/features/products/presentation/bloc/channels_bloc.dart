import 'package:craftbook/core/error/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/channel_repository.dart';
import '../../domain/usecases/delete_channel.dart';
import '../../domain/usecases/get_channels.dart';
import '../../domain/usecases/update_channel.dart';
import 'channels_event.dart';
import 'channels_state.dart';

/// BLoC for managing channels list
class ChannelsBloc extends Bloc<ChannelsEvent, ChannelsState> {
  final GetChannels getChannels;
  final UpdateChannel updateChannel;
  final DeleteChannel deleteChannel;
  final ChannelRepository channelRepository;

  ChannelsBloc({
    required this.getChannels,
    required this.updateChannel,
    required this.deleteChannel,
    required this.channelRepository,
  }) : super(ChannelsInitial()) {
    on<LoadChannels>(_onLoadChannels);
    on<CreateChannelEvent>(_onCreateChannel);
    on<UpdateChannelEvent>(_onUpdateChannel);
    on<DeleteChannelEvent>(_onDeleteChannel);
  }

  Future<void> _onLoadChannels(
    LoadChannels event,
    Emitter<ChannelsState> emit,
  ) async {
    if (state is! ChannelsLoaded) emit(ChannelsLoading());
    final result = await getChannels(activeOnly: event.activeOnly);
    switch (result) {
      case Error(:final failure):
        emit(ChannelsError(failure.message));
      case Success(:final value):
        emit(ChannelsLoaded(value));
    }
  }

  Future<void> _onCreateChannel(
    CreateChannelEvent event,
    Emitter<ChannelsState> emit,
  ) async {
    final result = await channelRepository.createChannel(
      name: event.name,
      commissionRate: event.commissionRate,
      transactionFeeRate: event.transactionFeeRate,
      flatFee: event.flatFee,
      shippingPaidByUs: event.shippingPaidByUs,
    );
    switch (result) {
      case Error(:final failure):
        emit(ChannelsError(failure.message));
      case Success():
        emit(ChannelCreated());
    }
  }

  Future<void> _onUpdateChannel(
    UpdateChannelEvent event,
    Emitter<ChannelsState> emit,
  ) async {
    final result = await updateChannel(
      id: event.id,
      name: event.name,
      commissionRate: event.commissionRate,
      transactionFeeRate: event.transactionFeeRate,
      flatFee: event.flatFee,
      shippingPaidByUs: event.shippingPaidByUs,
      isActive: event.isActive,
    );
    switch (result) {
      case Error(:final failure):
        emit(ChannelsError(failure.message));
      case Success():
        // Re-load channels after successful update
        add(const LoadChannels());
    }
  }

  Future<void> _onDeleteChannel(
    DeleteChannelEvent event,
    Emitter<ChannelsState> emit,
  ) async {
    final result = await deleteChannel(event.channelId);
    switch (result) {
      case Error(:final failure):
        emit(ChannelsError(failure.message));
      case Success():
        emit(ChannelDeleted());
        add(const LoadChannels());
    }
  }
}
