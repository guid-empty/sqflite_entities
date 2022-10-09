import 'package:sqflite_entities/sqflite_entities.dart';
import 'package:sqflite_entities_annotations/sqflite_entities_annotations.dart';

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
  @SqlField(
    fieldName: 'first_name',
    fieldType: SqlFieldType.text,
  )
  final String firstName;

  @SqlField(
    fieldName: 'last_name',
    fieldType: SqlFieldType.text,
  )
  final String lastName;

  @SqlField(
    fieldName: 'position',
    fieldType: SqlFieldType.text,
  )
  final String? position;

  @SqlField(
    fieldName: 'profile',
    fieldType: SqlFieldType.text,
  )
  final String? profile;

  @SqlField(
    fieldName: 'team_name',
    fieldType: SqlFieldType.text,
  )
  final String? teamName;

  ProfileEntity({
    required this.firstName,
    required this.lastName,
    this.position,
    this.profile,
    this.teamName,
  });
}
