import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_entities/sqflite_entities.dart';

import 'environment.dart';
import 'models/user_profile_entity.dart';

void main() {
  late SqliteEngine engine;

  sqfliteFfiInit();

  Future<SqliteEngine> _prepareSqliteEngine(
    String databaseFilePath,
  ) async {
    engine = await initializeTestDbEngineEnvironment(
      databaseFilePath,
    );

    return engine;
  }

  group(
    'SqliteEngine',
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

      test('should store and retrieve entities correctly', () async {
        await engine.storeEntity(ProfileEntity(
          firstName: 'John',
          lastName: 'Smith',
          age: 30,
        ));

        final entities = await engine.retrieveCollection<ProfileEntity>();

        expect(entities, isNotEmpty);
        expect(entities.first.age, 30);
        expect(entities.first.firstName, 'John');
        expect(entities.first.lastName, 'Smith');
        expect(entities.first.position, isNull);
      });
    },
  );
}
