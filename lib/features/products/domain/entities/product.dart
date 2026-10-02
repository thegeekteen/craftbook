import 'package:equatable/equatable.dart';

/// Product entity
class Product extends Equatable {
  final int? id;
  final String name;
  final String? description;
  final double sellPrice;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    this.id,
    required this.name,
    this.description,
    required this.sellPrice,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        sellPrice,
        isActive,
        createdAt,
        updatedAt,
      ];

  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? sellPrice,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sellPrice: sellPrice ?? this.sellPrice,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
