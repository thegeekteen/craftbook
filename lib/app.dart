import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// Narrow import: the full barrel exports Document/Node/Attribute and friends,
// which would collide with the names this file already uses.
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
import 'package:go_router/go_router.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/route_names.dart';
import 'core/widgets/app_shell.dart';
import 'core/theme/palettes.dart';
import 'features/settings/domain/entities/theme_settings.dart';
import 'features/settings/presentation/bloc/theme_cubit.dart';
import 'features/stock/presentation/bloc/materials_bloc.dart';

import 'features/today/presentation/pages/today_page.dart';
import 'features/today/presentation/pages/calendar_page.dart';
import 'features/orders/presentation/pages/orders_list_page.dart';
import 'features/orders/presentation/pages/new_order_page.dart';
import 'features/orders/presentation/pages/order_details_page.dart';
import 'features/stock/presentation/pages/materials_list_page.dart';
import 'features/stock/presentation/pages/material_detail_page.dart';
import 'features/stock/presentation/pages/new_material_page.dart';
import 'features/stock/presentation/pages/receive_stock_page.dart';
import 'features/stock/presentation/pages/buy_list_page.dart';
import 'features/products/presentation/pages/products_list_page.dart';
import 'features/products/presentation/pages/product_detail_page.dart';
import 'features/products/presentation/pages/product_editor_page.dart';
import 'features/products/presentation/pages/receive_product_stock_page.dart';
import 'features/order_fields/presentation/pages/order_fields_page.dart';
import 'features/products/presentation/pages/channels_page.dart';
import 'features/earnings/presentation/pages/earnings_page.dart';
import 'features/earnings/presentation/pages/product_earnings_page.dart';
import 'features/notes/presentation/pages/note_edit_page.dart';
import 'features/notes/presentation/pages/notes_page.dart';
import 'features/settings/presentation/pages/about_page.dart';
import 'features/social_links/presentation/pages/social_links_page.dart';
import 'features/settings/presentation/pages/settings_page.dart';

class CraftbookApp extends StatelessWidget {
  /// [initialLocation], [themeMode] and [palette] are overridable for
  /// screenshots and tests; the app itself starts on Today and uses the
  /// saved appearance.
  CraftbookApp({
    super.key,
    String initialLocation = RouteNames.today,
    this.themeMode,
    this.palette,
    this.scaffoldMessengerKey,
  }) : _router = _buildRouter(initialLocation);

  final ThemeMode? themeMode;
  final AppPalette? palette;

  /// Lets the app restarter show a message in a freshly rebuilt app.
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    Widget app(ThemeSettings look) => MaterialApp.router(
          title: 'CraftBook',
          theme: AppTheme.light(look.palette),
          darkTheme: AppTheme.dark(look.palette),
          themeMode: look.mode,
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: scaffoldMessengerKey,
          // Quill looks its toolbar strings up through these; without them the
          // note editor throws while building.
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          routerConfig: _router,
        );

    final fixedMode = themeMode;
    final fixedPalette = palette;
    if (fixedMode != null && fixedPalette != null) {
      return app(ThemeSettings(mode: fixedMode, palette: fixedPalette));
    }
    return BlocBuilder<ThemeCubit, ThemeSettings>(
      bloc: getIt<ThemeCubit>(),
      builder: (context, saved) => app(
        ThemeSettings(
          mode: fixedMode ?? saved.mode,
          palette: fixedPalette ?? saved.palette,
        ),
      ),
    );
  }

  static GoRouter _buildRouter(String initialLocation) => GoRouter(
        initialLocation: initialLocation,
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
              GoRoute(
                path: RouteNames.about,
                builder: (context, state) => const AboutPage(),
              ),
              // Catalogue pages keep the bottom nav (they belong to More/Stock).
              GoRoute(
                path: RouteNames.products,
                builder: (context, state) => const ProductsListPage(),
              ),
              GoRoute(
                path: RouteNames.buyList,
                builder: (context, state) => const BuyListPage(),
              ),
              GoRoute(
                path: RouteNames.notes,
                builder: (context, state) => const NotesPage(),
              ),
            ],
          ),
          // Top-level (no shell): these are pushed from the order wizard, and a
          // shell child there would mount a second AppShell and duplicate its
          // GlobalKey.
          GoRoute(
            path: RouteNames.channels,
            builder: (context, state) => const ChannelsPage(),
          ),
          GoRoute(
            path: RouteNames.orderFields,
            builder: (context, state) => const OrderFieldsPage(),
          ),
          GoRoute(
            path: RouteNames.socialLinks,
            builder: (context, state) => const SocialLinksPage(),
          ),
          // The note editor takes the whole screen, keyboard and toolbar included.
          GoRoute(
            path: RouteNames.newNote,
            builder: (context, state) => const NoteEditPage(),
          ),
          GoRoute(
            path: RouteNames.noteDetail,
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return NoteEditPage(noteId: id);
            },
          ),
          GoRoute(
            path: RouteNames.calendarWeek,
            builder: (context, state) => const CalendarPage(),
          ),
          GoRoute(
            path: RouteNames.calendarMonth,
            builder: (context, state) =>
                const CalendarPage(initialMode: CalendarMode.month),
          ),
          GoRoute(
            path: RouteNames.newOrder,
            builder: (context, state) => const NewOrderPage(),
          ),
          GoRoute(
            path: RouteNames.editOrder,
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return NewOrderPage(orderId: id);
            },
          ),
          GoRoute(
            path: RouteNames.orderDetail,
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return OrderDetailsPage(orderId: id);
            },
          ),
          GoRoute(
            path: RouteNames.newMaterial,
            builder: (context, state) => const NewMaterialPage(),
          ),
          GoRoute(
            path: RouteNames.editMaterial,
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return NewMaterialPage(materialId: id);
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
            path: RouteNames.newProduct,
            builder: (context, state) => const ProductEditorPage(),
          ),
          GoRoute(
            path: RouteNames.productDetail,
            builder: (context, state) {
              final id = int.parse(state.pathParameters['id']!);
              return ProductDetailPage(productId: id);
            },
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
            path: RouteNames.productEarnings,
            builder: (context, state) {
              final id = int.parse(state.pathParameters['productId']!);
              DateTime? at(String key) {
                final ms = int.tryParse(state.uri.queryParameters[key] ?? '');
                return ms == null
                    ? null
                    : DateTime.fromMillisecondsSinceEpoch(ms);
              }

              return ProductEarningsPage(
                productId: id,
                startDate: at('start'),
                endDate: at('end'),
              );
            },
          ),
        ],
      );
}
