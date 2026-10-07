import 'package:get_it/get_it.dart';

import '../../database/app_database.dart';
import '../services/backup_store.dart';
import '../../database/daos/channel_dao.dart';
import '../../database/daos/earnings_dao.dart';
import '../../database/daos/material_dao.dart';
import '../../database/daos/order_dao.dart';
import '../../database/daos/product_dao.dart';

import '../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../features/settings/domain/repositories/settings_repository.dart';
import '../../features/settings/presentation/bloc/currency_cubit.dart';
import '../../features/settings/presentation/bloc/tax_settings_cubit.dart';
import '../../database/daos/discount_preset_dao.dart';
import '../../features/discounts/data/repositories/discount_preset_repository_impl.dart';
import '../../features/discounts/domain/repositories/discount_preset_repository.dart';
import '../../features/discounts/domain/usecases/discount_preset_usecases.dart';
import '../../features/discounts/presentation/bloc/discount_presets_bloc.dart';
import '../../database/daos/unit_dao.dart';
import '../../features/units/data/repositories/unit_repository_impl.dart';
import '../../features/units/domain/repositories/unit_repository.dart';
import '../../features/units/domain/usecases/unit_usecases.dart';
import '../../features/units/presentation/bloc/units_bloc.dart';
import '../../features/settings/presentation/bloc/language_cubit.dart';
import '../../features/settings/presentation/bloc/order_amount_cubit.dart';
import '../../features/settings/presentation/bloc/theme_cubit.dart';
import '../../features/products/data/repositories/channel_repository_impl.dart';
import '../../features/products/data/repositories/product_repository_impl.dart';
import '../../features/products/domain/repositories/channel_repository.dart';
import '../../features/products/domain/repositories/product_repository.dart';
import '../../features/products/domain/usecases/get_channels.dart';
import '../../features/products/domain/usecases/update_channel.dart';
import '../../features/products/domain/usecases/get_products.dart';
import '../../features/products/domain/usecases/create_product.dart';
import '../../features/products/domain/usecases/update_product.dart';
import '../../features/products/domain/usecases/set_product_photo.dart';
import '../../features/products/domain/usecases/delete_product.dart';
import '../../features/products/domain/usecases/delete_channel.dart';
import '../../features/products/domain/usecases/calculate_bom_cost.dart';
import '../../features/products/domain/usecases/calculate_buildable_quantity.dart';
import '../../features/products/domain/usecases/receive_product_stock.dart';
import '../../features/products/domain/usecases/adjust_product_stock.dart';
import '../../features/products/domain/usecases/get_product_history.dart';
import '../../features/products/domain/usecases/get_low_stock_products.dart';
import '../../features/products/domain/usecases/get_pending_order_counts.dart';

import '../../features/stock/data/repositories/material_repository_impl.dart';
import '../../features/stock/domain/repositories/material_repository.dart';
import '../../features/stock/domain/usecases/get_materials.dart';
import '../../features/stock/domain/usecases/set_material_archived.dart';
import '../../features/stock/domain/usecases/get_material_detail.dart';
import '../../features/stock/domain/usecases/receive_stock.dart';
import '../../features/stock/domain/usecases/adjust_stock.dart';
import '../../features/stock/domain/usecases/get_buy_list.dart';
import '../../features/stock/domain/usecases/get_blocked_products.dart';
import '../../features/stock/domain/usecases/delete_material.dart';
import '../../features/stock/domain/usecases/update_material.dart';

