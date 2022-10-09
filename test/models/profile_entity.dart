import 'package:sqflite_entities/src/annotations/sql_entity_definition.dart';
import 'package:sqflite_entities/src/annotations/sql_field.dart';
import 'package:sqflite_entities/src/annotations/sql_field_type.dart';
import 'package:sqflite_entities/src/sql_adapter.dart';

part 'profile_entity.sql.g.dart';

@SqlEntityDefinition(
  tableName: 'profile',
  fields: [
    SqlField(
      fieldName: 'id',
      fieldType: SqlFieldType.integer,
      isAutoIncrement: true,
      isPrimaryKey: true,
    ),
    SqlField(
        fieldName: 'created',
        fieldType: SqlFieldType.integer,
        defaultValueExpression: '(DATETIME(\'now\'))'),
  ],
)
class ProfileEntity {
  @SqlField(fieldName: 'first_name')
  final String firstName;

  @SqlField(fieldName: 'last_name')
  final String lastName;

  @SqlField(fieldName: 'position')
  final String? position;

  @SqlField(
    fieldName: 'age',
    fieldType: SqlFieldType.integer,
  )
  final int age;

  ProfileEntity({
    required this.firstName,
    required this.lastName,
    required this.age,
    this.position,
  });
}
