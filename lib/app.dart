import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
// Narrow import: the full barrel exports Document/Node/Attribute and friends,
// which would collide with the names this file already uses.
import 'package:flutter_quill/flutter_quill.dart'
    show FlutterQuillLocalizations;
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'core/di/injection.dart';
import 'core/utils/l10n_extension.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/route_names.dart';
import 'core/widgets/app_shell.dart';
import 'core/theme/palettes.dart';
import 'features/settings/domain/entities/app_language.dart';
import 'features/settings/domain/entities/theme_settings.dart';
import 'features/settings/presentation/bloc/language_cubit.dart';
import 'l10n/gen/app_localizations.dart';
import 'features/settings/presentation/bloc/theme_cubit.dart';
import 'features/stock/presentation/bloc/materials_bloc.dart';

import 'features/today/presentation/pages/today_page.dart';
import 'features/today/presentation/pages/calendar_page.dart';
import 'features/orders/presentation/pages/orders_list_page.dart';
import 'features/orders/presentation/pages/new_order_page.dart';
import 'features/orders/presentation/pages/order_details_page.dart';
import 'features/orders/presentation/pages/receivables_page.dart';
import 'features/stock/presentation/pages/material_detail_page.dart';
import 'features/stock/presentation/pages/new_material_page.dart';
import 'features/stock/presentation/pages/receive_stock_page.dart';
import 'features/stock/presentation/pages/buy_list_page.dart';
import 'features/products/presentation/pages/inventory_page.dart';
import 'features/products/presentation/pages/product_detail_page.dart';
import 'features/products/presentation/pages/product_editor_page.dart';
import 'features/products/presentation/pages/receive_product_stock_page.dart';
import 'features/order_fields/presentation/pages/order_fields_page.dart';
import 'features/debug/presentation/pages/database_info_page.dart';
import 'features/products/presentation/pages/channels_page.dart';
import 'features/discounts/presentation/pages/discounts_page.dart';
import 'features/units/presentation/pages/units_page.dart';
import 'features/earnings/domain/entities/report_filter.dart';
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
    this.language,
    this.scaffoldMessengerKey,
  }) : _router = _buildRouter(initialLocation);

  final ThemeMode? themeMode;
  final AppPalette? palette;

  /// Fixes the language for tests and screenshots; null follows the saved one.
  final AppLanguage? language;

  /// Lets the app restarter show a message in a freshly rebuilt app.
  final GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;
  final GoRouter _router;

  @override
  Widget build(BuildContext context) {
    Widget app(ThemeSettings look, AppLanguage language) => MaterialApp.router(
          onGenerateTitle: (context) => context.l10n.appName,
          theme: AppTheme.light(look.palette),
          darkTheme: AppTheme.dark(look.palette),
          themeMode: look.mode,
          debugShowCheckedModeBanner: false,
          scaffoldMessengerKey: scaffoldMessengerKey,
          locale: language.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          // Quill looks its toolbar strings up through these; without them the
          // note editor throws while building.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FlutterQuillLocalizations.delegate,
          ],
          // Existing DateFormat calls read the default locale, so keep it in
          // step with the language the app resolved.
          builder: (context, child) {
            Intl.defaultLocale = Localizations.localeOf(context).toString();
            return child ?? const SizedBox.shrink();
          },
          routerConfig: _router,
        );

    final fixedMode = themeMode;
    final fixedPalette = palette;
    final fixedLanguage = language;
    if (fixedMode != null && fixedPalette != null && fixedLanguage != null) {
      return app(
          ThemeSettings(mode: fixedMode, palette: fixedPalette), fixedLanguage);
    }
    return BlocBuilder<LanguageCubit, AppLanguage>(
      bloc: getIt<LanguageCubit>(),
      builder: (context, savedLanguage) =>
          BlocBuilder<ThemeCubit, ThemeSettings>(
        bloc: getIt<ThemeCubit>(),
        builder: (context, saved) => app(
          ThemeSettings(
            mode: fixedMode ?? saved.mode,
            palette: fixedPalette ?? saved.palette,
          ),
          fixedLanguage ?? savedLanguage,
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
              // Materials is a tab of the Products page now.
              GoRoute(
                path: RouteNames.materials,
                redirect: (context, state) => RouteNames.materialsTab,
              ),
              GoRoute(
                path: RouteNames.reports,
                builder: (context, state) => const EarningsPage(),
              ),
              GoRoute(
                path: RouteNames.receivables,
                builder: (context, state) => const ReceivablesPage(),
              ),
              GoRoute(
                path: RouteNames.settings,
                builder: (context, state) => const SettingsPage(),
              ),
              GoRoute(
                path: RouteNames.about,
                builder: (context, state) => const AboutPage(),
              ),
              // Products and Materials share the Inventory tab; the buy list
              // keeps the bottom nav too.
              GoRoute(
                path: RouteNames.products,
                builder: (context, state) => InventoryPage(
                  initialTab:
                      InventoryTab.parse(state.uri.queryParameters['tab']),
                ),
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
            path: RouteNames.discounts,
            builder: (context, state) => const DiscountsPage(),
          ),
          GoRoute(
            path: RouteNames.units,
            builder: (context, state) => const UnitsPage(),
          ),
          // Debug tools, mounted only by the debug section on the More page.
          GoRoute(
            path: RouteNames.debugDatabase,
            builder: (context, state) => const DatabaseInfoPage(),
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
            path: RouteNames.productReport,
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
                // The report's filter rides along; a deep link has none.
                filter: state.extra is ReportFilter
                    ? state.extra as ReportFilter
                    : ReportFilter.none,
                startDate: at('start'),
                endDate: at('end'),
              );
            },
          ),
        ],
      );
}
