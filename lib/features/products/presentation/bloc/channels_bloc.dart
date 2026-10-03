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
    emit(ChannelsLoading());
    final result = await getChannels(activeOnly: event.activeOnly);
    result.fold(
      (failure) => emit(ChannelsError(failure.message)),
      (channels) => emit(ChannelsLoaded(channels)),
    );
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
    result.fold(
      (failure) => emit(ChannelsError(failure.message)),
      (_) => emit(ChannelCreated()),
    );
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
    result.fold(
      (failure) => emit(ChannelsError(failure.message)),
      (_) {
        // Re-load channels after successful update
        add(const LoadChannels());
      },
    );
  }

  Future<void> _onDeleteChannel(
    DeleteChannelEvent event,
    Emitter<ChannelsState> emit,
  ) async {
    final result = await deleteChannel(event.channelId);
    result.fold(
      (failure) => emit(ChannelsError(failure.message)),
      (_) {
        emit(ChannelDeleted());
        add(const LoadChannels());
      },
    );
  }
}
