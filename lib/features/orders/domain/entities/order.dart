import 'package:equatable/equatable.dart';

/// Order status enum
enum OrderStatus {
  pending,
  packed,
  shipped,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.packed:
        return 'Packed';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

/// Order entity
class Order extends Equatable {
  final int? id;
  final String customerName;
  final String customerAddress;
  final String? note;
  final DateTime orderDate;
  final DateTime shipByDate;
  final DateTime? packedAt;
  final DateTime? shippedAt;
  final OrderStatus status;
  final int? channelId;
  final double totalSales;
  final double totalMaterialCost;
  final double channelFees;
  final double shippingCost;
  final double profit;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    this.id,
    required this.customerName,
    required this.customerAddress,
    this.note,
    required this.orderDate,
    required this.shipByDate,
    this.packedAt,
    this.shippedAt,
    required this.status,
    this.channelId,
    required this.totalSales,
    required this.totalMaterialCost,
    required this.channelFees,
    required this.shippingCost,
    required this.profit,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        customerName,
        customerAddress,
        note,
        orderDate,
        shipByDate,
        packedAt,
        shippedAt,
        status,
        channelId,
        totalSales,
        totalMaterialCost,
        channelFees,
        shippingCost,
        profit,
        createdAt,
        updatedAt,
      ];

  Order copyWith({
    int? id,
    String? customerName,
    String? customerAddress,
    String? note,
    DateTime? orderDate,
    DateTime? shipByDate,
    DateTime? packedAt,
    DateTime? shippedAt,
    OrderStatus? status,
    int? channelId,
    double? totalSales,
    double? totalMaterialCost,
    double? channelFees,
    double? shippingCost,
    double? profit,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      note: note ?? this.note,
      orderDate: orderDate ?? this.orderDate,
      shipByDate: shipByDate ?? this.shipByDate,
      packedAt: packedAt ?? this.packedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      status: status ?? this.status,
      channelId: channelId ?? this.channelId,
      totalSales: totalSales ?? this.totalSales,
      totalMaterialCost: totalMaterialCost ?? this.totalMaterialCost,
      channelFees: channelFees ?? this.channelFees,
      shippingCost: shippingCost ?? this.shippingCost,
      profit: profit ?? this.profit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
