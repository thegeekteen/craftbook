import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

enum PhotoSource { camera, gallery }

/// Takes or picks one photo and hands back small JPEG bytes ready to store
/// in the database.
class PhotoPicker {
  /// Large enough to fill the full-screen viewer, small enough (~50–150 KB)
  /// that dozens of products don't bloat a backup.
  static const maxDimension = 800.0;
  static const jpegQuality = 80;

  final ImagePicker _picker;

  PhotoPicker([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  /// Null when the user backs out. Throws if the camera or gallery can't be
  /// opened (no camera, permission denied), so the caller can say so.
  Future<Uint8List?> pick(PhotoSource source) async {
    final file = await _picker.pickImage(
      source: source == PhotoSource.camera
          ? ImageSource.camera
          : ImageSource.gallery,
      maxWidth: maxDimension,
      maxHeight: maxDimension,
      imageQuality: jpegQuality,
    );
    return file?.readAsBytes();
  }
}
