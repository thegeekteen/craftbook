import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../database/app_database.dart' as db;
import '../../../../database/daos/order_field_dao.dart';
import '../../domain/entities/order_field.dart';
import '../../domain/repositories/order_field_repository.dart';

class OrderFieldRepositoryImpl implements OrderFieldRepository {
  final OrderFieldDao dao;

  OrderFieldRepositoryImpl(this.dao);

  @override
  Future<Result<List<OrderField>>> getFields({
    bool includeArchived = true,
  }) async {
    try {
      final rows = await dao.getDefinitionsWithUsage();
      return Success([
        for (final (row, usage) in rows)
          if (includeArchived || !row.isArchived) toEntity(row, usage),
      ]);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<OrderField?>> getField(int id) async {
    final result = await getFields();
    return switch (result) {
      Success(:final value) =>
        Success(value.where((f) => f.id == id).firstOrNull),
      Error(:final failure) => Error(failure),
    };
  }

  @override
  Future<Result<int>> createField(OrderField field) async {
    try {
      final id = await dao.transaction(() async {
        return dao.insertDefinition(db.OrderFieldDefinitionsCompanion.insert(
          name: field.name,
          type: field.type.dbName,
          options: Value(_encodeOptions(field)),
          isMultiline: Value(field.isMultiline),
          position: Value(await dao.nextPosition()),
        ));
      });
      return Success(id);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> updateField(OrderField field) async {
    try {
      final updated = await dao.updateDefinition(
        field.id!,
        db.OrderFieldDefinitionsCompanion(
          name: Value(field.name),
          type: Value(field.type.dbName),
          options: Value(_encodeOptions(field)),
          isMultiline: Value(field.isMultiline),
        ),
      );
      if (updated == 0) return const Error(NotFoundFailure('Field not found'));
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteField(int id) async {
    try {
      await dao.deleteDefinition(id);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> setArchived(int id, bool archived) async {
    try {
      await dao.transaction(() async {
        await dao.updateDefinition(
          id,
          db.OrderFieldDefinitionsCompanion(
            isArchived: Value(archived),
            position:
                archived ? const Value.absent() : Value(await dao.nextPosition()),
          ),
        );
      });
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> reorder(List<int> ids) async {
    try {
      await dao.setPositions(ids);
      return const Success(null);
    } catch (e) {
      return Error(DatabaseFailure(e.toString()));
    }
  }

  static String? _encodeOptions(OrderField field) =>
      field.type == OrderFieldType.choice ? jsonEncode(field.options) : null;

  /// Shared with the orders repository, which reads definitions alongside
  /// an order's values.
  static OrderField toEntity(db.OrderFieldDefinition row, [int usage = 0]) {
    return OrderField(
      id: row.id,
      name: row.name,
      type: OrderFieldType.fromDb(row.type),
      isMultiline: row.isMultiline,
      options: _decodeOptions(row.options),
      position: row.position,
      isArchived: row.isArchived,
      usageCount: usage,
    );
  }

  static List<String> _decodeOptions(String? json) {
    if (json == null || json.isEmpty) return const [];
    try {
      return [for (final o in jsonDecode(json) as List) o.toString()];
    } on FormatException {
      return const [];
    }
  }
}
