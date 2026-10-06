import 'dart:math';

import 'fake_random.dart';
import 'fake_shop.dart';
import 'fake_vocabulary.dart';

/// The places the shop sells, one of every fee shape the app can charge.
///
/// `Channel.calculateFees` adds commission, transaction fee and a flat fee, so
/// a shop that only ever had marketplace-rate channels would never show that a
/// walk-in order has no fees at all.
List<ChannelPlan> buildChannels(Random random) {
  final names = takeSome(random, channelNames, 5, channelNames.length);
  final plans = <ChannelPlan>[];

  for (final (index, name) in names.indexed) {
    final shape = feeShapes[index % feeShapes.length];
    plans.add(ChannelPlan(
      ref: index + 1,
      name: name,
      commissionRate: shape.commission(random),
      transactionFeeRate: shape.transaction(random),
      flatFee: shape.flat,
      shippingPaidByUs: shape.shipping,
      paidByDefault: shape.paidByDefault,
      // The last one is a channel the shop stopped selling through but still
      // has orders behind, which is what blocking a channel delete is for.
      isActive: index < names.length - 1,
    ));
  }
  return plans;
}

/// A fee shape: which components are non-zero, and whether orders there start
/// out paid.
class _FeeShape {
  final double Function(Random) commission;
  final double Function(Random) transaction;
  final double flat;
  final double shipping;
  final bool paidByDefault;

  const _FeeShape({
    required this.commission,
    required this.transaction,
    this.flat = 0,
    this.shipping = 0,
    this.paidByDefault = true,
  });
}

/// Every combination the fee calculator can be handed, in this order: all
/// three, commission alone, a flat fee alone, and nothing at all. The channel
/// list walks it, so a shop with five channels sees each shape.
const feeShapes = [
  _FeeShape(
    commission: _percentBetween8and12,
    transaction: _percentBetween1and3,
    flat: 5,
    shipping: 40,
  ),
  _FeeShape(
    commission: _percentBetween5and8,
    transaction: _none,
    shipping: 30,
  ),
  _FeeShape(
    commission: _none,
    transaction: _none,
    flat: 20,
    shipping: 0,
  ),
  _FeeShape(
    commission: _none,
    transaction: _none,
    paidByDefault: false,
  ),
];

double _percentBetween8and12(Random random) =>
    random.intBetween(8, 12).toDouble();
double _percentBetween5and8(Random random) =>
    random.intBetween(5, 8).toDouble();
double _percentBetween1and3(Random random) =>
    random.intBetween(1, 3).toDouble();
double _none(Random random) => 0;

/// Chosen so the paused channel is always a real one with orders behind it
/// rather than the fee-shape filler.
const channelNames = [
  'Shopee',
  'TikTok Shop',
  'Lazada',
  'Facebook Marketplace',
  'Walk-in',
  'Carousell',
  'Instagram DM',
];
