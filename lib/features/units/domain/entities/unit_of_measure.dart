import 'package:equatable/equatable.dart';

/// A unit materials and products are counted in ("pc", "sheet", "kg").
///
/// Labels render exactly as typed. The app never pluralises them, because
/// adding an "s" would be wrong for abbreviations like kg, m and ml.
class UnitOfMeasure extends Equatable {
  final int? id;
  final String label;
  final int position;

  /// New materials and products start on this one. Exactly one unit has it,
  /// and the list is never empty, so there is always one.
  final bool isDefault;

  const UnitOfMeasure({
    this.id,
    required this.label,
    this.position = 0,
    this.isDefault = false,
  });

  @override
  List<Object?> get props => [id, label, position, isDefault];
}
