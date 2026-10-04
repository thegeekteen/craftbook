import 'package:equatable/equatable.dart';

enum OrderFieldType {
  text('Text'),
  number('Number'),
  date('Date'),
  choice('Choice');

  const OrderFieldType(this.label);

  final String label;

  /// The value stored in `order_field_definitions.type`.
  String get dbName => name;

  /// Unknown names read as text so a value is never hidden.
  static OrderFieldType fromDb(String value) => OrderFieldType.values
      .firstWhere((t) => t.dbName == value, orElse: () => OrderFieldType.text);
}

/// A detail the shop notes on each order: address, size, wrap style…
class OrderField extends Equatable {
  final int? id;
  final String name;
  final OrderFieldType type;

  /// Only meaningful for text fields.
  final bool isMultiline;

  /// The choices of a choice field, in display order.
  final List<String> options;
  final int position;

  /// Archived fields aren't asked for on orders but stay on past ones.
  final bool isArchived;

  /// How many orders hold a value for this field.
  final int usageCount;

  const OrderField({
    this.id,
    required this.name,
    required this.type,
    this.isMultiline = false,
    this.options = const [],
    this.position = 0,
    this.isArchived = false,
    this.usageCount = 0,
  });

  bool get isUsed => usageCount > 0;

  @override
  List<Object?> get props => [
        id,
        name,
        type,
        isMultiline,
        options,
        position,
        isArchived,
        usageCount,
      ];

  OrderField copyWith({
    int? id,
    String? name,
    OrderFieldType? type,
    bool? isMultiline,
    List<String>? options,
    int? position,
    bool? isArchived,
    int? usageCount,
  }) {
    return OrderField(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      isMultiline: isMultiline ?? this.isMultiline,
      options: options ?? this.options,
      position: position ?? this.position,
      isArchived: isArchived ?? this.isArchived,
      usageCount: usageCount ?? this.usageCount,
    );
  }
}
