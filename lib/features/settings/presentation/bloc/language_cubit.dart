import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_language.dart';
import '../../domain/repositories/settings_repository.dart';

/// App-wide language choice (System / English / Filipino).
class LanguageCubit extends Cubit<AppLanguage> {
  final SettingsRepository repository;

  LanguageCubit(this.repository) : super(AppLanguage.system);

  Future<void> load() async => emit(await repository.getLanguage());

  /// Applies immediately; persisting is best-effort so a failed write only
  /// means the choice isn't remembered next launch.
  Future<void> set(AppLanguage language) async {
    emit(language);
    await repository.setLanguage(language);
  }
}
