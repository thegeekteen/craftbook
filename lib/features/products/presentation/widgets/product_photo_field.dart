import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/services/photo_picker.dart';
import '../../../../core/theme/colors.dart';
import '../../../../core/theme/text_styles.dart';
import '../../../../core/utils/extensions.dart';
import '../../../../core/widgets/app_sheet.dart';
import '../../../../core/widgets/product_photo.dart';

/// The photo slot at the top of the product editor. Tapping it offers the
/// camera, the gallery, or removing the current photo.
class ProductPhotoField extends StatelessWidget {
  final Uint8List? photo;
  final String name;
  final ValueChanged<Uint8List?> onChanged;

  const ProductPhotoField({
    super.key,
    required this.photo,
    required this.name,
    required this.onChanged,
  });

  Future<void> _choose(BuildContext context) async {
    final action = await showAppSheet<_PhotoAction>(
      context: context,
      title: 'Product photo',
      subtitle: 'Shown when you pick products for an order.',
      builder: (sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.photo_camera_outlined),
            title: const Text('Take photo'),
            onTap: () => Navigator.pop(sheetContext, _PhotoAction.camera),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Choose from gallery'),
            onTap: () => Navigator.pop(sheetContext, _PhotoAction.gallery),
          ),
          if (photo != null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  Icon(Icons.delete_outline, color: sheetContext.colors.alert),
              title: Text('Remove photo',
                  style: TextStyle(color: sheetContext.colors.alert)),
              onTap: () => Navigator.pop(sheetContext, _PhotoAction.remove),
            ),
        ],
      ),
    );
    if (action == null || !context.mounted) return;

    if (action == _PhotoAction.remove) {
      onChanged(null);
      return;
    }
    try {
      final bytes = await getIt<PhotoPicker>().pick(
        action == _PhotoAction.camera
            ? PhotoSource.camera
            : PhotoSource.gallery,
      );
      if (bytes != null) onChanged(bytes);
    } catch (e) {
      if (!context.mounted) return;
      context.showSnackBar(
        action == _PhotoAction.camera
            ? "Couldn't open the camera"
            : "Couldn't open your photos",
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        InkWell(
          onTap: () => _choose(context),
          child: ProductPhoto(bytes: photo, name: name, size: 88),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton.icon(
                style: TextButton.styleFrom(padding: EdgeInsets.zero),
                onPressed: () => _choose(context),
                icon: Icon(photo == null
                    ? Icons.add_a_photo_outlined
                    : Icons.edit_outlined),
                label: Text(photo == null ? 'Add photo' : 'Change photo'),
              ),
              Text(
                'Helps you spot the right item when making an order.',
                style: AppTextStyles.bodySmall.copyWith(color: c.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

enum _PhotoAction { camera, gallery, remove }
