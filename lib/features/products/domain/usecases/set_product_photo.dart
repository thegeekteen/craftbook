import 'dart:typed_data';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';

import '../repositories/product_repository.dart';

/// Sets or clears a product's photo.
class SetProductPhoto {
  /// Photos are resized when picked, so anything this large means the
  /// resize didn't happen and the bytes would bloat every backup.
  static const maxBytes = 2 * 1024 * 1024;

  final ProductRepository repository;

  SetProductPhoto(this.repository);

  /// A null [photo] removes the current one.
  Future<Result<void>> call(int productId, Uint8List? photo) {
    if (photo != null && photo.isEmpty) {
      return Future.value(
          const Error(ValidationFailure('That photo could not be read')));
    }
    if (photo != null && photo.length > maxBytes) {
      return Future.value(
          const Error(ValidationFailure('That photo is too large')));
    }
    return repository.setProductPhoto(productId, photo);
  }
}
