import 'package:flutter_test/flutter_test.dart';

import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/stock/domain/entities/material.dart';
import 'package:craftbook/features/products/domain/entities/channel.dart';

void main() {
  group('Order entity', () {
    test('copyWith creates new instance with updated fields', () {
      final order = Order(
        id: 1,
        customerName: 'Test',
        orderDate: DateTime(2026, 8, 26),
        shipByDate: DateTime(2026, 8, 28),
        status: OrderStatus.pending,
        totalSales: 100,
        totalMaterialCost: 20,
        channelFees: 10,
        shippingCost: 0,
        profit: 70,
        createdAt: DateTime(2026, 8, 26),
        updatedAt: DateTime(2026, 8, 26),
      );

      final updated = order.copyWith(status: OrderStatus.packed);
      expect(updated.status, OrderStatus.packed);
      expect(updated.customerName, 'Test');
    });

    test('OrderStatus displayName returns correct values', () {
      expect(OrderStatus.pending.displayName, 'Pending');
      expect(OrderStatus.packed.displayName, 'Packed');
      expect(OrderStatus.shipped.displayName, 'Shipped');
      expect(OrderStatus.cancelled.displayName, 'Cancelled');
    });
  });

  group('Material entity', () {
    test('quantityFree is onHand minus promised', () {
      final material = Material(
        id: 1,
        name: 'Magnet sheet',
        packSize: 20,
        packPrice: 180,
        unitCost: 9,
        quantityOnHand: 14,
        quantityPromised: 4,
        alertLevel: 20,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(material.quantityFree, 10);
    });

    test('isLowStock when onHand <= alertLevel', () {
      final lowMaterial = Material(
        id: 1,
        name: 'Photo top',
        packSize: 20,
        packPrice: 240,
        unitCost: 12,
        quantityOnHand: 6,
        quantityPromised: 2,
        alertLevel: 15,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(lowMaterial.isLowStock, true);
    });

    test('isLowStock is false when onHand > alertLevel', () {
      final okMaterial = Material(
        id: 2,
        name: 'Pouch',
        packSize: 100,
        packPrice: 150,
        unitCost: 1.5,
        quantityOnHand: 62,
        quantityPromised: 6,
        alertLevel: 30,
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 1),
      );

      expect(okMaterial.isLowStock, false);
    });
  });

  group('Channel entity', () {
    test('calculateFees computes commission + transaction + flat', () {
      final channel = Channel(
        id: 1,
        name: 'Shopee',
        commissionRate: 6.0,
        transactionFeeRate: 2.0,
        flatFee: 0.0,
        shippingPaidByUs: 0.0,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
      );

      final fees = channel.calculateFees(1000.0);
      expect(fees, 80.0); // 6% + 2% = 8% of 1000
    });

    test('calculateFees includes flat fee', () {
      final channel = Channel(
        id: 2,
        name: 'TikTok',
        commissionRate: 7.0,
        transactionFeeRate: 0.0,
        flatFee: 15.0,
        shippingPaidByUs: 0.0,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
      );

      final fees = channel.calculateFees(1000.0);
      expect(fees, 85.0); // 7% of 1000 = 70 + 15 flat
    });
  });
}
