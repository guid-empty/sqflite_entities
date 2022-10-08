// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_entity.dart';

// **************************************************************************
// SqfliteAdapterGenerator
// **************************************************************************

///
/// Factory method to create Entity from raw sql data
///
ImageEntity _$ImageEntityFromSqlDataMap(Map<String, dynamic> rawData) {
  return ImageEntity(
    id: rawData['id'] as int,
    createdAt: SqliteCodec.dateTimeDecode(rawData['created_at'] as int),
    uploadedAt:
        SqliteCodec.dateTimeDecodeNullable(rawData['uploaded_at'] as int?),
    fileSizeBytes: rawData['file_size_bytes'] as int?,
    isFileUploaded:
        SqliteCodec.boolDecodeNullable(rawData['is_file_uploaded'] as int),
    width: rawData['width'] as int,
    height: rawData['height'] as int,
    isDeleted: SqliteCodec.boolDecodeNullable(rawData['is_deleted'] as int),
  );
}

///
/// Factory method to get raw sql data from class annotated by SqlEntityDefinition
///
Map<String, dynamic> _$ImageEntityToSqlDataMap(ImageEntity instance) {
  final val = <String, dynamic>{};
  val['id'] = instance.id;
  val['created_at'] = SqliteCodec.dateTimeEncode(instance.createdAt);
  val['uploaded_at'] = SqliteCodec.dateTimeEncodeNullable(instance.uploadedAt);
  val['file_size_bytes'] = instance.fileSizeBytes;
  val['is_file_uploaded'] =
      SqliteCodec.boolEncodeNullable(instance.isFileUploaded);
  val['width'] = instance.width;
  val['height'] = instance.height;
  val['is_deleted'] = SqliteCodec.boolEncodeNullable(instance.isDeleted);
  return val;
}

///
/// Sqflite table columns declarations
///
class ImageEntityColumnsDeclaration {
  const ImageEntityColumnsDeclaration();

  final String id = 'id';
  final String createdAt = 'created_at';
  final String uploadedAt = 'uploaded_at';
  final String fileSizeBytes = 'file_size_bytes';
  final String isFileUploaded = 'is_file_uploaded';
  final String width = 'width';
  final String height = 'height';
  final String isDeleted = 'is_deleted';
}

///
/// Helper class used to create table for class annotated by SqlEntityDefinition
///
class ImageEntitySqlAdapter implements SqlAdapter<ImageEntity> {
  static const ImageEntityColumnsDeclaration columns =
      ImageEntityColumnsDeclaration();

  const ImageEntitySqlAdapter();

  @override
  Type get modelType => ImageEntity;

  @override
  ImageEntity deserialize(Map<String, dynamic> json) =>
      _$ImageEntityFromSqlDataMap(json);

  @override
  Map<String, dynamic> serialize(ImageEntity entity) =>
      _$ImageEntityToSqlDataMap(entity);

  @override
  String get tableName => 'images';

  @override
  String get createEntityTableScript => '''
        
CREATE TABLE images(
		id INTEGER PRIMARY KEY,
		created_at INTEGER NOT NULL ,
		uploaded_at INTEGER,
		file_size_bytes INTEGER,
		is_file_uploaded INTEGER NOT NULL ,
		width INTEGER NOT NULL ,
		height INTEGER NOT NULL ,
		is_deleted INTEGER NOT NULL )
      ''';
}
