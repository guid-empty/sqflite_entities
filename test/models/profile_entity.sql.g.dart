// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_entity.dart';

// **************************************************************************
// SqfliteAdapterGenerator
// **************************************************************************

///
/// Factory method to create Entity from raw sql data
///
ProfileEntity _$ProfileEntityFromSqlDataMap(Map<String, dynamic> rawData) {
  return ProfileEntity(
    firstName: rawData['first_name'] as String,
    lastName: rawData['last_name'] as String,
    position: rawData['position'] as String?,
    age: rawData['age'] as int,
  );
}

///
/// Factory method to get raw sql data from class annotated by SqlEntityDefinition
///
Map<String, dynamic> _$ProfileEntityToSqlDataMap(ProfileEntity instance) {
  final val = <String, dynamic>{};
  val['first_name'] = instance.firstName;
  val['last_name'] = instance.lastName;
  val['position'] = instance.position;
  val['age'] = instance.age;
  return val;
}

///
/// Sqflite table columns declarations
///
class ProfileEntityColumnsDeclaration {
  const ProfileEntityColumnsDeclaration();

  final String firstName = 'first_name';
  final String lastName = 'last_name';
  final String position = 'position';
  final String age = 'age';
  final String id = 'id';
  final String created = 'created';
}

///
/// Helper class used to create table for class annotated by SqlEntityDefinition
///
class ProfileEntitySqlAdapter implements SqlAdapter<ProfileEntity> {
  static const ProfileEntityColumnsDeclaration columns =
      ProfileEntityColumnsDeclaration();

  const ProfileEntitySqlAdapter();

  @override
  Type get modelType => ProfileEntity;

  @override
  ProfileEntity deserialize(Map<String, dynamic> json) =>
      _$ProfileEntityFromSqlDataMap(json);

  @override
  Map<String, dynamic> serialize(ProfileEntity entity) =>
      _$ProfileEntityToSqlDataMap(entity);

  @override
  String get tableName => 'profile';

  @override
  String get createEntityTableScript => '''
        
CREATE TABLE profile(
		first_name TEXT NOT NULL ,
		last_name TEXT NOT NULL ,
		position TEXT,
		age INTEGER NOT NULL ,
		id INTEGER PRIMARY KEY AUTOINCREMENT ,
		created INTEGER NOT NULL  DEFAULT (DATETIME('now')))
      ''';
}
