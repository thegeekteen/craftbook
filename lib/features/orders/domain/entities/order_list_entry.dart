import 'package:equatable/equatable.dart';

import 'order.dart';

/// One product line on an order, for list summaries.
class OrderLine extends Equatable {
  final String productName;
  final int quantity;

  const OrderLine({required this.productName, required this.quantity});

  @override
  List<Object?> get props => [productName, quantity];
}

/// An order plus what list screens show about it: channel and items.
class OrderListEntry extends Equatable {
  final Order order;
  final String? channelName;
  final List<OrderLine> lines;

  const OrderListEntry({
    required this.order,
    this.channelName,
    this.lines = const [],
  });

  /// "2× Crochet tulip bouquet · 1× Kraft gift box"
  String get itemSummary =>
      lines.map((l) => '${l.quantity}× ${l.productName}').join(' · ');

  int get pieceCount => lines.fold(0, (sum, l) => sum + l.quantity);

  @override
  List<Object?> get props => [order, channelName, lines];
}
