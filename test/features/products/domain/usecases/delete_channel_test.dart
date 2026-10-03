import 'package:craftbook/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/products/domain/repositories/channel_repository.dart';
import 'package:craftbook/features/products/domain/usecases/delete_channel.dart';

class MockChannelRepository extends Mock implements ChannelRepository {}

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late DeleteChannel deleteChannel;
  late MockChannelRepository mockChannelRepo;
  late MockOrderRepository mockOrderRepo;

  final orderWithChannel = Order(
    id: 1,
    customerName: 'Test',
    customerAddress: 'Addr',
    orderDate: DateTime(2026, 1, 1),
    shipByDate: DateTime(2026, 1, 5),
    status: OrderStatus.pending,
    channelId: 5,
    totalSales: 100,
    totalMaterialCost: 30,
    channelFees: 10,
    shippingCost: 0,
    profit: 60,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  final orderNoChannel = Order(
    id: 2,
    customerName: 'Test',
    customerAddress: 'Addr',
    orderDate: DateTime(2026, 1, 1),
    shipByDate: DateTime(2026, 1, 5),
    status: OrderStatus.pending,
    totalSales: 100,
    totalMaterialCost: 30,
    channelFees: 10,
    shippingCost: 0,
    profit: 60,
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockChannelRepo = MockChannelRepository();
    mockOrderRepo = MockOrderRepository();
    deleteChannel = DeleteChannel(
      channelRepository: mockChannelRepo,
      orderRepository: mockOrderRepo,
    );
  });

  group('DeleteChannel', () {
    test('deletes channel when no orders reference it', () async {
      when(() => mockOrderRepo.getAllOrders())
          .thenAnswer(
              (_) async => Success<List<Order>>([orderNoChannel]));
      when(() => mockChannelRepo.deleteChannel(5))
          .thenAnswer((_) async => const Success<void>(null));

      final result = await deleteChannel(5);

      expect(result, isA<Success<void>>());
      verify(() => mockChannelRepo.deleteChannel(5)).called(1);
    });

    test('blocks deletion when orders reference the channel', () async {
      when(() => mockOrderRepo.getAllOrders()).thenAnswer(
          (_) async => Success<List<Order>>([orderWithChannel]));

      final result = await deleteChannel(5);

      expect(result, isA<Error<void>>());
      switch (result) {
        case Error(:final failure):
          expect(failure, isA<ValidationFailure>());
          expect(failure.message, contains('order'));
        case Success():
          fail('Should return error');
      }
      verifyNever(() => mockChannelRepo.deleteChannel(any()));
    });

    test('deletes channel when no orders exist at all', () async {
      when(() => mockOrderRepo.getAllOrders())
          .thenAnswer((_) async => const Success<List<Order>>([]));
      when(() => mockChannelRepo.deleteChannel(5))
          .thenAnswer((_) async => const Success<void>(null));

      final result = await deleteChannel(5);

      expect(result, isA<Success<void>>());
      verify(() => mockChannelRepo.deleteChannel(5)).called(1);
    });
  });
}
