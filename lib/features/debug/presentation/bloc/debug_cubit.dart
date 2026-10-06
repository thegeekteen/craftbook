import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/seed_outcome.dart';
import '../../domain/usecases/clear_shop_data.dart';
import '../../domain/usecases/get_database_info.dart';
import '../../domain/usecases/seed_fake_shop.dart';
import 'debug_state.dart';

/// Runs the debug tools and reports how far each got.
///
/// The caller shows the confirmation and restarts the app afterwards, which is
/// why the results come back to the widget rather than being pushed as state:
/// restarting disposes this cubit, and a screen that has to redraw from an
/// empty database can't be listening to a cubit that is going away.
class DebugCubit extends Cubit<DebugState> {
  DebugCubit({
    required this.seedFakeShop,
    required this.clearShopData,
    required this.getDatabaseInfo,
  }) : super(const DebugState());

  final SeedFakeShop seedFakeShop;
  final ClearShopData clearShopData;
  final GetDatabaseInfo getDatabaseInfo;

  Future<Result<SeedOutcome>> seed({int? seed}) async {
    if (state.isBusy) {
      return const Error(ValidationFailure('Already working.'));
    }
    _emit(const DebugState(phase: DebugPhase.seeding));
    final result = await seedFakeShop(seed: seed);
    _emit(switch (result) {
      Error(:final failure) => DebugState(error: failure.message),
      Success() => const DebugState(),
    });
    return result;
  }

  Future<Result<void>> clear() async {
    if (state.isBusy) {
      return const Error(ValidationFailure('Already working.'));
    }
    _emit(const DebugState(phase: DebugPhase.clearing));
    final result = await clearShopData();
    _emit(switch (result) {
      Error(:final failure) => DebugState(error: failure.message),
      Success() => const DebugState(),
    });
    return result;
  }

  Future<void> loadInfo() async {
    switch (await getDatabaseInfo()) {
      case Success(:final value):
        _emit(state.copyWith(info: value));
      case Error(:final failure):
        _emit(state.copyWith(error: failure.message));
    }
  }

  void _emit(DebugState next) {
    if (isClosed) return;
    emit(next);
  }
}
