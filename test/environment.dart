import 'dart:io';

import 'package:sqflite/sqflite_dev.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_entities/src/sqlite_engine.dart';

import 'models/profile_entity.dart';
import 'models/test_db_engine.dart';

Future<SqliteEngine> initializePerInstanceSqliteEngineEnvironment(
  String databaseFilePath,
) async {
  setMockDatabaseFactory(databaseFactoryFfi);

  final file = File(databaseFilePath);
  if (file.existsSync()) {
    await file.delete();
  }

  final engine = TestDBEngine()
    ..registryAdapters([
      const ProfileEntitySqlAdapter(),
    ]);

  await engine.initialize(
    databaseIdentity: 'test_only',
    filePathFactory: () => databaseFilePath,
  );
  return engine;
}
