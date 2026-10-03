import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/route_names.dart';
import 'core/widgets/app_shell.dart';
import 'features/stock/presentation/bloc/materials_bloc.dart';

import 'features/today/presentation/pages/today_page.dart';
import 'features/today/presentation/pages/calendar_week_page.dart';
import 'features/today/presentation/pages/calendar_month_page.dart';
import 'features/orders/presentation/pages/orders_list_page.dart';
import 'features/orders/presentation/pages/new_order_page.dart';
import 'features/orders/presentation/pages/order_details_page.dart';
import 'features/stock/presentation/pages/materials_list_page.dart';
import 'features/stock/presentation/pages/material_detail_page.dart';
import 'features/stock/presentation/pages/receive_stock_page.dart';
import 'features/stock/presentation/pages/buy_list_page.dart';
import 'features/products/presentation/pages/products_list_page.dart';
import 'features/products/presentation/pages/product_editor_page.dart';
import 'features/products/presentation/pages/receive_product_stock_page.dart';
import 'features/products/presentation/pages/channels_page.dart';
import 'features/earnings/presentation/pages/earnings_page.dart';
import 'features/earnings/presentation/pages/product_earnings_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';

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
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
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
      ),
      GoRoute(
        path: RouteNames.calendarWeek,
        builder: (context, state) => const CalendarWeekPage(),
      ),
      GoRoute(
        path: RouteNames.calendarMonth,
        builder: (context, state) => const CalendarMonthPage(),
      ),
      GoRoute(
        path: RouteNames.newOrder,
        builder: (context, state) => const NewOrderPage(),
      ),
      GoRoute(
        path: RouteNames.orderDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return OrderDetailsPage(orderId: id);
        },
      ),
      GoRoute(
        path: RouteNames.materialDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MaterialDetailPage(materialId: id);
        },
      ),
      GoRoute(
        path: RouteNames.receiveStock,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return BlocProvider(
            create: (_) => getIt<MaterialsBloc>(),
            child: ReceiveStockPage(materialId: id),
          );
        },
      ),
      GoRoute(
        path: RouteNames.buyList,
        builder: (context, state) => const BuyListPage(),
      ),
      GoRoute(
        path: RouteNames.products,
        builder: (context, state) => const ProductsListPage(),
      ),
      GoRoute(
        path: RouteNames.newProduct,
        builder: (context, state) => const ProductEditorPage(),
      ),
      GoRoute(
        path: RouteNames.productEditor,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProductEditorPage(productId: id);
        },
      ),
      GoRoute(
        path: RouteNames.receiveProductStock,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ReceiveProductStockPage(productId: id);
        },
      ),
      GoRoute(
        path: RouteNames.channels,
        builder: (context, state) => const ChannelsPage(),
      ),
      GoRoute(
        path: RouteNames.productEarnings,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['productId']!);
          return ProductEarningsPage(productId: id);
        },
      ),
    ],
  );
}
