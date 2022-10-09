import 'package:sqflite_entities/sqflite_entities.dart';

class TestDBEngine extends SqliteEngine {
  @override
  int get dbVersion => 1;

  @override
  Map<int, DatabaseMigration> get migrations => {};
}
