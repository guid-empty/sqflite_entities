import 'dart:io';

import 'package:sqflite/sqflite_dev.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_entities/sqflite_entities.dart';

import 'models/test_db_engine.dart';
import 'models/user_profile_entity.dart';

Future<SqliteEngine> initializeTestDbEngineEnvironment(
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
