import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_entities/src/sqlite_engine.dart';

import 'environment.dart';
import 'models/profile_entity.dart';

void main() {
  late SqliteEngine engine;

  sqfliteFfiInit();

  Future<SqliteEngine> _prepareSqliteEngine(
    String databaseFilePath,
  ) async {
    engine = await initializePerInstanceSqliteEngineEnvironment(
      databaseFilePath,
    );

    final profile = ProfileEntity(
      firstName: 'John',
      lastName: 'Smith',
      age: 30,
    );

    await engine.storeEntity(profile);
    return engine;
  }

  group(
    'ClientDataCacheStorage',
    () {
      late Directory databaseFileDirectory;

      setUp(() async {
        databaseFileDirectory = await Directory.systemTemp.createTemp('db');

        final databaseFilePath =
            join(databaseFileDirectory.path, 'test_data_db.db');

        engine = await _prepareSqliteEngine(
          databaseFilePath,
        );
      });

      tearDown(() async {
        await databaseFileDirectory.delete(recursive: true);
      });

      test('should store and retrieve visits correctly', () async {
        final entities = await engine.retrieveCollection<ProfileEntity>();

        expect(entities, isNotEmpty);
      });
    },
  );
}
