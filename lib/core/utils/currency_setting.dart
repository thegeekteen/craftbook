import 'package:equatable/equatable.dart';

/// The shop's currency: only how amounts are written. Changing it never
/// converts stored amounts.
class CurrencySetting extends Equatable {
  /// ISO code, or [customCode] for a symbol the user typed.
  final String code;
  final String symbol;
  final int decimals;
  final String name;

  const CurrencySetting({
    required this.code,
    required this.symbol,
    this.decimals = 2,
    this.name = '',
  });

  static const customCode = 'CUSTOM';

  static const php =
      CurrencySetting(code: 'PHP', symbol: '₱', name: 'Philippine peso');

  /// The currencies offered in Settings, most likely first.
  static const presets = [
    php,
    CurrencySetting(code: 'USD', symbol: r'$', name: 'US dollar'),
    CurrencySetting(code: 'EUR', symbol: '€', name: 'Euro'),
    CurrencySetting(code: 'GBP', symbol: '£', name: 'British pound'),
    CurrencySetting(code: 'AUD', symbol: r'A$', name: 'Australian dollar'),
    CurrencySetting(code: 'CAD', symbol: r'C$', name: 'Canadian dollar'),
    CurrencySetting(code: 'SGD', symbol: r'S$', name: 'Singapore dollar'),
    CurrencySetting(code: 'MYR', symbol: 'RM', name: 'Malaysian ringgit'),
    CurrencySetting(code: 'IDR', symbol: 'Rp', name: 'Indonesian rupiah'),
    CurrencySetting(code: 'THB', symbol: '฿', name: 'Thai baht'),
    CurrencySetting(
        code: 'VND', symbol: '₫', decimals: 0, name: 'Vietnamese dong'),
    CurrencySetting(code: 'INR', symbol: '₹', name: 'Indian rupee'),
    CurrencySetting(
        code: 'JPY', symbol: '¥', decimals: 0, name: 'Japanese yen'),
  ];

  static CurrencySetting? preset(String code) {
    for (final p in presets) {
      if (p.code == code) return p;
    }
    return null;
  }

  bool get isCustom => code == customCode;

  /// "₱ · Philippine peso", or just the symbol for a custom one.
  String get label => isCustom ? '$symbol · Custom' : '$symbol · $name';

  @override
  List<Object?> get props => [code, symbol, decimals];
}
