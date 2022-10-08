import 'package:how_to_use_sqlite_adapters/sqlite/sqlite_codec.dart';
import 'package:sqflite_entities/sqflite_entities.dart';
import 'package:sqflite_entities_annotations/sqflite_entities_annotations.dart';

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
    toRawData: SqfliteCodec.dateTimeEncode,
    fromRawData: SqfliteCodec.dateTimeDecode,
  )
  final DateTime createdAt;

  @SqlField(
    fieldName: 'uploaded_at',
    fieldType: SqlFieldType.integer,
    toRawData: SqfliteCodec.dateTimeEncodeNullable,
    fromRawData: SqfliteCodec.dateTimeDecodeNullable,
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
    toRawData: SqfliteCodec.boolEncodeNullable,
    fromRawData: SqfliteCodec.boolDecodeNullable,
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
    toRawData: SqfliteCodec.boolEncodeNullable,
    fromRawData: SqfliteCodec.boolDecodeNullable,
  )
  final bool isDeleted;

  ImageEntity({
    required this.id,
    required this.width,
    required this.height,
    required this.createdAt,
    this.uploadedAt,
    this.fileSizeBytes,
    this.isFileUploaded = false,
    this.isDeleted = false,
  });
}