import '../../features/orders/data/repositories/order_repository_impl.dart';
import '../../features/orders/domain/repositories/order_repository.dart';
import '../../features/orders/domain/usecases/get_orders.dart';
import '../../features/orders/domain/usecases/create_order.dart';
import '../../features/orders/domain/usecases/pack_order.dart';
import '../../features/orders/domain/usecases/ship_order.dart';
import '../../features/orders/domain/usecases/get_receivables.dart';
import '../../features/orders/domain/usecases/set_order_paid.dart';
import '../../features/orders/presentation/bloc/receivables_cubit.dart';
import '../../features/orders/domain/usecases/update_order_note.dart';
import '../../features/orders/domain/usecases/adjust_materials_used.dart';
import '../../features/orders/domain/usecases/update_order.dart';
import '../../features/orders/domain/usecases/calculate_order_profit.dart';
import '../../features/orders/domain/usecases/cancel_order.dart';
import '../../features/orders/domain/usecases/restore_order.dart';
import '../../features/orders/domain/usecases/delete_order.dart';
import '../../features/orders/domain/usecases/return_order_stock.dart';
import '../../features/orders/domain/usecases/get_order_list_entries.dart';
import '../../features/orders/domain/usecases/preview_order.dart';

import '../../database/daos/social_link_dao.dart';
import '../../features/social_links/data/repositories/social_link_repository_impl.dart';
import '../../features/social_links/domain/repositories/social_link_repository.dart';
import '../../features/social_links/domain/usecases/delete_social_link.dart';
import '../../features/social_links/domain/usecases/get_social_links.dart';
import '../../features/social_links/domain/usecases/reorder_social_links.dart';
import '../../features/social_links/domain/usecases/save_social_link.dart';
import '../../features/social_links/presentation/bloc/social_links_bloc.dart';
import '../services/link_launcher.dart';
import '../services/photo_picker.dart';
import '../../features/earnings/data/repositories/earnings_repository_impl.dart';
import '../../features/earnings/domain/repositories/earnings_repository.dart';
import '../../features/earnings/domain/usecases/get_earnings_summary.dart';
import '../../features/earnings/domain/usecases/get_product_earnings.dart';
import '../../features/earnings/domain/usecases/get_waste_summary.dart';
import '../../features/earnings/domain/usecases/get_profit_trend.dart';
import '../../features/earnings/domain/usecases/get_product_order_lines.dart';

import '../../features/today/domain/usecases/get_alert_summary.dart';
import '../../features/today/domain/usecases/get_today_dashboard.dart';

import '../../features/products/presentation/bloc/products_bloc.dart';
import '../../features/products/presentation/bloc/channels_bloc.dart';
import '../../features/stock/presentation/bloc/materials_bloc.dart';
import '../../features/orders/presentation/bloc/orders_list_bloc.dart';
import '../../features/orders/presentation/bloc/new_order_bloc.dart';
import '../../features/orders/presentation/bloc/order_detail_bloc.dart';
import '../../features/today/presentation/bloc/today_bloc.dart';
import '../../features/earnings/presentation/bloc/earnings_bloc.dart';
import '../../database/daos/order_field_dao.dart';
import '../../features/order_fields/data/repositories/order_field_repository_impl.dart';
import '../../features/order_fields/domain/repositories/order_field_repository.dart';
import '../../features/order_fields/domain/usecases/get_order_fields.dart';
import '../../features/order_fields/domain/usecases/remove_order_field.dart';
import '../../features/order_fields/domain/usecases/reorder_order_fields.dart';
import '../../features/order_fields/domain/usecases/restore_order_field.dart';
import '../../features/order_fields/domain/usecases/save_order_field.dart';
import '../../features/order_fields/presentation/bloc/order_fields_bloc.dart';
import '../../database/daos/note_dao.dart';
import '../../features/notes/data/repositories/note_repository_impl.dart';
import '../../features/notes/domain/repositories/note_repository.dart';
import '../../features/notes/domain/usecases/delete_note.dart';
import '../../features/notes/domain/usecases/get_note.dart';
import '../../features/notes/domain/usecases/get_notes.dart';
import '../../features/notes/domain/usecases/get_pinned_notes.dart';
import '../../features/notes/domain/usecases/restore_note.dart';
import '../../features/notes/domain/usecases/save_note.dart';
import '../../features/notes/domain/usecases/set_note_pinned.dart';
import '../../features/notes/presentation/bloc/note_edit_cubit.dart';
import '../../features/notes/presentation/bloc/notes_bloc.dart';
import '../../features/updates/data/repositories/github_update_repository.dart';
import '../../features/updates/domain/repositories/update_repository.dart';
import '../../features/updates/domain/usecases/check_for_update.dart';
import '../../features/updates/domain/usecases/install_update.dart';
import '../../features/updates/presentation/bloc/update_cubit.dart';
import '../../features/debug/data/repositories/shop_data_repository_impl.dart';
import '../../features/debug/domain/repositories/shop_data_repository.dart';
import '../../features/debug/domain/usecases/clear_shop_data.dart';
import '../../features/debug/domain/usecases/get_coverage_report.dart';
import '../../features/debug/domain/usecases/get_database_info.dart';
import '../../features/debug/domain/usecases/seed_fake_shop.dart';
import '../../features/debug/presentation/bloc/debug_cubit.dart';

