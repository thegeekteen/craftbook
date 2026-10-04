import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../entities/order_field.dart';
import '../repositories/order_field_repository.dart';

/// Adds a field (when [id] is null) or edits one. Returns the field's id.
class SaveOrderField {
  final OrderFieldRepository repository;

  SaveOrderField(this.repository);

  Future<Result<int>> call({
    int? id,
    required String name,
    required OrderFieldType type,
    bool isMultiline = false,
    List<String> options = const [],
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Error(ValidationFailure('Give the field a name'));
    }

    final cleanOptions = <String>[];
    if (type == OrderFieldType.choice) {
      for (final o in options) {
        final option = o.trim();
        final duplicate = cleanOptions
            .any((c) => c.toLowerCase() == option.toLowerCase());
        if (option.isNotEmpty && !duplicate) cleanOptions.add(option);
      }
      if (cleanOptions.isEmpty) {
        return const Error(ValidationFailure('Add at least one choice'));
      }
    }

    final existingResult = await repository.getFields();
    final List<OrderField> existing;
    switch (existingResult) {
      case Error(:final failure):
        return Error(failure);
      case Success(:final value):
        existing = value;
    }

    final clash = existing.any(
      (f) => f.id != id && f.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (clash) {
      return Error(ValidationFailure('There is already a field called $trimmed'));
    }

    final field = OrderField(
      id: id,
      name: trimmed,
      type: type,
      isMultiline: type == OrderFieldType.text && isMultiline,
      options: cleanOptions,
    );

    if (id == null) return repository.createField(field);

    final current = existing.where((f) => f.id == id).firstOrNull;
    if (current == null) {
      return const Error(NotFoundFailure('Field not found'));
    }
    // Stored values are encoded for their type; switching would garble them.
    if (current.isUsed && current.type != type) {
      return const Error(ValidationFailure(
        "Type can't change once orders use the field",
      ));
    }
    final result = await repository.updateField(field);
    return switch (result) {
      Success() => Success(id),
      Error(:final failure) => Error(failure),
    };
  }
}
