import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/tax_settings.dart';
import '../../domain/repositories/settings_repository.dart';

/// The shop's tax settings. New orders read them when they start.
class TaxSettingsCubit extends Cubit<TaxSettings> {
  final SettingsRepository repository;

  TaxSettingsCubit(this.repository) : super(const TaxSettings());

  Future<void> load() async => emit(await repository.getTaxSettings());

  /// Applies immediately; persisting is best-effort so a failed write only
  /// means the change isn't remembered next launch.
  Future<void> set(TaxSettings tax) async {
    emit(tax);
    await repository.setTaxSettings(tax);
  }
}
