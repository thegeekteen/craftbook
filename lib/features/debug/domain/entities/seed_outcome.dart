import '../../../../core/factory/coverage.dart';

/// What a seed run ended with, for the Debug row to report.
class SeedOutcome {
  /// The number the shop was built from. Same number, same shop.
  final int seed;
  final int orders;
  final int materials;
  final int products;

  /// Lines on the buy list afterwards, which is the one page that is easy to
  /// seed empty by accident.
  final int buyListLines;
  final CoverageReport coverage;

  const SeedOutcome({
    required this.seed,
    required this.orders,
    required this.materials,
    required this.products,
    required this.buyListLines,
    required this.coverage,
  });

  String get summary => 'seed $seed · $orders orders · $materials materials · '
      '$products products · $buyListLines to buy';

  List<String> get gaps => coverage.gaps;
}
