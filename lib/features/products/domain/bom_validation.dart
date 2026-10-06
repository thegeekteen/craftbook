import '../../../../core/error/failures.dart';

/// Why a bill of materials can't be saved, or null when it can.
///
/// Uses needs no check here: the editor removes a line whose Uses hits 0.
/// Makes does, because the cost per product and every reservation divide by
/// it, and a typed 0 would otherwise sail through.
ValidationFailure? validateBomMakes(
  Iterable<({String materialName, double makes})> lines,
) {
  for (final line in lines) {
    if (line.makes <= 0) {
      return ValidationFailure('${line.materialName}: Makes must be above 0');
    }
  }
  return null;
}
