import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/route_names.dart';
import '../theme/colors.dart';

/// Bottom-nav shell for the five tabs. Catalogue pages under More
/// (Products, Channels, Buy list) also live in the shell so the nav stays
/// visible there.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.wb_sunny_outlined),
      selectedIcon: Icon(Icons.wb_sunny_rounded),
      label: 'Today',
    ),
    NavigationDestination(
      icon: Icon(Icons.receipt_long_outlined),
      selectedIcon: Icon(Icons.receipt_long_rounded),
      label: 'Orders',
    ),
    NavigationDestination(
      icon: Icon(Icons.inventory_2_outlined),
      selectedIcon: Icon(Icons.inventory_2_rounded),
      label: 'Stock',
    ),
    NavigationDestination(
      icon: Icon(Icons.payments_outlined),
      selectedIcon: Icon(Icons.payments_rounded),
      label: 'Money',
    ),
    NavigationDestination(
      icon: Icon(Icons.grid_view_outlined),
      selectedIcon: Icon(Icons.grid_view_rounded),
      label: 'More',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: child,
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: c.hair)),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndexFor(GoRouterState.of(context).uri.path),
          onDestinationSelected: (index) => _onTabSelected(context, index),
          destinations: _destinations,
        ),
      ),
    );
  }

  /// Which tab a path belongs to.
  static int selectedIndexFor(String location) {
    if (location.startsWith('/orders')) return 1;
    if (location.startsWith('/materials') || location.startsWith('/stock')) {
      return 2;
    }
    if (location.startsWith('/earnings')) return 3;
    if (location.startsWith('/settings') ||
        location.startsWith('/products') ||
        location.startsWith('/channels') ||
        location.startsWith(RouteNames.about)) {
      return 4;
    }
    return 0;
  }

  void _onTabSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(RouteNames.today);
      case 1:
        context.go(RouteNames.orders);
      case 2:
        context.go(RouteNames.materials);
      case 3:
        context.go(RouteNames.earnings);
      case 4:
        context.go(RouteNames.settings);
    }
  }
}
