import 'dart:math';

import '../utils/quantity.dart';

/// The random draws the fake shop is built from.
///
/// Money lands on 2 decimals and quantities on [quantityDecimals] — the same
/// rounding the database applies on write — so what the generator predicts
/// during a seed is what the app reads back afterwards.
extension FakeRandom on Random {
  /// Whole number between [low] and [high], both ends included.
  int intBetween(int low, int high) => low + nextInt(high - low + 1);

  /// An amount of money, on the scale amounts are stored at.
  double money(double low, double high) {
    final value = low + nextDouble() * (high - low);
    return (value * 100).roundToDouble() / 100;
  }

  /// A quantity on a fixed [step], so fractions read like something a person
  /// typed (0.5 m, 2.25 sheets) rather than float noise.
  double qtyBetween(double low, double high, {double step = 0.5}) {
    final steps = ((high - low) / step).floor();
    return qty(low + step * nextInt(steps + 1));
  }

  /// One in [outOf].
  bool oneIn(int outOf) => nextInt(outOf) == 0;

  T oneOf<T>(List<T> options) => options[nextInt(options.length)];

  /// A value from [options] most of the time, `null` the rest — for fields
  /// the shop sometimes leaves blank.
  T? oneOfOrNull<T>(List<T> options, {int blankOutOf = 4}) =>
      oneIn(blankOutOf) ? null : oneOf(options);

  /// [count] distinct entries, in a random order.
  List<T> sample<T>(List<T> options, int count) {
    final pool = [...options]..shuffle(this);
    return pool.take(count > pool.length ? pool.length : count).toList();
  }

  /// A moment inside [first] and [last].
  DateTime between(DateTime first, DateTime last) {
    final span = last.difference(first);
    return first.add(Duration(milliseconds: nextInt(span.inMilliseconds + 1)));
  }

  /// Whole days before [from], 0 included.
  DateTime daysBefore(DateTime from, int maxDays) =>
      from.subtract(Duration(days: nextInt(maxDays + 1)));
}

/// Whether a whole number of [packSize] is a nice round stock count.
bool isWholeMultiple(double value, double packSize) =>
    sameQty(value / packSize, (value / packSize).roundToDouble());
