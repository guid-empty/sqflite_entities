import 'package:sqflite_entities/sqflite_entities.dart';

class ApplicationDBStorage extends SqliteEngine {
  @override
  int get dbVersion => 3;

  ///
  /// Keep in the mind some limitations described here
  /// https://efthymis.com/migrating-a-mobile-database-in-flutter-sqlite/
  /// for example, one of them is:
  /// Mind you that there is a limitation in sqflite,
  /// which prevents the execution of multiple sql statements
  /// in a single db.execute()call.
  /// This means that you have to separate multiple statements into different executions.
  /// < ------------------------------ >
  /// Altering the columns:
  /// see some details here https://www.sqlite.org/omitted.html to understand what
  /// are the things supported by sqlite
  /// We can't add constraint to existing columns (solution: create new, drop old, rename)
  ///
  /// Some important answers are discussed here:
  /// https://stackoverflow.com/questions/1884818/how-do-i-add-a-foreign-key-to-an-existing-sqlite-table
  ///
  /// < ------------------------------ >
  /// https://www.sqlite.org/faq.html - migrations
  /// SQLite has limited ALTER TABLE support that you can use to add a column
  /// to the end of a table or to change the name of a table.
  /// If you want to make more complex changes in the structure of a table,
  /// you will have to recreate the table.
  /// You can save existing data to a temporary table,
  /// drop the old table, create the new table,
  /// then copy the data back in from the temporary table.
  ///
  /// For example, suppose you have a table named "t1" with
  /// columns names "a", "b", and "c" and that you want to delete column "c" from this table.
  /// The following steps illustrate how this could be done:
  ///
  ///       BEGIN TRANSACTION;
  ///       CREATE TEMPORARY TABLE t1_backup(a,b);
  ///       INSERT INTO t1_backup SELECT a,b FROM t1;
  ///       DROP TABLE t1;
  ///       CREATE TABLE t1(a,b);
  ///       INSERT INTO t1 SELECT a,b FROM t1_backup;
  ///       DROP TABLE t1_backup;
  ///       COMMIT;
  /// < ------------------------------ >
  /// Current version of Sqlite used in sqflite package can be fetched in
  /// https://github.com/tekartik/sqflite/blob/master/sqflite/doc/version.md
  /// Knowing the version should give us understanding what are the SQL constructions
  /// can be used to write migrations like described below:
  ///
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
