import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/order_amount_shown.dart';
import '../../domain/repositories/settings_repository.dart';

/// App-wide choice of the amount order cards show: total or profit.
class OrderAmountCubit extends Cubit<OrderAmountShown> {
  final SettingsRepository repository;

  OrderAmountCubit(this.repository) : super(OrderAmountShown.total);

  Future<void> load() async => emit(await repository.getOrderAmountShown());

  /// Applies immediately; persisting is best-effort so a failed write only
  /// means the choice isn't remembered next launch.
  Future<void> set(OrderAmountShown shown) async {
    emit(shown);
    await repository.setOrderAmountShown(shown);
  }
}