final getIt = GetIt.instance;

/// Registers everything. Tests pass an in-memory [database].
Future<void> configureDependencies({AppDatabase? database}) async {
  final db = database ?? AppDatabase();

  // Database
  getIt.registerSingleton<AppDatabase>(db);

  getIt.registerLazySingleton(() => BackupStore());

  // DAOs
  getIt.registerSingleton(OrderDao(db));
  getIt.registerSingleton(MaterialDao(db));
  getIt.registerSingleton(ProductDao(db));
  getIt.registerSingleton(ChannelDao(db));
  getIt.registerSingleton(EarningsDao(db));
  getIt.registerSingleton(OrderFieldDao(db));
  getIt.registerSingleton(NoteDao(db));
  getIt.registerSingleton(SocialLinkDao(db));
  getIt.registerSingleton(DiscountPresetDao(db));
  getIt.registerSingleton(UnitDao(db));
  getIt.registerLazySingleton<LinkLauncher>(() => const LinkLauncher());
  getIt.registerLazySingleton<PhotoPicker>(() => PhotoPicker());

  // Repositories
  getIt.registerLazySingleton<ChannelRepository>(
    () => ChannelRepositoryImpl(getIt<ChannelDao>()),
  );
  getIt.registerLazySingleton<ProductRepository>(
    () => ProductRepositoryImpl(getIt<ProductDao>()),
  );
  getIt.registerLazySingleton<MaterialRepository>(
    () => MaterialRepositoryImpl(getIt<MaterialDao>(), getIt<ProductDao>()),
  );
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(getIt<OrderDao>()),
  );
  getIt.registerLazySingleton<OrderFieldRepository>(
    () => OrderFieldRepositoryImpl(getIt<OrderFieldDao>()),
  );
  getIt.registerLazySingleton<NoteRepository>(
    () => NoteRepositoryImpl(getIt<NoteDao>()),
  );
  getIt.registerLazySingleton<DiscountPresetRepository>(
    () => DiscountPresetRepositoryImpl(getIt<DiscountPresetDao>()),
  );
  getIt.registerLazySingleton<UnitRepository>(
    () => UnitRepositoryImpl(getIt<UnitDao>()),
  );
  getIt.registerLazySingleton<SocialLinkRepository>(
    () => SocialLinkRepositoryImpl(getIt<SocialLinkDao>()),
  );
  getIt.registerLazySingleton<EarningsRepository>(
    () => EarningsRepositoryImpl(getIt<EarningsDao>()),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<UpdateRepository>(
    () => GithubUpdateRepository(),
  );

  // Use Cases - Order fields
  getIt.registerFactory(() => GetOrderFields(getIt()));
  getIt.registerFactory(() => SaveOrderField(getIt()));
  getIt.registerFactory(() => RemoveOrderField(getIt()));
  getIt.registerFactory(() => RestoreOrderField(getIt()));
  getIt.registerFactory(() => ReorderOrderFields(getIt()));

  // Use Cases - Social links
  getIt.registerFactory(() => GetDiscountPresets(getIt()));
  getIt.registerFactory(() => SaveDiscountPreset(getIt()));
  getIt.registerFactory(() => DeleteDiscountPreset(getIt()));
  getIt.registerFactory(() => ReorderDiscountPresets(getIt()));

  // Use Cases - Units of measure
  getIt.registerFactory(() => GetUnits(getIt()));
  getIt.registerFactory(() => GetDefaultUnit(getIt()));
  getIt.registerFactory(() => SaveUnit(getIt()));
  getIt.registerFactory(() => DeleteUnit(getIt()));
  getIt.registerFactory(() => ReorderUnits(getIt()));
  getIt.registerFactory(() => SetDefaultUnit(getIt()));
  getIt.registerFactory(() => GetSocialLinks(getIt()));
  getIt.registerFactory(() => SaveSocialLink(getIt()));
  getIt.registerFactory(() => DeleteSocialLink(getIt()));
  getIt.registerFactory(() => ReorderSocialLinks(getIt()));

  // Use Cases - Notes
  getIt.registerFactory(() => GetNotes(getIt()));
  getIt.registerFactory(() => GetPinnedNotes(getIt()));
  getIt.registerFactory(() => GetNote(getIt()));
  getIt.registerFactory(() => SaveNote(getIt()));
  getIt.registerFactory(() => SetNotePinned(getIt()));
  getIt.registerFactory(() => DeleteNote(getIt()));
  getIt.registerFactory(() => RestoreNote(getIt()));

  // Use Cases - Updates
  getIt.registerFactory(() => CheckForUpdate(getIt()));
  getIt.registerFactory(() => InstallUpdate(getIt()));

  // Use Cases - Products
  getIt.registerFactory(() => GetChannels(getIt()));
  getIt.registerFactory(() => UpdateChannel(getIt()));
  getIt.registerFactory(() => GetProducts(getIt()));
  getIt.registerFactory(() => CreateProduct(getIt()));
  getIt.registerFactory(() => UpdateProduct(getIt()));
  getIt.registerFactory(() => SetProductPhoto(getIt()));
  getIt.registerFactory(() => CalculateBomCost(getIt()));
  getIt.registerFactory(() => CalculateBuildableQuantity(getIt()));
  getIt.registerFactory(() => DeleteProduct(productRepository: getIt()));
  getIt.registerFactory(() => ReceiveProductStock(getIt()));
  getIt.registerFactory(() => AdjustProductStock(getIt()));
  getIt.registerFactory(() => GetProductHistory(getIt()));
  getIt.registerFactory(() => GetLowStockProducts(getIt()));
  getIt.registerFactory(() => GetPendingOrderCounts(getIt()));
  getIt.registerFactory(() => DeleteChannel(
        channelRepository: getIt(),
        orderRepository: getIt(),
      ));

  // Use Cases - Stock
  getIt.registerFactory(() => GetMaterials(getIt()));
  getIt.registerFactory(() => SetMaterialArchived(getIt()));
  getIt.registerFactory(() => GetMaterialDetail(getIt()));
  getIt.registerFactory(() => UpdateMaterial(getIt()));
  getIt.registerFactory(() => ReceiveStock(getIt()));
  getIt.registerFactory(() => AdjustStock(getIt()));
  getIt.registerFactory(() => GetBuyList(getIt()));
  getIt.registerFactory(() => GetBlockedProducts(getIt()));
  getIt.registerFactory(() => DeleteMaterial(
        materialRepository: getIt(),
        productRepository: getIt(),
      ));

  // Use Cases - Orders
  getIt.registerFactory(() => GetOrders(getIt()));
  getIt.registerFactory(() => CreateOrder(
        orderRepository: getIt(),
        productRepository: getIt(),
        materialRepository: getIt(),
      ));
  getIt.registerFactory(() => PackOrder(
        orderRepository: getIt(),
        materialRepository: getIt(),
        productRepository: getIt(),
      ));
  getIt.registerFactory(() => ShipOrder(getIt()));
  getIt.registerFactory(() => UpdateOrderNote(getIt()));
  getIt.registerFactory(() => SetOrderPaid(getIt()));
  getIt.registerFactory(() => GetReceivables(
        orderRepository: getIt(),
        getOrderListEntries: getIt(),
      ));
  getIt.registerFactory(() => AdjustMaterialsUsed(getIt(), getIt()));
  getIt.registerFactory(() => CalculateOrderProfit(getIt()));
  getIt.registerFactory(() => PreviewOrder(
        productRepository: getIt(),
        materialRepository: getIt(),
        calculateOrderProfit: getIt(),
        orderRepository: getIt(),
      ));
  getIt.registerFactory(() => UpdateOrder(
        orderRepository: getIt(),
        productRepository: getIt(),
        materialRepository: getIt(),
        calculateOrderProfit: getIt(),
      ));
  getIt.registerFactory(() => GetOrderListEntries(
        orderRepository: getIt(),
        channelRepository: getIt(),
      ));
  getIt.registerFactory(() => ReturnOrderStock(
        orderRepository: getIt(),
        materialRepository: getIt(),
        productRepository: getIt(),
      ));
  getIt.registerFactory(() => DeleteOrder(
        orderRepository: getIt(),
        returnOrderStock: getIt(),
      ));
  getIt.registerFactory(() => CancelOrder(
        orderRepository: getIt(),
        returnOrderStock: getIt(),
      ));
  getIt.registerFactory(() => RestoreOrder(
        orderRepository: getIt(),
        materialRepository: getIt(),
        productRepository: getIt(),
      ));

  // Use Cases - Earnings
  getIt.registerFactory(() => GetEarningsSummary(getIt()));
  getIt.registerFactory(() => GetProductEarnings(getIt()));
  getIt.registerFactory(() => GetWasteSummary(getIt()));
  getIt.registerFactory(() => GetProfitTrend(getIt()));
  getIt.registerFactory(() => GetProductOrderLines(getIt()));

  // Use Cases - Today
  getIt.registerFactory(() => GetAlertSummary(getIt(), getIt()));
  getIt.registerFactory(() => GetTodayDashboard(
        orderRepository: getIt(),
        earningsRepository: getIt(),
        getAlertSummary: getIt(),
        getOrderListEntries: getIt(),
      ));

  // Debug tools. The fake-data seeder drives the app's own write path, so it is
  // handed the same use cases the pages are; only the timestamps it has to
  // backdate go through ShopDataRepository.
  getIt.registerLazySingleton<ShopDataRepository>(
    () => ShopDataRepositoryImpl(getIt<AppDatabase>()),
  );
  getIt.registerFactory(() => GetCoverageReport(
        orders: getIt(),
        materials: getIt(),
        products: getIt(),
        channels: getIt(),
        fields: getIt(),
        notes: getIt(),
        links: getIt(),
        presets: getIt(),
        settings: getIt(),
        getBuyList: getIt(),
      ));
  getIt.registerFactory(() => SeedFakeShop(
        shopData: getIt(),
        settings: getIt(),
        units: getIt(),
        channels: getIt(),
        materials: getIt(),
        products: getIt(),
        fields: getIt(),
        notes: getIt(),
        links: getIt(),
        orders: getIt(),
        savePreset: getIt(),
        createOrder: getIt(),
        packOrder: getIt(),
        shipOrder: getIt(),
        cancelOrder: getIt(),
        restoreOrder: getIt(),
        adjustMaterialsUsed: getIt(),
        setOrderPaid: getIt(),
        getBuyList: getIt(),
        coverage: getIt(),
      ));
  getIt.registerFactory(() => ClearShopData(getIt()));
  getIt.registerFactory(
      () => GetDatabaseInfo(shopData: getIt(), coverage: getIt()));

  // BLoCs
  getIt.registerFactory(() => ProductsBloc(
        getProducts: getIt(),
        createProduct: getIt(),
        updateProduct: getIt(),
        deleteProduct: getIt(),
        calculateBomCost: getIt(),
        calculateBuildableQuantity: getIt(),
        getPendingOrderCounts: getIt(),
      ));
  getIt.registerFactory(() => OrderFieldsBloc(
        getOrderFields: getIt(),
        saveOrderField: getIt(),
        removeOrderField: getIt(),
        restoreOrderField: getIt(),
        reorderOrderFields: getIt(),
      ));
  getIt.registerFactory(() => ReceivablesCubit(getIt()));
  getIt.registerFactory(() => DiscountPresetsBloc(
        getPresets: getIt(),
        savePreset: getIt(),
        deletePreset: getIt(),
        reorderPresets: getIt(),
      ));
  getIt.registerFactory(() => UnitsBloc(
        getUnits: getIt(),
        saveUnit: getIt(),
        deleteUnit: getIt(),
        reorderUnits: getIt(),
        setDefaultUnit: getIt(),
      ));
  getIt.registerFactory(() => SocialLinksBloc(
        getSocialLinks: getIt(),
        saveSocialLink: getIt(),
        deleteSocialLink: getIt(),
        reorderSocialLinks: getIt(),
      ));
  getIt.registerFactory(() => NotesBloc(
        getNotes: getIt(),
        setNotePinned: getIt(),
        deleteNote: getIt(),
        restoreNote: getIt(),
      ));
  getIt.registerFactory(() => NoteEditCubit(
        getNote: getIt(),
        saveNote: getIt(),
        deleteNote: getIt(),
      ));
  getIt.registerFactory(() => ChannelsBloc(
        getChannels: getIt(),
        updateChannel: getIt(),
        deleteChannel: getIt(),
        channelRepository: getIt(),
      ));
  getIt.registerFactory(() => MaterialsBloc(
        getMaterials: getIt(),
        getBuyList: getIt(),
        receiveStock: getIt(),
        deleteMaterial: getIt(),
        updateMaterial: getIt(),
        materialRepository: getIt(),
        getLowStockProducts: getIt(),
      ));
  getIt.registerFactory(() => OrdersListBloc(
        getOrders: getIt(),
        getOrderListEntries: getIt(),
      ));
  getIt.registerFactory(() => NewOrderBloc(
        createOrder: getIt(),
        updateOrder: getIt(),
        orderRepository: getIt(),
        calculateOrderProfit: getIt(),
        previewOrder: getIt(),
        taxSettings: () => getIt<TaxSettingsCubit>().state,
      ));
  getIt.registerFactory(() => OrderDetailBloc(
        orderRepository: getIt(),
        channelRepository: getIt(),
        materialRepository: getIt(),
        productRepository: getIt(),
        adjustMaterialsUsed: getIt(),
        packOrder: getIt(),
        shipOrder: getIt(),
        cancelOrder: getIt(),
        restoreOrder: getIt(),
        deleteOrder: getIt(),
        updateOrderNote: getIt(),
        setOrderPaid: getIt(),
      ));
  // App-wide: lives above the router, so a singleton.
  getIt.registerSingleton(ThemeCubit(getIt()),
      dispose: (cubit) => cubit.close());
  getIt.registerSingleton(LanguageCubit(getIt()),
      dispose: (cubit) => cubit.close());
  getIt.registerSingleton(OrderAmountCubit(getIt()),
      dispose: (cubit) => cubit.close());
  getIt.registerSingleton(CurrencyCubit(getIt()),
      dispose: (cubit) => cubit.close());
  getIt.registerSingleton(TaxSettingsCubit(getIt()),
      dispose: (cubit) => cubit.close());
  getIt.registerFactory(() => UpdateCubit(
        repository: getIt(),
        checkForUpdate: getIt(),
        installUpdate: getIt(),
      ));
  getIt.registerFactory(() => DebugCubit(
        seedFakeShop: getIt(),
        clearShopData: getIt(),
        getDatabaseInfo: getIt(),
      ));
  getIt.registerFactory(() => TodayBloc(
        getTodayDashboard: getIt(),
        getPinnedNotes: getIt(),
      ));
  getIt.registerFactory(() => EarningsBloc(
        getEarningsSummary: getIt(),
        getProductEarnings: getIt(),
        getWasteSummary: getIt(),
        getProfitTrend: getIt(),
      ));
}
