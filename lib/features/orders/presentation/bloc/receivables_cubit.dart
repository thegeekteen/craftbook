import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/usecases/get_receivables.dart';

sealed class ReceivablesState extends Equatable {
  const ReceivablesState();

  @override
  List<Object?> get props => [];
}

class ReceivablesLoading extends ReceivablesState {
  const ReceivablesLoading();
}

class ReceivablesLoaded extends ReceivablesState {
  final Receivables receivables;

  const ReceivablesLoaded(this.receivables);

  @override
  List<Object?> get props => [receivables];
}

class ReceivablesError extends ReceivablesState {
  final String message;

  const ReceivablesError(this.message);

  @override
  List<Object?> get props => [message];
}

/// What customers still owe, for the Waiting for payment page.
class ReceivablesCubit extends Cubit<ReceivablesState> {
  final GetReceivables getReceivables;

  ReceivablesCubit(this.getReceivables) : super(const ReceivablesLoading());

  /// Keeps the list on screen while reloading after a change.
  Future<void> load() async {
    final result = await getReceivables();
    switch (result) {
      case Error(:final failure):
        emit(ReceivablesError(failure.message));
      case Success(:final value):
        emit(ReceivablesLoaded(value));
    }
  }
}
