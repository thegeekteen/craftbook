import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/route_names.dart';
import 'features/today/presentation/pages/today_page.dart';
import 'features/orders/presentation/pages/orders_list_page.dart';
import 'features/stock/presentation/pages/materials_list_page.dart';
import 'features/earnings/presentation/pages/earnings_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';

/// Main Craftbook application
class CraftbookApp extends StatelessWidget {
  CraftbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Craftbook',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }

  final GoRouter _router = GoRouter(
    initialLocation: RouteNames.today,
    routes: [
      GoRoute(
        path: RouteNames.today,
        builder: (context, state) => const TodayPage(),
      ),
      GoRoute(
        path: RouteNames.orders,
        builder: (context, state) => const OrdersListPage(),
      ),
      GoRoute(
        path: RouteNames.materials,
        builder: (context, state) => const MaterialsListPage(),
      ),
      GoRoute(
        path: RouteNames.earnings,
        builder: (context, state) => const EarningsPage(),
      ),
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsPage(),
      ),
    ],
  );
}
