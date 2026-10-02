import 'package:flutter/material.dart';

/// Today page - Flow 1: Day view
class TodayPage extends StatelessWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
      ),
      body: const Center(
        child: Text('Today page - Coming soon'),
      ),
    );
  }

  Widget myScaffold() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Today'),
      ),
      body: const Center(
        child: Text('Today page - Coming soon'),
      ),
    );
  }
}
