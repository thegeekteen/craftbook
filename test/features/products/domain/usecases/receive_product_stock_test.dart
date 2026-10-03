import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/products/domain/usecases/receive_product_stock.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late ReceiveProductStock receiveProductStock;
  late MockProductRepository mockRepo;

  setUp(() {
    mockRepo = MockProductRepository();
    receiveProductStock = ReceiveProductStock(mockRepo);
  });

  group('ReceiveProductStock', () {
    test('calls repository with correct parameters', () async {
      when(() => mockRepo.receiveProductStock(
            productId: 1,
            quantity: 10,
            pricePerUnit: 25.0,
            reference: any(named: 'reference'),
          )).thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await receiveProductStock(
        productId: 1,
        quantity: 10,
        pricePerUnit: 25.0,
      );

      expect(result.isRight(), true);
      verify(() => mockRepo.receiveProductStock(
            productId: 1,
            quantity: 10,
            pricePerUnit: 25.0,
            reference: any(named: 'reference'),
          )).called(1);
    });

    test('returns validation failure when quantity is zero', () async {
      final result = await receiveProductStock(
        productId: 1,
        quantity: 0,
        pricePerUnit: 25.0,
      );

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('Should return left'),
      );
      verifyNever(() => mockRepo.receiveProductStock(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
            pricePerUnit: any(named: 'pricePerUnit'),
            reference: any(named: 'reference'),
          ));
    });

    test('returns validation failure when quantity is negative', () async {
      final result = await receiveProductStock(
        productId: 1,
        quantity: -5,
        pricePerUnit: 25.0,
      );

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('Should return left'),
      );
    });

    test('returns validation failure when price is negative', () async {
      final result = await receiveProductStock(
        productId: 1,
        quantity: 10,
        pricePerUnit: -5.0,
      );

      expect(result.isLeft(), true);
      result.fold(
        (f) => expect(f, isA<ValidationFailure>()),
        (_) => fail('Should return left'),
      );
    });

    test('allows zero price per unit', () async {
      when(() => mockRepo.receiveProductStock(
            productId: any(named: 'productId'),
            quantity: any(named: 'quantity'),
            pricePerUnit: any(named: 'pricePerUnit'),
            reference: any(named: 'reference'),
          )).thenAnswer((_) async => const Right<Failure, void>(null));

      final result = await receiveProductStock(
        productId: 1,
        quantity: 10,
        pricePerUnit: 0,
      );

      expect(result.isRight(), true);
    });
  });
}
