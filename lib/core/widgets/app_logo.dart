import 'package:flutter/material.dart';


/// The CraftBook launcher icon, for in-app places like the About footer.
///
/// Reuses the launcher artwork so the app looks the same on the home screen
/// and inside.
class AppLogo extends StatelessWidget {
  static const asset = 'assets/icon/icon_legacy.png';

  final double size;

  const AppLogo({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.28),
      child: Image.asset(
        asset,
        width: size,
        height: size,
        // Decoded at display size; the source is 1024px.
        cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
        semanticLabel: 'CraftBook logo',
      ),
    );
  }
}
