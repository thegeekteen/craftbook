import 'package:dartz/dartz.dart' hide Order;
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
              (_) async => Right<Failure, List<Order>>([orderNoChannel]));
      when(() => mockChannelRepo.deleteChannel(5))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await deleteChannel(5);

      expect(result.isRight(), true);
      verify(() => mockChannelRepo.deleteChannel(5)).called(1);
    });

    test('blocks deletion when orders reference the channel', () async {
      when(() => mockOrderRepo.getAllOrders()).thenAnswer(
          (_) async => Right<Failure, List<Order>>([orderWithChannel]));

      final result = await deleteChannel(5);

      expect(result.isLeft(), true);
      result.fold(
        (f) {
          expect(f, isA<ValidationFailure>());
          expect(f.message, contains('order'));
        },
        (_) => fail('Should return left'),
      );
      verifyNever(() => mockChannelRepo.deleteChannel(any()));
    });

    test('deletes channel when no orders exist at all', () async {
      when(() => mockOrderRepo.getAllOrders())
          .thenAnswer((_) async => Right<Failure, List<Order>>([]));
      when(() => mockChannelRepo.deleteChannel(5))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await deleteChannel(5);

      expect(result.isRight(), true);
      verify(() => mockChannelRepo.deleteChannel(5)).called(1);
    });
  });
}
