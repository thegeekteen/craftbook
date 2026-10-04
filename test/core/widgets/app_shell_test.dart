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

    test('maps the other tabs', () {
      expect(AppShell.selectedIndexFor('/orders'), 1);
      expect(AppShell.selectedIndexFor('/materials'), 2);
      expect(AppShell.selectedIndexFor('/earnings'), 3);
      expect(AppShell.selectedIndexFor('/settings'), 4);
    });
  });
}
