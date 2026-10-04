import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/orders/domain/entities/order.dart';
import 'package:craftbook/features/orders/domain/entities/order_list_entry.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/get_order_list_entries.dart';
import 'package:craftbook/features/products/domain/entities/channel.dart';
import 'package:craftbook/features/products/domain/repositories/channel_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

class MockChannelRepository extends Mock implements ChannelRepository {}

void main() {
  late MockOrderRepository orders;
  late MockChannelRepository channels;
  late GetOrderListEntries useCase;
  final now = DateTime(2026, 10, 4);

  Order order(int id, {int? channelId}) => Order(
        id: id,
        customerName: 'C$id',
        orderDate: now,
        shipByDate: now,
        status: OrderStatus.pending,
        channelId: channelId,
        totalSales: 100,
        totalMaterialCost: 10,
        channelFees: 5,
        shippingCost: 0,
        profit: 85,
        createdAt: now,
        updatedAt: now,
      );

  setUp(() {
    orders = MockOrderRepository();
    channels = MockChannelRepository();
    useCase = GetOrderListEntries(
        orderRepository: orders, channelRepository: channels);
  });

  test('joins channel names and product lines', () async {
    when(() => orders.getOrderLines([1, 2]))
        .thenAnswer((_) async => const Success({
              1: [
                OrderLine(productName: 'Tulip', quantity: 2),
                OrderLine(productName: 'Box', quantity: 1)
              ],
            }));
    when(() => channels.getAllChannels()).thenAnswer((_) async => Success([
          Channel(
            id: 7,
            name: 'Shopee',
            commissionRate: 0,
            transactionFeeRate: 0,
            flatFee: 0,
            shippingPaidByUs: 0,
            isActive: true,
            createdAt: now,
          ),
        ]));

    final result = await useCase([order(1, channelId: 7), order(2)]);

    final entries = (result as Success<List<OrderListEntry>>).value;
    expect(entries[0].channelName, 'Shopee');
    expect(entries[0].itemSummary, '2× Tulip · 1× Box');
    expect(entries[0].pieceCount, 3);
    expect(entries[1].channelName, isNull);
    expect(entries[1].lines, isEmpty);
  });

  test('empty input skips the database', () async {
    final result = await useCase(const []);
    expect(result, const Success<List<OrderListEntry>>([]));
    verifyZeroInteractions(orders);
    verifyZeroInteractions(channels);
  });

  test('passes failures through', () async {
    when(() => orders.getOrderLines(any()))
        .thenAnswer((_) async => const Error(DatabaseFailure('x')));
    final result = await useCase([order(1)]);
    expect(result, isA<Error<List<OrderListEntry>>>());
  });
}
