import 'package:equatable/equatable.dart';

/// Base class for channels events
abstract class ChannelsEvent extends Equatable {
  const ChannelsEvent();

  @override
  List<Object?> get props => [];
}

/// Load all channels from the database
class LoadChannels extends ChannelsEvent {
  final bool activeOnly;

  const LoadChannels({this.activeOnly = false});

  @override
  List<Object?> get props => [activeOnly];
}

/// Create a new channel
class CreateChannelEvent extends ChannelsEvent {
  final String name;
  final double commissionRate;
  final double transactionFeeRate;
  final double flatFee;
  final double shippingPaidByUs;

  const CreateChannelEvent({
    required this.name,
    required this.commissionRate,
    required this.transactionFeeRate,
    required this.flatFee,
    required this.shippingPaidByUs,
  });

  @override
  List<Object?> get props => [
        name,
        commissionRate,
        transactionFeeRate,
        flatFee,
        shippingPaidByUs,
      ];
}

/// Update an existing channel
class UpdateChannelEvent extends ChannelsEvent {
  final int id;
  final String? name;
  final double? commissionRate;
  final double? transactionFeeRate;
  final double? flatFee;
  final double? shippingPaidByUs;
  final bool? isActive;

  const UpdateChannelEvent({
    required this.id,
    this.name,
    this.commissionRate,
    this.transactionFeeRate,
    this.flatFee,
    this.shippingPaidByUs,
    this.isActive,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        commissionRate,
        transactionFeeRate,
        flatFee,
        shippingPaidByUs,
        isActive,
      ];
}
