import 'package:craftbook/core/error/result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/products/domain/usecases/adjust_product_stock.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late AdjustProductStock adjustProductStock;
  late MockProductRepository mockRepo;

  setUp(() {
    mockRepo = MockProductRepository();
    adjustProductStock = AdjustProductStock(mockRepo);
  });

  group('AdjustProductStock', () {
    test('calls repository with correct parameters', () async {
      when(() => mockRepo.adjustProductStock(
            productId: 1,
            newQuantityOnHand: 50,
          )).thenAnswer((_) async => const Success<void>(null));

      final result = await adjustProductStock(
        productId: 1,
        newQuantityOnHand: 50,
      );

      expect(result, isA<Success<void>>());
      verify(() => mockRepo.adjustProductStock(
            productId: 1,
            newQuantityOnHand: 50,
          )).called(1);
    });

    test('allows adjusting to zero', () async {
      when(() => mockRepo.adjustProductStock(
            productId: any(named: 'productId'),
            newQuantityOnHand: any(named: 'newQuantityOnHand'),
          )).thenAnswer((_) async => const Success<void>(null));

      final result = await adjustProductStock(
        productId: 1,
        newQuantityOnHand: 0,
      );

      expect(result, isA<Success<void>>());
    });

    test('returns validation failure when quantity is negative', () async {
      final result = await adjustProductStock(
        productId: 1,
        newQuantityOnHand: -5,
      );

      expect(result, isA<Error<void>>());
      switch (result) {
        case Error(:final failure):
          expect(failure, isA<ValidationFailure>());
        case Success():
          fail('Should return error');
      }
      verifyNever(() => mockRepo.adjustProductStock(
            productId: any(named: 'productId'),
            newQuantityOnHand: any(named: 'newQuantityOnHand'),
          ));
    });

    test('propagates repository failure', () async {
      when(() => mockRepo.adjustProductStock(
            productId: any(named: 'productId'),
            newQuantityOnHand: any(named: 'newQuantityOnHand'),
          )).thenAnswer(
          (_) async => Error(DatabaseFailure('DB error')));

      final result = await adjustProductStock(
        productId: 1,
        newQuantityOnHand: 10,
      );

      expect(result, isA<Error<void>>());
      switch (result) {
        case Error(:final failure):
          expect(failure, isA<DatabaseFailure>());
        case Success():
          fail('Should return error');
      }
    });
  });
}
