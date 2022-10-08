import 'package:sqflite_entities/src/sqlite_engine.dart';

class TestDBEngine extends SqliteEngine {
  @override
  int get dbVersion => 1;

  @override
  Map<int, DatabaseMigration> get migrations => {};
}
