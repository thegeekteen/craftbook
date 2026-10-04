import 'package:equatable/equatable.dart';

import 'order_field.dart';

/// One order's value for one field, ready to show.
class OrderFieldEntry extends Equatable {
  final OrderField field;

  /// As stored; see `OrderFieldCodec` for the encoding per type.
  final String value;

  const OrderFieldEntry({required this.field, required this.value});

  @override
  List<Object?> get props => [field, value];
}
