import 'package:craftbook/core/widgets/app_restarter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('restart reloads, rebuilds the app from scratch and shows the message', (tester) async {
    var reloads = 0;
    var builds = 0;
    await tester.pumpWidget(AppRestarter(
      reload: () async => reloads++,
      builder: (messengerKey) {
        builds++;
        return MaterialApp(
          scaffoldMessengerKey: messengerKey,
          home: const Scaffold(body: _Counter()),
        );
      },
    ));

    await tester.tap(find.byType(_Counter));
    await tester.pump();
    expect(find.text('taps: 1'), findsOneWidget);

    final restarter = tester.state<AppRestarterState>(find.byType(AppRestarter));
    await restarter.restart(message: 'Backup restored');
    await tester.pump();
    await tester.pump();

    expect(reloads, 1);
    expect(builds, 2);
    // Old state is gone: the new app starts fresh.
    expect(find.text('taps: 0'), findsOneWidget);
    expect(find.text('Backup restored'), findsOneWidget);
  });

  testWidgets('maybeOf finds the restarter above, and is null without one', (tester) async {
    late BuildContext inside;
    await tester.pumpWidget(AppRestarter(
      reload: () async {},
      builder: (key) => MaterialApp(home: Builder(builder: (c) => const SizedBox())),
    ));
    inside = tester.element(find.byType(SizedBox));
    expect(AppRestarter.maybeOf(inside), isNotNull);

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    inside = tester.element(find.byType(SizedBox));
    expect(AppRestarter.maybeOf(inside), isNull);
  });
}

class _Counter extends StatefulWidget {
  const _Counter();

  @override
  State<_Counter> createState() => _CounterState();
}

class _CounterState extends State<_Counter> {
  int _taps = 0;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => setState(() => _taps++),
        child: Text('taps: $_taps'),
      );
}
