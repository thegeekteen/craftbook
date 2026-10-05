import 'package:craftbook/core/widgets/app_shell.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppShell.selectedIndexFor', () {
    test('maps the root to Today', () {
      expect(AppShell.selectedIndexFor('/'), 0);
    });

    test('keeps Notes under the More tab', () {
      expect(AppShell.selectedIndexFor('/notes'), 4);
    });

    test('keeps Materials and the buy list under the More tab', () {
      expect(AppShell.selectedIndexFor('/materials'), 4);
      expect(AppShell.selectedIndexFor('/materials/3'), 4);
      expect(AppShell.selectedIndexFor('/stock/buy-list'), 4);
    });

    test('maps the other tabs', () {
      expect(AppShell.selectedIndexFor('/orders'), 1);
      expect(AppShell.selectedIndexFor('/products'), 2);
      expect(AppShell.selectedIndexFor('/products/3'), 2);
      expect(AppShell.selectedIndexFor('/reports'), 3);
      expect(AppShell.selectedIndexFor('/settings'), 4);
    });
  });
}
