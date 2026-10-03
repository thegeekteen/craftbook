import 'package:craftbook/core/theme/colors.dart';
import 'package:craftbook/core/theme/palettes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final hi = la > lb ? la : lb;
  final lo = la > lb ? lb : la;
  return (hi + 0.05) / (lo + 0.05);
}

double _hueGap(Color a, Color b) {
  final d = (HSLColor.fromColor(a).hue - HSLColor.fromColor(b).hue).abs();
  return d > 180 ? 360 - d : d;
}

void main() {
  test('Forest is the original palette', () {
    expect(AppPalette.forest.light, same(CraftColors.light));
    expect(AppPalette.forest.dark, same(CraftColors.dark));
  });

  group('fromName', () {
    test('finds every palette by name', () {
      for (final p in AppPalette.values) {
        expect(AppPalette.fromName(p.name), p);
      }
    });
    test('falls back to Forest', () {
      expect(AppPalette.fromName(null), AppPalette.forest);
      expect(AppPalette.fromName('neon'), AppPalette.forest);
    });
  });

  for (final palette in AppPalette.values) {
    for (final brightness in Brightness.values) {
      final c = palette.forBrightness(brightness);
      group('${palette.name} ${brightness.name}', () {
        test('text is readable on the page and on cards', () {
          expect(_contrast(c.ink, c.paper), greaterThanOrEqualTo(4.5));
          expect(_contrast(c.ink, c.surface), greaterThanOrEqualTo(4.5));
        });
        test('the accent works as text on cards', () {
          expect(_contrast(c.go, c.surface), greaterThanOrEqualTo(4.5));
        });
        test('text on accent fills is readable', () {
          for (final fill in [c.go, c.alert, c.coin]) {
            expect(_contrast(c.onAccent, fill), greaterThanOrEqualTo(4.5));
          }
        });
        test('the summary board is readable', () {
          expect(_contrast(c.boardInk, c.board), greaterThanOrEqualTo(4.5));
        });
        test('accent, alert and warn stay distinguishable', () {
          expect(_hueGap(c.go, c.alert), greaterThanOrEqualTo(20));
          expect(_hueGap(c.go, c.warn), greaterThanOrEqualTo(20));
          expect(_hueGap(c.alert, c.warn), greaterThanOrEqualTo(20));
        });
      });
    }
  }
}
