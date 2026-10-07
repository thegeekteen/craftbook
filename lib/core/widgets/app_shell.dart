import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/route_names.dart';
import '../theme/colors.dart';
import '../utils/l10n_extension.dart';

/// Bottom-nav shell for the five tabs. Inventory holds Products (what
/// orders are made of) and Materials as two tabs; the buy list it opens
/// lives in the shell too so the nav stays visible.
class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  static List<NavigationDestination> _destinations(BuildContext context) => [
        NavigationDestination(
          icon: const Icon(Icons.wb_sunny_outlined),
          selectedIcon: Icon(Icons.wb_sunny_rounded),
          label: context.l10n.navToday,
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long_rounded),
          label: context.l10n.navOrders,
        ),
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2_rounded),
          label: context.l10n.navInventory,
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart_rounded),
          label: context.l10n.navReports,
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          selectedIcon: Icon(Icons.grid_view_rounded),
          label: context.l10n.navMore,
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
          destinations: _destinations(context),
        ),
      ),
    );
  }

  /// Which tab a path belongs to.
  static int selectedIndexFor(String location) {
    if (location.startsWith('/orders')) return 1;
    if (location.startsWith('/products') ||
        location.startsWith('/materials') ||
        location.startsWith('/stock')) {
      return 2;
    }
    if (location.startsWith(RouteNames.reports) ||
        location.startsWith(RouteNames.receivables)) {
      return 3;
    }
    if (location.startsWith('/settings') ||
        location.startsWith('/channels') ||
        location.startsWith(RouteNames.notes) ||
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
        context.go(RouteNames.products);
      case 3:
        context.go(RouteNames.reports);
      case 4:
        context.go(RouteNames.settings);
    }
  }
}
