import 'dart:async';

import 'package:equatable/equatable.dart';

/// Base class for orders list events
abstract class OrdersListEvent extends Equatable {
  const OrdersListEvent();

  @override
  List<Object?> get props => [];
}

/// Load (or reload) every order. Filtering happens in the view so chip
/// counts stay accurate. [done] completes when loading finishes.
class LoadOrders extends OrdersListEvent {
  final Completer<void>? done;

  const LoadOrders({this.done});
}
