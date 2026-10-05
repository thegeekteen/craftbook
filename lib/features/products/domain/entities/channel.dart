import 'package:equatable/equatable.dart';

/// Channel entity
class Channel extends Equatable {
  final int? id;
  final String name;
  final double commissionRate;
  final double transactionFeeRate;
  final double flatFee;
  final double shippingPaidByUs;
  final bool isActive;

  /// Whether new orders on this channel start out paid.
  final bool paidByDefault;
  final DateTime createdAt;

  const Channel({
    this.id,
    required this.name,
    required this.commissionRate,
    required this.transactionFeeRate,
    required this.flatFee,
    required this.shippingPaidByUs,
    required this.isActive,
    this.paidByDefault = true,
    required this.createdAt,
  });

  double calculateFees(double salesAmount) {
    final commission = salesAmount * (commissionRate / 100);
    final transactionFee = salesAmount * (transactionFeeRate / 100);
    return commission + transactionFee + flatFee;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        commissionRate,
        transactionFeeRate,
        flatFee,
        shippingPaidByUs,
        isActive,
        paidByDefault,
        createdAt,
      ];

  Channel copyWith({
    int? id,
    String? name,
    double? commissionRate,
    double? transactionFeeRate,
    double? flatFee,
    double? shippingPaidByUs,
    bool? isActive,
    bool? paidByDefault,
    DateTime? createdAt,
  }) {
    return Channel(
      id: id ?? this.id,
      name: name ?? this.name,
      commissionRate: commissionRate ?? this.commissionRate,
      transactionFeeRate: transactionFeeRate ?? this.transactionFeeRate,
      flatFee: flatFee ?? this.flatFee,
      shippingPaidByUs: shippingPaidByUs ?? this.shippingPaidByUs,
      isActive: isActive ?? this.isActive,
      paidByDefault: paidByDefault ?? this.paidByDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
