import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_entities/src/sql_adapter.dart';

typedef DatabaseFilePathFactory = String Function();
typedef DatabaseMigration = Future<void> Function(Database);

///
/// Базовый класс для работы с локальным хранилищем данных на основе Sqlite;
///
/// How to know current version of sqlite -
/// https://github.com/tekartik/sqflite/blob/master/sqflite/doc/version.md
///
/// See more details about the process with working with sqlite engine in
/// https://www.notion.so/97174a6df21d46338022752d02d0c402
///
abstract class SqliteEngine {
  final List<SqlAdapter> _adapters = [];

  Database? _database;

  final ConflictAlgorithm _conflictAlgorithm;

  late final Map<Type, SqlAdapter> _adaptersMap;

  String? _databaseIdentity;

  SqliteEngine({
    ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace,
  }) : _conflictAlgorithm = conflictAlgorithm;

  int get dbVersion;

  Map<int, DatabaseMigration> get migrations;

  Future<T> beginTransaction<T>(
    Future<T> Function(Transaction txn) action, {
    bool? exclusive,
  }) =>
      _database!.transaction(action, exclusive: exclusive);

  Future<void> clearEntities<T>({
    Transaction? transaction,
  }) {
    final adapter = _adaptersMap[T]!;
    return (transaction ?? _database)!.delete(adapter.tableName);
  }

  Future<void> deleteEntity<T>({
    required String where,
    required List<dynamic> whereArgs,
    Transaction? transaction,
  }) {
    final adapter = _adaptersMap[T]!;
    return (transaction ?? _database)!.delete(
      adapter.tableName,
      where: where,
      whereArgs: whereArgs,
    );
  }

  Future<SqliteEngine> initialize({
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

    await _database?.close();
    _database = await openDatabase(
      path,
      onCreate: (db, version) {
        for (final adapter in _adapters) {
          db.execute(adapter.createEntityTableScript);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        for (var i = oldVersion + 1; i <= newVersion; i++) {
          final migration = migrations[i];
          if (migration != null) {
            await migration(db);
          }
        }
      },
      version: dbVersion,
    );

    return this;
  }

  Future<List<T>> queryEntities<T>({
    required String where,
    List<dynamic>? whereArgs,
    String? orderBy,
    int? limit,
    Transaction? transaction,
  }) async {
    final adapter = _adaptersMap[T]!;
    final serializedStates = await (transaction ?? _database)!.query(
      adapter.tableName,
      where: where,
      whereArgs: whereArgs,
      orderBy: orderBy,
      limit: limit,
    );

    final entities = serializedStates.map((state) {
      final entity = adapter.deserialize(state) as T;
      return entity;
    });

    return entities.toList();
  }

  void registryAdapters(Iterable<SqlAdapter> adapters) {
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
        await (transaction ?? _database)!.query(adapter.tableName);

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
        await (transaction ?? _database)!.query(adapter.tableName, limit: 1);

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

    return (transaction ?? _database)!.insert(
      adapter.tableName,
      rawData,
      conflictAlgorithm: _conflictAlgorithm,
    );
  }

  Future<void> updateEntity<T>(
    T entity, {
    required String where,
    required List<dynamic> whereArgs,
    List<String>? columnsOnly,
    Transaction? transaction,
  }) {
    final adapter = _adaptersMap[T]!;
    final rawData = adapter.serialize(entity);

    if (columnsOnly != null && columnsOnly.isNotEmpty) {
      rawData.removeWhere(
          (columnName, value) => !columnsOnly.contains(columnName));
    }

    return (transaction ?? _database)!.update(
      adapter.tableName,
      rawData,
      conflictAlgorithm: _conflictAlgorithm,
      where: where,
      whereArgs: whereArgs,
    );
  }
}
