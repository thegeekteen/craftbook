import 'package:flutter/material.dart';

/// Rebuilds the whole app in place, for when the database file underneath
/// it has been swapped (restore, undo restore).
class AppRestarter extends StatefulWidget {
  const AppRestarter({super.key, required this.reload, required this.builder});

  /// Re-registers dependencies against the new database file.
  final Future<void> Function() reload;

  /// Builds a fresh app. Pass [messengerKey] to its `MaterialApp`, so a
  /// message can be shown once the new app is up.
  final Widget Function(GlobalKey<ScaffoldMessengerState> messengerKey) builder;

  /// Null in tests and screenshots, which mount the app without one.
  static AppRestarterState? maybeOf(BuildContext context) =>
      context.findAncestorStateOfType<AppRestarterState>();

  @override
  State<AppRestarter> createState() => AppRestarterState();
}

class AppRestarterState extends State<AppRestarter> {
  // A new key each time: reusing a GlobalKey would carry the old app's
  // element subtree over into the new one.
  late GlobalKey<ScaffoldMessengerState> _messengerKey;
  late Widget _app;
  Key _subtreeKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _build();
  }

  void _build() {
    _messengerKey = GlobalKey<ScaffoldMessengerState>();
    _app = widget.builder(_messengerKey);
  }

  /// Reloads dependencies, then replaces the app, which starts on Today.
  /// [message] shows as a snackbar in the new app.
  Future<void> restart({String? message}) async {
    await widget.reload();
    if (!mounted) return;
    setState(() {
      _subtreeKey = UniqueKey();
      _build();
    });
    if (message == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _messengerKey.currentState?.showSnackBar(SnackBar(content: Text(message)));
    });
  }

  @override
  Widget build(BuildContext context) => KeyedSubtree(key: _subtreeKey, child: _app);
}
