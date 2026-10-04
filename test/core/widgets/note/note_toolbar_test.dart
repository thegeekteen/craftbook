import 'package:craftbook/core/widgets/note/note_toolbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../support/note_harness.dart';

void main() {
  const fullOnly = [
    'Inline code',
    'Highlight',
    'Large heading',
    'Small heading',
    'Quote',
    'Code block',
    'Indent',
    'Outdent',
    'Align centre',
    'Align right',
    'Link',
  ];

  late QuillController controller;

  setUp(() => controller = QuillController.basic());
  tearDown(() => controller.dispose());

  Future<void> pump(WidgetTester tester, {required bool full}) async {
    await tester.pumpWidget(wrapWithTheme(Align(
      alignment: Alignment.bottomCenter,
      child: NoteToolbar(controller: controller, full: full),
    )));
  }

  /// Every tool's tooltip, scrolled into view or not.
  Set<String> tools(WidgetTester tester) => {
        for (final b in tester.widgetList<IconButton>(
            find.byType(IconButton, skipOffstage: false)))
          if (b.tooltip != null) b.tooltip!,
      };

  testWidgets('the compact toolbar keeps to the order-note set',
      (tester) async {
    await pump(tester, full: false);
    expect(tools(tester),
        containsAll(['Bold', 'Heading', 'Checklist', 'Clear formatting']));
    expect(tools(tester).intersection(fullOnly.toSet()), isEmpty);
  });

  testWidgets('the full toolbar adds the rest', (tester) async {
    await pump(tester, full: true);
    expect(tools(tester), containsAll([...fullOnly, 'Bold', 'Checklist']));
  });

  testWidgets('a block button formats the line', (tester) async {
    controller.replaceText(0, 0, 'Hello', null);
    await pump(tester, full: true);
    await tester.scrollUntilVisible(find.byTooltip('Quote'), 100,
        scrollable: find.byType(Scrollable));
    await tester.tap(find.byTooltip('Quote'));
    await tester.pump();
    expect(controller.getSelectionStyle().attributes[Attribute.blockQuote.key],
        Attribute.blockQuote);
  });

  testWidgets('a highlight is stored by palette name', (tester) async {
    controller
      ..replaceText(0, 0, 'Hello', null)
      ..updateSelection(const TextSelection(baseOffset: 0, extentOffset: 5),
          ChangeSource.local);
    await pump(tester, full: true);
    await tester.tap(find.byTooltip('Highlight'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Green'));
    await tester.pumpAndSettle();

    final ops = controller.document.toDelta().toJson();
    expect(ops.first, {
      'insert': 'Hello',
      'attributes': {'background': 'go'}
    });
  });

  testWidgets('a link with nothing selected inserts the address',
      (tester) async {
    await pump(tester, full: true);
    await tester.scrollUntilVisible(find.byTooltip('Link'), 100,
        scrollable: find.byType(Scrollable));
    await tester.tap(find.byTooltip('Link'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'https://shop.example');
    await tester.tap(find.text('Apply'));
    await tester.pumpAndSettle();

    final ops = controller.document.toDelta().toJson();
    expect(ops.first, {
      'insert': 'https://shop.example',
      'attributes': {'link': 'https://shop.example'},
    });
  });
}
