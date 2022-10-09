import 'package:sqflite_entities/src/annotations/sql_field.dart';

///
/// Use this annotation to mark some model
/// as needed to be stored in Sqlite storage;
/// For model annotated by [SqlEntityDefinition] Sqlite Engine will create the table named as [tableName];
/// More over, use can specify some additional fields using the [fields] property, if you want to save not
/// only model fields (see more details in [SqlField])
///
class SqlEntityDefinition {
  ///
  /// Table name used to store concrete model
  ///
  final String tableName;

  ///
  /// Use can specify some additional fields using the [fields] property, if you want to save not
  /// only model fields (see more details in [SqlField])
  ///
  final Iterable<SqlField> fields;

  const SqlEntityDefinition({
    required this.tableName,
    this.fields = const [],
  });
}
