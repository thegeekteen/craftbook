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

  /// Sum of the discount lines (the lines themselves load separately).
  final double discountTotal;

  /// Percent; null when the order has no tax.
  final double? taxRate;
  final double taxAmount;

  /// True when item prices include the tax, false when it's added on top.
  final bool taxInclusive;
  final bool isPaid;
  final DateTime? paidAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    this.id,
    required this.customerName,
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
    this.discountTotal = 0,
    this.taxRate,
    this.taxAmount = 0,
    this.taxInclusive = true,
    this.isPaid = true,
    this.paidAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasTax => taxRate != null;

  bool get hasDiscount => discountTotal > 0;

  /// Waiting for the customer's money: unpaid and not called off.
  bool get isAwaitingPayment => !isPaid && status != OrderStatus.cancelled;

  @override
  List<Object?> get props => [
        id,
        customerName,
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
        discountTotal,
        taxRate,
        taxAmount,
        taxInclusive,
        isPaid,
        paidAt,
        createdAt,
        updatedAt,
      ];

  Order copyWith({
    int? id,
    String? customerName,
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
    double? discountTotal,
    double? taxRate,
    bool clearTax = false,
    double? taxAmount,
    bool? taxInclusive,
    bool? isPaid,
    DateTime? paidAt,
    bool clearPaidAt = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
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
      discountTotal: discountTotal ?? this.discountTotal,
      taxRate: clearTax ? null : (taxRate ?? this.taxRate),
      taxAmount: taxAmount ?? this.taxAmount,
      taxInclusive: taxInclusive ?? this.taxInclusive,
      isPaid: isPaid ?? this.isPaid,
      paidAt: clearPaidAt ? null : (paidAt ?? this.paidAt),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
