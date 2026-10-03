import 'package:get_it/get_it.dart';

import '../../database/app_database.dart';
import '../../database/daos/channel_dao.dart';
import '../../database/daos/earnings_dao.dart';
import '../../database/daos/material_dao.dart';
import '../../database/daos/order_dao.dart';
import '../../database/daos/product_dao.dart';

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
import '../../features/orders/domain/usecases/adjust_materials_used.dart';
import '../../features/orders/domain/usecases/update_order.dart';
import '../../features/orders/domain/usecases/calculate_order_profit.dart';
import '../../features/orders/domain/usecases/delete_order.dart';
import '../../features/orders/domain/usecases/get_order_list_entries.dart';
import '../../features/orders/domain/usecases/preview_order.dart';

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

final getIt = GetIt.instance;

/// Registers everything. Tests pass an in-memory [database].
Future<void> configureDependencies({AppDatabase? database}) async {
  final db = database ?? AppDatabase();

  // Database
  getIt.registerSingleton<AppDatabase>(db);

  // DAOs
  getIt.registerSingleton(OrderDao(db));
  getIt.registerSingleton(MaterialDao(db));
  getIt.registerSingleton(ProductDao(db));
  getIt.registerSingleton(ChannelDao(db));
  getIt.registerSingleton(EarningsDao(db));

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
  getIt.registerLazySingleton<EarningsRepository>(
    () => EarningsRepositoryImpl(getIt<EarningsDao>()),
  );

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
  ));
  getIt.registerFactory(() => TodayBloc(getTodayDashboard: getIt()));
  getIt.registerFactory(() => EarningsBloc(
    getEarningsSummary: getIt(),
    getProductEarnings: getIt(),
    getWasteSummary: getIt(),
    getProfitTrend: getIt(),
  ));
}
