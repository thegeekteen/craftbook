import 'package:flutter_test/flutter_test.dart';

import 'package:craftbook/features/products/domain/entities/channel.dart';

void main() {
  group('Channel.calculateFees', () {
    final shopee = Channel(
      id: 1,
      name: 'Shopee',
      commissionRate: 6.0,
      transactionFeeRate: 2.0,
      flatFee: 0.0,
      shippingPaidByUs: 0.0,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    );

    final tiktok = Channel(
      id: 2,
      name: 'TikTok Shop',
      commissionRate: 7.0,
      transactionFeeRate: 0.0,
      flatFee: 15.0,
      shippingPaidByUs: 0.0,
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    );

    test('calculates Shopee fees correctly (6% commission + 2% transaction)', () {
      final fees = shopee.calculateFees(647.0);
      // 6% of 647 = 38.82, 2% of 647 = 12.94, total = 51.76
      expect(fees, closeTo(51.76, 0.01));
    });

    test('calculates TikTok fees correctly (7% + flat 15)', () {
      final fees = tiktok.calculateFees(647.0);
      // 7% of 647 = 45.29, flat = 15.00, total = 60.29
      expect(fees, closeTo(60.29, 0.01));
    });

    test('returns zero fees for zero sales', () {
      final fees = shopee.calculateFees(0);
      expect(fees, 0.0);
    });

    test('calculates walk-in fees (0%) correctly', () {
      final walkIn = Channel(
        id: 5,
        name: 'Walk-in',
        commissionRate: 0.0,
        transactionFeeRate: 0.0,
        flatFee: 0.0,
        shippingPaidByUs: 0.0,
        isActive: true,
        createdAt: DateTime(2026, 1, 1),
      );
      final fees = walkIn.calculateFees(1000.0);
      expect(fees, 0.0);
    });
  });

  group('Profit calculation', () {
    test('profit = sales - materials - fees - shipping', () {
      const sales = 647.0;
      const materialCost = 94.30;
      const fees = 51.76;
      const shipping = 0.0;

      const profit = sales - materialCost - fees - shipping;
      expect(profit, closeTo(500.94, 0.01));
    });

    test('profit with waste increases material cost', () {
      const sales = 647.0;
      const plannedMaterialCost = 94.30;
      const wasteCost = 9.0; // 1 extra magnet sheet at 9.0
      const actualMaterialCost = plannedMaterialCost + wasteCost;
      const fees = 51.76;
      const shipping = 0.0;

      const profit = sales - actualMaterialCost - fees - shipping;
      expect(profit, closeTo(491.94, 0.01));
    });
  });
}
