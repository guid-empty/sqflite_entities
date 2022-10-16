# Sqflite entities

Sqflite package extension to add some ORM abilities. From Sqlite/Sqflite fan, with love ).

# Index

- [Index](#index)
- [Motivation](#motivation)
- [Code generation](#code-generation)
- [What is inside](#what-is-inside)
- [DbEngine](#dbengine)
- [Field mapping](#field-mapping)
- [What if we need to support DateTime for our entity?](#what-if-we-need-to-support-datetime-for-our-entity)
- [Primary Key](#primary-key)
- [Custom fields](#custom-fields)
- [Migration from one database version to new one](#migration-from-one-database-version-to-new-one)
- [Hive to SQLite migration](#hive-to-sqlite-migration)
- [Usage](#usage)

## Motivation

Sqflite (https://pub.dev/packages/sqflite) is a cool and powerful sqlite package
that supports a lot of stuff, including:

* Support transactions and batches
* Automatic version management during open
* Helpers for insert/query/update/delete queries
* DB operation executed in a background thread on iOS and Android

But there is one thing missing - an ORM approach that would allow you to get some
ORM practices out of the box for working with classes in the code,
the instances of which you plan to store in the database and further continue to work with them.


This package is an attempt to add some syntax sugar to Sqflite that makes it even easier,
declarative, and safer when we are talking about data type conversions.

I'll try to show you how it might look in our code.

Imagine that we have an entity of type ProfileEntity that needs to be stored in the database.
In Dart, it is declared like this:


```dart
class ProfileEntity {
  final String firstName;
  final String lastName;
  final String? position;
  final String? profile;
...
}
```

If we want to store instances of this type in the database (we can reference it as *Entity* further),
we can mark it up in the code with **@SqlEntityDefinition** annotations,
including setting the name of the table in the database.

For example, it might look like this:

```dart
@SqlEntityDefinition(tableName: 'profile')
class ProfileEntity {
  @SqlField(fieldName: 'first_name')
  final String firstName;

  @SqlField(fieldName: 'last_name')
  final String lastName;

  @SqlField(fieldName: 'position')
  final String? position;

  @SqlField(fieldName: 'profile')
  final String? profile;

  @SqlField(fieldName: 'team_name')
  final String? teamName;

```

In this example, using the *SqlEntityDefinition* annotation, we specify the name of the table (*profile*).
Using the *SqlField* annotation, we determine which are the fields we need to store in the database,
and corresponding columns to be used to store them.

Very similar to Hive, isn't it https://pub.dev/packages/hive#store-objects?

## Code generation

Then there is the step of code generation.

We add the corresponding part file to the file of the declared entity itself,
by analogy with how we do it for json_serializable, freezed or hive etc.

For example,

```dart
part 'profile_entity.sql.g.dart';

@SqlEntityDefinition(tableName: 'profile')
class ProfileEntity {
```

Let's start code generation:

```shell
flutter pub run build_runner build --delete-conflicting-outputs
```

As a result, after code generation, the following functions will be available to us in the code:

Storing the Entity:

```dart
await dbEngine.storeEntity(
    ProfileEntity(
      firstName: 'A',
      lastName: 'B',
    ),
  );
```

Get all available entities of specified Type:

```dart
await dbEngine.retrieveCollection<ProfileEntity>();
```


Or just the very first one:
```dart
await dbEngine.retrieveFirstEntity<ProfileEntity>();
```


Update an entity according to a given condition:


```dart
final updatedEntity = ProfileEntity(
    firstName: 'A',
    lastName: 'C',
  );

await dbEngine.updateEntity(
    updatedEntity,
    where: '${ProfileEntitySqlAdapter.columns.lastName} == ?',
    whereArgs: ['B'],
  );
```


Or we can delete some entities by condition:

```dart
await dbEngine.deleteEntity<ProfileEntity>(
    where: '${ProfileEntitySqlAdapter.columns.lastName} == ?',
    whereArgs: ['B'],
  );
```

or all entities at once:

```dart
await dbEngine.clearEntities<ProfileEntity>();
```

If you need to return a data set from the database according to your custom conditions,
you can use the **queryEntities** construct:

```dart
final selectedEntities = await dbEngine.queryEntities<ProfileEntity>(
    where: '${ProfileEntitySqlAdapter.columns.lastName} == ?',
    whereArgs: ['B'],
    orderBy: '${ProfileEntitySqlAdapter.columns.firstName} ASC',
    limit: 1
  );
```

A very important thing that should not be forgotten is Ttransactions.

They are also supported, just specify transaction object in helper methods:

Example:

```dart
await dbEngine.beginTransaction((txn) async {
    await dbEngine.updateEntity(
      updatedEntity,
      where: '${ProfileEntitySqlAdapter.columns.lastName} == ?',
      whereArgs: ['B'],
      transaction: txn,
    );

    await dbEngine.deleteEntity<ProfileEntity>(
      where: '${ProfileEntitySqlAdapter.columns.lastName} == ?',
      whereArgs: ['B'],
      transaction: txn,
    );
  });
```

And batches:

```dart
await dbEngine.beginTransaction(
      (transaction) async {
        final batch = transaction.batch();
        dbEngine.storeEntitiesBatch(entities: entities, batch: batch);
        await batch commit(noResult: true);
      },
    )
```

## What is inside?

After code generation for each entity in the generated classes, we get several important things:

* Factory method to create Entity from raw sql data
* Factory method to get raw sql data from class annotated by SqlEntityDefinition
* SqlAdapter Class - Helper class used to create table for class annotated by SqlEntityDefinition.
This class contains the logic for serializing an entity into a database format (in fact, it is a Json Map),
deserialization logic, and a Sqlite script for creating a table inside the database.

For the examples above, our SqlAdapter will look like this:

```dart
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
    created INTEGER NOT NULL DEFAULT (DATETIME('now')))
      ''';
}
```

## DbEngine

SqlAdapters themselves do not know how to work with a database.
They need some kind of engine.
In the examples above, we worked with methods through a dbEngine instance.

What is it?

In order to be able to create the appropriate tables in the database for our entities after code generation,
we create such an auxiliary class, inherited from the provided **SqliteEngine** class.
The only field that needs to be implemented is to specify the database version (to be able to migrate in the future).


For example,

```dart
class ApplicationDBEngine extends SqliteEngine {
  @override
  int get dbVersion => 1;
}
```

Next, when we want to work with database we need to create and initialize an instance of our SqliteEngine:

```dart
final dbEngine = ApplicationDBEngine();
```

Using the **registryAdapters** method,
we enumerate the list of sql adapters of all types for which we need to create our own tables:

```dart
dbEngine.registryAdapters(
    [
      const ImageEntitySqlAdapter(),
      const ProfileEntitySqlAdapter(),
    ],
  );
```

The last thing we need is to create the database itself in case it doesn't exist.

```dart
await dbEngine.initialize(databaseIdentity: 'test_only')
```


You can also configure a specific file name using the optional *filePathFactory* parameter.

```dart
await dbEngine.initialize(
    databaseIdentity: 'test_only',
    filePathFactory: () => applicationDatabaseFilePath,
  )
```

## Field mapping

Above, for the Profile entity, we used the *TEXT* data type to store entity fields.
This data type is used by default, if we do not specify otherwise.

But we can specify any of the supported Sqlite data types using the SqlField annotation
on the fieldType field:

For example,

```dart
  @SqlField(
    fieldName: 'uploaded_at',
    fieldType: SqlFieldType.integer,
```

The following **SqlFieldType** enumeration types are supported:

* integer
* real
* text
* blob

what corresponds to the used sqlite type: https://www.sqlite.org/datatype3.html

## What if we need to support DateTime for our entity?

Sqlite does not support the Date data type. 
However, using the **Sqlfield** annotation,
we can support custom serialization / deserialization of this data type to any of the data types
supported in Sqlite.

For example, convert datetime from dart to int data type via *microsecondsSinceEpoch*. 
Back via *DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch)*.

The same is true for the boolean type, performing conversions to and from integer.

We can do this by specifying tear-off methods for the toRawData, fromRawData factories.

For example,

```dart
  @SqlField(
    fieldName: 'created_at',
    fieldType: SqlFieldType.integer,
    toRawData: SqliteCodec.dateTimeEncode,
    fromRawData: SqliteCodec.dateTimeDecode,
  )
  final DateTime createdAt;

...

abstract class SqliteCodec {
  static DateTime dateTimeDecode(int microsecondsSinceEpoch) =>
      DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);

  static int dateTimeEncode(DateTime value) => value.microsecondsSinceEpoch;
}

```

## Primary Key

In order to maintain the uniqueness of records, using the SqlField annotation,
you can specify that a particular field will be used as the primary key in the corresponding table.

For example,

```dart
  @SqlField(
    fieldName: 'id',
    fieldType: SqlFieldType.integer,
    isPrimaryKey: true
  )
  final int id;
```

You can specify *isPrimaryKey* for several fields - in this case, the compound primary key will be formed.

## Custom fields

It happens that for some entities we need to support some service fields in the database table
that should not be part of the class.

This can be an auto increment field, or other fields with default values set,
such as the date a record was created in a table, or the date it was updated.


In this case, you can use the **SqlEntityDefinition** annotation
by specifying such fields outside the entity itself.

For example,

```dart
@SqlEntityDefinition(
  tableName: 'profile',
  fields: [
    SQLField(
      fieldName: 'id',
      fieldType: SqlFieldType.integer,
      isAutoIncrement: true,
      isPrimaryKey: true,
    ),
    SQLField(
        fieldName: 'created',
        fieldType: SqlFieldType.integer,
        defaultValueExpression: '(DATETIME(\'now\'))'),
  ],
)
```

For the case above, these fields can also be used in where expressions,
for example, for custom queries in queryEntities.

```dart
  await dbEngine.queryEntities<ProfileEntity>(
    where: '${ProfileEntitySqlAdapter.columns.created} > ? ',
    whereArgs: [
      lastCreatedDate,
    ],
  );
```


## Migration from one database version to new one

Above, we talked about creating our own SqliteEngine class,
which will contain all the logic for working with entities.

```dart
class ApplicationDBEngine extends SqliteEngine {
  @override
  int get dbVersion => 1;
}
```

It was important to specify the version number.

It often happens that the database changes and it is necessary to support it with an upgrade to a new version.

There is also support for such a scenario, and it is implemented through the implementation of the property

```dart
Map<int, DatabaseMigration> get migrations;
```


*migrations* getter should return a Map whose key is the version number to which the script specified by the DatabaseMigration
function will be executed.

For example, such migrations might look like this:

```dart
  Map<int, DatabaseMigration> get migrations => {
        2: (db) => db.execute(
              'ALTER TABLE profile ADD COLUMN team_lead TEXT',
            ),
        3: (db) => db.execute(
              'ALTER TABLE image ADD COLUMN created INTEGER',
            ),
      };
```

This collection of migrations tells us that if version 2 is installed on the client,
and the current version of the new database should become 3,
then only the script will be executed:

```sql
ALTER TABLE image ADD COLUMN created INTEGER
```

If version 1 was previously installed, then both migrations will be performed -
from version 1 to version 2, and from version 2 to version 3.

## Hive to SQLite migration

As shown above, the proposed approach is very similar to Hive,
when we use annotations to define the types that Hive will work with.

The *@HiveType* annotation corresponds to the *SqlEntityDefinition*.

@HiveField to @SqlField.

*TypeAdapter* is responsible for about the same functions as *SqlAdapter*.


At the same time, the logic for registering a list of such adapters is also very similar.

Compare the code:

```dart
hive.registerAdapter(ImageEntityAdapter());
hive.registerAdapter(ProfileEntityAdapter());
```

and

```dart
  dbEngine.registryAdapters(
    [
      const ImageEntitySqlAdapter(),
      const ProfileEntitySqlAdapter(),
    ],
  );
```


Therefore, if you want to switch from Hive to Sqflite, it will be quite easy for you to do it.
Of course it won't be so easy ). 
You will need to refactor all interactions with your entities in the code (to store them, retrieve etc).

But, welcome.


## Usage

To mark up your classes with **@Sql**... annotations, 
and to declare the Sqlite database engine class (under the hood is Sqflite), 
you need to add sqflite_entities package to the pubspec in the dependencies:

*sqflite_entities_annotations*

```shell
flutter pub add sqflite_entities
```

To perform the code generation, you need to add the *sqflite_entities_generator* package to dev_dependencies:

```shell
flutter pub add sqflite_entities_generator --dev
```


Wishes and comments are welcome.