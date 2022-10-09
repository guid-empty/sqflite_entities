// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_entity.dart';

// **************************************************************************
// SqfliteEntitiesGenerator
// **************************************************************************

///
/// Factory method to create Entity from raw sql data
///
ProfileEntity _$ProfileEntityFromSqlDataMap(Map<String, dynamic> rawData) {
  return ProfileEntity(
    firstName: rawData['first_name'] as String,
    lastName: rawData['last_name'] as String,
    position: rawData['position'] as String?,
    profile: rawData['profile'] as String?,
    teamName: rawData['team_name'] as String?,
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
  val['profile'] = instance.profile;
  val['team_name'] = instance.teamName;
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
  final String profile = 'profile';
  final String teamName = 'team_name';
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
		profile TEXT,
		team_name TEXT,
		id INTEGER PRIMARY KEY AUTOINCREMENT ,
		created INTEGER NOT NULL  DEFAULT (DATETIME('now')))
      ''';
}
