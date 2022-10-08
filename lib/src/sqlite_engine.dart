import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_entities/src/sql_adapter.dart';

typedef DatabaseFilePathFactory = String Function();
typedef DatabaseMigration = Future<void> Function(Database);

abstract class SqfliteEngine {
  final List<SqlAdapter<Object>> _adapters = [];

  Database _database;

  final ConflictAlgorithm _conflictAlgorithm;

  Map<Type, SqlAdapter> _adaptersMap;

  String _databaseIdentity;

  SqfliteEngine({
    required Database database,
    required String databaseIdentity,
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
    Map<Type, SqlAdapter> adaptersMap = const {},
  })  : _conflictAlgorithm = conflictAlgorithm,
        _adaptersMap = adaptersMap,
        _database = database,
        _databaseIdentity = databaseIdentity;

  int get dbVersion;

  Map<int, DatabaseMigration> get migrations;

  Future<T> beginTransaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) =>
      _database.transaction(action, exclusive: exclusive);

  Future<void> clearEntities<T>({
    Transaction? transaction,
  }) {
    final adapter = _adaptersMap[T]!;
    return (transaction ?? _database).delete(adapter.tableName);
  }

  Future<void> deleteEntity<T>({
    required String where,
    required List<dynamic> whereArgs,
    Transaction? transaction,
  }) {
    final adapter = _adaptersMap[T]!;
    return (transaction ?? _database).delete(
      adapter.tableName,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<SqfliteEngine> initialize({
    required String databaseIdentity,
    DatabaseFilePathFactory? filePathFactory,
  }) async {
    if (_databaseIdentity == databaseIdentity) {
      return this;
    }

    _databaseIdentity = databaseIdentity;

    final path = filePathFactory != null
        ? filePathFactory()
        : join(
            await getDatabasesPath(),
            'sqlite_data_$databaseIdentity.db',
          );

    await _database.close();
    _database = await openDatabase(
      path,
      onCreate: (db, version) {
        for (final adapter in _adapters) {
          db.execute(adapter.createEntityTableScript);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        for (var i = oldVersion + 1; i <= newVersion; i++) {
          final migration = migrations[i]!;
          await migration(db);
        }
      },
      version: dbVersion,
    );

    return this;
  }

  Future<List<T>> queryEntities<T>({
    required String where,
    List<dynamic>? whereArgs,
    int? limit,
    Transaction? transaction,
  }) async {
    final adapter = _adaptersMap[T]!;
    final serializedStates = await (transaction ?? _database).query(
      adapter.tableName,
      where: where,
      whereArgs: whereArgs,
      limit: limit,
    );

    final entities = serializedStates.map((state) {
      final entity = adapter.deserialize(state) as T;
      return entity;
    });

    return entities.toList();
  }

  void registryAdapters(Iterable<SqlAdapter<Object>> adapters) {
    _adapters.addAll(adapters);
    _adaptersMap = {
      for (var adapter in _adapters) (adapter).modelType: adapter
    };
  }

  Future<List<T>> retrieveCollection<T>({
    Transaction? transaction,
  }) async {
    final adapter = _adaptersMap[T]!;
    final serializedStates =
        await (transaction ?? _database).query(adapter.tableName);

    final entities = serializedStates.map((state) {
      final entity = adapter.deserialize(state) as T;
      return entity;
    });

    return entities.toList();
  }

  Future<T?> retrieveFirstEntity<T>({
    Transaction? transaction,
  }) async {
    final adapter = _adaptersMap[T]!;

    final maps =
        await (transaction ?? _database).query(adapter.tableName, limit: 1);

    if (maps.isEmpty) {
      return null;
    }

    return adapter.deserialize(maps[0]) as T;
  }

  void storeEntitiesBatch<T>({
    required Iterable<T> entities,
    required Batch batch,
  }) {
    final adapter = _adaptersMap[T]!;

    for (final entity in entities) {
      final rawData = adapter.serialize(entity);
      batch.insert(
        adapter.tableName,
        rawData,
        conflictAlgorithm: _conflictAlgorithm,
      );
    }
  }

  Future<void> storeEntity<T>(
    T entity, {
    Transaction? transaction,
  }) {
    final adapter = _adaptersMap[T]!;
    final rawData = adapter.serialize(entity);

    return (transaction ?? _database).insert(
      adapter.tableName,
      rawData,
      conflictAlgorithm: _conflictAlgorithm,
    );
  }

  Future<void> updateEntity<T>(
    T entity, {
    required String where,
    required List<dynamic> whereArgs,
    Transaction? transaction,
  }) {
    final adapter = _adaptersMap[T]!;
    final rawData = adapter.serialize(entity);

    return (transaction ?? _database).update(
      adapter.tableName,
      rawData,
      conflictAlgorithm: _conflictAlgorithm,
      where: where,
      whereArgs: whereArgs,
    );
  }
}
