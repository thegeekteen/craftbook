import 'package:dartz/dartz.dart';
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
          )).thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await adjustProductStock(
        productId: 1,
        newQuantityOnHand: 50,
      );

      expect(result.isRight(), true);
      verify(() => mockRepo.adjustProductStock(
            productId: 1,
            newQuantityOnHand: 50,
          )).called(1);
    });

    test('allows adjusting to zero', () async {
      when(() => mockRepo.adjustProductStock(
            productId: any(named: 'productId'),
            newQuantityOnHand: any(named: 'newQuantityOnHand'),
          )).thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await adjustProductStock(
        productId: 1,
        newQuantityOnHand: 0,
      );

      expect(result.isRight(), true);
    });

    test('returns validation failure when quantity is negative', () async {
      final result = await adjustProductStock(
        productId: 1,
        newQuantityOnHand: -5,
      );

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('Should return left'),
      );
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
          (_) async => Left(DatabaseFailure('DB error')));

      final result = await adjustProductStock(
        productId: 1,
        newQuantityOnHand: 10,
      );

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<DatabaseFailure>()),
        (_) => fail('Should return left'),
      );
    });
  });
}
