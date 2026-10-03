import 'package:craftbook/core/error/failures.dart';
import 'package:craftbook/core/error/result.dart';
import 'package:craftbook/core/utils/note_codec.dart';
import 'package:craftbook/features/orders/domain/repositories/order_repository.dart';
import 'package:craftbook/features/orders/domain/usecases/update_order_note.dart';
import 'package:dart_quill_delta/dart_quill_delta.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late MockOrderRepository repository;
  late UpdateOrderNote updateOrderNote;

  setUp(() {
    repository = MockOrderRepository();
    updateOrderNote = UpdateOrderNote(repository);
    when(() => repository.updateOrderNote(any(), any()))
        .thenAnswer((_) async => const Success(null));
  });

  test('stores the note as given', () async {
    final note = NoteCodec.encode(Delta()..insert('Ring twice\n', {'list': 'checked'}))!;

    expect(await updateOrderNote(3, note), const Success<void>(null));
    verify(() => repository.updateOrderNote(3, note)).called(1);
  });

  test('stores a note with no words in it as null', () async {
    // An emptied checklist still has list formatting, but nothing to read.
    const empty = '[{"insert":"\\n","attributes":{"list":"unchecked"}}]';

    await updateOrderNote(3, empty);
    await updateOrderNote(3, '   ');
    verify(() => repository.updateOrderNote(3, null)).called(2);
  });

  test('passes a repository failure through', () async {
    when(() => repository.updateOrderNote(any(), any()))
        .thenAnswer((_) async => const Error(NotFoundFailure('Order not found')));

    expect(
      await updateOrderNote(3, 'Ring twice'),
      const Error<void>(NotFoundFailure('Order not found')),
    );
  });
}
