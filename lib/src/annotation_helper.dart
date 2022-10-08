import 'package:analyzer/dart/element/element.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqflite_entities_annotations/sqflite_entities_annotations.dart';

const _sqlEntityChecker = TypeChecker.fromRuntime(SqlEntityDefinition);
const _sqlFieldChecker = TypeChecker.fromRuntime(SqlField);

FieldDescriptor? getFieldDescriptorForElement(Element element) {
  final dartObject = _sqlFieldChecker.firstAnnotationOfExact(element);
  if (dartObject == null) {
    return null;
  }

  final encoder = dartObject.getField('toRawData')?.toFunctionValue();
  final decoder = dartObject.getField('fromRawData')?.toFunctionValue();

  String? encoderName;
  String? decoderName;

  if (encoder != null) {
    _checkFactoryFunction(encoder);
    encoderName = encoder.name;
    if (encoder is MethodElement) {
      encoderName = '${encoder.enclosingElement3.name}.$encoderName';
    }
  }

  if (decoder != null) {
    _checkFactoryFunction(decoder);
    decoderName = decoder.name;
    if (decoder is MethodElement) {
      decoderName = '${decoder.enclosingElement3.name}.$decoderName';
    }
  }

  final defaultValue =
      dartObject.getField('defaultValueExpression')?.toStringValue();
  final fieldName = dartObject.getField('fieldName')?.toStringValue();
  final isPrimaryKey =
      dartObject.getField('isPrimaryKey')!.toBoolValue() ?? false;
  final fieldType = SqlFieldType.parse(
    dartObject.getField('fieldType')!.getField('value')!.toStringValue()!,
  );
  final isAutoIncrement =
      dartObject.getField('isAutoIncrement')?.toBoolValue() ?? false;

  return FieldDescriptor(
    sqlFieldName: fieldName ?? element.name!,
    sqlFieldType: fieldType,
    isPrimaryKey: isPrimaryKey,
    defaultValueExpression: defaultValue,
    encoder: encoderName,
    decoder: decoderName,
    isAutoIncrement: isAutoIncrement,
  );
}

SqlEntityDefinition getSqlEntityAnnotation(Element element) {
  final dartObject = _sqlEntityChecker.firstAnnotationOfExact(element)!;

  final additionalFields = dartObject.getField('fields')?.toListValue() ?? [];
  final tableName = dartObject.getField('tableName')!.toStringValue()!;

  final sqlFields = <SqlField>[];
  for (final field in additionalFields) {
    final fieldName = field.getField('fieldName')!.toStringValue()!;
    final defaultValueExpression =
        field.getField('defaultValueExpression')?.toStringValue();
    final isPrimaryKey = field.getField('isPrimaryKey')!.toBoolValue() ?? false;
    final fieldType = SqlFieldType.parse(
      field.getField('fieldType')!.getField('value')!.toStringValue()!,
    );
    final isAutoIncrement =
        field.getField('isAutoIncrement')?.toBoolValue() ?? false;

    sqlFields.add(
      SqlField(
        fieldName: fieldName,
        fieldType: fieldType,
        isPrimaryKey: isPrimaryKey,
        defaultValueExpression: defaultValueExpression,
        isAutoIncrement: isAutoIncrement,
      ),
    );
  }

  return SqlEntityDefinition(
    tableName: tableName,
    fields: sqlFields,
  );
}

void _checkFactoryFunction(ExecutableElement executableElement) {
  if (executableElement.parameters.isEmpty ||
      executableElement.parameters.first.isNamed ||
      executableElement.parameters.where((pe) => !pe.isOptional).length > 1) {
    throw InvalidGenerationSourceError(
        'Error with `@JsonKey` on `${executableElement.name}`. The function `${executableElement.name}` must have one '
        'positional parameter.',
        element: executableElement);
  }
}

class AccessorDescriptor {
  final String propertyName;
  final String propertyType;
  final bool isNullable;

  AccessorDescriptor({
    required this.propertyType,
    required this.propertyName,
    required this.isNullable,
  });
}

class FieldDescriptor {
  final String sqlFieldName;
  final SqlFieldType sqlFieldType;
  final bool isPrimaryKey;
  final bool isNullable;
  final bool isAutoIncrement;
  final String? defaultValueExpression;
  final String? dartModelPropertyName;
  final String? dartModelPropertyType;
  final String? encoder;
  final String? decoder;

  final bool hasFactory;

  FieldDescriptor({
    required this.sqlFieldName,
    required this.sqlFieldType,
    required this.isPrimaryKey,
    this.defaultValueExpression,
    this.hasFactory = true,
    this.isNullable = false,
    this.isAutoIncrement = false,
    this.encoder,
    this.decoder,
    String? dartModelPropertyName,
    String? dartModelPropertyType,
  })  : dartModelPropertyName = dartModelPropertyName ?? sqlFieldName,
        dartModelPropertyType = dartModelPropertyType ?? 'String';
}
