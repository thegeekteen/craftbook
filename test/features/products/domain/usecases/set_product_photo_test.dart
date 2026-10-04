import 'dart:typed_data';

import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/features/products/domain/repositories/product_repository.dart';
import 'package:craftbook/features/products/domain/usecases/set_product_photo.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRepository extends Mock implements ProductRepository {}

void main() {
  late MockProductRepository repo;
  late SetProductPhoto setPhoto;

  setUp(() {
    repo = MockProductRepository();
    setPhoto = SetProductPhoto(repo);
    when(() => repo.setProductPhoto(any(), any()))
        .thenAnswer((_) async => const Success(null));
  });

  test('stores the photo', () async {
    final photo = Uint8List.fromList([1, 2, 3]);
    expect(await setPhoto(1, photo), const Success<void>(null));
    verify(() => repo.setProductPhoto(1, photo)).called(1);
  });

  test('null removes the photo', () async {
    expect(await setPhoto(1, null), const Success<void>(null));
    verify(() => repo.setProductPhoto(1, null)).called(1);
  });

  test('rejects empty bytes without touching the repository', () async {
    final result = await setPhoto(1, Uint8List(0));
    expect(result, isA<Error<void>>());
    expect((result as Error<void>).failure, isA<ValidationFailure>());
    verifyNever(() => repo.setProductPhoto(any(), any()));
  });

  test('rejects a photo over the size cap', () async {
    final result = await setPhoto(1, Uint8List(SetProductPhoto.maxBytes + 1));
    expect(result, isA<Error<void>>());
    expect((result as Error<void>).failure, isA<ValidationFailure>());
    verifyNever(() => repo.setProductPhoto(any(), any()));
  });

  test('passes a missing product through', () async {
    when(() => repo.setProductPhoto(any(), any())).thenAnswer(
        (_) async => const Error(NotFoundFailure('Product not found')));
    final result = await setPhoto(99, Uint8List.fromList([1]));
    expect((result as Error<void>).failure, isA<NotFoundFailure>());
  });
}
