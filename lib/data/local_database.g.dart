// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_database.dart';

// ignore_for_file: type=lint
class $SkramblsTable extends Skrambls with TableInfo<$SkramblsTable, Skrambl> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SkramblsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _destinationMeta = const VerificationMeta(
    'destination',
  );
  @override
  late final GeneratedColumn<String> destination = GeneratedColumn<String>(
    'destination',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    note,
    status,
    createdAt,
    destination,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'skrambls';
  @override
  VerificationContext validateIntegrity(
    Insertable<Skrambl> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    } else if (isInserting) {
      context.missing(_noteMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('destination')) {
      context.handle(
        _destinationMeta,
        destination.isAcceptableOrUnknown(
          data['destination']!,
          _destinationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_destinationMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Skrambl map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Skrambl(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      destination: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}destination'],
      )!,
    );
  }

  @override
  $SkramblsTable createAlias(String alias) {
    return $SkramblsTable(attachedDatabase, alias);
  }
}

class Skrambl extends DataClass implements Insertable<Skrambl> {
  final int id;
  final String note;
  final int status;
  final DateTime createdAt;
  final String destination;
  const Skrambl({
    required this.id,
    required this.note,
    required this.status,
    required this.createdAt,
    required this.destination,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['note'] = Variable<String>(note);
    map['status'] = Variable<int>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['destination'] = Variable<String>(destination);
    return map;
  }

  SkramblsCompanion toCompanion(bool nullToAbsent) {
    return SkramblsCompanion(
      id: Value(id),
      note: Value(note),
      status: Value(status),
      createdAt: Value(createdAt),
      destination: Value(destination),
    );
  }

  factory Skrambl.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Skrambl(
      id: serializer.fromJson<int>(json['id']),
      note: serializer.fromJson<String>(json['note']),
      status: serializer.fromJson<int>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      destination: serializer.fromJson<String>(json['destination']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'note': serializer.toJson<String>(note),
      'status': serializer.toJson<int>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'destination': serializer.toJson<String>(destination),
    };
  }

  Skrambl copyWith({
    int? id,
    String? note,
    int? status,
    DateTime? createdAt,
    String? destination,
  }) => Skrambl(
    id: id ?? this.id,
    note: note ?? this.note,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    destination: destination ?? this.destination,
  );
  Skrambl copyWithCompanion(SkramblsCompanion data) {
    return Skrambl(
      id: data.id.present ? data.id.value : this.id,
      note: data.note.present ? data.note.value : this.note,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      destination: data.destination.present
          ? data.destination.value
          : this.destination,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Skrambl(')
          ..write('id: $id, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('destination: $destination')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, note, status, createdAt, destination);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Skrambl &&
          other.id == this.id &&
          other.note == this.note &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.destination == this.destination);
}

class SkramblsCompanion extends UpdateCompanion<Skrambl> {
  final Value<int> id;
  final Value<String> note;
  final Value<int> status;
  final Value<DateTime> createdAt;
  final Value<String> destination;
  const SkramblsCompanion({
    this.id = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.destination = const Value.absent(),
  });
  SkramblsCompanion.insert({
    this.id = const Value.absent(),
    required String note,
    required int status,
    this.createdAt = const Value.absent(),
    required String destination,
  }) : note = Value(note),
       status = Value(status),
       destination = Value(destination);
  static Insertable<Skrambl> custom({
    Expression<int>? id,
    Expression<String>? note,
    Expression<int>? status,
    Expression<DateTime>? createdAt,
    Expression<String>? destination,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (destination != null) 'destination': destination,
    });
  }

  SkramblsCompanion copyWith({
    Value<int>? id,
    Value<String>? note,
    Value<int>? status,
    Value<DateTime>? createdAt,
    Value<String>? destination,
  }) {
    return SkramblsCompanion(
      id: id ?? this.id,
      note: note ?? this.note,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      destination: destination ?? this.destination,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (destination.present) {
      map['destination'] = Variable<String>(destination.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SkramblsCompanion(')
          ..write('id: $id, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('destination: $destination')
          ..write(')'))
        .toString();
  }
}

abstract class _$LocalDatabase extends GeneratedDatabase {
  _$LocalDatabase(QueryExecutor e) : super(e);
  $LocalDatabaseManager get managers => $LocalDatabaseManager(this);
  late final $SkramblsTable skrambls = $SkramblsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [skrambls];
}

typedef $$SkramblsTableCreateCompanionBuilder =
    SkramblsCompanion Function({
      Value<int> id,
      required String note,
      required int status,
      Value<DateTime> createdAt,
      required String destination,
    });
typedef $$SkramblsTableUpdateCompanionBuilder =
    SkramblsCompanion Function({
      Value<int> id,
      Value<String> note,
      Value<int> status,
      Value<DateTime> createdAt,
      Value<String> destination,
    });

class $$SkramblsTableFilterComposer
    extends Composer<_$LocalDatabase, $SkramblsTable> {
  $$SkramblsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SkramblsTableOrderingComposer
    extends Composer<_$LocalDatabase, $SkramblsTable> {
  $$SkramblsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SkramblsTableAnnotationComposer
    extends Composer<_$LocalDatabase, $SkramblsTable> {
  $$SkramblsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get destination => $composableBuilder(
    column: $table.destination,
    builder: (column) => column,
  );
}

class $$SkramblsTableTableManager
    extends
        RootTableManager<
          _$LocalDatabase,
          $SkramblsTable,
          Skrambl,
          $$SkramblsTableFilterComposer,
          $$SkramblsTableOrderingComposer,
          $$SkramblsTableAnnotationComposer,
          $$SkramblsTableCreateCompanionBuilder,
          $$SkramblsTableUpdateCompanionBuilder,
          (Skrambl, BaseReferences<_$LocalDatabase, $SkramblsTable, Skrambl>),
          Skrambl,
          PrefetchHooks Function()
        > {
  $$SkramblsTableTableManager(_$LocalDatabase db, $SkramblsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SkramblsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SkramblsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SkramblsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> destination = const Value.absent(),
              }) => SkramblsCompanion(
                id: id,
                note: note,
                status: status,
                createdAt: createdAt,
                destination: destination,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String note,
                required int status,
                Value<DateTime> createdAt = const Value.absent(),
                required String destination,
              }) => SkramblsCompanion.insert(
                id: id,
                note: note,
                status: status,
                createdAt: createdAt,
                destination: destination,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SkramblsTableProcessedTableManager =
    ProcessedTableManager<
      _$LocalDatabase,
      $SkramblsTable,
      Skrambl,
      $$SkramblsTableFilterComposer,
      $$SkramblsTableOrderingComposer,
      $$SkramblsTableAnnotationComposer,
      $$SkramblsTableCreateCompanionBuilder,
      $$SkramblsTableUpdateCompanionBuilder,
      (Skrambl, BaseReferences<_$LocalDatabase, $SkramblsTable, Skrambl>),
      Skrambl,
      PrefetchHooks Function()
    >;

class $LocalDatabaseManager {
  final _$LocalDatabase _db;
  $LocalDatabaseManager(this._db);
  $$SkramblsTableTableManager get skrambls =>
      $$SkramblsTableTableManager(_db, _db.skrambls);
}
