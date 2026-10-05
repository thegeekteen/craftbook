import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/currency_setting.dart';
import '../../domain/repositories/settings_repository.dart';

/// The shop's currency. Every emit also reconfigures [CurrencyFormatter],
/// and the app rebuilds on it so amounts already on screen switch too.
class CurrencyCubit extends Cubit<CurrencySetting> {
  final SettingsRepository repository;

  CurrencyCubit(this.repository) : super(CurrencyFormatter.currency);

  Future<void> load() async => _apply(await repository.getCurrency());

  /// Applies immediately; persisting is best-effort so a failed write only
  /// means the choice isn't remembered next launch.
  Future<void> set(CurrencySetting currency) async {
    _apply(currency);
    await repository.setCurrency(currency);
  }

  void _apply(CurrencySetting currency) {
    CurrencyFormatter.configure(currency);
    emit(currency);
  }
}
