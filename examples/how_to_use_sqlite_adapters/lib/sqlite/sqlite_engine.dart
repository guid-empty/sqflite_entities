import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_entities/sqflite_entities.dart';

class PerInstanceSqfliteEngine extends SqfliteEngine {
  PerInstanceSqfliteEngine({
    required Database database,
    required String databaseIdentity,
  }) : super(database: database, databaseIdentity: databaseIdentity);

  @override
  int get dbVersion => 3;

  @override
  Map<int, DatabaseMigration> get migrations => {
        2: (db) => db.execute(
              'ALTER TABLE visits ADD COLUMN tasks_title_filter TEXT',
            ),
        3: (db) => db.execute(
              'ALTER TABLE visits ADD COLUMN is_started_online INTEGER',
            ),
      };
}
