import 'package:craftbook/core/theme/app_theme.dart';
import 'package:craftbook/features/orders/presentation/widgets/leave_order_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../support/localized_app.dart';

void main() {
  Future<LeaveChoice?> choose(WidgetTester tester, String button,
      {bool isDraft = false}) async {
    LeaveChoice? picked;
    await tester.pumpWidget(localizedApp(
      Builder(
        builder: (context) => TextButton(
          onPressed: () async =>
              picked = await LeaveOrderDialog.show(context, isDraft: isDraft),
          child: const Text('open'),
        ),
      ),
      theme: AppTheme.lightTheme,
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(button));
    await tester.pumpAndSettle();
    return picked;
  }

  testWidgets('offers keeping the order before throwing it away',
      (tester) async {
    expect(await choose(tester, 'Save draft'), LeaveChoice.saveDraft);
    expect(await choose(tester, 'Discard'), LeaveChoice.discard);
    expect(await choose(tester, 'Keep editing'), LeaveChoice.keepEditing);
  });

  testWidgets('a new order and a reopened draft are asked differently',
      (tester) async {
    await tester.pumpWidget(localizedApp(
        const Scaffold(body: LeaveOrderDialog()),
        theme: AppTheme.lightTheme));
    expect(find.text('Keep this order for later?'), findsOneWidget);

    await tester.pumpWidget(localizedApp(
        const Scaffold(body: LeaveOrderDialog(isDraft: true)),
        theme: AppTheme.lightTheme));
    expect(find.text('Save changes to this draft?'), findsOneWidget);
    expect(find.text('Discard leaves the draft as it was.'), findsOneWidget);
  });
}
