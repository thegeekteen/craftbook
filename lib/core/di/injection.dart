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
import '../../features/products/domain/usecases/delete_product.dart';
import '../../features/products/domain/usecases/delete_channel.dart';
import '../../features/products/domain/usecases/calculate_bom_cost.dart';
import '../../features/products/domain/usecases/calculate_buildable_quantity.dart';
import '../../features/products/domain/usecases/receive_product_stock.dart';
import '../../features/products/domain/usecases/adjust_product_stock.dart';
import '../../features/products/domain/usecases/get_product_history.dart';

import '../../features/stock/data/repositories/material_repository_impl.dart';
import '../../features/stock/domain/repositories/material_repository.dart';
import '../../features/stock/domain/usecases/get_materials.dart';
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
import '../../features/orders/domain/usecases/update_order_note.dart';
import '../../features/orders/domain/usecases/adjust_materials_used.dart';
import '../../features/orders/domain/usecases/update_order.dart';
import '../../features/orders/domain/usecases/calculate_order_profit.dart';
import '../../features/orders/domain/usecases/delete_order.dart';
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
  getIt.registerLazySingleton<LinkLauncher>(() => const LinkLauncher());

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
  getIt.registerLazySingleton<SocialLinkRepository>(
    () => SocialLinkRepositoryImpl(getIt<SocialLinkDao>()),
  );
  getIt.registerLazySingleton<EarningsRepository>(
    () => EarningsRepositoryImpl(getIt<EarningsDao>()),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(getIt<AppDatabase>()),
  );

  // Use Cases - Order fields
  getIt.registerFactory(() => GetOrderFields(getIt()));
  getIt.registerFactory(() => SaveOrderField(getIt()));
  getIt.registerFactory(() => RemoveOrderField(getIt()));
  getIt.registerFactory(() => RestoreOrderField(getIt()));
  getIt.registerFactory(() => ReorderOrderFields(getIt()));

  // Use Cases - Social links
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

  // Use Cases - Products
  getIt.registerFactory(() => GetChannels(getIt()));
  getIt.registerFactory(() => UpdateChannel(getIt()));
  getIt.registerFactory(() => GetProducts(getIt()));
  getIt.registerFactory(() => CreateProduct(getIt()));
  getIt.registerFactory(() => UpdateProduct(getIt()));
  getIt.registerFactory(() => CalculateBomCost(getIt()));
  getIt.registerFactory(() => CalculateBuildableQuantity(getIt()));
  getIt.registerFactory(() => DeleteProduct(productRepository: getIt()));
  getIt.registerFactory(() => ReceiveProductStock(getIt()));
  getIt.registerFactory(() => AdjustProductStock(getIt()));
  getIt.registerFactory(() => GetProductHistory(getIt()));
  getIt.registerFactory(() => DeleteChannel(
        channelRepository: getIt(),
        orderRepository: getIt(),
      ));

  // Use Cases - Stock
  getIt.registerFactory(() => GetMaterials(getIt()));
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
  getIt.registerFactory(() => AdjustMaterialsUsed(getIt()));
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
  getIt.registerFactory(() => DeleteOrder(
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
  getIt.registerFactory(() => GetAlertSummary(getIt()));
  getIt.registerFactory(() => GetTodayDashboard(
        orderRepository: getIt(),
        earningsRepository: getIt(),
        getAlertSummary: getIt(),
        getOrderListEntries: getIt(),
      ));

  // BLoCs
  getIt.registerFactory(() => ProductsBloc(
        getProducts: getIt(),
        createProduct: getIt(),
        updateProduct: getIt(),
        deleteProduct: getIt(),
        calculateBomCost: getIt(),
        calculateBuildableQuantity: getIt(),
      ));
  getIt.registerFactory(() => OrderFieldsBloc(
        getOrderFields: getIt(),
        saveOrderField: getIt(),
        removeOrderField: getIt(),
        restoreOrderField: getIt(),
        reorderOrderFields: getIt(),
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
      ));
  getIt.registerFactory(() => OrderDetailBloc(
        orderRepository: getIt(),
        channelRepository: getIt(),
        materialRepository: getIt(),
        productRepository: getIt(),
        adjustMaterialsUsed: getIt(),
        packOrder: getIt(),
        shipOrder: getIt(),
        deleteOrder: getIt(),
        updateOrderNote: getIt(),
      ));
  // App-wide: lives above the router, so a singleton.
  getIt.registerSingleton(ThemeCubit(getIt()),
      dispose: (cubit) => cubit.close());
  getIt.registerSingleton(OrderAmountCubit(getIt()),
      dispose: (cubit) => cubit.close());
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
