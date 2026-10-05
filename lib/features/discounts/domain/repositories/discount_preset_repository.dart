import '../../../../core/error/result.dart';
import '../entities/discount_preset.dart';

abstract class DiscountPresetRepository {
  /// In the order they're shown.
  Future<Result<List<DiscountPreset>>> getPresets();

  /// Adds [preset] at the end of the list.
  Future<Result<int>> createPreset(DiscountPreset preset);
  Future<Result<void>> updatePreset(DiscountPreset preset);
  Future<Result<void>> deletePreset(int id);

  /// Sets the order presets are listed in.
  Future<Result<void>> reorder(List<int> ids);
}
