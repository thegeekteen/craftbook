import 'package:dartz/dartz.dart' hide Order;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_item.dart';
import 'package:craftbook/features/orders/domain/entities/order_material.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/get_orders.dart';
import 'package:craftbook/features/orders/domain/usecases/ship_order.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late GetOrders getOrders;
  late ShipOrder shipOrder;
  late MockOrderRepository mockRepository;

  final testOrder = Order(
    id: 1,
    customerName: 'Jessa Ramos',
    customerAddress: 'Cebu City',
    orderDate: DateTime(2026, 8, 26),
    shipByDate: DateTime(2026, 8, 28),
    status: OrderStatus.pending,
    channelId: 1,
    totalSales: 647.0,
    totalMaterialCost: 94.30,
    channelFees: 51.76,
    shippingCost: 0.0,
    profit: 500.94,
    createdAt: DateTime(2026, 8, 26),
    updatedAt: DateTime(2026, 8, 26),
  );

  setUp(() {
    mockRepository = MockOrderRepository();
    getOrders = GetOrders(mockRepository);
    shipOrder = ShipOrder(mockRepository);
  });

  group('GetOrders', () {
    test('returns all orders when no status filter', () async {
      when(() => mockRepository.getAllOrders())
          .thenAnswer((_) async => Right<Failure, List<Order>>([testOrder]));

      final result = await getOrders();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return left'),
        (orders) => expect(orders, [testOrder]),
      );
      verify(() => mockRepository.getAllOrders()).called(1);
    });

    test('returns filtered orders by status', () async {
      when(() => mockRepository.getOrdersByStatus(OrderStatus.pending))
          .thenAnswer((_) async => Right<Failure, List<Order>>([testOrder]));

      final result = await getOrders(status: OrderStatus.pending);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return left'),
        (orders) => expect(orders, [testOrder]),
      );
      verify(() => mockRepository.getOrdersByStatus(OrderStatus.pending)).called(1);
    });

    test('returns failure on repository error', () async {
      when(() => mockRepository.getAllOrders())
          .thenAnswer((_) async => Left(const DatabaseFailure('error')));

      final result = await getOrders();

      expect(result, isA<Left>());
    });
  });

  group('ShipOrder', () {
    test('ships order successfully', () async {
      when(() => mockRepository.shipOrder(1))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await shipOrder(1);

      expect(result, const Right<Failure, void>(null));
      verify(() => mockRepository.shipOrder(1)).called(1);
    });
  });
}
