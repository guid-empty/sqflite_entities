import 'package:example/sqlite/sqlite_codec.dart';
import 'package:sqflite_entities/sqflite_entities.dart';
import 'package:sqflite_entities/sqflite_entities_annotations.dart';

part 'image_entity.sql.g.dart';

@SqlEntityDefinition(tableName: 'images')
class ImageEntity {
  @SqlField(
    fieldName: 'id',
    fieldType: SqlFieldType.integer,
    isPrimaryKey: true,
  )
  final int id;

  @SqlField(
    fieldName: 'created_at',
    fieldType: SqlFieldType.integer,
    toRawData: SqliteCodec.dateTimeEncode,
    fromRawData: SqliteCodec.dateTimeDecode,
  )
  final DateTime createdAt;

  @SqlField(
    fieldName: 'uploaded_at',
    fieldType: SqlFieldType.integer,
    toRawData: SqliteCodec.dateTimeEncodeNullable,
    fromRawData: SqliteCodec.dateTimeDecodeNullable,
  )
  final DateTime? uploadedAt;

  @SqlField(
    fieldName: 'file_size_bytes',
    fieldType: SqlFieldType.integer,
  )
  final int? fileSizeBytes;

  @SqlField(
    fieldName: 'is_file_uploaded',
    fieldType: SqlFieldType.integer,
    toRawData: SqliteCodec.boolEncodeNullable,
    fromRawData: SqliteCodec.boolDecodeNullable,
  )
  final bool isFileUploaded;

  @SqlField(
    fieldName: 'width',
    fieldType: SqlFieldType.integer,
  )
  final int width;

  @SqlField(
    fieldName: 'height',
    fieldType: SqlFieldType.integer,
  )
  final int height;

  @SqlField(
    fieldName: 'is_deleted',
    fieldType: SqlFieldType.integer,
    toRawData: SqliteCodec.boolEncodeNullable,
    fromRawData: SqliteCodec.boolDecodeNullable,
  )
  final bool isDeleted;

  @SqlField(
    fieldName: 'author_id',
    fieldType: SqlFieldType.integer,
  )
  final int? authorId;

  ImageEntity({
    required this.id,
    required this.width,
    required this.height,
    required this.createdAt,
    this.uploadedAt,
    this.fileSizeBytes,
    this.isFileUploaded = false,
    this.isDeleted = false,
    this.authorId,
  });
}
