import 'package:flutter/widgets.dart';

/// The three corner radii used across the app, plus fully rounded pills.
class AppRadii {
  AppRadii._();

  static const double tag = 4;
  static const double control = 10;
  static const double card = 16;
  static const double sheet = 24;
  static const double pill = 999;

  static const BorderRadius tagAll = BorderRadius.all(Radius.circular(tag));
  static const BorderRadius controlAll =
      BorderRadius.all(Radius.circular(control));
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;

  /// Side gutter for every page body.
  static const double gutter = 16;

  /// Bottom padding that keeps the last list item clear of an extended FAB.
  static const double fabClearance = 96;

  static const EdgeInsets page = EdgeInsets.fromLTRB(gutter, 4, gutter, 24);
}
