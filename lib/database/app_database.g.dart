// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $OrdersTable extends Orders with TableInfo<$OrdersTable, Order> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrdersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _customerNameMeta =
      const VerificationMeta('customerName');
  @override
  late final GeneratedColumn<String> customerName = GeneratedColumn<String>(
      'customer_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _orderDateMeta =
      const VerificationMeta('orderDate');
  @override
  late final GeneratedColumn<DateTime> orderDate = GeneratedColumn<DateTime>(
      'order_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _shipByDateMeta =
      const VerificationMeta('shipByDate');
  @override
  late final GeneratedColumn<DateTime> shipByDate = GeneratedColumn<DateTime>(
      'ship_by_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _packedAtMeta =
      const VerificationMeta('packedAt');
  @override
  late final GeneratedColumn<DateTime> packedAt = GeneratedColumn<DateTime>(
      'packed_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _shippedAtMeta =
      const VerificationMeta('shippedAt');
  @override
  late final GeneratedColumn<DateTime> shippedAt = GeneratedColumn<DateTime>(
      'shipped_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _channelIdMeta =
      const VerificationMeta('channelId');
  @override
  late final GeneratedColumn<int> channelId = GeneratedColumn<int>(
      'channel_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _totalSalesMeta =
      const VerificationMeta('totalSales');
  @override
  late final GeneratedColumn<double> totalSales = GeneratedColumn<double>(
      'total_sales', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _totalMaterialCostMeta =
      const VerificationMeta('totalMaterialCost');
  @override
  late final GeneratedColumn<double> totalMaterialCost =
      GeneratedColumn<double>('total_material_cost', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _channelFeesMeta =
      const VerificationMeta('channelFees');
  @override
  late final GeneratedColumn<double> channelFees = GeneratedColumn<double>(
      'channel_fees', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _shippingCostMeta =
      const VerificationMeta('shippingCost');
  @override
  late final GeneratedColumn<double> shippingCost = GeneratedColumn<double>(
      'shipping_cost', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _profitMeta = const VerificationMeta('profit');
  @override
  late final GeneratedColumn<double> profit = GeneratedColumn<double>(
      'profit', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        customerName,
        note,
        orderDate,
        shipByDate,
        packedAt,
        shippedAt,
        status,
        channelId,
        totalSales,
        totalMaterialCost,
        channelFees,
        shippingCost,
        profit,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'orders';
  @override
  VerificationContext validateIntegrity(Insertable<Order> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_name')) {
      context.handle(
          _customerNameMeta,
          customerName.isAcceptableOrUnknown(
              data['customer_name']!, _customerNameMeta));
    } else if (isInserting) {
      context.missing(_customerNameMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('order_date')) {
      context.handle(_orderDateMeta,
          orderDate.isAcceptableOrUnknown(data['order_date']!, _orderDateMeta));
    } else if (isInserting) {
      context.missing(_orderDateMeta);
    }
    if (data.containsKey('ship_by_date')) {
      context.handle(
          _shipByDateMeta,
          shipByDate.isAcceptableOrUnknown(
              data['ship_by_date']!, _shipByDateMeta));
    } else if (isInserting) {
      context.missing(_shipByDateMeta);
    }
    if (data.containsKey('packed_at')) {
      context.handle(_packedAtMeta,
          packedAt.isAcceptableOrUnknown(data['packed_at']!, _packedAtMeta));
    }
    if (data.containsKey('shipped_at')) {
      context.handle(_shippedAtMeta,
          shippedAt.isAcceptableOrUnknown(data['shipped_at']!, _shippedAtMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('channel_id')) {
      context.handle(_channelIdMeta,
          channelId.isAcceptableOrUnknown(data['channel_id']!, _channelIdMeta));
    }
    if (data.containsKey('total_sales')) {
      context.handle(
          _totalSalesMeta,
          totalSales.isAcceptableOrUnknown(
              data['total_sales']!, _totalSalesMeta));
    } else if (isInserting) {
      context.missing(_totalSalesMeta);
    }
    if (data.containsKey('total_material_cost')) {
      context.handle(
          _totalMaterialCostMeta,
          totalMaterialCost.isAcceptableOrUnknown(
              data['total_material_cost']!, _totalMaterialCostMeta));
    }
    if (data.containsKey('channel_fees')) {
      context.handle(
          _channelFeesMeta,
          channelFees.isAcceptableOrUnknown(
              data['channel_fees']!, _channelFeesMeta));
    }
    if (data.containsKey('shipping_cost')) {
      context.handle(
          _shippingCostMeta,
          shippingCost.isAcceptableOrUnknown(
              data['shipping_cost']!, _shippingCostMeta));
    }
    if (data.containsKey('profit')) {
      context.handle(_profitMeta,
          profit.isAcceptableOrUnknown(data['profit']!, _profitMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Order map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Order(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      customerName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}customer_name'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
      orderDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}order_date'])!,
      shipByDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ship_by_date'])!,
      packedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}packed_at']),
      shippedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}shipped_at']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      channelId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}channel_id']),
      totalSales: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_sales'])!,
      totalMaterialCost: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}total_material_cost'])!,
      channelFees: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}channel_fees'])!,
      shippingCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}shipping_cost'])!,
      profit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}profit'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $OrdersTable createAlias(String alias) {
    return $OrdersTable(attachedDatabase, alias);
  }
}

class Order extends DataClass implements Insertable<Order> {
  final int id;
  final String customerName;
  final String? note;
  final DateTime orderDate;
  final DateTime shipByDate;
  final DateTime? packedAt;
  final DateTime? shippedAt;
  final String status;
  final int? channelId;
  final double totalSales;
  final double totalMaterialCost;
  final double channelFees;
  final double shippingCost;
  final double profit;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Order(
      {required this.id,
      required this.customerName,
      this.note,
      required this.orderDate,
      required this.shipByDate,
      this.packedAt,
      this.shippedAt,
      required this.status,
      this.channelId,
      required this.totalSales,
      required this.totalMaterialCost,
      required this.channelFees,
      required this.shippingCost,
      required this.profit,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_name'] = Variable<String>(customerName);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['order_date'] = Variable<DateTime>(orderDate);
    map['ship_by_date'] = Variable<DateTime>(shipByDate);
    if (!nullToAbsent || packedAt != null) {
      map['packed_at'] = Variable<DateTime>(packedAt);
    }
    if (!nullToAbsent || shippedAt != null) {
      map['shipped_at'] = Variable<DateTime>(shippedAt);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || channelId != null) {
      map['channel_id'] = Variable<int>(channelId);
    }
    map['total_sales'] = Variable<double>(totalSales);
    map['total_material_cost'] = Variable<double>(totalMaterialCost);
    map['channel_fees'] = Variable<double>(channelFees);
    map['shipping_cost'] = Variable<double>(shippingCost);
    map['profit'] = Variable<double>(profit);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  OrdersCompanion toCompanion(bool nullToAbsent) {
    return OrdersCompanion(
      id: Value(id),
      customerName: Value(customerName),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      orderDate: Value(orderDate),
      shipByDate: Value(shipByDate),
      packedAt: packedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(packedAt),
      shippedAt: shippedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(shippedAt),
      status: Value(status),
      channelId: channelId == null && nullToAbsent
          ? const Value.absent()
          : Value(channelId),
      totalSales: Value(totalSales),
      totalMaterialCost: Value(totalMaterialCost),
      channelFees: Value(channelFees),
      shippingCost: Value(shippingCost),
      profit: Value(profit),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Order.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Order(
      id: serializer.fromJson<int>(json['id']),
      customerName: serializer.fromJson<String>(json['customerName']),
      note: serializer.fromJson<String?>(json['note']),
      orderDate: serializer.fromJson<DateTime>(json['orderDate']),
      shipByDate: serializer.fromJson<DateTime>(json['shipByDate']),
      packedAt: serializer.fromJson<DateTime?>(json['packedAt']),
      shippedAt: serializer.fromJson<DateTime?>(json['shippedAt']),
      status: serializer.fromJson<String>(json['status']),
      channelId: serializer.fromJson<int?>(json['channelId']),
      totalSales: serializer.fromJson<double>(json['totalSales']),
      totalMaterialCost: serializer.fromJson<double>(json['totalMaterialCost']),
      channelFees: serializer.fromJson<double>(json['channelFees']),
      shippingCost: serializer.fromJson<double>(json['shippingCost']),
      profit: serializer.fromJson<double>(json['profit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerName': serializer.toJson<String>(customerName),
      'note': serializer.toJson<String?>(note),
      'orderDate': serializer.toJson<DateTime>(orderDate),
      'shipByDate': serializer.toJson<DateTime>(shipByDate),
      'packedAt': serializer.toJson<DateTime?>(packedAt),
      'shippedAt': serializer.toJson<DateTime?>(shippedAt),
      'status': serializer.toJson<String>(status),
      'channelId': serializer.toJson<int?>(channelId),
      'totalSales': serializer.toJson<double>(totalSales),
      'totalMaterialCost': serializer.toJson<double>(totalMaterialCost),
      'channelFees': serializer.toJson<double>(channelFees),
      'shippingCost': serializer.toJson<double>(shippingCost),
      'profit': serializer.toJson<double>(profit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Order copyWith(
          {int? id,
          String? customerName,
          Value<String?> note = const Value.absent(),
          DateTime? orderDate,
          DateTime? shipByDate,
          Value<DateTime?> packedAt = const Value.absent(),
          Value<DateTime?> shippedAt = const Value.absent(),
          String? status,
          Value<int?> channelId = const Value.absent(),
          double? totalSales,
          double? totalMaterialCost,
          double? channelFees,
          double? shippingCost,
          double? profit,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Order(
        id: id ?? this.id,
        customerName: customerName ?? this.customerName,
        note: note.present ? note.value : this.note,
        orderDate: orderDate ?? this.orderDate,
        shipByDate: shipByDate ?? this.shipByDate,
        packedAt: packedAt.present ? packedAt.value : this.packedAt,
        shippedAt: shippedAt.present ? shippedAt.value : this.shippedAt,
        status: status ?? this.status,
        channelId: channelId.present ? channelId.value : this.channelId,
        totalSales: totalSales ?? this.totalSales,
        totalMaterialCost: totalMaterialCost ?? this.totalMaterialCost,
        channelFees: channelFees ?? this.channelFees,
        shippingCost: shippingCost ?? this.shippingCost,
        profit: profit ?? this.profit,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Order copyWithCompanion(OrdersCompanion data) {
    return Order(
      id: data.id.present ? data.id.value : this.id,
      customerName: data.customerName.present
          ? data.customerName.value
          : this.customerName,
      note: data.note.present ? data.note.value : this.note,
      orderDate: data.orderDate.present ? data.orderDate.value : this.orderDate,
      shipByDate:
          data.shipByDate.present ? data.shipByDate.value : this.shipByDate,
      packedAt: data.packedAt.present ? data.packedAt.value : this.packedAt,
      shippedAt: data.shippedAt.present ? data.shippedAt.value : this.shippedAt,
      status: data.status.present ? data.status.value : this.status,
      channelId: data.channelId.present ? data.channelId.value : this.channelId,
      totalSales:
          data.totalSales.present ? data.totalSales.value : this.totalSales,
      totalMaterialCost: data.totalMaterialCost.present
          ? data.totalMaterialCost.value
          : this.totalMaterialCost,
      channelFees:
          data.channelFees.present ? data.channelFees.value : this.channelFees,
      shippingCost: data.shippingCost.present
          ? data.shippingCost.value
          : this.shippingCost,
      profit: data.profit.present ? data.profit.value : this.profit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Order(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('note: $note, ')
          ..write('orderDate: $orderDate, ')
          ..write('shipByDate: $shipByDate, ')
          ..write('packedAt: $packedAt, ')
          ..write('shippedAt: $shippedAt, ')
          ..write('status: $status, ')
          ..write('channelId: $channelId, ')
          ..write('totalSales: $totalSales, ')
          ..write('totalMaterialCost: $totalMaterialCost, ')
          ..write('channelFees: $channelFees, ')
          ..write('shippingCost: $shippingCost, ')
          ..write('profit: $profit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      customerName,
      note,
      orderDate,
      shipByDate,
      packedAt,
      shippedAt,
      status,
      channelId,
      totalSales,
      totalMaterialCost,
      channelFees,
      shippingCost,
      profit,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Order &&
          other.id == this.id &&
          other.customerName == this.customerName &&
          other.note == this.note &&
          other.orderDate == this.orderDate &&
          other.shipByDate == this.shipByDate &&
          other.packedAt == this.packedAt &&
          other.shippedAt == this.shippedAt &&
          other.status == this.status &&
          other.channelId == this.channelId &&
          other.totalSales == this.totalSales &&
          other.totalMaterialCost == this.totalMaterialCost &&
          other.channelFees == this.channelFees &&
          other.shippingCost == this.shippingCost &&
          other.profit == this.profit &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class OrdersCompanion extends UpdateCompanion<Order> {
  final Value<int> id;
  final Value<String> customerName;
  final Value<String?> note;
  final Value<DateTime> orderDate;
  final Value<DateTime> shipByDate;
  final Value<DateTime?> packedAt;
  final Value<DateTime?> shippedAt;
  final Value<String> status;
  final Value<int?> channelId;
  final Value<double> totalSales;
  final Value<double> totalMaterialCost;
  final Value<double> channelFees;
  final Value<double> shippingCost;
  final Value<double> profit;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const OrdersCompanion({
    this.id = const Value.absent(),
    this.customerName = const Value.absent(),
    this.note = const Value.absent(),
    this.orderDate = const Value.absent(),
    this.shipByDate = const Value.absent(),
    this.packedAt = const Value.absent(),
    this.shippedAt = const Value.absent(),
    this.status = const Value.absent(),
    this.channelId = const Value.absent(),
    this.totalSales = const Value.absent(),
    this.totalMaterialCost = const Value.absent(),
    this.channelFees = const Value.absent(),
    this.shippingCost = const Value.absent(),
    this.profit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  OrdersCompanion.insert({
    this.id = const Value.absent(),
    required String customerName,
    this.note = const Value.absent(),
    required DateTime orderDate,
    required DateTime shipByDate,
    this.packedAt = const Value.absent(),
    this.shippedAt = const Value.absent(),
    required String status,
    this.channelId = const Value.absent(),
    required double totalSales,
    this.totalMaterialCost = const Value.absent(),
    this.channelFees = const Value.absent(),
    this.shippingCost = const Value.absent(),
    this.profit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : customerName = Value(customerName),
        orderDate = Value(orderDate),
        shipByDate = Value(shipByDate),
        status = Value(status),
        totalSales = Value(totalSales);
  static Insertable<Order> custom({
    Expression<int>? id,
    Expression<String>? customerName,
    Expression<String>? note,
    Expression<DateTime>? orderDate,
    Expression<DateTime>? shipByDate,
    Expression<DateTime>? packedAt,
    Expression<DateTime>? shippedAt,
    Expression<String>? status,
    Expression<int>? channelId,
    Expression<double>? totalSales,
    Expression<double>? totalMaterialCost,
    Expression<double>? channelFees,
    Expression<double>? shippingCost,
    Expression<double>? profit,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerName != null) 'customer_name': customerName,
      if (note != null) 'note': note,
      if (orderDate != null) 'order_date': orderDate,
      if (shipByDate != null) 'ship_by_date': shipByDate,
      if (packedAt != null) 'packed_at': packedAt,
      if (shippedAt != null) 'shipped_at': shippedAt,
      if (status != null) 'status': status,
      if (channelId != null) 'channel_id': channelId,
      if (totalSales != null) 'total_sales': totalSales,
      if (totalMaterialCost != null) 'total_material_cost': totalMaterialCost,
      if (channelFees != null) 'channel_fees': channelFees,
      if (shippingCost != null) 'shipping_cost': shippingCost,
      if (profit != null) 'profit': profit,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  OrdersCompanion copyWith(
      {Value<int>? id,
      Value<String>? customerName,
      Value<String?>? note,
      Value<DateTime>? orderDate,
      Value<DateTime>? shipByDate,
      Value<DateTime?>? packedAt,
      Value<DateTime?>? shippedAt,
      Value<String>? status,
      Value<int?>? channelId,
      Value<double>? totalSales,
      Value<double>? totalMaterialCost,
      Value<double>? channelFees,
      Value<double>? shippingCost,
      Value<double>? profit,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return OrdersCompanion(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      note: note ?? this.note,
      orderDate: orderDate ?? this.orderDate,
      shipByDate: shipByDate ?? this.shipByDate,
      packedAt: packedAt ?? this.packedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      status: status ?? this.status,
      channelId: channelId ?? this.channelId,
      totalSales: totalSales ?? this.totalSales,
      totalMaterialCost: totalMaterialCost ?? this.totalMaterialCost,
      channelFees: channelFees ?? this.channelFees,
      shippingCost: shippingCost ?? this.shippingCost,
      profit: profit ?? this.profit,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerName.present) {
      map['customer_name'] = Variable<String>(customerName.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (orderDate.present) {
      map['order_date'] = Variable<DateTime>(orderDate.value);
    }
    if (shipByDate.present) {
      map['ship_by_date'] = Variable<DateTime>(shipByDate.value);
    }
    if (packedAt.present) {
      map['packed_at'] = Variable<DateTime>(packedAt.value);
    }
    if (shippedAt.present) {
      map['shipped_at'] = Variable<DateTime>(shippedAt.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (channelId.present) {
      map['channel_id'] = Variable<int>(channelId.value);
    }
    if (totalSales.present) {
      map['total_sales'] = Variable<double>(totalSales.value);
    }
    if (totalMaterialCost.present) {
      map['total_material_cost'] = Variable<double>(totalMaterialCost.value);
    }
    if (channelFees.present) {
      map['channel_fees'] = Variable<double>(channelFees.value);
    }
    if (shippingCost.present) {
      map['shipping_cost'] = Variable<double>(shippingCost.value);
    }
    if (profit.present) {
      map['profit'] = Variable<double>(profit.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrdersCompanion(')
          ..write('id: $id, ')
          ..write('customerName: $customerName, ')
          ..write('note: $note, ')
          ..write('orderDate: $orderDate, ')
          ..write('shipByDate: $shipByDate, ')
          ..write('packedAt: $packedAt, ')
          ..write('shippedAt: $shippedAt, ')
          ..write('status: $status, ')
          ..write('channelId: $channelId, ')
          ..write('totalSales: $totalSales, ')
          ..write('totalMaterialCost: $totalMaterialCost, ')
          ..write('channelFees: $channelFees, ')
          ..write('shippingCost: $shippingCost, ')
          ..write('profit: $profit, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $OrderItemsTable extends OrderItems
    with TableInfo<$OrderItemsTable, OrderItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitPriceMeta =
      const VerificationMeta('unitPrice');
  @override
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
      'unit_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, orderId, productId, quantity, unitPrice, subtotal, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_items';
  @override
  VerificationContext validateIntegrity(Insertable<OrderItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_price')) {
      context.handle(_unitPriceMeta,
          unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta));
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_price'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OrderItemsTable createAlias(String alias) {
    return $OrderItemsTable(attachedDatabase, alias);
  }
}

class OrderItem extends DataClass implements Insertable<OrderItem> {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final DateTime createdAt;
  const OrderItem(
      {required this.id,
      required this.orderId,
      required this.productId,
      required this.quantity,
      required this.unitPrice,
      required this.subtotal,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<int>(orderId);
    map['product_id'] = Variable<int>(productId);
    map['quantity'] = Variable<int>(quantity);
    map['unit_price'] = Variable<double>(unitPrice);
    map['subtotal'] = Variable<double>(subtotal);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OrderItemsCompanion toCompanion(bool nullToAbsent) {
    return OrderItemsCompanion(
      id: Value(id),
      orderId: Value(orderId),
      productId: Value(productId),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      subtotal: Value(subtotal),
      createdAt: Value(createdAt),
    );
  }

  factory OrderItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderItem(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<int>(json['orderId']),
      productId: serializer.fromJson<int>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<int>(orderId),
      'productId': serializer.toJson<int>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'unitPrice': serializer.toJson<double>(unitPrice),
      'subtotal': serializer.toJson<double>(subtotal),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OrderItem copyWith(
          {int? id,
          int? orderId,
          int? productId,
          int? quantity,
          double? unitPrice,
          double? subtotal,
          DateTime? createdAt}) =>
      OrderItem(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        subtotal: subtotal ?? this.subtotal,
        createdAt: createdAt ?? this.createdAt,
      );
  OrderItem copyWithCompanion(OrderItemsCompanion data) {
    return OrderItem(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderItem(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('subtotal: $subtotal, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, orderId, productId, quantity, unitPrice, subtotal, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderItem &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.subtotal == this.subtotal &&
          other.createdAt == this.createdAt);
}

class OrderItemsCompanion extends UpdateCompanion<OrderItem> {
  final Value<int> id;
  final Value<int> orderId;
  final Value<int> productId;
  final Value<int> quantity;
  final Value<double> unitPrice;
  final Value<double> subtotal;
  final Value<DateTime> createdAt;
  const OrderItemsCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OrderItemsCompanion.insert({
    this.id = const Value.absent(),
    required int orderId,
    required int productId,
    required int quantity,
    required double unitPrice,
    required double subtotal,
    this.createdAt = const Value.absent(),
  })  : orderId = Value(orderId),
        productId = Value(productId),
        quantity = Value(quantity),
        unitPrice = Value(unitPrice),
        subtotal = Value(subtotal);
  static Insertable<OrderItem> custom({
    Expression<int>? id,
    Expression<int>? orderId,
    Expression<int>? productId,
    Expression<int>? quantity,
    Expression<double>? unitPrice,
    Expression<double>? subtotal,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (subtotal != null) 'subtotal': subtotal,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OrderItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? orderId,
      Value<int>? productId,
      Value<int>? quantity,
      Value<double>? unitPrice,
      Value<double>? subtotal,
      Value<DateTime>? createdAt}) {
    return OrderItemsCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      subtotal: subtotal ?? this.subtotal,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderItemsCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('subtotal: $subtotal, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $OrderMaterialsTable extends OrderMaterials
    with TableInfo<$OrderMaterialsTable, OrderMaterial> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderMaterialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _materialIdMeta =
      const VerificationMeta('materialId');
  @override
  late final GeneratedColumn<int> materialId = GeneratedColumn<int>(
      'material_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _plannedQuantityMeta =
      const VerificationMeta('plannedQuantity');
  @override
  late final GeneratedColumn<int> plannedQuantity = GeneratedColumn<int>(
      'planned_quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _actualQuantityMeta =
      const VerificationMeta('actualQuantity');
  @override
  late final GeneratedColumn<int> actualQuantity = GeneratedColumn<int>(
      'actual_quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _wasteQuantityMeta =
      const VerificationMeta('wasteQuantity');
  @override
  late final GeneratedColumn<int> wasteQuantity = GeneratedColumn<int>(
      'waste_quantity', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _wasteReasonMeta =
      const VerificationMeta('wasteReason');
  @override
  late final GeneratedColumn<String> wasteReason = GeneratedColumn<String>(
      'waste_reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _unitCostMeta =
      const VerificationMeta('unitCost');
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
      'unit_cost', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        orderId,
        materialId,
        plannedQuantity,
        actualQuantity,
        wasteQuantity,
        wasteReason,
        unitCost,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_materials';
  @override
  VerificationContext validateIntegrity(Insertable<OrderMaterial> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('material_id')) {
      context.handle(
          _materialIdMeta,
          materialId.isAcceptableOrUnknown(
              data['material_id']!, _materialIdMeta));
    } else if (isInserting) {
      context.missing(_materialIdMeta);
    }
    if (data.containsKey('planned_quantity')) {
      context.handle(
          _plannedQuantityMeta,
          plannedQuantity.isAcceptableOrUnknown(
              data['planned_quantity']!, _plannedQuantityMeta));
    } else if (isInserting) {
      context.missing(_plannedQuantityMeta);
    }
    if (data.containsKey('actual_quantity')) {
      context.handle(
          _actualQuantityMeta,
          actualQuantity.isAcceptableOrUnknown(
              data['actual_quantity']!, _actualQuantityMeta));
    } else if (isInserting) {
      context.missing(_actualQuantityMeta);
    }
    if (data.containsKey('waste_quantity')) {
      context.handle(
          _wasteQuantityMeta,
          wasteQuantity.isAcceptableOrUnknown(
              data['waste_quantity']!, _wasteQuantityMeta));
    }
    if (data.containsKey('waste_reason')) {
      context.handle(
          _wasteReasonMeta,
          wasteReason.isAcceptableOrUnknown(
              data['waste_reason']!, _wasteReasonMeta));
    }
    if (data.containsKey('unit_cost')) {
      context.handle(_unitCostMeta,
          unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta));
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderMaterial map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderMaterial(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      materialId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}material_id'])!,
      plannedQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}planned_quantity'])!,
      actualQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}actual_quantity'])!,
      wasteQuantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}waste_quantity'])!,
      wasteReason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}waste_reason']),
      unitCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_cost'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OrderMaterialsTable createAlias(String alias) {
    return $OrderMaterialsTable(attachedDatabase, alias);
  }
}

class OrderMaterial extends DataClass implements Insertable<OrderMaterial> {
  final int id;
  final int orderId;
  final int materialId;
  final int plannedQuantity;
  final int actualQuantity;
  final int wasteQuantity;
  final String? wasteReason;
  final double unitCost;
  final DateTime createdAt;
  const OrderMaterial(
      {required this.id,
      required this.orderId,
      required this.materialId,
      required this.plannedQuantity,
      required this.actualQuantity,
      required this.wasteQuantity,
      this.wasteReason,
      required this.unitCost,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<int>(orderId);
    map['material_id'] = Variable<int>(materialId);
    map['planned_quantity'] = Variable<int>(plannedQuantity);
    map['actual_quantity'] = Variable<int>(actualQuantity);
    map['waste_quantity'] = Variable<int>(wasteQuantity);
    if (!nullToAbsent || wasteReason != null) {
      map['waste_reason'] = Variable<String>(wasteReason);
    }
    map['unit_cost'] = Variable<double>(unitCost);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OrderMaterialsCompanion toCompanion(bool nullToAbsent) {
    return OrderMaterialsCompanion(
      id: Value(id),
      orderId: Value(orderId),
      materialId: Value(materialId),
      plannedQuantity: Value(plannedQuantity),
      actualQuantity: Value(actualQuantity),
      wasteQuantity: Value(wasteQuantity),
      wasteReason: wasteReason == null && nullToAbsent
          ? const Value.absent()
          : Value(wasteReason),
      unitCost: Value(unitCost),
      createdAt: Value(createdAt),
    );
  }

  factory OrderMaterial.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderMaterial(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<int>(json['orderId']),
      materialId: serializer.fromJson<int>(json['materialId']),
      plannedQuantity: serializer.fromJson<int>(json['plannedQuantity']),
      actualQuantity: serializer.fromJson<int>(json['actualQuantity']),
      wasteQuantity: serializer.fromJson<int>(json['wasteQuantity']),
      wasteReason: serializer.fromJson<String?>(json['wasteReason']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<int>(orderId),
      'materialId': serializer.toJson<int>(materialId),
      'plannedQuantity': serializer.toJson<int>(plannedQuantity),
      'actualQuantity': serializer.toJson<int>(actualQuantity),
      'wasteQuantity': serializer.toJson<int>(wasteQuantity),
      'wasteReason': serializer.toJson<String?>(wasteReason),
      'unitCost': serializer.toJson<double>(unitCost),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OrderMaterial copyWith(
          {int? id,
          int? orderId,
          int? materialId,
          int? plannedQuantity,
          int? actualQuantity,
          int? wasteQuantity,
          Value<String?> wasteReason = const Value.absent(),
          double? unitCost,
          DateTime? createdAt}) =>
      OrderMaterial(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        materialId: materialId ?? this.materialId,
        plannedQuantity: plannedQuantity ?? this.plannedQuantity,
        actualQuantity: actualQuantity ?? this.actualQuantity,
        wasteQuantity: wasteQuantity ?? this.wasteQuantity,
        wasteReason: wasteReason.present ? wasteReason.value : this.wasteReason,
        unitCost: unitCost ?? this.unitCost,
        createdAt: createdAt ?? this.createdAt,
      );
  OrderMaterial copyWithCompanion(OrderMaterialsCompanion data) {
    return OrderMaterial(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      materialId:
          data.materialId.present ? data.materialId.value : this.materialId,
      plannedQuantity: data.plannedQuantity.present
          ? data.plannedQuantity.value
          : this.plannedQuantity,
      actualQuantity: data.actualQuantity.present
          ? data.actualQuantity.value
          : this.actualQuantity,
      wasteQuantity: data.wasteQuantity.present
          ? data.wasteQuantity.value
          : this.wasteQuantity,
      wasteReason:
          data.wasteReason.present ? data.wasteReason.value : this.wasteReason,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderMaterial(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('materialId: $materialId, ')
          ..write('plannedQuantity: $plannedQuantity, ')
          ..write('actualQuantity: $actualQuantity, ')
          ..write('wasteQuantity: $wasteQuantity, ')
          ..write('wasteReason: $wasteReason, ')
          ..write('unitCost: $unitCost, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, orderId, materialId, plannedQuantity,
      actualQuantity, wasteQuantity, wasteReason, unitCost, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderMaterial &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.materialId == this.materialId &&
          other.plannedQuantity == this.plannedQuantity &&
          other.actualQuantity == this.actualQuantity &&
          other.wasteQuantity == this.wasteQuantity &&
          other.wasteReason == this.wasteReason &&
          other.unitCost == this.unitCost &&
          other.createdAt == this.createdAt);
}

class OrderMaterialsCompanion extends UpdateCompanion<OrderMaterial> {
  final Value<int> id;
  final Value<int> orderId;
  final Value<int> materialId;
  final Value<int> plannedQuantity;
  final Value<int> actualQuantity;
  final Value<int> wasteQuantity;
  final Value<String?> wasteReason;
  final Value<double> unitCost;
  final Value<DateTime> createdAt;
  const OrderMaterialsCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.materialId = const Value.absent(),
    this.plannedQuantity = const Value.absent(),
    this.actualQuantity = const Value.absent(),
    this.wasteQuantity = const Value.absent(),
    this.wasteReason = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OrderMaterialsCompanion.insert({
    this.id = const Value.absent(),
    required int orderId,
    required int materialId,
    required int plannedQuantity,
    required int actualQuantity,
    this.wasteQuantity = const Value.absent(),
    this.wasteReason = const Value.absent(),
    required double unitCost,
    this.createdAt = const Value.absent(),
  })  : orderId = Value(orderId),
        materialId = Value(materialId),
        plannedQuantity = Value(plannedQuantity),
        actualQuantity = Value(actualQuantity),
        unitCost = Value(unitCost);
  static Insertable<OrderMaterial> custom({
    Expression<int>? id,
    Expression<int>? orderId,
    Expression<int>? materialId,
    Expression<int>? plannedQuantity,
    Expression<int>? actualQuantity,
    Expression<int>? wasteQuantity,
    Expression<String>? wasteReason,
    Expression<double>? unitCost,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (materialId != null) 'material_id': materialId,
      if (plannedQuantity != null) 'planned_quantity': plannedQuantity,
      if (actualQuantity != null) 'actual_quantity': actualQuantity,
      if (wasteQuantity != null) 'waste_quantity': wasteQuantity,
      if (wasteReason != null) 'waste_reason': wasteReason,
      if (unitCost != null) 'unit_cost': unitCost,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OrderMaterialsCompanion copyWith(
      {Value<int>? id,
      Value<int>? orderId,
      Value<int>? materialId,
      Value<int>? plannedQuantity,
      Value<int>? actualQuantity,
      Value<int>? wasteQuantity,
      Value<String?>? wasteReason,
      Value<double>? unitCost,
      Value<DateTime>? createdAt}) {
    return OrderMaterialsCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      materialId: materialId ?? this.materialId,
      plannedQuantity: plannedQuantity ?? this.plannedQuantity,
      actualQuantity: actualQuantity ?? this.actualQuantity,
      wasteQuantity: wasteQuantity ?? this.wasteQuantity,
      wasteReason: wasteReason ?? this.wasteReason,
      unitCost: unitCost ?? this.unitCost,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (materialId.present) {
      map['material_id'] = Variable<int>(materialId.value);
    }
    if (plannedQuantity.present) {
      map['planned_quantity'] = Variable<int>(plannedQuantity.value);
    }
    if (actualQuantity.present) {
      map['actual_quantity'] = Variable<int>(actualQuantity.value);
    }
    if (wasteQuantity.present) {
      map['waste_quantity'] = Variable<int>(wasteQuantity.value);
    }
    if (wasteReason.present) {
      map['waste_reason'] = Variable<String>(wasteReason.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderMaterialsCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('materialId: $materialId, ')
          ..write('plannedQuantity: $plannedQuantity, ')
          ..write('actualQuantity: $actualQuantity, ')
          ..write('wasteQuantity: $wasteQuantity, ')
          ..write('wasteReason: $wasteReason, ')
          ..write('unitCost: $unitCost, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $OrderProductsTable extends OrderProducts
    with TableInfo<$OrderProductsTable, OrderProduct> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitCostMeta =
      const VerificationMeta('unitCost');
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
      'unit_cost', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, orderId, productId, quantity, unitCost, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_products';
  @override
  VerificationContext validateIntegrity(Insertable<OrderProduct> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(_unitCostMeta,
          unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta));
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderProduct map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderProduct(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_cost'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OrderProductsTable createAlias(String alias) {
    return $OrderProductsTable(attachedDatabase, alias);
  }
}

class OrderProduct extends DataClass implements Insertable<OrderProduct> {
  final int id;
  final int orderId;
  final int productId;
  final int quantity;
  final double unitCost;
  final DateTime createdAt;
  const OrderProduct(
      {required this.id,
      required this.orderId,
      required this.productId,
      required this.quantity,
      required this.unitCost,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['order_id'] = Variable<int>(orderId);
    map['product_id'] = Variable<int>(productId);
    map['quantity'] = Variable<int>(quantity);
    map['unit_cost'] = Variable<double>(unitCost);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OrderProductsCompanion toCompanion(bool nullToAbsent) {
    return OrderProductsCompanion(
      id: Value(id),
      orderId: Value(orderId),
      productId: Value(productId),
      quantity: Value(quantity),
      unitCost: Value(unitCost),
      createdAt: Value(createdAt),
    );
  }

  factory OrderProduct.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderProduct(
      id: serializer.fromJson<int>(json['id']),
      orderId: serializer.fromJson<int>(json['orderId']),
      productId: serializer.fromJson<int>(json['productId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'orderId': serializer.toJson<int>(orderId),
      'productId': serializer.toJson<int>(productId),
      'quantity': serializer.toJson<int>(quantity),
      'unitCost': serializer.toJson<double>(unitCost),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OrderProduct copyWith(
          {int? id,
          int? orderId,
          int? productId,
          int? quantity,
          double? unitCost,
          DateTime? createdAt}) =>
      OrderProduct(
        id: id ?? this.id,
        orderId: orderId ?? this.orderId,
        productId: productId ?? this.productId,
        quantity: quantity ?? this.quantity,
        unitCost: unitCost ?? this.unitCost,
        createdAt: createdAt ?? this.createdAt,
      );
  OrderProduct copyWithCompanion(OrderProductsCompanion data) {
    return OrderProduct(
      id: data.id.present ? data.id.value : this.id,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      productId: data.productId.present ? data.productId.value : this.productId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderProduct(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, orderId, productId, quantity, unitCost, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderProduct &&
          other.id == this.id &&
          other.orderId == this.orderId &&
          other.productId == this.productId &&
          other.quantity == this.quantity &&
          other.unitCost == this.unitCost &&
          other.createdAt == this.createdAt);
}

class OrderProductsCompanion extends UpdateCompanion<OrderProduct> {
  final Value<int> id;
  final Value<int> orderId;
  final Value<int> productId;
  final Value<int> quantity;
  final Value<double> unitCost;
  final Value<DateTime> createdAt;
  const OrderProductsCompanion({
    this.id = const Value.absent(),
    this.orderId = const Value.absent(),
    this.productId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OrderProductsCompanion.insert({
    this.id = const Value.absent(),
    required int orderId,
    required int productId,
    required int quantity,
    required double unitCost,
    this.createdAt = const Value.absent(),
  })  : orderId = Value(orderId),
        productId = Value(productId),
        quantity = Value(quantity),
        unitCost = Value(unitCost);
  static Insertable<OrderProduct> custom({
    Expression<int>? id,
    Expression<int>? orderId,
    Expression<int>? productId,
    Expression<int>? quantity,
    Expression<double>? unitCost,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (orderId != null) 'order_id': orderId,
      if (productId != null) 'product_id': productId,
      if (quantity != null) 'quantity': quantity,
      if (unitCost != null) 'unit_cost': unitCost,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OrderProductsCompanion copyWith(
      {Value<int>? id,
      Value<int>? orderId,
      Value<int>? productId,
      Value<int>? quantity,
      Value<double>? unitCost,
      Value<DateTime>? createdAt}) {
    return OrderProductsCompanion(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderProductsCompanion(')
          ..write('id: $id, ')
          ..write('orderId: $orderId, ')
          ..write('productId: $productId, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MaterialsTable extends Materials
    with TableInfo<$MaterialsTable, Material> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaterialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _packSizeMeta =
      const VerificationMeta('packSize');
  @override
  late final GeneratedColumn<int> packSize = GeneratedColumn<int>(
      'pack_size', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _packPriceMeta =
      const VerificationMeta('packPrice');
  @override
  late final GeneratedColumn<double> packPrice = GeneratedColumn<double>(
      'pack_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _unitCostMeta =
      const VerificationMeta('unitCost');
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
      'unit_cost', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _quantityOnHandMeta =
      const VerificationMeta('quantityOnHand');
  @override
  late final GeneratedColumn<int> quantityOnHand = GeneratedColumn<int>(
      'quantity_on_hand', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _quantityPromisedMeta =
      const VerificationMeta('quantityPromised');
  @override
  late final GeneratedColumn<int> quantityPromised = GeneratedColumn<int>(
      'quantity_promised', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _alertLevelMeta =
      const VerificationMeta('alertLevel');
  @override
  late final GeneratedColumn<int> alertLevel = GeneratedColumn<int>(
      'alert_level', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _supplierMeta =
      const VerificationMeta('supplier');
  @override
  late final GeneratedColumn<String> supplier = GeneratedColumn<String>(
      'supplier', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastReceivedAtMeta =
      const VerificationMeta('lastReceivedAt');
  @override
  late final GeneratedColumn<DateTime> lastReceivedAt =
      GeneratedColumn<DateTime>('last_received_at', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        packSize,
        packPrice,
        unitCost,
        quantityOnHand,
        quantityPromised,
        alertLevel,
        supplier,
        lastReceivedAt,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'materials';
  @override
  VerificationContext validateIntegrity(Insertable<Material> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('pack_size')) {
      context.handle(_packSizeMeta,
          packSize.isAcceptableOrUnknown(data['pack_size']!, _packSizeMeta));
    } else if (isInserting) {
      context.missing(_packSizeMeta);
    }
    if (data.containsKey('pack_price')) {
      context.handle(_packPriceMeta,
          packPrice.isAcceptableOrUnknown(data['pack_price']!, _packPriceMeta));
    } else if (isInserting) {
      context.missing(_packPriceMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(_unitCostMeta,
          unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta));
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('quantity_on_hand')) {
      context.handle(
          _quantityOnHandMeta,
          quantityOnHand.isAcceptableOrUnknown(
              data['quantity_on_hand']!, _quantityOnHandMeta));
    }
    if (data.containsKey('quantity_promised')) {
      context.handle(
          _quantityPromisedMeta,
          quantityPromised.isAcceptableOrUnknown(
              data['quantity_promised']!, _quantityPromisedMeta));
    }
    if (data.containsKey('alert_level')) {
      context.handle(
          _alertLevelMeta,
          alertLevel.isAcceptableOrUnknown(
              data['alert_level']!, _alertLevelMeta));
    } else if (isInserting) {
      context.missing(_alertLevelMeta);
    }
    if (data.containsKey('supplier')) {
      context.handle(_supplierMeta,
          supplier.isAcceptableOrUnknown(data['supplier']!, _supplierMeta));
    }
    if (data.containsKey('last_received_at')) {
      context.handle(
          _lastReceivedAtMeta,
          lastReceivedAt.isAcceptableOrUnknown(
              data['last_received_at']!, _lastReceivedAtMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Material map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Material(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      packSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pack_size'])!,
      packPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}pack_price'])!,
      unitCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_cost'])!,
      quantityOnHand: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity_on_hand'])!,
      quantityPromised: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity_promised'])!,
      alertLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}alert_level'])!,
      supplier: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}supplier']),
      lastReceivedAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_received_at']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $MaterialsTable createAlias(String alias) {
    return $MaterialsTable(attachedDatabase, alias);
  }
}

class Material extends DataClass implements Insertable<Material> {
  final int id;
  final String name;
  final int packSize;
  final double packPrice;
  final double unitCost;
  final int quantityOnHand;
  final int quantityPromised;
  final int alertLevel;
  final String? supplier;
  final DateTime? lastReceivedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Material(
      {required this.id,
      required this.name,
      required this.packSize,
      required this.packPrice,
      required this.unitCost,
      required this.quantityOnHand,
      required this.quantityPromised,
      required this.alertLevel,
      this.supplier,
      this.lastReceivedAt,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['pack_size'] = Variable<int>(packSize);
    map['pack_price'] = Variable<double>(packPrice);
    map['unit_cost'] = Variable<double>(unitCost);
    map['quantity_on_hand'] = Variable<int>(quantityOnHand);
    map['quantity_promised'] = Variable<int>(quantityPromised);
    map['alert_level'] = Variable<int>(alertLevel);
    if (!nullToAbsent || supplier != null) {
      map['supplier'] = Variable<String>(supplier);
    }
    if (!nullToAbsent || lastReceivedAt != null) {
      map['last_received_at'] = Variable<DateTime>(lastReceivedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MaterialsCompanion toCompanion(bool nullToAbsent) {
    return MaterialsCompanion(
      id: Value(id),
      name: Value(name),
      packSize: Value(packSize),
      packPrice: Value(packPrice),
      unitCost: Value(unitCost),
      quantityOnHand: Value(quantityOnHand),
      quantityPromised: Value(quantityPromised),
      alertLevel: Value(alertLevel),
      supplier: supplier == null && nullToAbsent
          ? const Value.absent()
          : Value(supplier),
      lastReceivedAt: lastReceivedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastReceivedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Material.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Material(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      packSize: serializer.fromJson<int>(json['packSize']),
      packPrice: serializer.fromJson<double>(json['packPrice']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      quantityOnHand: serializer.fromJson<int>(json['quantityOnHand']),
      quantityPromised: serializer.fromJson<int>(json['quantityPromised']),
      alertLevel: serializer.fromJson<int>(json['alertLevel']),
      supplier: serializer.fromJson<String?>(json['supplier']),
      lastReceivedAt: serializer.fromJson<DateTime?>(json['lastReceivedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'packSize': serializer.toJson<int>(packSize),
      'packPrice': serializer.toJson<double>(packPrice),
      'unitCost': serializer.toJson<double>(unitCost),
      'quantityOnHand': serializer.toJson<int>(quantityOnHand),
      'quantityPromised': serializer.toJson<int>(quantityPromised),
      'alertLevel': serializer.toJson<int>(alertLevel),
      'supplier': serializer.toJson<String?>(supplier),
      'lastReceivedAt': serializer.toJson<DateTime?>(lastReceivedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Material copyWith(
          {int? id,
          String? name,
          int? packSize,
          double? packPrice,
          double? unitCost,
          int? quantityOnHand,
          int? quantityPromised,
          int? alertLevel,
          Value<String?> supplier = const Value.absent(),
          Value<DateTime?> lastReceivedAt = const Value.absent(),
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Material(
        id: id ?? this.id,
        name: name ?? this.name,
        packSize: packSize ?? this.packSize,
        packPrice: packPrice ?? this.packPrice,
        unitCost: unitCost ?? this.unitCost,
        quantityOnHand: quantityOnHand ?? this.quantityOnHand,
        quantityPromised: quantityPromised ?? this.quantityPromised,
        alertLevel: alertLevel ?? this.alertLevel,
        supplier: supplier.present ? supplier.value : this.supplier,
        lastReceivedAt:
            lastReceivedAt.present ? lastReceivedAt.value : this.lastReceivedAt,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Material copyWithCompanion(MaterialsCompanion data) {
    return Material(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      packSize: data.packSize.present ? data.packSize.value : this.packSize,
      packPrice: data.packPrice.present ? data.packPrice.value : this.packPrice,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      quantityOnHand: data.quantityOnHand.present
          ? data.quantityOnHand.value
          : this.quantityOnHand,
      quantityPromised: data.quantityPromised.present
          ? data.quantityPromised.value
          : this.quantityPromised,
      alertLevel:
          data.alertLevel.present ? data.alertLevel.value : this.alertLevel,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      lastReceivedAt: data.lastReceivedAt.present
          ? data.lastReceivedAt.value
          : this.lastReceivedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Material(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('packSize: $packSize, ')
          ..write('packPrice: $packPrice, ')
          ..write('unitCost: $unitCost, ')
          ..write('quantityOnHand: $quantityOnHand, ')
          ..write('quantityPromised: $quantityPromised, ')
          ..write('alertLevel: $alertLevel, ')
          ..write('supplier: $supplier, ')
          ..write('lastReceivedAt: $lastReceivedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      packSize,
      packPrice,
      unitCost,
      quantityOnHand,
      quantityPromised,
      alertLevel,
      supplier,
      lastReceivedAt,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Material &&
          other.id == this.id &&
          other.name == this.name &&
          other.packSize == this.packSize &&
          other.packPrice == this.packPrice &&
          other.unitCost == this.unitCost &&
          other.quantityOnHand == this.quantityOnHand &&
          other.quantityPromised == this.quantityPromised &&
          other.alertLevel == this.alertLevel &&
          other.supplier == this.supplier &&
          other.lastReceivedAt == this.lastReceivedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MaterialsCompanion extends UpdateCompanion<Material> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> packSize;
  final Value<double> packPrice;
  final Value<double> unitCost;
  final Value<int> quantityOnHand;
  final Value<int> quantityPromised;
  final Value<int> alertLevel;
  final Value<String?> supplier;
  final Value<DateTime?> lastReceivedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const MaterialsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.packSize = const Value.absent(),
    this.packPrice = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.quantityOnHand = const Value.absent(),
    this.quantityPromised = const Value.absent(),
    this.alertLevel = const Value.absent(),
    this.supplier = const Value.absent(),
    this.lastReceivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MaterialsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int packSize,
    required double packPrice,
    required double unitCost,
    this.quantityOnHand = const Value.absent(),
    this.quantityPromised = const Value.absent(),
    required int alertLevel,
    this.supplier = const Value.absent(),
    this.lastReceivedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : name = Value(name),
        packSize = Value(packSize),
        packPrice = Value(packPrice),
        unitCost = Value(unitCost),
        alertLevel = Value(alertLevel);
  static Insertable<Material> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? packSize,
    Expression<double>? packPrice,
    Expression<double>? unitCost,
    Expression<int>? quantityOnHand,
    Expression<int>? quantityPromised,
    Expression<int>? alertLevel,
    Expression<String>? supplier,
    Expression<DateTime>? lastReceivedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (packSize != null) 'pack_size': packSize,
      if (packPrice != null) 'pack_price': packPrice,
      if (unitCost != null) 'unit_cost': unitCost,
      if (quantityOnHand != null) 'quantity_on_hand': quantityOnHand,
      if (quantityPromised != null) 'quantity_promised': quantityPromised,
      if (alertLevel != null) 'alert_level': alertLevel,
      if (supplier != null) 'supplier': supplier,
      if (lastReceivedAt != null) 'last_received_at': lastReceivedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MaterialsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? packSize,
      Value<double>? packPrice,
      Value<double>? unitCost,
      Value<int>? quantityOnHand,
      Value<int>? quantityPromised,
      Value<int>? alertLevel,
      Value<String?>? supplier,
      Value<DateTime?>? lastReceivedAt,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return MaterialsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      packSize: packSize ?? this.packSize,
      packPrice: packPrice ?? this.packPrice,
      unitCost: unitCost ?? this.unitCost,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      quantityPromised: quantityPromised ?? this.quantityPromised,
      alertLevel: alertLevel ?? this.alertLevel,
      supplier: supplier ?? this.supplier,
      lastReceivedAt: lastReceivedAt ?? this.lastReceivedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (packSize.present) {
      map['pack_size'] = Variable<int>(packSize.value);
    }
    if (packPrice.present) {
      map['pack_price'] = Variable<double>(packPrice.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (quantityOnHand.present) {
      map['quantity_on_hand'] = Variable<int>(quantityOnHand.value);
    }
    if (quantityPromised.present) {
      map['quantity_promised'] = Variable<int>(quantityPromised.value);
    }
    if (alertLevel.present) {
      map['alert_level'] = Variable<int>(alertLevel.value);
    }
    if (supplier.present) {
      map['supplier'] = Variable<String>(supplier.value);
    }
    if (lastReceivedAt.present) {
      map['last_received_at'] = Variable<DateTime>(lastReceivedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaterialsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('packSize: $packSize, ')
          ..write('packPrice: $packPrice, ')
          ..write('unitCost: $unitCost, ')
          ..write('quantityOnHand: $quantityOnHand, ')
          ..write('quantityPromised: $quantityPromised, ')
          ..write('alertLevel: $alertLevel, ')
          ..write('supplier: $supplier, ')
          ..write('lastReceivedAt: $lastReceivedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _descriptionMeta =
      const VerificationMeta('description');
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
      'description', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sellPriceMeta =
      const VerificationMeta('sellPrice');
  @override
  late final GeneratedColumn<double> sellPrice = GeneratedColumn<double>(
      'sell_price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _isStandaloneMeta =
      const VerificationMeta('isStandalone');
  @override
  late final GeneratedColumn<bool> isStandalone = GeneratedColumn<bool>(
      'is_standalone', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_standalone" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _quantityOnHandMeta =
      const VerificationMeta('quantityOnHand');
  @override
  late final GeneratedColumn<int> quantityOnHand = GeneratedColumn<int>(
      'quantity_on_hand', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _quantityPromisedMeta =
      const VerificationMeta('quantityPromised');
  @override
  late final GeneratedColumn<int> quantityPromised = GeneratedColumn<int>(
      'quantity_promised', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _unitCostMeta =
      const VerificationMeta('unitCost');
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
      'unit_cost', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _alertLevelMeta =
      const VerificationMeta('alertLevel');
  @override
  late final GeneratedColumn<int> alertLevel = GeneratedColumn<int>(
      'alert_level', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        description,
        sellPrice,
        isActive,
        isStandalone,
        quantityOnHand,
        quantityPromised,
        unitCost,
        alertLevel,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<Product> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
          _descriptionMeta,
          description.isAcceptableOrUnknown(
              data['description']!, _descriptionMeta));
    }
    if (data.containsKey('sell_price')) {
      context.handle(_sellPriceMeta,
          sellPrice.isAcceptableOrUnknown(data['sell_price']!, _sellPriceMeta));
    } else if (isInserting) {
      context.missing(_sellPriceMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('is_standalone')) {
      context.handle(
          _isStandaloneMeta,
          isStandalone.isAcceptableOrUnknown(
              data['is_standalone']!, _isStandaloneMeta));
    }
    if (data.containsKey('quantity_on_hand')) {
      context.handle(
          _quantityOnHandMeta,
          quantityOnHand.isAcceptableOrUnknown(
              data['quantity_on_hand']!, _quantityOnHandMeta));
    }
    if (data.containsKey('quantity_promised')) {
      context.handle(
          _quantityPromisedMeta,
          quantityPromised.isAcceptableOrUnknown(
              data['quantity_promised']!, _quantityPromisedMeta));
    }
    if (data.containsKey('unit_cost')) {
      context.handle(_unitCostMeta,
          unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta));
    }
    if (data.containsKey('alert_level')) {
      context.handle(
          _alertLevelMeta,
          alertLevel.isAcceptableOrUnknown(
              data['alert_level']!, _alertLevelMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      description: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}description']),
      sellPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sell_price'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      isStandalone: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_standalone'])!,
      quantityOnHand: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity_on_hand'])!,
      quantityPromised: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity_promised'])!,
      unitCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_cost'])!,
      alertLevel: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}alert_level'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final int id;
  final String name;
  final String? description;
  final double sellPrice;
  final bool isActive;
  final bool isStandalone;
  final int quantityOnHand;
  final int quantityPromised;
  final double unitCost;
  final int alertLevel;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Product(
      {required this.id,
      required this.name,
      this.description,
      required this.sellPrice,
      required this.isActive,
      required this.isStandalone,
      required this.quantityOnHand,
      required this.quantityPromised,
      required this.unitCost,
      required this.alertLevel,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['sell_price'] = Variable<double>(sellPrice);
    map['is_active'] = Variable<bool>(isActive);
    map['is_standalone'] = Variable<bool>(isStandalone);
    map['quantity_on_hand'] = Variable<int>(quantityOnHand);
    map['quantity_promised'] = Variable<int>(quantityPromised);
    map['unit_cost'] = Variable<double>(unitCost);
    map['alert_level'] = Variable<int>(alertLevel);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      sellPrice: Value(sellPrice),
      isActive: Value(isActive),
      isStandalone: Value(isStandalone),
      quantityOnHand: Value(quantityOnHand),
      quantityPromised: Value(quantityPromised),
      unitCost: Value(unitCost),
      alertLevel: Value(alertLevel),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      sellPrice: serializer.fromJson<double>(json['sellPrice']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isStandalone: serializer.fromJson<bool>(json['isStandalone']),
      quantityOnHand: serializer.fromJson<int>(json['quantityOnHand']),
      quantityPromised: serializer.fromJson<int>(json['quantityPromised']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      alertLevel: serializer.fromJson<int>(json['alertLevel']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'sellPrice': serializer.toJson<double>(sellPrice),
      'isActive': serializer.toJson<bool>(isActive),
      'isStandalone': serializer.toJson<bool>(isStandalone),
      'quantityOnHand': serializer.toJson<int>(quantityOnHand),
      'quantityPromised': serializer.toJson<int>(quantityPromised),
      'unitCost': serializer.toJson<double>(unitCost),
      'alertLevel': serializer.toJson<int>(alertLevel),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Product copyWith(
          {int? id,
          String? name,
          Value<String?> description = const Value.absent(),
          double? sellPrice,
          bool? isActive,
          bool? isStandalone,
          int? quantityOnHand,
          int? quantityPromised,
          double? unitCost,
          int? alertLevel,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description.present ? description.value : this.description,
        sellPrice: sellPrice ?? this.sellPrice,
        isActive: isActive ?? this.isActive,
        isStandalone: isStandalone ?? this.isStandalone,
        quantityOnHand: quantityOnHand ?? this.quantityOnHand,
        quantityPromised: quantityPromised ?? this.quantityPromised,
        unitCost: unitCost ?? this.unitCost,
        alertLevel: alertLevel ?? this.alertLevel,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      sellPrice: data.sellPrice.present ? data.sellPrice.value : this.sellPrice,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isStandalone: data.isStandalone.present
          ? data.isStandalone.value
          : this.isStandalone,
      quantityOnHand: data.quantityOnHand.present
          ? data.quantityOnHand.value
          : this.quantityOnHand,
      quantityPromised: data.quantityPromised.present
          ? data.quantityPromised.value
          : this.quantityPromised,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      alertLevel:
          data.alertLevel.present ? data.alertLevel.value : this.alertLevel,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sellPrice: $sellPrice, ')
          ..write('isActive: $isActive, ')
          ..write('isStandalone: $isStandalone, ')
          ..write('quantityOnHand: $quantityOnHand, ')
          ..write('quantityPromised: $quantityPromised, ')
          ..write('unitCost: $unitCost, ')
          ..write('alertLevel: $alertLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      description,
      sellPrice,
      isActive,
      isStandalone,
      quantityOnHand,
      quantityPromised,
      unitCost,
      alertLevel,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.sellPrice == this.sellPrice &&
          other.isActive == this.isActive &&
          other.isStandalone == this.isStandalone &&
          other.quantityOnHand == this.quantityOnHand &&
          other.quantityPromised == this.quantityPromised &&
          other.unitCost == this.unitCost &&
          other.alertLevel == this.alertLevel &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<double> sellPrice;
  final Value<bool> isActive;
  final Value<bool> isStandalone;
  final Value<int> quantityOnHand;
  final Value<int> quantityPromised;
  final Value<double> unitCost;
  final Value<int> alertLevel;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.sellPrice = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isStandalone = const Value.absent(),
    this.quantityOnHand = const Value.absent(),
    this.quantityPromised = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.alertLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    required double sellPrice,
    this.isActive = const Value.absent(),
    this.isStandalone = const Value.absent(),
    this.quantityOnHand = const Value.absent(),
    this.quantityPromised = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.alertLevel = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  })  : name = Value(name),
        sellPrice = Value(sellPrice);
  static Insertable<Product> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<double>? sellPrice,
    Expression<bool>? isActive,
    Expression<bool>? isStandalone,
    Expression<int>? quantityOnHand,
    Expression<int>? quantityPromised,
    Expression<double>? unitCost,
    Expression<int>? alertLevel,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (sellPrice != null) 'sell_price': sellPrice,
      if (isActive != null) 'is_active': isActive,
      if (isStandalone != null) 'is_standalone': isStandalone,
      if (quantityOnHand != null) 'quantity_on_hand': quantityOnHand,
      if (quantityPromised != null) 'quantity_promised': quantityPromised,
      if (unitCost != null) 'unit_cost': unitCost,
      if (alertLevel != null) 'alert_level': alertLevel,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProductsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? description,
      Value<double>? sellPrice,
      Value<bool>? isActive,
      Value<bool>? isStandalone,
      Value<int>? quantityOnHand,
      Value<int>? quantityPromised,
      Value<double>? unitCost,
      Value<int>? alertLevel,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      sellPrice: sellPrice ?? this.sellPrice,
      isActive: isActive ?? this.isActive,
      isStandalone: isStandalone ?? this.isStandalone,
      quantityOnHand: quantityOnHand ?? this.quantityOnHand,
      quantityPromised: quantityPromised ?? this.quantityPromised,
      unitCost: unitCost ?? this.unitCost,
      alertLevel: alertLevel ?? this.alertLevel,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (sellPrice.present) {
      map['sell_price'] = Variable<double>(sellPrice.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (isStandalone.present) {
      map['is_standalone'] = Variable<bool>(isStandalone.value);
    }
    if (quantityOnHand.present) {
      map['quantity_on_hand'] = Variable<int>(quantityOnHand.value);
    }
    if (quantityPromised.present) {
      map['quantity_promised'] = Variable<int>(quantityPromised.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (alertLevel.present) {
      map['alert_level'] = Variable<int>(alertLevel.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('sellPrice: $sellPrice, ')
          ..write('isActive: $isActive, ')
          ..write('isStandalone: $isStandalone, ')
          ..write('quantityOnHand: $quantityOnHand, ')
          ..write('quantityPromised: $quantityPromised, ')
          ..write('unitCost: $unitCost, ')
          ..write('alertLevel: $alertLevel, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $BomItemsTable extends BomItems with TableInfo<$BomItemsTable, BomItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BomItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _materialIdMeta =
      const VerificationMeta('materialId');
  @override
  late final GeneratedColumn<int> materialId = GeneratedColumn<int>(
      'material_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _quantityRequiredMeta =
      const VerificationMeta('quantityRequired');
  @override
  late final GeneratedColumn<int> quantityRequired = GeneratedColumn<int>(
      'quantity_required', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, productId, materialId, quantityRequired, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bom_items';
  @override
  VerificationContext validateIntegrity(Insertable<BomItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('material_id')) {
      context.handle(
          _materialIdMeta,
          materialId.isAcceptableOrUnknown(
              data['material_id']!, _materialIdMeta));
    } else if (isInserting) {
      context.missing(_materialIdMeta);
    }
    if (data.containsKey('quantity_required')) {
      context.handle(
          _quantityRequiredMeta,
          quantityRequired.isAcceptableOrUnknown(
              data['quantity_required']!, _quantityRequiredMeta));
    } else if (isInserting) {
      context.missing(_quantityRequiredMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BomItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BomItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      materialId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}material_id'])!,
      quantityRequired: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity_required'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $BomItemsTable createAlias(String alias) {
    return $BomItemsTable(attachedDatabase, alias);
  }
}

class BomItem extends DataClass implements Insertable<BomItem> {
  final int id;
  final int productId;
  final int materialId;
  final int quantityRequired;
  final DateTime createdAt;
  const BomItem(
      {required this.id,
      required this.productId,
      required this.materialId,
      required this.quantityRequired,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<int>(productId);
    map['material_id'] = Variable<int>(materialId);
    map['quantity_required'] = Variable<int>(quantityRequired);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  BomItemsCompanion toCompanion(bool nullToAbsent) {
    return BomItemsCompanion(
      id: Value(id),
      productId: Value(productId),
      materialId: Value(materialId),
      quantityRequired: Value(quantityRequired),
      createdAt: Value(createdAt),
    );
  }

  factory BomItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BomItem(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int>(json['productId']),
      materialId: serializer.fromJson<int>(json['materialId']),
      quantityRequired: serializer.fromJson<int>(json['quantityRequired']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int>(productId),
      'materialId': serializer.toJson<int>(materialId),
      'quantityRequired': serializer.toJson<int>(quantityRequired),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  BomItem copyWith(
          {int? id,
          int? productId,
          int? materialId,
          int? quantityRequired,
          DateTime? createdAt}) =>
      BomItem(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        materialId: materialId ?? this.materialId,
        quantityRequired: quantityRequired ?? this.quantityRequired,
        createdAt: createdAt ?? this.createdAt,
      );
  BomItem copyWithCompanion(BomItemsCompanion data) {
    return BomItem(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      materialId:
          data.materialId.present ? data.materialId.value : this.materialId,
      quantityRequired: data.quantityRequired.present
          ? data.quantityRequired.value
          : this.quantityRequired,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BomItem(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('materialId: $materialId, ')
          ..write('quantityRequired: $quantityRequired, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, productId, materialId, quantityRequired, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BomItem &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.materialId == this.materialId &&
          other.quantityRequired == this.quantityRequired &&
          other.createdAt == this.createdAt);
}

class BomItemsCompanion extends UpdateCompanion<BomItem> {
  final Value<int> id;
  final Value<int> productId;
  final Value<int> materialId;
  final Value<int> quantityRequired;
  final Value<DateTime> createdAt;
  const BomItemsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.materialId = const Value.absent(),
    this.quantityRequired = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BomItemsCompanion.insert({
    this.id = const Value.absent(),
    required int productId,
    required int materialId,
    required int quantityRequired,
    this.createdAt = const Value.absent(),
  })  : productId = Value(productId),
        materialId = Value(materialId),
        quantityRequired = Value(quantityRequired);
  static Insertable<BomItem> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<int>? materialId,
    Expression<int>? quantityRequired,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (materialId != null) 'material_id': materialId,
      if (quantityRequired != null) 'quantity_required': quantityRequired,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BomItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? productId,
      Value<int>? materialId,
      Value<int>? quantityRequired,
      Value<DateTime>? createdAt}) {
    return BomItemsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      materialId: materialId ?? this.materialId,
      quantityRequired: quantityRequired ?? this.quantityRequired,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (materialId.present) {
      map['material_id'] = Variable<int>(materialId.value);
    }
    if (quantityRequired.present) {
      map['quantity_required'] = Variable<int>(quantityRequired.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BomItemsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('materialId: $materialId, ')
          ..write('quantityRequired: $quantityRequired, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ChannelsTable extends Channels with TableInfo<$ChannelsTable, Channel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChannelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _commissionRateMeta =
      const VerificationMeta('commissionRate');
  @override
  late final GeneratedColumn<double> commissionRate = GeneratedColumn<double>(
      'commission_rate', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _transactionFeeRateMeta =
      const VerificationMeta('transactionFeeRate');
  @override
  late final GeneratedColumn<double> transactionFeeRate =
      GeneratedColumn<double>('transaction_fee_rate', aliasedName, false,
          type: DriftSqlType.double,
          requiredDuringInsert: false,
          defaultValue: const Constant(0.0));
  static const VerificationMeta _flatFeeMeta =
      const VerificationMeta('flatFee');
  @override
  late final GeneratedColumn<double> flatFee = GeneratedColumn<double>(
      'flat_fee', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _shippingPaidByUsMeta =
      const VerificationMeta('shippingPaidByUs');
  @override
  late final GeneratedColumn<double> shippingPaidByUs = GeneratedColumn<double>(
      'shipping_paid_by_us', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0.0));
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
      'is_active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_active" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        commissionRate,
        transactionFeeRate,
        flatFee,
        shippingPaidByUs,
        isActive,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'channels';
  @override
  VerificationContext validateIntegrity(Insertable<Channel> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('commission_rate')) {
      context.handle(
          _commissionRateMeta,
          commissionRate.isAcceptableOrUnknown(
              data['commission_rate']!, _commissionRateMeta));
    }
    if (data.containsKey('transaction_fee_rate')) {
      context.handle(
          _transactionFeeRateMeta,
          transactionFeeRate.isAcceptableOrUnknown(
              data['transaction_fee_rate']!, _transactionFeeRateMeta));
    }
    if (data.containsKey('flat_fee')) {
      context.handle(_flatFeeMeta,
          flatFee.isAcceptableOrUnknown(data['flat_fee']!, _flatFeeMeta));
    }
    if (data.containsKey('shipping_paid_by_us')) {
      context.handle(
          _shippingPaidByUsMeta,
          shippingPaidByUs.isAcceptableOrUnknown(
              data['shipping_paid_by_us']!, _shippingPaidByUsMeta));
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Channel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Channel(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      commissionRate: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}commission_rate'])!,
      transactionFeeRate: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}transaction_fee_rate'])!,
      flatFee: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}flat_fee'])!,
      shippingPaidByUs: attachedDatabase.typeMapping.read(
          DriftSqlType.double, data['${effectivePrefix}shipping_paid_by_us'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_active'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $ChannelsTable createAlias(String alias) {
    return $ChannelsTable(attachedDatabase, alias);
  }
}

class Channel extends DataClass implements Insertable<Channel> {
  final int id;
  final String name;
  final double commissionRate;
  final double transactionFeeRate;
  final double flatFee;
  final double shippingPaidByUs;
  final bool isActive;
  final DateTime createdAt;
  const Channel(
      {required this.id,
      required this.name,
      required this.commissionRate,
      required this.transactionFeeRate,
      required this.flatFee,
      required this.shippingPaidByUs,
      required this.isActive,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['commission_rate'] = Variable<double>(commissionRate);
    map['transaction_fee_rate'] = Variable<double>(transactionFeeRate);
    map['flat_fee'] = Variable<double>(flatFee);
    map['shipping_paid_by_us'] = Variable<double>(shippingPaidByUs);
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ChannelsCompanion toCompanion(bool nullToAbsent) {
    return ChannelsCompanion(
      id: Value(id),
      name: Value(name),
      commissionRate: Value(commissionRate),
      transactionFeeRate: Value(transactionFeeRate),
      flatFee: Value(flatFee),
      shippingPaidByUs: Value(shippingPaidByUs),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory Channel.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Channel(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      commissionRate: serializer.fromJson<double>(json['commissionRate']),
      transactionFeeRate:
          serializer.fromJson<double>(json['transactionFeeRate']),
      flatFee: serializer.fromJson<double>(json['flatFee']),
      shippingPaidByUs: serializer.fromJson<double>(json['shippingPaidByUs']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'commissionRate': serializer.toJson<double>(commissionRate),
      'transactionFeeRate': serializer.toJson<double>(transactionFeeRate),
      'flatFee': serializer.toJson<double>(flatFee),
      'shippingPaidByUs': serializer.toJson<double>(shippingPaidByUs),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Channel copyWith(
          {int? id,
          String? name,
          double? commissionRate,
          double? transactionFeeRate,
          double? flatFee,
          double? shippingPaidByUs,
          bool? isActive,
          DateTime? createdAt}) =>
      Channel(
        id: id ?? this.id,
        name: name ?? this.name,
        commissionRate: commissionRate ?? this.commissionRate,
        transactionFeeRate: transactionFeeRate ?? this.transactionFeeRate,
        flatFee: flatFee ?? this.flatFee,
        shippingPaidByUs: shippingPaidByUs ?? this.shippingPaidByUs,
        isActive: isActive ?? this.isActive,
        createdAt: createdAt ?? this.createdAt,
      );
  Channel copyWithCompanion(ChannelsCompanion data) {
    return Channel(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      commissionRate: data.commissionRate.present
          ? data.commissionRate.value
          : this.commissionRate,
      transactionFeeRate: data.transactionFeeRate.present
          ? data.transactionFeeRate.value
          : this.transactionFeeRate,
      flatFee: data.flatFee.present ? data.flatFee.value : this.flatFee,
      shippingPaidByUs: data.shippingPaidByUs.present
          ? data.shippingPaidByUs.value
          : this.shippingPaidByUs,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Channel(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('commissionRate: $commissionRate, ')
          ..write('transactionFeeRate: $transactionFeeRate, ')
          ..write('flatFee: $flatFee, ')
          ..write('shippingPaidByUs: $shippingPaidByUs, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, commissionRate, transactionFeeRate,
      flatFee, shippingPaidByUs, isActive, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Channel &&
          other.id == this.id &&
          other.name == this.name &&
          other.commissionRate == this.commissionRate &&
          other.transactionFeeRate == this.transactionFeeRate &&
          other.flatFee == this.flatFee &&
          other.shippingPaidByUs == this.shippingPaidByUs &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class ChannelsCompanion extends UpdateCompanion<Channel> {
  final Value<int> id;
  final Value<String> name;
  final Value<double> commissionRate;
  final Value<double> transactionFeeRate;
  final Value<double> flatFee;
  final Value<double> shippingPaidByUs;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  const ChannelsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.commissionRate = const Value.absent(),
    this.transactionFeeRate = const Value.absent(),
    this.flatFee = const Value.absent(),
    this.shippingPaidByUs = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ChannelsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.commissionRate = const Value.absent(),
    this.transactionFeeRate = const Value.absent(),
    this.flatFee = const Value.absent(),
    this.shippingPaidByUs = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Channel> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<double>? commissionRate,
    Expression<double>? transactionFeeRate,
    Expression<double>? flatFee,
    Expression<double>? shippingPaidByUs,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (commissionRate != null) 'commission_rate': commissionRate,
      if (transactionFeeRate != null)
        'transaction_fee_rate': transactionFeeRate,
      if (flatFee != null) 'flat_fee': flatFee,
      if (shippingPaidByUs != null) 'shipping_paid_by_us': shippingPaidByUs,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ChannelsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<double>? commissionRate,
      Value<double>? transactionFeeRate,
      Value<double>? flatFee,
      Value<double>? shippingPaidByUs,
      Value<bool>? isActive,
      Value<DateTime>? createdAt}) {
    return ChannelsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      commissionRate: commissionRate ?? this.commissionRate,
      transactionFeeRate: transactionFeeRate ?? this.transactionFeeRate,
      flatFee: flatFee ?? this.flatFee,
      shippingPaidByUs: shippingPaidByUs ?? this.shippingPaidByUs,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (commissionRate.present) {
      map['commission_rate'] = Variable<double>(commissionRate.value);
    }
    if (transactionFeeRate.present) {
      map['transaction_fee_rate'] = Variable<double>(transactionFeeRate.value);
    }
    if (flatFee.present) {
      map['flat_fee'] = Variable<double>(flatFee.value);
    }
    if (shippingPaidByUs.present) {
      map['shipping_paid_by_us'] = Variable<double>(shippingPaidByUs.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChannelsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('commissionRate: $commissionRate, ')
          ..write('transactionFeeRate: $transactionFeeRate, ')
          ..write('flatFee: $flatFee, ')
          ..write('shippingPaidByUs: $shippingPaidByUs, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _materialIdMeta =
      const VerificationMeta('materialId');
  @override
  late final GeneratedColumn<int> materialId = GeneratedColumn<int>(
      'material_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitCostMeta =
      const VerificationMeta('unitCost');
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
      'unit_cost', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _referenceMeta =
      const VerificationMeta('reference');
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
      'reference', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, materialId, orderId, type, quantity, unitCost, createdAt, reference];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(Insertable<StockMovement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('material_id')) {
      context.handle(
          _materialIdMeta,
          materialId.isAcceptableOrUnknown(
              data['material_id']!, _materialIdMeta));
    } else if (isInserting) {
      context.missing(_materialIdMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(_unitCostMeta,
          unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta));
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('reference')) {
      context.handle(_referenceMeta,
          reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      materialId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}material_id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_cost'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      reference: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference']),
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovement extends DataClass implements Insertable<StockMovement> {
  final int id;
  final int materialId;
  final int? orderId;
  final String type;
  final int quantity;
  final double unitCost;
  final DateTime createdAt;
  final String? reference;
  const StockMovement(
      {required this.id,
      required this.materialId,
      this.orderId,
      required this.type,
      required this.quantity,
      required this.unitCost,
      required this.createdAt,
      this.reference});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['material_id'] = Variable<int>(materialId);
    if (!nullToAbsent || orderId != null) {
      map['order_id'] = Variable<int>(orderId);
    }
    map['type'] = Variable<String>(type);
    map['quantity'] = Variable<int>(quantity);
    map['unit_cost'] = Variable<double>(unitCost);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      materialId: Value(materialId),
      orderId: orderId == null && nullToAbsent
          ? const Value.absent()
          : Value(orderId),
      type: Value(type),
      quantity: Value(quantity),
      unitCost: Value(unitCost),
      createdAt: Value(createdAt),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
    );
  }

  factory StockMovement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovement(
      id: serializer.fromJson<int>(json['id']),
      materialId: serializer.fromJson<int>(json['materialId']),
      orderId: serializer.fromJson<int?>(json['orderId']),
      type: serializer.fromJson<String>(json['type']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      reference: serializer.fromJson<String?>(json['reference']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'materialId': serializer.toJson<int>(materialId),
      'orderId': serializer.toJson<int?>(orderId),
      'type': serializer.toJson<String>(type),
      'quantity': serializer.toJson<int>(quantity),
      'unitCost': serializer.toJson<double>(unitCost),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'reference': serializer.toJson<String?>(reference),
    };
  }

  StockMovement copyWith(
          {int? id,
          int? materialId,
          Value<int?> orderId = const Value.absent(),
          String? type,
          int? quantity,
          double? unitCost,
          DateTime? createdAt,
          Value<String?> reference = const Value.absent()}) =>
      StockMovement(
        id: id ?? this.id,
        materialId: materialId ?? this.materialId,
        orderId: orderId.present ? orderId.value : this.orderId,
        type: type ?? this.type,
        quantity: quantity ?? this.quantity,
        unitCost: unitCost ?? this.unitCost,
        createdAt: createdAt ?? this.createdAt,
        reference: reference.present ? reference.value : this.reference,
      );
  StockMovement copyWithCompanion(StockMovementsCompanion data) {
    return StockMovement(
      id: data.id.present ? data.id.value : this.id,
      materialId:
          data.materialId.present ? data.materialId.value : this.materialId,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      type: data.type.present ? data.type.value : this.type,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      reference: data.reference.present ? data.reference.value : this.reference,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovement(')
          ..write('id: $id, ')
          ..write('materialId: $materialId, ')
          ..write('orderId: $orderId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('createdAt: $createdAt, ')
          ..write('reference: $reference')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, materialId, orderId, type, quantity, unitCost, createdAt, reference);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovement &&
          other.id == this.id &&
          other.materialId == this.materialId &&
          other.orderId == this.orderId &&
          other.type == this.type &&
          other.quantity == this.quantity &&
          other.unitCost == this.unitCost &&
          other.createdAt == this.createdAt &&
          other.reference == this.reference);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovement> {
  final Value<int> id;
  final Value<int> materialId;
  final Value<int?> orderId;
  final Value<String> type;
  final Value<int> quantity;
  final Value<double> unitCost;
  final Value<DateTime> createdAt;
  final Value<String?> reference;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.materialId = const Value.absent(),
    this.orderId = const Value.absent(),
    this.type = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.reference = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    this.id = const Value.absent(),
    required int materialId,
    this.orderId = const Value.absent(),
    required String type,
    required int quantity,
    required double unitCost,
    this.createdAt = const Value.absent(),
    this.reference = const Value.absent(),
  })  : materialId = Value(materialId),
        type = Value(type),
        quantity = Value(quantity),
        unitCost = Value(unitCost);
  static Insertable<StockMovement> custom({
    Expression<int>? id,
    Expression<int>? materialId,
    Expression<int>? orderId,
    Expression<String>? type,
    Expression<int>? quantity,
    Expression<double>? unitCost,
    Expression<DateTime>? createdAt,
    Expression<String>? reference,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (materialId != null) 'material_id': materialId,
      if (orderId != null) 'order_id': orderId,
      if (type != null) 'type': type,
      if (quantity != null) 'quantity': quantity,
      if (unitCost != null) 'unit_cost': unitCost,
      if (createdAt != null) 'created_at': createdAt,
      if (reference != null) 'reference': reference,
    });
  }

  StockMovementsCompanion copyWith(
      {Value<int>? id,
      Value<int>? materialId,
      Value<int?>? orderId,
      Value<String>? type,
      Value<int>? quantity,
      Value<double>? unitCost,
      Value<DateTime>? createdAt,
      Value<String?>? reference}) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      materialId: materialId ?? this.materialId,
      orderId: orderId ?? this.orderId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      createdAt: createdAt ?? this.createdAt,
      reference: reference ?? this.reference,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (materialId.present) {
      map['material_id'] = Variable<int>(materialId.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('materialId: $materialId, ')
          ..write('orderId: $orderId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('createdAt: $createdAt, ')
          ..write('reference: $reference')
          ..write(')'))
        .toString();
  }
}

class $ProductStockMovementsTable extends ProductStockMovements
    with TableInfo<$ProductStockMovementsTable, ProductStockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductStockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _quantityMeta =
      const VerificationMeta('quantity');
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
      'quantity', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _unitCostMeta =
      const VerificationMeta('unitCost');
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
      'unit_cost', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _referenceMeta =
      const VerificationMeta('reference');
  @override
  late final GeneratedColumn<String> reference = GeneratedColumn<String>(
      'reference', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, productId, orderId, type, quantity, unitCost, createdAt, reference];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'product_stock_movements';
  @override
  VerificationContext validateIntegrity(
      Insertable<ProductStockMovement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(_quantityMeta,
          quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta));
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(_unitCostMeta,
          unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta));
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('reference')) {
      context.handle(_referenceMeta,
          reference.isAcceptableOrUnknown(data['reference']!, _referenceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProductStockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductStockMovement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id']),
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      quantity: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quantity'])!,
      unitCost: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}unit_cost'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      reference: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reference']),
    );
  }

  @override
  $ProductStockMovementsTable createAlias(String alias) {
    return $ProductStockMovementsTable(attachedDatabase, alias);
  }
}

class ProductStockMovement extends DataClass
    implements Insertable<ProductStockMovement> {
  final int id;
  final int productId;
  final int? orderId;
  final String type;
  final int quantity;
  final double unitCost;
  final DateTime createdAt;
  final String? reference;
  const ProductStockMovement(
      {required this.id,
      required this.productId,
      this.orderId,
      required this.type,
      required this.quantity,
      required this.unitCost,
      required this.createdAt,
      this.reference});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<int>(productId);
    if (!nullToAbsent || orderId != null) {
      map['order_id'] = Variable<int>(orderId);
    }
    map['type'] = Variable<String>(type);
    map['quantity'] = Variable<int>(quantity);
    map['unit_cost'] = Variable<double>(unitCost);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || reference != null) {
      map['reference'] = Variable<String>(reference);
    }
    return map;
  }

  ProductStockMovementsCompanion toCompanion(bool nullToAbsent) {
    return ProductStockMovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      orderId: orderId == null && nullToAbsent
          ? const Value.absent()
          : Value(orderId),
      type: Value(type),
      quantity: Value(quantity),
      unitCost: Value(unitCost),
      createdAt: Value(createdAt),
      reference: reference == null && nullToAbsent
          ? const Value.absent()
          : Value(reference),
    );
  }

  factory ProductStockMovement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductStockMovement(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int>(json['productId']),
      orderId: serializer.fromJson<int?>(json['orderId']),
      type: serializer.fromJson<String>(json['type']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      reference: serializer.fromJson<String?>(json['reference']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int>(productId),
      'orderId': serializer.toJson<int?>(orderId),
      'type': serializer.toJson<String>(type),
      'quantity': serializer.toJson<int>(quantity),
      'unitCost': serializer.toJson<double>(unitCost),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'reference': serializer.toJson<String?>(reference),
    };
  }

  ProductStockMovement copyWith(
          {int? id,
          int? productId,
          Value<int?> orderId = const Value.absent(),
          String? type,
          int? quantity,
          double? unitCost,
          DateTime? createdAt,
          Value<String?> reference = const Value.absent()}) =>
      ProductStockMovement(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        orderId: orderId.present ? orderId.value : this.orderId,
        type: type ?? this.type,
        quantity: quantity ?? this.quantity,
        unitCost: unitCost ?? this.unitCost,
        createdAt: createdAt ?? this.createdAt,
        reference: reference.present ? reference.value : this.reference,
      );
  ProductStockMovement copyWithCompanion(ProductStockMovementsCompanion data) {
    return ProductStockMovement(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      type: data.type.present ? data.type.value : this.type,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      reference: data.reference.present ? data.reference.value : this.reference,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductStockMovement(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('orderId: $orderId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('createdAt: $createdAt, ')
          ..write('reference: $reference')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, productId, orderId, type, quantity, unitCost, createdAt, reference);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductStockMovement &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.orderId == this.orderId &&
          other.type == this.type &&
          other.quantity == this.quantity &&
          other.unitCost == this.unitCost &&
          other.createdAt == this.createdAt &&
          other.reference == this.reference);
}

class ProductStockMovementsCompanion
    extends UpdateCompanion<ProductStockMovement> {
  final Value<int> id;
  final Value<int> productId;
  final Value<int?> orderId;
  final Value<String> type;
  final Value<int> quantity;
  final Value<double> unitCost;
  final Value<DateTime> createdAt;
  final Value<String?> reference;
  const ProductStockMovementsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.orderId = const Value.absent(),
    this.type = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.reference = const Value.absent(),
  });
  ProductStockMovementsCompanion.insert({
    this.id = const Value.absent(),
    required int productId,
    this.orderId = const Value.absent(),
    required String type,
    required int quantity,
    required double unitCost,
    this.createdAt = const Value.absent(),
    this.reference = const Value.absent(),
  })  : productId = Value(productId),
        type = Value(type),
        quantity = Value(quantity),
        unitCost = Value(unitCost);
  static Insertable<ProductStockMovement> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<int>? orderId,
    Expression<String>? type,
    Expression<int>? quantity,
    Expression<double>? unitCost,
    Expression<DateTime>? createdAt,
    Expression<String>? reference,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (orderId != null) 'order_id': orderId,
      if (type != null) 'type': type,
      if (quantity != null) 'quantity': quantity,
      if (unitCost != null) 'unit_cost': unitCost,
      if (createdAt != null) 'created_at': createdAt,
      if (reference != null) 'reference': reference,
    });
  }

  ProductStockMovementsCompanion copyWith(
      {Value<int>? id,
      Value<int>? productId,
      Value<int?>? orderId,
      Value<String>? type,
      Value<int>? quantity,
      Value<double>? unitCost,
      Value<DateTime>? createdAt,
      Value<String?>? reference}) {
    return ProductStockMovementsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      orderId: orderId ?? this.orderId,
      type: type ?? this.type,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      createdAt: createdAt ?? this.createdAt,
      reference: reference ?? this.reference,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (reference.present) {
      map['reference'] = Variable<String>(reference.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductStockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('orderId: $orderId, ')
          ..write('type: $type, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('createdAt: $createdAt, ')
          ..write('reference: $reference')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'));
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns => [id, key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(Insertable<Setting> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final String key;
  final String value;
  final DateTime updatedAt;
  const Setting(
      {required this.id,
      required this.key,
      required this.value,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory Setting.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Setting copyWith(
          {int? id, String? key, String? value, DateTime? updatedAt}) =>
      Setting(
        id: id ?? this.id,
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    required String key,
    required String value,
    this.updatedAt = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SettingsCompanion copyWith(
      {Value<int>? id,
      Value<String>? key,
      Value<String>? value,
      Value<DateTime>? updatedAt}) {
    return SettingsCompanion(
      id: id ?? this.id,
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $OrderFieldDefinitionsTable extends OrderFieldDefinitions
    with TableInfo<$OrderFieldDefinitionsTable, OrderFieldDefinition> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderFieldDefinitionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _optionsMeta =
      const VerificationMeta('options');
  @override
  late final GeneratedColumn<String> options = GeneratedColumn<String>(
      'options', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isMultilineMeta =
      const VerificationMeta('isMultiline');
  @override
  late final GeneratedColumn<bool> isMultiline = GeneratedColumn<bool>(
      'is_multiline', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_multiline" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isArchivedMeta =
      const VerificationMeta('isArchived');
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
      'is_archived', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_archived" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, type, options, isMultiline, position, isArchived, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_field_definitions';
  @override
  VerificationContext validateIntegrity(
      Insertable<OrderFieldDefinition> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('options')) {
      context.handle(_optionsMeta,
          options.isAcceptableOrUnknown(data['options']!, _optionsMeta));
    }
    if (data.containsKey('is_multiline')) {
      context.handle(
          _isMultilineMeta,
          isMultiline.isAcceptableOrUnknown(
              data['is_multiline']!, _isMultilineMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    if (data.containsKey('is_archived')) {
      context.handle(
          _isArchivedMeta,
          isArchived.isAcceptableOrUnknown(
              data['is_archived']!, _isArchivedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OrderFieldDefinition map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderFieldDefinition(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      options: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}options']),
      isMultiline: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_multiline'])!,
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
      isArchived: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_archived'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $OrderFieldDefinitionsTable createAlias(String alias) {
    return $OrderFieldDefinitionsTable(attachedDatabase, alias);
  }
}

class OrderFieldDefinition extends DataClass
    implements Insertable<OrderFieldDefinition> {
  final int id;
  final String name;

  /// 'text' | 'number' | 'date' | 'choice'
  final String type;

  /// JSON list of option labels; only set for choice fields.
  final String? options;
  final bool isMultiline;
  final int position;

  /// Archived fields are no longer asked for, but past orders keep their
  /// values.
  final bool isArchived;
  final DateTime createdAt;
  const OrderFieldDefinition(
      {required this.id,
      required this.name,
      required this.type,
      this.options,
      required this.isMultiline,
      required this.position,
      required this.isArchived,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || options != null) {
      map['options'] = Variable<String>(options);
    }
    map['is_multiline'] = Variable<bool>(isMultiline);
    map['position'] = Variable<int>(position);
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OrderFieldDefinitionsCompanion toCompanion(bool nullToAbsent) {
    return OrderFieldDefinitionsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      options: options == null && nullToAbsent
          ? const Value.absent()
          : Value(options),
      isMultiline: Value(isMultiline),
      position: Value(position),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
    );
  }

  factory OrderFieldDefinition.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderFieldDefinition(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      options: serializer.fromJson<String?>(json['options']),
      isMultiline: serializer.fromJson<bool>(json['isMultiline']),
      position: serializer.fromJson<int>(json['position']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'options': serializer.toJson<String?>(options),
      'isMultiline': serializer.toJson<bool>(isMultiline),
      'position': serializer.toJson<int>(position),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OrderFieldDefinition copyWith(
          {int? id,
          String? name,
          String? type,
          Value<String?> options = const Value.absent(),
          bool? isMultiline,
          int? position,
          bool? isArchived,
          DateTime? createdAt}) =>
      OrderFieldDefinition(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        options: options.present ? options.value : this.options,
        isMultiline: isMultiline ?? this.isMultiline,
        position: position ?? this.position,
        isArchived: isArchived ?? this.isArchived,
        createdAt: createdAt ?? this.createdAt,
      );
  OrderFieldDefinition copyWithCompanion(OrderFieldDefinitionsCompanion data) {
    return OrderFieldDefinition(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      options: data.options.present ? data.options.value : this.options,
      isMultiline:
          data.isMultiline.present ? data.isMultiline.value : this.isMultiline,
      position: data.position.present ? data.position.value : this.position,
      isArchived:
          data.isArchived.present ? data.isArchived.value : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderFieldDefinition(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('options: $options, ')
          ..write('isMultiline: $isMultiline, ')
          ..write('position: $position, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, type, options, isMultiline, position, isArchived, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderFieldDefinition &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.options == this.options &&
          other.isMultiline == this.isMultiline &&
          other.position == this.position &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt);
}

class OrderFieldDefinitionsCompanion
    extends UpdateCompanion<OrderFieldDefinition> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> options;
  final Value<bool> isMultiline;
  final Value<int> position;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  const OrderFieldDefinitionsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.options = const Value.absent(),
    this.isMultiline = const Value.absent(),
    this.position = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  OrderFieldDefinitionsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    this.options = const Value.absent(),
    this.isMultiline = const Value.absent(),
    this.position = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  })  : name = Value(name),
        type = Value(type);
  static Insertable<OrderFieldDefinition> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? options,
    Expression<bool>? isMultiline,
    Expression<int>? position,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (options != null) 'options': options,
      if (isMultiline != null) 'is_multiline': isMultiline,
      if (position != null) 'position': position,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  OrderFieldDefinitionsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? type,
      Value<String?>? options,
      Value<bool>? isMultiline,
      Value<int>? position,
      Value<bool>? isArchived,
      Value<DateTime>? createdAt}) {
    return OrderFieldDefinitionsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      options: options ?? this.options,
      isMultiline: isMultiline ?? this.isMultiline,
      position: position ?? this.position,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (options.present) {
      map['options'] = Variable<String>(options.value);
    }
    if (isMultiline.present) {
      map['is_multiline'] = Variable<bool>(isMultiline.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderFieldDefinitionsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('options: $options, ')
          ..write('isMultiline: $isMultiline, ')
          ..write('position: $position, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $OrderFieldValuesTable extends OrderFieldValues
    with TableInfo<$OrderFieldValuesTable, OrderFieldValue> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OrderFieldValuesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _orderIdMeta =
      const VerificationMeta('orderId');
  @override
  late final GeneratedColumn<int> orderId = GeneratedColumn<int>(
      'order_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES orders (id) ON DELETE CASCADE'));
  static const VerificationMeta _fieldIdMeta =
      const VerificationMeta('fieldId');
  @override
  late final GeneratedColumn<int> fieldId = GeneratedColumn<int>(
      'field_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES order_field_definitions (id)'));
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [orderId, fieldId, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'order_field_values';
  @override
  VerificationContext validateIntegrity(Insertable<OrderFieldValue> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('order_id')) {
      context.handle(_orderIdMeta,
          orderId.isAcceptableOrUnknown(data['order_id']!, _orderIdMeta));
    } else if (isInserting) {
      context.missing(_orderIdMeta);
    }
    if (data.containsKey('field_id')) {
      context.handle(_fieldIdMeta,
          fieldId.isAcceptableOrUnknown(data['field_id']!, _fieldIdMeta));
    } else if (isInserting) {
      context.missing(_fieldIdMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {orderId, fieldId};
  @override
  OrderFieldValue map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OrderFieldValue(
      orderId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}order_id'])!,
      fieldId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}field_id'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $OrderFieldValuesTable createAlias(String alias) {
    return $OrderFieldValuesTable(attachedDatabase, alias);
  }
}

class OrderFieldValue extends DataClass implements Insertable<OrderFieldValue> {
  final int orderId;
  final int fieldId;
  final String value;
  const OrderFieldValue(
      {required this.orderId, required this.fieldId, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['order_id'] = Variable<int>(orderId);
    map['field_id'] = Variable<int>(fieldId);
    map['value'] = Variable<String>(value);
    return map;
  }

  OrderFieldValuesCompanion toCompanion(bool nullToAbsent) {
    return OrderFieldValuesCompanion(
      orderId: Value(orderId),
      fieldId: Value(fieldId),
      value: Value(value),
    );
  }

  factory OrderFieldValue.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OrderFieldValue(
      orderId: serializer.fromJson<int>(json['orderId']),
      fieldId: serializer.fromJson<int>(json['fieldId']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'orderId': serializer.toJson<int>(orderId),
      'fieldId': serializer.toJson<int>(fieldId),
      'value': serializer.toJson<String>(value),
    };
  }

  OrderFieldValue copyWith({int? orderId, int? fieldId, String? value}) =>
      OrderFieldValue(
        orderId: orderId ?? this.orderId,
        fieldId: fieldId ?? this.fieldId,
        value: value ?? this.value,
      );
  OrderFieldValue copyWithCompanion(OrderFieldValuesCompanion data) {
    return OrderFieldValue(
      orderId: data.orderId.present ? data.orderId.value : this.orderId,
      fieldId: data.fieldId.present ? data.fieldId.value : this.fieldId,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OrderFieldValue(')
          ..write('orderId: $orderId, ')
          ..write('fieldId: $fieldId, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(orderId, fieldId, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OrderFieldValue &&
          other.orderId == this.orderId &&
          other.fieldId == this.fieldId &&
          other.value == this.value);
}

class OrderFieldValuesCompanion extends UpdateCompanion<OrderFieldValue> {
  final Value<int> orderId;
  final Value<int> fieldId;
  final Value<String> value;
  final Value<int> rowid;
  const OrderFieldValuesCompanion({
    this.orderId = const Value.absent(),
    this.fieldId = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OrderFieldValuesCompanion.insert({
    required int orderId,
    required int fieldId,
    required String value,
    this.rowid = const Value.absent(),
  })  : orderId = Value(orderId),
        fieldId = Value(fieldId),
        value = Value(value);
  static Insertable<OrderFieldValue> custom({
    Expression<int>? orderId,
    Expression<int>? fieldId,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (orderId != null) 'order_id': orderId,
      if (fieldId != null) 'field_id': fieldId,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OrderFieldValuesCompanion copyWith(
      {Value<int>? orderId,
      Value<int>? fieldId,
      Value<String>? value,
      Value<int>? rowid}) {
    return OrderFieldValuesCompanion(
      orderId: orderId ?? this.orderId,
      fieldId: fieldId ?? this.fieldId,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (orderId.present) {
      map['order_id'] = Variable<int>(orderId.value);
    }
    if (fieldId.present) {
      map['field_id'] = Variable<int>(fieldId.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OrderFieldValuesCompanion(')
          ..write('orderId: $orderId, ')
          ..write('fieldId: $fieldId, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $NotesTable extends Notes with TableInfo<$NotesTable, Note> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
      'body', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isPinnedMeta =
      const VerificationMeta('isPinned');
  @override
  late final GeneratedColumn<bool> isPinned = GeneratedColumn<bool>(
      'is_pinned', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_pinned" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, body, isPinned, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'notes';
  @override
  VerificationContext validateIntegrity(Insertable<Note> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('body')) {
      context.handle(
          _bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));
    }
    if (data.containsKey('is_pinned')) {
      context.handle(_isPinnedMeta,
          isPinned.isAcceptableOrUnknown(data['is_pinned']!, _isPinnedMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Note map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Note(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      body: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}body']),
      isPinned: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_pinned'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $NotesTable createAlias(String alias) {
    return $NotesTable(attachedDatabase, alias);
  }
}

class Note extends DataClass implements Insertable<Note> {
  final int id;
  final String title;

  /// Quill Delta JSON, read and written through `NoteCodec`.
  final String? body;

  /// Pinned notes sort first and show on Today.
  final bool isPinned;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Note(
      {required this.id,
      required this.title,
      this.body,
      required this.isPinned,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || body != null) {
      map['body'] = Variable<String>(body);
    }
    map['is_pinned'] = Variable<bool>(isPinned);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  NotesCompanion toCompanion(bool nullToAbsent) {
    return NotesCompanion(
      id: Value(id),
      title: Value(title),
      body: body == null && nullToAbsent ? const Value.absent() : Value(body),
      isPinned: Value(isPinned),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Note.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Note(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String?>(json['body']),
      isPinned: serializer.fromJson<bool>(json['isPinned']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String?>(body),
      'isPinned': serializer.toJson<bool>(isPinned),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Note copyWith(
          {int? id,
          String? title,
          Value<String?> body = const Value.absent(),
          bool? isPinned,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      Note(
        id: id ?? this.id,
        title: title ?? this.title,
        body: body.present ? body.value : this.body,
        isPinned: isPinned ?? this.isPinned,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  Note copyWithCompanion(NotesCompanion data) {
    return Note(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
      isPinned: data.isPinned.present ? data.isPinned.value : this.isPinned,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Note(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('isPinned: $isPinned, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, body, isPinned, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Note &&
          other.id == this.id &&
          other.title == this.title &&
          other.body == this.body &&
          other.isPinned == this.isPinned &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class NotesCompanion extends UpdateCompanion<Note> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> body;
  final Value<bool> isPinned;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const NotesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  NotesCompanion.insert({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.isPinned = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  static Insertable<Note> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? body,
    Expression<bool>? isPinned,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (isPinned != null) 'is_pinned': isPinned,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  NotesCompanion copyWith(
      {Value<int>? id,
      Value<String>? title,
      Value<String?>? body,
      Value<bool>? isPinned,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt}) {
    return NotesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      isPinned: isPinned ?? this.isPinned,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (isPinned.present) {
      map['is_pinned'] = Variable<bool>(isPinned.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NotesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('isPinned: $isPinned, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SocialLinksTable extends SocialLinks
    with TableInfo<$SocialLinksTable, SocialLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SocialLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _platformMeta =
      const VerificationMeta('platform');
  @override
  late final GeneratedColumn<String> platform = GeneratedColumn<String>(
      'platform', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
      'label', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _urlMeta = const VerificationMeta('url');
  @override
  late final GeneratedColumn<String> url = GeneratedColumn<String>(
      'url', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _positionMeta =
      const VerificationMeta('position');
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
      'position', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns =>
      [id, platform, label, url, colorValue, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'social_links';
  @override
  VerificationContext validateIntegrity(Insertable<SocialLink> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('platform')) {
      context.handle(_platformMeta,
          platform.isAcceptableOrUnknown(data['platform']!, _platformMeta));
    } else if (isInserting) {
      context.missing(_platformMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
          _labelMeta, label.isAcceptableOrUnknown(data['label']!, _labelMeta));
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('url')) {
      context.handle(
          _urlMeta, url.isAcceptableOrUnknown(data['url']!, _urlMeta));
    } else if (isInserting) {
      context.missing(_urlMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    }
    if (data.containsKey('position')) {
      context.handle(_positionMeta,
          position.isAcceptableOrUnknown(data['position']!, _positionMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SocialLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SocialLink(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      platform: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}platform'])!,
      label: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}label'])!,
      url: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}url'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value']),
      position: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}position'])!,
    );
  }

  @override
  $SocialLinksTable createAlias(String alias) {
    return $SocialLinksTable(attachedDatabase, alias);
  }
}

class SocialLink extends DataClass implements Insertable<SocialLink> {
  final int id;

  /// A preset key (`facebook`, `shopee`…) or `custom`.
  final String platform;
  final String label;
  final String url;

  /// ARGB tile colour, only for `custom` links; presets carry their own.
  final int? colorValue;
  final int position;
  const SocialLink(
      {required this.id,
      required this.platform,
      required this.label,
      required this.url,
      this.colorValue,
      required this.position});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['platform'] = Variable<String>(platform);
    map['label'] = Variable<String>(label);
    map['url'] = Variable<String>(url);
    if (!nullToAbsent || colorValue != null) {
      map['color_value'] = Variable<int>(colorValue);
    }
    map['position'] = Variable<int>(position);
    return map;
  }

  SocialLinksCompanion toCompanion(bool nullToAbsent) {
    return SocialLinksCompanion(
      id: Value(id),
      platform: Value(platform),
      label: Value(label),
      url: Value(url),
      colorValue: colorValue == null && nullToAbsent
          ? const Value.absent()
          : Value(colorValue),
      position: Value(position),
    );
  }

  factory SocialLink.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SocialLink(
      id: serializer.fromJson<int>(json['id']),
      platform: serializer.fromJson<String>(json['platform']),
      label: serializer.fromJson<String>(json['label']),
      url: serializer.fromJson<String>(json['url']),
      colorValue: serializer.fromJson<int?>(json['colorValue']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'platform': serializer.toJson<String>(platform),
      'label': serializer.toJson<String>(label),
      'url': serializer.toJson<String>(url),
      'colorValue': serializer.toJson<int?>(colorValue),
      'position': serializer.toJson<int>(position),
    };
  }

  SocialLink copyWith(
          {int? id,
          String? platform,
          String? label,
          String? url,
          Value<int?> colorValue = const Value.absent(),
          int? position}) =>
      SocialLink(
        id: id ?? this.id,
        platform: platform ?? this.platform,
        label: label ?? this.label,
        url: url ?? this.url,
        colorValue: colorValue.present ? colorValue.value : this.colorValue,
        position: position ?? this.position,
      );
  SocialLink copyWithCompanion(SocialLinksCompanion data) {
    return SocialLink(
      id: data.id.present ? data.id.value : this.id,
      platform: data.platform.present ? data.platform.value : this.platform,
      label: data.label.present ? data.label.value : this.label,
      url: data.url.present ? data.url.value : this.url,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SocialLink(')
          ..write('id: $id, ')
          ..write('platform: $platform, ')
          ..write('label: $label, ')
          ..write('url: $url, ')
          ..write('colorValue: $colorValue, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, platform, label, url, colorValue, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SocialLink &&
          other.id == this.id &&
          other.platform == this.platform &&
          other.label == this.label &&
          other.url == this.url &&
          other.colorValue == this.colorValue &&
          other.position == this.position);
}

class SocialLinksCompanion extends UpdateCompanion<SocialLink> {
  final Value<int> id;
  final Value<String> platform;
  final Value<String> label;
  final Value<String> url;
  final Value<int?> colorValue;
  final Value<int> position;
  const SocialLinksCompanion({
    this.id = const Value.absent(),
    this.platform = const Value.absent(),
    this.label = const Value.absent(),
    this.url = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.position = const Value.absent(),
  });
  SocialLinksCompanion.insert({
    this.id = const Value.absent(),
    required String platform,
    required String label,
    required String url,
    this.colorValue = const Value.absent(),
    this.position = const Value.absent(),
  })  : platform = Value(platform),
        label = Value(label),
        url = Value(url);
  static Insertable<SocialLink> custom({
    Expression<int>? id,
    Expression<String>? platform,
    Expression<String>? label,
    Expression<String>? url,
    Expression<int>? colorValue,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (platform != null) 'platform': platform,
      if (label != null) 'label': label,
      if (url != null) 'url': url,
      if (colorValue != null) 'color_value': colorValue,
      if (position != null) 'position': position,
    });
  }

  SocialLinksCompanion copyWith(
      {Value<int>? id,
      Value<String>? platform,
      Value<String>? label,
      Value<String>? url,
      Value<int?>? colorValue,
      Value<int>? position}) {
    return SocialLinksCompanion(
      id: id ?? this.id,
      platform: platform ?? this.platform,
      label: label ?? this.label,
      url: url ?? this.url,
      colorValue: colorValue ?? this.colorValue,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (platform.present) {
      map['platform'] = Variable<String>(platform.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (url.present) {
      map['url'] = Variable<String>(url.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SocialLinksCompanion(')
          ..write('id: $id, ')
          ..write('platform: $platform, ')
          ..write('label: $label, ')
          ..write('url: $url, ')
          ..write('colorValue: $colorValue, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $OrdersTable orders = $OrdersTable(this);
  late final $OrderItemsTable orderItems = $OrderItemsTable(this);
  late final $OrderMaterialsTable orderMaterials = $OrderMaterialsTable(this);
  late final $OrderProductsTable orderProducts = $OrderProductsTable(this);
  late final $MaterialsTable materials = $MaterialsTable(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $BomItemsTable bomItems = $BomItemsTable(this);
  late final $ChannelsTable channels = $ChannelsTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  late final $ProductStockMovementsTable productStockMovements =
      $ProductStockMovementsTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  late final $OrderFieldDefinitionsTable orderFieldDefinitions =
      $OrderFieldDefinitionsTable(this);
  late final $OrderFieldValuesTable orderFieldValues =
      $OrderFieldValuesTable(this);
  late final $NotesTable notes = $NotesTable(this);
  late final $SocialLinksTable socialLinks = $SocialLinksTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        orders,
        orderItems,
        orderMaterials,
        orderProducts,
        materials,
        products,
        bomItems,
        channels,
        stockMovements,
        productStockMovements,
        settings,
        orderFieldDefinitions,
        orderFieldValues,
        notes,
        socialLinks
      ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('orders',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('order_field_values', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
}

typedef $$OrdersTableCreateCompanionBuilder = OrdersCompanion Function({
  Value<int> id,
  required String customerName,
  Value<String?> note,
  required DateTime orderDate,
  required DateTime shipByDate,
  Value<DateTime?> packedAt,
  Value<DateTime?> shippedAt,
  required String status,
  Value<int?> channelId,
  required double totalSales,
  Value<double> totalMaterialCost,
  Value<double> channelFees,
  Value<double> shippingCost,
  Value<double> profit,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$OrdersTableUpdateCompanionBuilder = OrdersCompanion Function({
  Value<int> id,
  Value<String> customerName,
  Value<String?> note,
  Value<DateTime> orderDate,
  Value<DateTime> shipByDate,
  Value<DateTime?> packedAt,
  Value<DateTime?> shippedAt,
  Value<String> status,
  Value<int?> channelId,
  Value<double> totalSales,
  Value<double> totalMaterialCost,
  Value<double> channelFees,
  Value<double> shippingCost,
  Value<double> profit,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$OrdersTableReferences
    extends BaseReferences<_$AppDatabase, $OrdersTable, Order> {
  $$OrdersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OrderFieldValuesTable, List<OrderFieldValue>>
      _orderFieldValuesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.orderFieldValues,
              aliasName: $_aliasNameGenerator(
                  db.orders.id, db.orderFieldValues.orderId));

  $$OrderFieldValuesTableProcessedTableManager get orderFieldValuesRefs {
    final manager =
        $$OrderFieldValuesTableTableManager($_db, $_db.orderFieldValues)
            .filter((f) => f.orderId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_orderFieldValuesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$OrdersTableFilterComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get orderDate => $composableBuilder(
      column: $table.orderDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get shipByDate => $composableBuilder(
      column: $table.shipByDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get packedAt => $composableBuilder(
      column: $table.packedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get shippedAt => $composableBuilder(
      column: $table.shippedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get channelId => $composableBuilder(
      column: $table.channelId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalSales => $composableBuilder(
      column: $table.totalSales, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalMaterialCost => $composableBuilder(
      column: $table.totalMaterialCost,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get channelFees => $composableBuilder(
      column: $table.channelFees, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get shippingCost => $composableBuilder(
      column: $table.shippingCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get profit => $composableBuilder(
      column: $table.profit, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> orderFieldValuesRefs(
      Expression<bool> Function($$OrderFieldValuesTableFilterComposer f) f) {
    final $$OrderFieldValuesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.orderFieldValues,
        getReferencedColumn: (t) => t.orderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderFieldValuesTableFilterComposer(
              $db: $db,
              $table: $db.orderFieldValues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get customerName => $composableBuilder(
      column: $table.customerName,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get orderDate => $composableBuilder(
      column: $table.orderDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get shipByDate => $composableBuilder(
      column: $table.shipByDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get packedAt => $composableBuilder(
      column: $table.packedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get shippedAt => $composableBuilder(
      column: $table.shippedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get channelId => $composableBuilder(
      column: $table.channelId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalSales => $composableBuilder(
      column: $table.totalSales, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalMaterialCost => $composableBuilder(
      column: $table.totalMaterialCost,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get channelFees => $composableBuilder(
      column: $table.channelFees, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get shippingCost => $composableBuilder(
      column: $table.shippingCost,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get profit => $composableBuilder(
      column: $table.profit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$OrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrdersTable> {
  $$OrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerName => $composableBuilder(
      column: $table.customerName, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get orderDate =>
      $composableBuilder(column: $table.orderDate, builder: (column) => column);

  GeneratedColumn<DateTime> get shipByDate => $composableBuilder(
      column: $table.shipByDate, builder: (column) => column);

  GeneratedColumn<DateTime> get packedAt =>
      $composableBuilder(column: $table.packedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get shippedAt =>
      $composableBuilder(column: $table.shippedAt, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get channelId =>
      $composableBuilder(column: $table.channelId, builder: (column) => column);

  GeneratedColumn<double> get totalSales => $composableBuilder(
      column: $table.totalSales, builder: (column) => column);

  GeneratedColumn<double> get totalMaterialCost => $composableBuilder(
      column: $table.totalMaterialCost, builder: (column) => column);

  GeneratedColumn<double> get channelFees => $composableBuilder(
      column: $table.channelFees, builder: (column) => column);

  GeneratedColumn<double> get shippingCost => $composableBuilder(
      column: $table.shippingCost, builder: (column) => column);

  GeneratedColumn<double> get profit =>
      $composableBuilder(column: $table.profit, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> orderFieldValuesRefs<T extends Object>(
      Expression<T> Function($$OrderFieldValuesTableAnnotationComposer a) f) {
    final $$OrderFieldValuesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.orderFieldValues,
        getReferencedColumn: (t) => t.orderId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderFieldValuesTableAnnotationComposer(
              $db: $db,
              $table: $db.orderFieldValues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OrdersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrdersTable,
    Order,
    $$OrdersTableFilterComposer,
    $$OrdersTableOrderingComposer,
    $$OrdersTableAnnotationComposer,
    $$OrdersTableCreateCompanionBuilder,
    $$OrdersTableUpdateCompanionBuilder,
    (Order, $$OrdersTableReferences),
    Order,
    PrefetchHooks Function({bool orderFieldValuesRefs})> {
  $$OrdersTableTableManager(_$AppDatabase db, $OrdersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> customerName = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<DateTime> orderDate = const Value.absent(),
            Value<DateTime> shipByDate = const Value.absent(),
            Value<DateTime?> packedAt = const Value.absent(),
            Value<DateTime?> shippedAt = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int?> channelId = const Value.absent(),
            Value<double> totalSales = const Value.absent(),
            Value<double> totalMaterialCost = const Value.absent(),
            Value<double> channelFees = const Value.absent(),
            Value<double> shippingCost = const Value.absent(),
            Value<double> profit = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              OrdersCompanion(
            id: id,
            customerName: customerName,
            note: note,
            orderDate: orderDate,
            shipByDate: shipByDate,
            packedAt: packedAt,
            shippedAt: shippedAt,
            status: status,
            channelId: channelId,
            totalSales: totalSales,
            totalMaterialCost: totalMaterialCost,
            channelFees: channelFees,
            shippingCost: shippingCost,
            profit: profit,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String customerName,
            Value<String?> note = const Value.absent(),
            required DateTime orderDate,
            required DateTime shipByDate,
            Value<DateTime?> packedAt = const Value.absent(),
            Value<DateTime?> shippedAt = const Value.absent(),
            required String status,
            Value<int?> channelId = const Value.absent(),
            required double totalSales,
            Value<double> totalMaterialCost = const Value.absent(),
            Value<double> channelFees = const Value.absent(),
            Value<double> shippingCost = const Value.absent(),
            Value<double> profit = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              OrdersCompanion.insert(
            id: id,
            customerName: customerName,
            note: note,
            orderDate: orderDate,
            shipByDate: shipByDate,
            packedAt: packedAt,
            shippedAt: shippedAt,
            status: status,
            channelId: channelId,
            totalSales: totalSales,
            totalMaterialCost: totalMaterialCost,
            channelFees: channelFees,
            shippingCost: shippingCost,
            profit: profit,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$OrdersTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({orderFieldValuesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (orderFieldValuesRefs) db.orderFieldValues
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (orderFieldValuesRefs)
                    await $_getPrefetchedData<Order, $OrdersTable,
                            OrderFieldValue>(
                        currentTable: table,
                        referencedTable: $$OrdersTableReferences
                            ._orderFieldValuesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OrdersTableReferences(db, table, p0)
                                .orderFieldValuesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.orderId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$OrdersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrdersTable,
    Order,
    $$OrdersTableFilterComposer,
    $$OrdersTableOrderingComposer,
    $$OrdersTableAnnotationComposer,
    $$OrdersTableCreateCompanionBuilder,
    $$OrdersTableUpdateCompanionBuilder,
    (Order, $$OrdersTableReferences),
    Order,
    PrefetchHooks Function({bool orderFieldValuesRefs})>;
typedef $$OrderItemsTableCreateCompanionBuilder = OrderItemsCompanion Function({
  Value<int> id,
  required int orderId,
  required int productId,
  required int quantity,
  required double unitPrice,
  required double subtotal,
  Value<DateTime> createdAt,
});
typedef $$OrderItemsTableUpdateCompanionBuilder = OrderItemsCompanion Function({
  Value<int> id,
  Value<int> orderId,
  Value<int> productId,
  Value<int> quantity,
  Value<double> unitPrice,
  Value<double> subtotal,
  Value<DateTime> createdAt,
});

class $$OrderItemsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$OrderItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitPrice => $composableBuilder(
      column: $table.unitPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OrderItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderItemsTable> {
  $$OrderItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OrderItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrderItemsTable,
    OrderItem,
    $$OrderItemsTableFilterComposer,
    $$OrderItemsTableOrderingComposer,
    $$OrderItemsTableAnnotationComposer,
    $$OrderItemsTableCreateCompanionBuilder,
    $$OrderItemsTableUpdateCompanionBuilder,
    (OrderItem, BaseReferences<_$AppDatabase, $OrderItemsTable, OrderItem>),
    OrderItem,
    PrefetchHooks Function()> {
  $$OrderItemsTableTableManager(_$AppDatabase db, $OrderItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> orderId = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double> unitPrice = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OrderItemsCompanion(
            id: id,
            orderId: orderId,
            productId: productId,
            quantity: quantity,
            unitPrice: unitPrice,
            subtotal: subtotal,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int orderId,
            required int productId,
            required int quantity,
            required double unitPrice,
            required double subtotal,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OrderItemsCompanion.insert(
            id: id,
            orderId: orderId,
            productId: productId,
            quantity: quantity,
            unitPrice: unitPrice,
            subtotal: subtotal,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrderItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrderItemsTable,
    OrderItem,
    $$OrderItemsTableFilterComposer,
    $$OrderItemsTableOrderingComposer,
    $$OrderItemsTableAnnotationComposer,
    $$OrderItemsTableCreateCompanionBuilder,
    $$OrderItemsTableUpdateCompanionBuilder,
    (OrderItem, BaseReferences<_$AppDatabase, $OrderItemsTable, OrderItem>),
    OrderItem,
    PrefetchHooks Function()>;
typedef $$OrderMaterialsTableCreateCompanionBuilder = OrderMaterialsCompanion
    Function({
  Value<int> id,
  required int orderId,
  required int materialId,
  required int plannedQuantity,
  required int actualQuantity,
  Value<int> wasteQuantity,
  Value<String?> wasteReason,
  required double unitCost,
  Value<DateTime> createdAt,
});
typedef $$OrderMaterialsTableUpdateCompanionBuilder = OrderMaterialsCompanion
    Function({
  Value<int> id,
  Value<int> orderId,
  Value<int> materialId,
  Value<int> plannedQuantity,
  Value<int> actualQuantity,
  Value<int> wasteQuantity,
  Value<String?> wasteReason,
  Value<double> unitCost,
  Value<DateTime> createdAt,
});

class $$OrderMaterialsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderMaterialsTable> {
  $$OrderMaterialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get plannedQuantity => $composableBuilder(
      column: $table.plannedQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get actualQuantity => $composableBuilder(
      column: $table.actualQuantity,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get wasteQuantity => $composableBuilder(
      column: $table.wasteQuantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wasteReason => $composableBuilder(
      column: $table.wasteReason, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$OrderMaterialsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderMaterialsTable> {
  $$OrderMaterialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get plannedQuantity => $composableBuilder(
      column: $table.plannedQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get actualQuantity => $composableBuilder(
      column: $table.actualQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get wasteQuantity => $composableBuilder(
      column: $table.wasteQuantity,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wasteReason => $composableBuilder(
      column: $table.wasteReason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OrderMaterialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderMaterialsTable> {
  $$OrderMaterialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<int> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => column);

  GeneratedColumn<int> get plannedQuantity => $composableBuilder(
      column: $table.plannedQuantity, builder: (column) => column);

  GeneratedColumn<int> get actualQuantity => $composableBuilder(
      column: $table.actualQuantity, builder: (column) => column);

  GeneratedColumn<int> get wasteQuantity => $composableBuilder(
      column: $table.wasteQuantity, builder: (column) => column);

  GeneratedColumn<String> get wasteReason => $composableBuilder(
      column: $table.wasteReason, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OrderMaterialsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrderMaterialsTable,
    OrderMaterial,
    $$OrderMaterialsTableFilterComposer,
    $$OrderMaterialsTableOrderingComposer,
    $$OrderMaterialsTableAnnotationComposer,
    $$OrderMaterialsTableCreateCompanionBuilder,
    $$OrderMaterialsTableUpdateCompanionBuilder,
    (
      OrderMaterial,
      BaseReferences<_$AppDatabase, $OrderMaterialsTable, OrderMaterial>
    ),
    OrderMaterial,
    PrefetchHooks Function()> {
  $$OrderMaterialsTableTableManager(
      _$AppDatabase db, $OrderMaterialsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderMaterialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderMaterialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderMaterialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> orderId = const Value.absent(),
            Value<int> materialId = const Value.absent(),
            Value<int> plannedQuantity = const Value.absent(),
            Value<int> actualQuantity = const Value.absent(),
            Value<int> wasteQuantity = const Value.absent(),
            Value<String?> wasteReason = const Value.absent(),
            Value<double> unitCost = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OrderMaterialsCompanion(
            id: id,
            orderId: orderId,
            materialId: materialId,
            plannedQuantity: plannedQuantity,
            actualQuantity: actualQuantity,
            wasteQuantity: wasteQuantity,
            wasteReason: wasteReason,
            unitCost: unitCost,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int orderId,
            required int materialId,
            required int plannedQuantity,
            required int actualQuantity,
            Value<int> wasteQuantity = const Value.absent(),
            Value<String?> wasteReason = const Value.absent(),
            required double unitCost,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OrderMaterialsCompanion.insert(
            id: id,
            orderId: orderId,
            materialId: materialId,
            plannedQuantity: plannedQuantity,
            actualQuantity: actualQuantity,
            wasteQuantity: wasteQuantity,
            wasteReason: wasteReason,
            unitCost: unitCost,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrderMaterialsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrderMaterialsTable,
    OrderMaterial,
    $$OrderMaterialsTableFilterComposer,
    $$OrderMaterialsTableOrderingComposer,
    $$OrderMaterialsTableAnnotationComposer,
    $$OrderMaterialsTableCreateCompanionBuilder,
    $$OrderMaterialsTableUpdateCompanionBuilder,
    (
      OrderMaterial,
      BaseReferences<_$AppDatabase, $OrderMaterialsTable, OrderMaterial>
    ),
    OrderMaterial,
    PrefetchHooks Function()>;
typedef $$OrderProductsTableCreateCompanionBuilder = OrderProductsCompanion
    Function({
  Value<int> id,
  required int orderId,
  required int productId,
  required int quantity,
  required double unitCost,
  Value<DateTime> createdAt,
});
typedef $$OrderProductsTableUpdateCompanionBuilder = OrderProductsCompanion
    Function({
  Value<int> id,
  Value<int> orderId,
  Value<int> productId,
  Value<int> quantity,
  Value<double> unitCost,
  Value<DateTime> createdAt,
});

class $$OrderProductsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderProductsTable> {
  $$OrderProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$OrderProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderProductsTable> {
  $$OrderProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OrderProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderProductsTable> {
  $$OrderProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OrderProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrderProductsTable,
    OrderProduct,
    $$OrderProductsTableFilterComposer,
    $$OrderProductsTableOrderingComposer,
    $$OrderProductsTableAnnotationComposer,
    $$OrderProductsTableCreateCompanionBuilder,
    $$OrderProductsTableUpdateCompanionBuilder,
    (
      OrderProduct,
      BaseReferences<_$AppDatabase, $OrderProductsTable, OrderProduct>
    ),
    OrderProduct,
    PrefetchHooks Function()> {
  $$OrderProductsTableTableManager(_$AppDatabase db, $OrderProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> orderId = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double> unitCost = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OrderProductsCompanion(
            id: id,
            orderId: orderId,
            productId: productId,
            quantity: quantity,
            unitCost: unitCost,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int orderId,
            required int productId,
            required int quantity,
            required double unitCost,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OrderProductsCompanion.insert(
            id: id,
            orderId: orderId,
            productId: productId,
            quantity: quantity,
            unitCost: unitCost,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$OrderProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrderProductsTable,
    OrderProduct,
    $$OrderProductsTableFilterComposer,
    $$OrderProductsTableOrderingComposer,
    $$OrderProductsTableAnnotationComposer,
    $$OrderProductsTableCreateCompanionBuilder,
    $$OrderProductsTableUpdateCompanionBuilder,
    (
      OrderProduct,
      BaseReferences<_$AppDatabase, $OrderProductsTable, OrderProduct>
    ),
    OrderProduct,
    PrefetchHooks Function()>;
typedef $$MaterialsTableCreateCompanionBuilder = MaterialsCompanion Function({
  Value<int> id,
  required String name,
  required int packSize,
  required double packPrice,
  required double unitCost,
  Value<int> quantityOnHand,
  Value<int> quantityPromised,
  required int alertLevel,
  Value<String?> supplier,
  Value<DateTime?> lastReceivedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$MaterialsTableUpdateCompanionBuilder = MaterialsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<int> packSize,
  Value<double> packPrice,
  Value<double> unitCost,
  Value<int> quantityOnHand,
  Value<int> quantityPromised,
  Value<int> alertLevel,
  Value<String?> supplier,
  Value<DateTime?> lastReceivedAt,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$MaterialsTableFilterComposer
    extends Composer<_$AppDatabase, $MaterialsTable> {
  $$MaterialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get packSize => $composableBuilder(
      column: $table.packSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get packPrice => $composableBuilder(
      column: $table.packPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantityOnHand => $composableBuilder(
      column: $table.quantityOnHand,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantityPromised => $composableBuilder(
      column: $table.quantityPromised,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get alertLevel => $composableBuilder(
      column: $table.alertLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get supplier => $composableBuilder(
      column: $table.supplier, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastReceivedAt => $composableBuilder(
      column: $table.lastReceivedAt,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$MaterialsTableOrderingComposer
    extends Composer<_$AppDatabase, $MaterialsTable> {
  $$MaterialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get packSize => $composableBuilder(
      column: $table.packSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get packPrice => $composableBuilder(
      column: $table.packPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantityOnHand => $composableBuilder(
      column: $table.quantityOnHand,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantityPromised => $composableBuilder(
      column: $table.quantityPromised,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get alertLevel => $composableBuilder(
      column: $table.alertLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get supplier => $composableBuilder(
      column: $table.supplier, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastReceivedAt => $composableBuilder(
      column: $table.lastReceivedAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$MaterialsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MaterialsTable> {
  $$MaterialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get packSize =>
      $composableBuilder(column: $table.packSize, builder: (column) => column);

  GeneratedColumn<double> get packPrice =>
      $composableBuilder(column: $table.packPrice, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<int> get quantityOnHand => $composableBuilder(
      column: $table.quantityOnHand, builder: (column) => column);

  GeneratedColumn<int> get quantityPromised => $composableBuilder(
      column: $table.quantityPromised, builder: (column) => column);

  GeneratedColumn<int> get alertLevel => $composableBuilder(
      column: $table.alertLevel, builder: (column) => column);

  GeneratedColumn<String> get supplier =>
      $composableBuilder(column: $table.supplier, builder: (column) => column);

  GeneratedColumn<DateTime> get lastReceivedAt => $composableBuilder(
      column: $table.lastReceivedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MaterialsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MaterialsTable,
    Material,
    $$MaterialsTableFilterComposer,
    $$MaterialsTableOrderingComposer,
    $$MaterialsTableAnnotationComposer,
    $$MaterialsTableCreateCompanionBuilder,
    $$MaterialsTableUpdateCompanionBuilder,
    (Material, BaseReferences<_$AppDatabase, $MaterialsTable, Material>),
    Material,
    PrefetchHooks Function()> {
  $$MaterialsTableTableManager(_$AppDatabase db, $MaterialsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaterialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaterialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaterialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> packSize = const Value.absent(),
            Value<double> packPrice = const Value.absent(),
            Value<double> unitCost = const Value.absent(),
            Value<int> quantityOnHand = const Value.absent(),
            Value<int> quantityPromised = const Value.absent(),
            Value<int> alertLevel = const Value.absent(),
            Value<String?> supplier = const Value.absent(),
            Value<DateTime?> lastReceivedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              MaterialsCompanion(
            id: id,
            name: name,
            packSize: packSize,
            packPrice: packPrice,
            unitCost: unitCost,
            quantityOnHand: quantityOnHand,
            quantityPromised: quantityPromised,
            alertLevel: alertLevel,
            supplier: supplier,
            lastReceivedAt: lastReceivedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required int packSize,
            required double packPrice,
            required double unitCost,
            Value<int> quantityOnHand = const Value.absent(),
            Value<int> quantityPromised = const Value.absent(),
            required int alertLevel,
            Value<String?> supplier = const Value.absent(),
            Value<DateTime?> lastReceivedAt = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              MaterialsCompanion.insert(
            id: id,
            name: name,
            packSize: packSize,
            packPrice: packPrice,
            unitCost: unitCost,
            quantityOnHand: quantityOnHand,
            quantityPromised: quantityPromised,
            alertLevel: alertLevel,
            supplier: supplier,
            lastReceivedAt: lastReceivedAt,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MaterialsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MaterialsTable,
    Material,
    $$MaterialsTableFilterComposer,
    $$MaterialsTableOrderingComposer,
    $$MaterialsTableAnnotationComposer,
    $$MaterialsTableCreateCompanionBuilder,
    $$MaterialsTableUpdateCompanionBuilder,
    (Material, BaseReferences<_$AppDatabase, $MaterialsTable, Material>),
    Material,
    PrefetchHooks Function()>;
typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> description,
  required double sellPrice,
  Value<bool> isActive,
  Value<bool> isStandalone,
  Value<int> quantityOnHand,
  Value<int> quantityPromised,
  Value<double> unitCost,
  Value<int> alertLevel,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> description,
  Value<double> sellPrice,
  Value<bool> isActive,
  Value<bool> isStandalone,
  Value<int> quantityOnHand,
  Value<int> quantityPromised,
  Value<double> unitCost,
  Value<int> alertLevel,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sellPrice => $composableBuilder(
      column: $table.sellPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isStandalone => $composableBuilder(
      column: $table.isStandalone, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantityOnHand => $composableBuilder(
      column: $table.quantityOnHand,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantityPromised => $composableBuilder(
      column: $table.quantityPromised,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get alertLevel => $composableBuilder(
      column: $table.alertLevel, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sellPrice => $composableBuilder(
      column: $table.sellPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isStandalone => $composableBuilder(
      column: $table.isStandalone,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantityOnHand => $composableBuilder(
      column: $table.quantityOnHand,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantityPromised => $composableBuilder(
      column: $table.quantityPromised,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get alertLevel => $composableBuilder(
      column: $table.alertLevel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
      column: $table.description, builder: (column) => column);

  GeneratedColumn<double> get sellPrice =>
      $composableBuilder(column: $table.sellPrice, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isStandalone => $composableBuilder(
      column: $table.isStandalone, builder: (column) => column);

  GeneratedColumn<int> get quantityOnHand => $composableBuilder(
      column: $table.quantityOnHand, builder: (column) => column);

  GeneratedColumn<int> get quantityPromised => $composableBuilder(
      column: $table.quantityPromised, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<int> get alertLevel => $composableBuilder(
      column: $table.alertLevel, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
    Product,
    PrefetchHooks Function()> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> description = const Value.absent(),
            Value<double> sellPrice = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<bool> isStandalone = const Value.absent(),
            Value<int> quantityOnHand = const Value.absent(),
            Value<int> quantityPromised = const Value.absent(),
            Value<double> unitCost = const Value.absent(),
            Value<int> alertLevel = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            name: name,
            description: description,
            sellPrice: sellPrice,
            isActive: isActive,
            isStandalone: isStandalone,
            quantityOnHand: quantityOnHand,
            quantityPromised: quantityPromised,
            unitCost: unitCost,
            alertLevel: alertLevel,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> description = const Value.absent(),
            required double sellPrice,
            Value<bool> isActive = const Value.absent(),
            Value<bool> isStandalone = const Value.absent(),
            Value<int> quantityOnHand = const Value.absent(),
            Value<int> quantityPromised = const Value.absent(),
            Value<double> unitCost = const Value.absent(),
            Value<int> alertLevel = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            name: name,
            description: description,
            sellPrice: sellPrice,
            isActive: isActive,
            isStandalone: isStandalone,
            quantityOnHand: quantityOnHand,
            quantityPromised: quantityPromised,
            unitCost: unitCost,
            alertLevel: alertLevel,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
    Product,
    PrefetchHooks Function()>;
typedef $$BomItemsTableCreateCompanionBuilder = BomItemsCompanion Function({
  Value<int> id,
  required int productId,
  required int materialId,
  required int quantityRequired,
  Value<DateTime> createdAt,
});
typedef $$BomItemsTableUpdateCompanionBuilder = BomItemsCompanion Function({
  Value<int> id,
  Value<int> productId,
  Value<int> materialId,
  Value<int> quantityRequired,
  Value<DateTime> createdAt,
});

class $$BomItemsTableFilterComposer
    extends Composer<_$AppDatabase, $BomItemsTable> {
  $$BomItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantityRequired => $composableBuilder(
      column: $table.quantityRequired,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$BomItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $BomItemsTable> {
  $$BomItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantityRequired => $composableBuilder(
      column: $table.quantityRequired,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$BomItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BomItemsTable> {
  $$BomItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => column);

  GeneratedColumn<int> get quantityRequired => $composableBuilder(
      column: $table.quantityRequired, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BomItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BomItemsTable,
    BomItem,
    $$BomItemsTableFilterComposer,
    $$BomItemsTableOrderingComposer,
    $$BomItemsTableAnnotationComposer,
    $$BomItemsTableCreateCompanionBuilder,
    $$BomItemsTableUpdateCompanionBuilder,
    (BomItem, BaseReferences<_$AppDatabase, $BomItemsTable, BomItem>),
    BomItem,
    PrefetchHooks Function()> {
  $$BomItemsTableTableManager(_$AppDatabase db, $BomItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BomItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BomItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BomItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<int> materialId = const Value.absent(),
            Value<int> quantityRequired = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BomItemsCompanion(
            id: id,
            productId: productId,
            materialId: materialId,
            quantityRequired: quantityRequired,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int productId,
            required int materialId,
            required int quantityRequired,
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              BomItemsCompanion.insert(
            id: id,
            productId: productId,
            materialId: materialId,
            quantityRequired: quantityRequired,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$BomItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BomItemsTable,
    BomItem,
    $$BomItemsTableFilterComposer,
    $$BomItemsTableOrderingComposer,
    $$BomItemsTableAnnotationComposer,
    $$BomItemsTableCreateCompanionBuilder,
    $$BomItemsTableUpdateCompanionBuilder,
    (BomItem, BaseReferences<_$AppDatabase, $BomItemsTable, BomItem>),
    BomItem,
    PrefetchHooks Function()>;
typedef $$ChannelsTableCreateCompanionBuilder = ChannelsCompanion Function({
  Value<int> id,
  required String name,
  Value<double> commissionRate,
  Value<double> transactionFeeRate,
  Value<double> flatFee,
  Value<double> shippingPaidByUs,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});
typedef $$ChannelsTableUpdateCompanionBuilder = ChannelsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<double> commissionRate,
  Value<double> transactionFeeRate,
  Value<double> flatFee,
  Value<double> shippingPaidByUs,
  Value<bool> isActive,
  Value<DateTime> createdAt,
});

class $$ChannelsTableFilterComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get commissionRate => $composableBuilder(
      column: $table.commissionRate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get transactionFeeRate => $composableBuilder(
      column: $table.transactionFeeRate,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get flatFee => $composableBuilder(
      column: $table.flatFee, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get shippingPaidByUs => $composableBuilder(
      column: $table.shippingPaidByUs,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$ChannelsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get commissionRate => $composableBuilder(
      column: $table.commissionRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get transactionFeeRate => $composableBuilder(
      column: $table.transactionFeeRate,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get flatFee => $composableBuilder(
      column: $table.flatFee, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get shippingPaidByUs => $composableBuilder(
      column: $table.shippingPaidByUs,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isActive => $composableBuilder(
      column: $table.isActive, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$ChannelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get commissionRate => $composableBuilder(
      column: $table.commissionRate, builder: (column) => column);

  GeneratedColumn<double> get transactionFeeRate => $composableBuilder(
      column: $table.transactionFeeRate, builder: (column) => column);

  GeneratedColumn<double> get flatFee =>
      $composableBuilder(column: $table.flatFee, builder: (column) => column);

  GeneratedColumn<double> get shippingPaidByUs => $composableBuilder(
      column: $table.shippingPaidByUs, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ChannelsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ChannelsTable,
    Channel,
    $$ChannelsTableFilterComposer,
    $$ChannelsTableOrderingComposer,
    $$ChannelsTableAnnotationComposer,
    $$ChannelsTableCreateCompanionBuilder,
    $$ChannelsTableUpdateCompanionBuilder,
    (Channel, BaseReferences<_$AppDatabase, $ChannelsTable, Channel>),
    Channel,
    PrefetchHooks Function()> {
  $$ChannelsTableTableManager(_$AppDatabase db, $ChannelsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChannelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChannelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChannelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> commissionRate = const Value.absent(),
            Value<double> transactionFeeRate = const Value.absent(),
            Value<double> flatFee = const Value.absent(),
            Value<double> shippingPaidByUs = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ChannelsCompanion(
            id: id,
            name: name,
            commissionRate: commissionRate,
            transactionFeeRate: transactionFeeRate,
            flatFee: flatFee,
            shippingPaidByUs: shippingPaidByUs,
            isActive: isActive,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<double> commissionRate = const Value.absent(),
            Value<double> transactionFeeRate = const Value.absent(),
            Value<double> flatFee = const Value.absent(),
            Value<double> shippingPaidByUs = const Value.absent(),
            Value<bool> isActive = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              ChannelsCompanion.insert(
            id: id,
            name: name,
            commissionRate: commissionRate,
            transactionFeeRate: transactionFeeRate,
            flatFee: flatFee,
            shippingPaidByUs: shippingPaidByUs,
            isActive: isActive,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ChannelsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ChannelsTable,
    Channel,
    $$ChannelsTableFilterComposer,
    $$ChannelsTableOrderingComposer,
    $$ChannelsTableAnnotationComposer,
    $$ChannelsTableCreateCompanionBuilder,
    $$ChannelsTableUpdateCompanionBuilder,
    (Channel, BaseReferences<_$AppDatabase, $ChannelsTable, Channel>),
    Channel,
    PrefetchHooks Function()>;
typedef $$StockMovementsTableCreateCompanionBuilder = StockMovementsCompanion
    Function({
  Value<int> id,
  required int materialId,
  Value<int?> orderId,
  required String type,
  required int quantity,
  required double unitCost,
  Value<DateTime> createdAt,
  Value<String?> reference,
});
typedef $$StockMovementsTableUpdateCompanionBuilder = StockMovementsCompanion
    Function({
  Value<int> id,
  Value<int> materialId,
  Value<int?> orderId,
  Value<String> type,
  Value<int> quantity,
  Value<double> unitCost,
  Value<DateTime> createdAt,
  Value<String?> reference,
});

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnFilters(column));
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnOrderings(column));
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get materialId => $composableBuilder(
      column: $table.materialId, builder: (column) => column);

  GeneratedColumn<int> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);
}

class $$StockMovementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StockMovementsTable,
    StockMovement,
    $$StockMovementsTableFilterComposer,
    $$StockMovementsTableOrderingComposer,
    $$StockMovementsTableAnnotationComposer,
    $$StockMovementsTableCreateCompanionBuilder,
    $$StockMovementsTableUpdateCompanionBuilder,
    (
      StockMovement,
      BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement>
    ),
    StockMovement,
    PrefetchHooks Function()> {
  $$StockMovementsTableTableManager(
      _$AppDatabase db, $StockMovementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> materialId = const Value.absent(),
            Value<int?> orderId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double> unitCost = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> reference = const Value.absent(),
          }) =>
              StockMovementsCompanion(
            id: id,
            materialId: materialId,
            orderId: orderId,
            type: type,
            quantity: quantity,
            unitCost: unitCost,
            createdAt: createdAt,
            reference: reference,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int materialId,
            Value<int?> orderId = const Value.absent(),
            required String type,
            required int quantity,
            required double unitCost,
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> reference = const Value.absent(),
          }) =>
              StockMovementsCompanion.insert(
            id: id,
            materialId: materialId,
            orderId: orderId,
            type: type,
            quantity: quantity,
            unitCost: unitCost,
            createdAt: createdAt,
            reference: reference,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StockMovementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StockMovementsTable,
    StockMovement,
    $$StockMovementsTableFilterComposer,
    $$StockMovementsTableOrderingComposer,
    $$StockMovementsTableAnnotationComposer,
    $$StockMovementsTableCreateCompanionBuilder,
    $$StockMovementsTableUpdateCompanionBuilder,
    (
      StockMovement,
      BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement>
    ),
    StockMovement,
    PrefetchHooks Function()>;
typedef $$ProductStockMovementsTableCreateCompanionBuilder
    = ProductStockMovementsCompanion Function({
  Value<int> id,
  required int productId,
  Value<int?> orderId,
  required String type,
  required int quantity,
  required double unitCost,
  Value<DateTime> createdAt,
  Value<String?> reference,
});
typedef $$ProductStockMovementsTableUpdateCompanionBuilder
    = ProductStockMovementsCompanion Function({
  Value<int> id,
  Value<int> productId,
  Value<int?> orderId,
  Value<String> type,
  Value<int> quantity,
  Value<double> unitCost,
  Value<DateTime> createdAt,
  Value<String?> reference,
});

class $$ProductStockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductStockMovementsTable> {
  $$ProductStockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnFilters(column));
}

class $$ProductStockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductStockMovementsTable> {
  $$ProductStockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get orderId => $composableBuilder(
      column: $table.orderId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quantity => $composableBuilder(
      column: $table.quantity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get unitCost => $composableBuilder(
      column: $table.unitCost, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reference => $composableBuilder(
      column: $table.reference, builder: (column) => ColumnOrderings(column));
}

class $$ProductStockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductStockMovementsTable> {
  $$ProductStockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get orderId =>
      $composableBuilder(column: $table.orderId, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get reference =>
      $composableBuilder(column: $table.reference, builder: (column) => column);
}

class $$ProductStockMovementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductStockMovementsTable,
    ProductStockMovement,
    $$ProductStockMovementsTableFilterComposer,
    $$ProductStockMovementsTableOrderingComposer,
    $$ProductStockMovementsTableAnnotationComposer,
    $$ProductStockMovementsTableCreateCompanionBuilder,
    $$ProductStockMovementsTableUpdateCompanionBuilder,
    (
      ProductStockMovement,
      BaseReferences<_$AppDatabase, $ProductStockMovementsTable,
          ProductStockMovement>
    ),
    ProductStockMovement,
    PrefetchHooks Function()> {
  $$ProductStockMovementsTableTableManager(
      _$AppDatabase db, $ProductStockMovementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductStockMovementsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductStockMovementsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductStockMovementsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<int?> orderId = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> quantity = const Value.absent(),
            Value<double> unitCost = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> reference = const Value.absent(),
          }) =>
              ProductStockMovementsCompanion(
            id: id,
            productId: productId,
            orderId: orderId,
            type: type,
            quantity: quantity,
            unitCost: unitCost,
            createdAt: createdAt,
            reference: reference,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int productId,
            Value<int?> orderId = const Value.absent(),
            required String type,
            required int quantity,
            required double unitCost,
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> reference = const Value.absent(),
          }) =>
              ProductStockMovementsCompanion.insert(
            id: id,
            productId: productId,
            orderId: orderId,
            type: type,
            quantity: quantity,
            unitCost: unitCost,
            createdAt: createdAt,
            reference: reference,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductStockMovementsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ProductStockMovementsTable,
        ProductStockMovement,
        $$ProductStockMovementsTableFilterComposer,
        $$ProductStockMovementsTableOrderingComposer,
        $$ProductStockMovementsTableAnnotationComposer,
        $$ProductStockMovementsTableCreateCompanionBuilder,
        $$ProductStockMovementsTableUpdateCompanionBuilder,
        (
          ProductStockMovement,
          BaseReferences<_$AppDatabase, $ProductStockMovementsTable,
              ProductStockMovement>
        ),
        ProductStockMovement,
        PrefetchHooks Function()>;
typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  required String key,
  required String value,
  Value<DateTime> updatedAt,
});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({
  Value<int> id,
  Value<String> key,
  Value<String> value,
  Value<DateTime> updatedAt,
});

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SettingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()> {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SettingsCompanion(
            id: id,
            key: key,
            value: value,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String key,
            required String value,
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              SettingsCompanion.insert(
            id: id,
            key: key,
            value: value,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SettingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting, BaseReferences<_$AppDatabase, $SettingsTable, Setting>),
    Setting,
    PrefetchHooks Function()>;
typedef $$OrderFieldDefinitionsTableCreateCompanionBuilder
    = OrderFieldDefinitionsCompanion Function({
  Value<int> id,
  required String name,
  required String type,
  Value<String?> options,
  Value<bool> isMultiline,
  Value<int> position,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
});
typedef $$OrderFieldDefinitionsTableUpdateCompanionBuilder
    = OrderFieldDefinitionsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> type,
  Value<String?> options,
  Value<bool> isMultiline,
  Value<int> position,
  Value<bool> isArchived,
  Value<DateTime> createdAt,
});

final class $$OrderFieldDefinitionsTableReferences extends BaseReferences<
    _$AppDatabase, $OrderFieldDefinitionsTable, OrderFieldDefinition> {
  $$OrderFieldDefinitionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$OrderFieldValuesTable, List<OrderFieldValue>>
      _orderFieldValuesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.orderFieldValues,
              aliasName: $_aliasNameGenerator(
                  db.orderFieldDefinitions.id, db.orderFieldValues.fieldId));

  $$OrderFieldValuesTableProcessedTableManager get orderFieldValuesRefs {
    final manager =
        $$OrderFieldValuesTableTableManager($_db, $_db.orderFieldValues)
            .filter((f) => f.fieldId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_orderFieldValuesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$OrderFieldDefinitionsTableFilterComposer
    extends Composer<_$AppDatabase, $OrderFieldDefinitionsTable> {
  $$OrderFieldDefinitionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get options => $composableBuilder(
      column: $table.options, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isMultiline => $composableBuilder(
      column: $table.isMultiline, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> orderFieldValuesRefs(
      Expression<bool> Function($$OrderFieldValuesTableFilterComposer f) f) {
    final $$OrderFieldValuesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.orderFieldValues,
        getReferencedColumn: (t) => t.fieldId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderFieldValuesTableFilterComposer(
              $db: $db,
              $table: $db.orderFieldValues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OrderFieldDefinitionsTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderFieldDefinitionsTable> {
  $$OrderFieldDefinitionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get options => $composableBuilder(
      column: $table.options, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isMultiline => $composableBuilder(
      column: $table.isMultiline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$OrderFieldDefinitionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderFieldDefinitionsTable> {
  $$OrderFieldDefinitionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get options =>
      $composableBuilder(column: $table.options, builder: (column) => column);

  GeneratedColumn<bool> get isMultiline => $composableBuilder(
      column: $table.isMultiline, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
      column: $table.isArchived, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> orderFieldValuesRefs<T extends Object>(
      Expression<T> Function($$OrderFieldValuesTableAnnotationComposer a) f) {
    final $$OrderFieldValuesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.orderFieldValues,
        getReferencedColumn: (t) => t.fieldId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrderFieldValuesTableAnnotationComposer(
              $db: $db,
              $table: $db.orderFieldValues,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$OrderFieldDefinitionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrderFieldDefinitionsTable,
    OrderFieldDefinition,
    $$OrderFieldDefinitionsTableFilterComposer,
    $$OrderFieldDefinitionsTableOrderingComposer,
    $$OrderFieldDefinitionsTableAnnotationComposer,
    $$OrderFieldDefinitionsTableCreateCompanionBuilder,
    $$OrderFieldDefinitionsTableUpdateCompanionBuilder,
    (OrderFieldDefinition, $$OrderFieldDefinitionsTableReferences),
    OrderFieldDefinition,
    PrefetchHooks Function({bool orderFieldValuesRefs})> {
  $$OrderFieldDefinitionsTableTableManager(
      _$AppDatabase db, $OrderFieldDefinitionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderFieldDefinitionsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderFieldDefinitionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderFieldDefinitionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> options = const Value.absent(),
            Value<bool> isMultiline = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OrderFieldDefinitionsCompanion(
            id: id,
            name: name,
            type: type,
            options: options,
            isMultiline: isMultiline,
            position: position,
            isArchived: isArchived,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String type,
            Value<String?> options = const Value.absent(),
            Value<bool> isMultiline = const Value.absent(),
            Value<int> position = const Value.absent(),
            Value<bool> isArchived = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
          }) =>
              OrderFieldDefinitionsCompanion.insert(
            id: id,
            name: name,
            type: type,
            options: options,
            isMultiline: isMultiline,
            position: position,
            isArchived: isArchived,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$OrderFieldDefinitionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({orderFieldValuesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (orderFieldValuesRefs) db.orderFieldValues
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (orderFieldValuesRefs)
                    await $_getPrefetchedData<OrderFieldDefinition,
                            $OrderFieldDefinitionsTable, OrderFieldValue>(
                        currentTable: table,
                        referencedTable: $$OrderFieldDefinitionsTableReferences
                            ._orderFieldValuesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$OrderFieldDefinitionsTableReferences(
                                    db, table, p0)
                                .orderFieldValuesRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.fieldId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$OrderFieldDefinitionsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $OrderFieldDefinitionsTable,
        OrderFieldDefinition,
        $$OrderFieldDefinitionsTableFilterComposer,
        $$OrderFieldDefinitionsTableOrderingComposer,
        $$OrderFieldDefinitionsTableAnnotationComposer,
        $$OrderFieldDefinitionsTableCreateCompanionBuilder,
        $$OrderFieldDefinitionsTableUpdateCompanionBuilder,
        (OrderFieldDefinition, $$OrderFieldDefinitionsTableReferences),
        OrderFieldDefinition,
        PrefetchHooks Function({bool orderFieldValuesRefs})>;
typedef $$OrderFieldValuesTableCreateCompanionBuilder
    = OrderFieldValuesCompanion Function({
  required int orderId,
  required int fieldId,
  required String value,
  Value<int> rowid,
});
typedef $$OrderFieldValuesTableUpdateCompanionBuilder
    = OrderFieldValuesCompanion Function({
  Value<int> orderId,
  Value<int> fieldId,
  Value<String> value,
  Value<int> rowid,
});

final class $$OrderFieldValuesTableReferences extends BaseReferences<
    _$AppDatabase, $OrderFieldValuesTable, OrderFieldValue> {
  $$OrderFieldValuesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $OrdersTable _orderIdTable(_$AppDatabase db) => db.orders.createAlias(
      $_aliasNameGenerator(db.orderFieldValues.orderId, db.orders.id));

  $$OrdersTableProcessedTableManager get orderId {
    final $_column = $_itemColumn<int>('order_id')!;

    final manager = $$OrdersTableTableManager($_db, $_db.orders)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_orderIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }

  static $OrderFieldDefinitionsTable _fieldIdTable(_$AppDatabase db) =>
      db.orderFieldDefinitions.createAlias($_aliasNameGenerator(
          db.orderFieldValues.fieldId, db.orderFieldDefinitions.id));

  $$OrderFieldDefinitionsTableProcessedTableManager get fieldId {
    final $_column = $_itemColumn<int>('field_id')!;

    final manager = $$OrderFieldDefinitionsTableTableManager(
            $_db, $_db.orderFieldDefinitions)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_fieldIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$OrderFieldValuesTableFilterComposer
    extends Composer<_$AppDatabase, $OrderFieldValuesTable> {
  $$OrderFieldValuesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  $$OrdersTableFilterComposer get orderId {
    final $$OrdersTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableFilterComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OrderFieldDefinitionsTableFilterComposer get fieldId {
    final $$OrderFieldDefinitionsTableFilterComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.fieldId,
            referencedTable: $db.orderFieldDefinitions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$OrderFieldDefinitionsTableFilterComposer(
                  $db: $db,
                  $table: $db.orderFieldDefinitions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$OrderFieldValuesTableOrderingComposer
    extends Composer<_$AppDatabase, $OrderFieldValuesTable> {
  $$OrderFieldValuesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  $$OrdersTableOrderingComposer get orderId {
    final $$OrdersTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableOrderingComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OrderFieldDefinitionsTableOrderingComposer get fieldId {
    final $$OrderFieldDefinitionsTableOrderingComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.fieldId,
            referencedTable: $db.orderFieldDefinitions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$OrderFieldDefinitionsTableOrderingComposer(
                  $db: $db,
                  $table: $db.orderFieldDefinitions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$OrderFieldValuesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OrderFieldValuesTable> {
  $$OrderFieldValuesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  $$OrdersTableAnnotationComposer get orderId {
    final $$OrdersTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.orderId,
        referencedTable: $db.orders,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$OrdersTableAnnotationComposer(
              $db: $db,
              $table: $db.orders,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }

  $$OrderFieldDefinitionsTableAnnotationComposer get fieldId {
    final $$OrderFieldDefinitionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.fieldId,
            referencedTable: $db.orderFieldDefinitions,
            getReferencedColumn: (t) => t.id,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$OrderFieldDefinitionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.orderFieldDefinitions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return composer;
  }
}

class $$OrderFieldValuesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $OrderFieldValuesTable,
    OrderFieldValue,
    $$OrderFieldValuesTableFilterComposer,
    $$OrderFieldValuesTableOrderingComposer,
    $$OrderFieldValuesTableAnnotationComposer,
    $$OrderFieldValuesTableCreateCompanionBuilder,
    $$OrderFieldValuesTableUpdateCompanionBuilder,
    (OrderFieldValue, $$OrderFieldValuesTableReferences),
    OrderFieldValue,
    PrefetchHooks Function({bool orderId, bool fieldId})> {
  $$OrderFieldValuesTableTableManager(
      _$AppDatabase db, $OrderFieldValuesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OrderFieldValuesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OrderFieldValuesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OrderFieldValuesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> orderId = const Value.absent(),
            Value<int> fieldId = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              OrderFieldValuesCompanion(
            orderId: orderId,
            fieldId: fieldId,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required int orderId,
            required int fieldId,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              OrderFieldValuesCompanion.insert(
            orderId: orderId,
            fieldId: fieldId,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$OrderFieldValuesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({orderId = false, fieldId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (orderId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.orderId,
                    referencedTable:
                        $$OrderFieldValuesTableReferences._orderIdTable(db),
                    referencedColumn:
                        $$OrderFieldValuesTableReferences._orderIdTable(db).id,
                  ) as T;
                }
                if (fieldId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.fieldId,
                    referencedTable:
                        $$OrderFieldValuesTableReferences._fieldIdTable(db),
                    referencedColumn:
                        $$OrderFieldValuesTableReferences._fieldIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$OrderFieldValuesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $OrderFieldValuesTable,
    OrderFieldValue,
    $$OrderFieldValuesTableFilterComposer,
    $$OrderFieldValuesTableOrderingComposer,
    $$OrderFieldValuesTableAnnotationComposer,
    $$OrderFieldValuesTableCreateCompanionBuilder,
    $$OrderFieldValuesTableUpdateCompanionBuilder,
    (OrderFieldValue, $$OrderFieldValuesTableReferences),
    OrderFieldValue,
    PrefetchHooks Function({bool orderId, bool fieldId})>;
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> body,
  Value<bool> isPinned,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String?> body,
  Value<bool> isPinned,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

class $$NotesTableFilterComposer extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$NotesTableOrderingComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isPinned => $composableBuilder(
      column: $table.isPinned, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$NotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NotesTable> {
  $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<bool> get isPinned =>
      $composableBuilder(column: $table.isPinned, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$NotesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $NotesTable,
    Note,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (Note, BaseReferences<_$AppDatabase, $NotesTable, Note>),
    Note,
    PrefetchHooks Function()> {
  $$NotesTableTableManager(_$AppDatabase db, $NotesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> body = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              NotesCompanion(
            id: id,
            title: title,
            body: body,
            isPinned: isPinned,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> body = const Value.absent(),
            Value<bool> isPinned = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
          }) =>
              NotesCompanion.insert(
            id: id,
            title: title,
            body: body,
            isPinned: isPinned,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$NotesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $NotesTable,
    Note,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (Note, BaseReferences<_$AppDatabase, $NotesTable, Note>),
    Note,
    PrefetchHooks Function()>;
typedef $$SocialLinksTableCreateCompanionBuilder = SocialLinksCompanion
    Function({
  Value<int> id,
  required String platform,
  required String label,
  required String url,
  Value<int?> colorValue,
  Value<int> position,
});
typedef $$SocialLinksTableUpdateCompanionBuilder = SocialLinksCompanion
    Function({
  Value<int> id,
  Value<String> platform,
  Value<String> label,
  Value<String> url,
  Value<int?> colorValue,
  Value<int> position,
});

class $$SocialLinksTableFilterComposer
    extends Composer<_$AppDatabase, $SocialLinksTable> {
  $$SocialLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnFilters(column));
}

class $$SocialLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $SocialLinksTable> {
  $$SocialLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get platform => $composableBuilder(
      column: $table.platform, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get label => $composableBuilder(
      column: $table.label, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get url => $composableBuilder(
      column: $table.url, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get position => $composableBuilder(
      column: $table.position, builder: (column) => ColumnOrderings(column));
}

class $$SocialLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $SocialLinksTable> {
  $$SocialLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get platform =>
      $composableBuilder(column: $table.platform, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get url =>
      $composableBuilder(column: $table.url, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);
}

class $$SocialLinksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SocialLinksTable,
    SocialLink,
    $$SocialLinksTableFilterComposer,
    $$SocialLinksTableOrderingComposer,
    $$SocialLinksTableAnnotationComposer,
    $$SocialLinksTableCreateCompanionBuilder,
    $$SocialLinksTableUpdateCompanionBuilder,
    (SocialLink, BaseReferences<_$AppDatabase, $SocialLinksTable, SocialLink>),
    SocialLink,
    PrefetchHooks Function()> {
  $$SocialLinksTableTableManager(_$AppDatabase db, $SocialLinksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SocialLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SocialLinksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SocialLinksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> platform = const Value.absent(),
            Value<String> label = const Value.absent(),
            Value<String> url = const Value.absent(),
            Value<int?> colorValue = const Value.absent(),
            Value<int> position = const Value.absent(),
          }) =>
              SocialLinksCompanion(
            id: id,
            platform: platform,
            label: label,
            url: url,
            colorValue: colorValue,
            position: position,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String platform,
            required String label,
            required String url,
            Value<int?> colorValue = const Value.absent(),
            Value<int> position = const Value.absent(),
          }) =>
              SocialLinksCompanion.insert(
            id: id,
            platform: platform,
            label: label,
            url: url,
            colorValue: colorValue,
            position: position,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SocialLinksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SocialLinksTable,
    SocialLink,
    $$SocialLinksTableFilterComposer,
    $$SocialLinksTableOrderingComposer,
    $$SocialLinksTableAnnotationComposer,
    $$SocialLinksTableCreateCompanionBuilder,
    $$SocialLinksTableUpdateCompanionBuilder,
    (SocialLink, BaseReferences<_$AppDatabase, $SocialLinksTable, SocialLink>),
    SocialLink,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$OrdersTableTableManager get orders =>
      $$OrdersTableTableManager(_db, _db.orders);
  $$OrderItemsTableTableManager get orderItems =>
      $$OrderItemsTableTableManager(_db, _db.orderItems);
  $$OrderMaterialsTableTableManager get orderMaterials =>
      $$OrderMaterialsTableTableManager(_db, _db.orderMaterials);
  $$OrderProductsTableTableManager get orderProducts =>
      $$OrderProductsTableTableManager(_db, _db.orderProducts);
  $$MaterialsTableTableManager get materials =>
      $$MaterialsTableTableManager(_db, _db.materials);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$BomItemsTableTableManager get bomItems =>
      $$BomItemsTableTableManager(_db, _db.bomItems);
  $$ChannelsTableTableManager get channels =>
      $$ChannelsTableTableManager(_db, _db.channels);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
  $$ProductStockMovementsTableTableManager get productStockMovements =>
      $$ProductStockMovementsTableTableManager(_db, _db.productStockMovements);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
  $$OrderFieldDefinitionsTableTableManager get orderFieldDefinitions =>
      $$OrderFieldDefinitionsTableTableManager(_db, _db.orderFieldDefinitions);
  $$OrderFieldValuesTableTableManager get orderFieldValues =>
      $$OrderFieldValuesTableTableManager(_db, _db.orderFieldValues);
  $$NotesTableTableManager get notes =>
      $$NotesTableTableManager(_db, _db.notes);
  $$SocialLinksTableTableManager get socialLinks =>
      $$SocialLinksTableTableManager(_db, _db.socialLinks);
}
