import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/features/products/domain/entities/channel.dart';
import 'package:craftbook/features/products/domain/repositories/channel_repository.dart';
import 'package:craftbook/features/products/domain/usecases/get_channels.dart';
import 'package:craftbook/features/products/domain/usecases/update_channel.dart';

class MockChannelRepository extends Mock implements ChannelRepository {}

void main() {
  late GetChannels getChannels;
  late UpdateChannel updateChannel;
  late MockChannelRepository mockRepository;

  final testChannel = Channel(
    id: 1,
    name: 'Shopee',
    commissionRate: 6.0,
    transactionFeeRate: 2.0,
    flatFee: 0.0,
    shippingPaidByUs: 0.0,
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    mockRepository = MockChannelRepository();
    getChannels = GetChannels(mockRepository);
    updateChannel = UpdateChannel(mockRepository);
  });

  group('GetChannels', () {
    test('returns all channels when activeOnly is false', () async {
      when(() => mockRepository.getAllChannels())
          .thenAnswer((_) async => Right<Failure, List<Channel>>([testChannel]));

      final result = await getChannels();

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return left'),
        (channels) => expect(channels, [testChannel]),
      );
      verify(() => mockRepository.getAllChannels()).called(1);
    });

    test('returns active channels when activeOnly is true', () async {
      when(() => mockRepository.getActiveChannels())
          .thenAnswer((_) async => Right<Failure, List<Channel>>([testChannel]));

      final result = await getChannels(activeOnly: true);

      expect(result.isRight(), true);
      result.fold(
        (_) => fail('Should not return left'),
        (channels) => expect(channels, [testChannel]),
      );
      verify(() => mockRepository.getActiveChannels()).called(1);
    });

    test('returns failure when repository fails', () async {
      when(() => mockRepository.getAllChannels())
          .thenAnswer((_) async => Left(const DatabaseFailure('DB error')));

      final result = await getChannels();

      expect(result, isA<Left>());
    });
  });

  group('UpdateChannel', () {
    test('updates channel successfully', () async {
      when(() => mockRepository.updateChannel(id: any(named: 'id'), name: any(named: 'name')))
          .thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await updateChannel(id: 1, name: 'Shopee Updated');

      expect(result, const Right<Failure, void>(null));
    });
  });
}
