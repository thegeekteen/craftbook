import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../theme/colors.dart';
import '../theme/dimens.dart';
import '../theme/text_styles.dart';
import '../utils/l10n_extension.dart';

/// A product's photo as a rounded square. Without a photo it shows the
/// product's initial, so rows line up whether or not a photo is set.
class ProductPhoto extends StatelessWidget {
  final Uint8List? bytes;
  final String name;
  final double size;
  final VoidCallback? onTap;

  const ProductPhoto({
    super.key,
    required this.bytes,
    required this.name,
    this.size = 44,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final photo = bytes;
    final dpr = MediaQuery.devicePixelRatioOf(context);

    final Widget content;
    if (photo != null) {
      content = Image.memory(
        photo,
        width: size,
        height: size,
        fit: BoxFit.cover,
        // Decode at display size; a full 800px decode per row adds up.
        cacheWidth: (size * dpr).round(),
        gaplessPlayback: true,
        errorBuilder: (_, __, ___) => _Initial(name: name, size: size),
      );
    } else {
      content = _Initial(name: name, size: size);
    }

    return Semantics(
      image: true,
      label: photo != null ? context.l10n.productPhotoOf(name) : null,
      child: GestureDetector(
        onTap: photo != null ? onTap : null,
        child: Container(
          width: size,
          height: size,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: c.paper,
            borderRadius: AppRadii.controlAll,
            border: Border.all(color: c.hair),
          ),
          child: content,
        ),
      ),
    );
  }
}

class _Initial extends StatelessWidget {
  final String name;
  final double size;

  const _Initial({required this.name, required this.size});

  @override
  Widget build(BuildContext context) {
    final trimmed = name.trim();
    final letter =
        trimmed.isEmpty ? '' : trimmed.characters.first.toUpperCase();
    return Center(
      child: letter.isEmpty
          ? Icon(Icons.image_outlined,
              size: size * 0.45, color: context.colors.muted)
          : Text(
              letter,
              style: AppTextStyles.displaySmall.copyWith(
                color: context.colors.muted,
                fontSize: size * 0.4,
                height: 1,
              ),
            ),
    );
  }
}

/// Shows [bytes] full screen with pinch-to-zoom.
Future<void> showPhotoViewer(
  BuildContext context, {
  required Uint8List bytes,
  required String title,
}) {
  return showDialog<void>(
    context: context,
    useSafeArea: false,
    builder: (dialogContext) => Dialog.fullscreen(
      backgroundColor: dialogContext.colors.board,
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              maxScale: 5,
              child: Center(child: Image.memory(bytes, fit: BoxFit.contain)),
            ),
          ),
          SafeArea(
            child: Row(
              children: [
                IconButton(
                  tooltip: context.l10n.commonClose,
                  color: dialogContext.colors.boardInk,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: dialogContext.colors.boardInk),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
