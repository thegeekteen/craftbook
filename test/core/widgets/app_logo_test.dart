import 'package:craftbook/core/widgets/app_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AppLogo renders the logo asset at the requested size', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: Center(child: AppLogo(size: 80))));

    final image = tester.widget<Image>(find.byType(Image));
    expect(image.width, 80);
    expect(image.height, 80);
    expect(image.semanticLabel, 'CraftBook logo');
  });
}
