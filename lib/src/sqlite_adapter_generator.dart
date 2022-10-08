import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqflite_entities/src/annotation_helper.dart';
import 'package:sqflite_entities_annotations/sqflite_entities_annotations.dart';

class SqfliteAdapterGenerator
    extends GeneratorForAnnotation<SqlEntityDefinition> {
  @override
  Future<String> generateForAnnotatedElement(
      Element element, ConstantReader annotation, BuildStep buildStep) async {
    if (element is! ClassElement) {
      throw InvalidGenerationSourceError(
        '@SqlEntityDefinition can only be used on classes.',
        element: element,
      );
    }

    final classElement = _getClass(element);
    final library = await buildStep.inputLibrary;

    final sqlEntityAnnotation = getSqlEntityAnnotation(element);

    final tableName = sqlEntityAnnotation.tableName;

    final fieldDescriptors = <FieldDescriptor>[
      ..._getFieldDescriptors(classElement, library),
      ...sqlEntityAnnotation.fields.map(
        (field) => FieldDescriptor(
          sqlFieldName: field.fieldName,
          sqlFieldType: field.fieldType,
          isPrimaryKey: field.isPrimaryKey,
          defaultValueExpression: field.defaultValueExpression,
          hasFactory: false,
          isAutoIncrement: field.isAutoIncrement,
        ),
      ),
    ];

    final adapterName = _generateSqlAdapterName(classElement.name);
    final adapterColumnsDeclarationName =
        _generateSqlColumnsDeclarationName(classElement.name);
    final toSqlDataFactoryName =
        _generateEntityToRawDataFactory(classElement.name);
    final fromSqlDataFactoryName =
        _generateEntityFromRawDataFactory(classElement.name);

    return '''
     ${_generateFromRawDataFactoryMethod(
      fromSqlDataFactoryName,
      classElement.name,
      fieldDescriptors.where((fd) => fd.hasFactory).toList(),
    )}
    
    ${_generateToRawDataFactoryMethod(
      toSqlDataFactoryName,
      classElement.name,
      fieldDescriptors.where((fd) => fd.hasFactory).toList(),
    )}

    ///
    /// Sqflite table columns declarations
    ///    
    class $adapterColumnsDeclarationName {
      const $adapterColumnsDeclarationName();
      
      ${_generateColumnNames(fieldDescriptors.toList())}
    }
    
    ///
    /// Helper class used to create table for class annotated by SqlEntityDefinition
    /// 
    class $adapterName implements SqlAdapter<${classElement.name}> {
    
      static const $adapterColumnsDeclarationName columns = $adapterColumnsDeclarationName();
    
      const $adapterName();
      
      @override
      Type get modelType => ${classElement.name};
  
      @override
      ${classElement.name} deserialize(Map<String, dynamic> json) => $fromSqlDataFactoryName(json);
      
      @override
      Map<String, dynamic> serialize(${classElement.name} entity) => $toSqlDataFactoryName(entity);
      
      @override
      String get tableName => '$tableName';
      
      @override
      String get createEntityTableScript => \'\'\'
        ${_generateEntityTableScript(tableName, fieldDescriptors)}
      \'\'\';

    }
    ''';
  }

  String _generateColumnNames(List<FieldDescriptor> fieldDescriptors) {
    final buffer = StringBuffer('\n');
    for (final fd in fieldDescriptors) {
      buffer.write(
          '\t\tfinal String ${fd.dartModelPropertyName} = \'${fd.sqlFieldName}\';\n');
    }

    return buffer.toString();
  }

  String _generateEntityTableScript(
    String tableName,
    List<FieldDescriptor> fieldDescriptors,
  ) {
    final isMultiColumnPrimaryKey =
        fieldDescriptors.where((fd) => fd.isPrimaryKey).length > 1;

    final buffer = StringBuffer('\nCREATE TABLE $tableName(\n');
    for (var i = 0; i < fieldDescriptors.length; i++) {
      final fd = fieldDescriptors[i];

      buffer.write('\t\t${fd.sqlFieldName} ${fd.sqlFieldType.value}');

      if (!fd.isPrimaryKey && !fd.isNullable) {
        buffer.write(' NOT NULL ');
      }

      if (fd.isPrimaryKey && !isMultiColumnPrimaryKey) {
        buffer.write(' PRIMARY KEY');
      }

      if (fd.defaultValueExpression?.isNotEmpty ?? false) {
        buffer
          ..write(' DEFAULT ')
          ..write(fd.defaultValueExpression);
      }

      if (fd.isAutoIncrement) {
        buffer.write(' AUTOINCREMENT ');
      }

      if (i < (fieldDescriptors.length - 1) || isMultiColumnPrimaryKey) {
        buffer.writeln(',');
      }
    }
    if (isMultiColumnPrimaryKey) {
      buffer.writeln('\t\t${_getMultiColumnPrimaryKey(fieldDescriptors)}');
    }

    buffer.write(')');
    return buffer.toString();
  }

  String _generateFromRawDataFactoryMethod(
    String factoryMethodName,
    String classEntityName,
    List<FieldDescriptor> fieldDescriptors,
  ) {
    final buffer = StringBuffer('\n');

    buffer.write('''
    ///
    /// Factory method to create Entity from raw sql data
    ///
    $classEntityName $factoryMethodName(Map<String, dynamic> rawData) {
      return $classEntityName( 
      
    ''');

    for (final fd in fieldDescriptors) {
      if (fd.decoder != null) {
        final dartFieldType = _getDartTypeForSqlFieldType(
          isNullable: fd.isNullable,
          fieldType: fd.sqlFieldType,
        );

        buffer.write(
            '\t\t${fd.dartModelPropertyName}: ${fd.decoder}(rawData[\'${fd.sqlFieldName}\'] as $dartFieldType), \n');
      } else {
        buffer.write(
            '\t\t${fd.dartModelPropertyName}: rawData[\'${fd.sqlFieldName}\'] as ${fd.dartModelPropertyType}, \n');
      }
    }

    buffer.writeln('''
      );
    }
    
    ''');

    return buffer.toString();
  }

  String _generateToRawDataFactoryMethod(
    String factoryMethodName,
    String classEntityName,
    List<FieldDescriptor> fieldDescriptors,
  ) {
    final buffer = StringBuffer('\n');

    buffer.write('''
    ///
    /// Factory method to get raw sql data from class annotated by SqlEntityDefinition
    ///
    Map<String, dynamic> $factoryMethodName($classEntityName instance) {
      final val = <String, dynamic>{};
    ''');

    for (final fd in fieldDescriptors) {
      if (fd.encoder != null) {
        final dartFieldType = _getDartTypeForSqlFieldType(
          isNullable: fd.isNullable,
          fieldType: fd.sqlFieldType,
        );

        final castExpression = !fd.isNullable ? ' as $dartFieldType ' : '';

        buffer.write(
            '\t\tval[\'${fd.sqlFieldName}\'] = ${fd.encoder}(instance.${fd.dartModelPropertyName}) $castExpression ;\n');
      } else {
        buffer.write(
            '\t\tval[\'${fd.sqlFieldName}\'] = instance.${fd.dartModelPropertyName};\n');
      }
    }

    buffer.writeln('''
      return val;
    }
    
    ''');

    return buffer.toString();
  }

  Set<AccessorDescriptor> _getAccessors(ClassElement cls) {
    final accessors = <AccessorDescriptor>{};

    final supertypes = cls.allSupertypes.map((it) => it.element2);
    for (final type in [cls, ...supertypes]) {
      for (final accessor in type.accessors) {
        if (accessor.isGetter) {
          final accessorType =
              accessor.type.returnType.getDisplayString(withNullability: true);

          accessors.add(
            AccessorDescriptor(
              propertyName: accessor.name,
              propertyType: accessorType,
              isNullable: accessor.type.returnType.nullabilitySuffix ==
                  NullabilitySuffix.question,
            ),
          );
        }
      }
    }

    return accessors;
  }

  ClassElement _getClass(Element element) => element as ClassElement;

  String _getDartTypeForSqlFieldType({
    required SqlFieldType fieldType,
    required bool isNullable,
  }) {
    final isNullableSuffix = isNullable ? '?' : '';
    if (fieldType == SqlFieldType.real) {
      return 'double$isNullableSuffix';
    }

    if (fieldType == SqlFieldType.integer) {
      return 'int$isNullableSuffix';
    }

    return 'String$isNullableSuffix';
  }

  Iterable<FieldDescriptor> _getFieldDescriptors(
      ClassElement classElement, LibraryElement library) {
    final accessors = _getAccessors(classElement);

    final getters = <FieldDescriptor>[];
    for (final accessor in accessors) {
      final getter = classElement.lookUpGetter(accessor.propertyName, library);
      if (getter != null) {
        final fd = getFieldDescriptorForElement(getter.variable) ??
            getFieldDescriptorForElement(getter);

        if (fd != null) {
          final field = getter.variable;
          getters.add(
            FieldDescriptor(
              sqlFieldName: fd.sqlFieldName,
              sqlFieldType: fd.sqlFieldType,
              isPrimaryKey: fd.isPrimaryKey,
              isAutoIncrement: fd.isAutoIncrement,
              defaultValueExpression: fd.defaultValueExpression,
              dartModelPropertyName: field.name,
              dartModelPropertyType: accessor.propertyType,
              hasFactory: true,
              decoder: fd.decoder,
              encoder: fd.encoder,
              isNullable: accessor.isNullable,
            ),
          );
        }
      }
    }

    return getters;
  }

  String _getMultiColumnPrimaryKey(List<FieldDescriptor> fieldDescriptors) {
    final primaryKeyFieldNames = fieldDescriptors
        .where((fd) => fd.isPrimaryKey)
        .map((fd) => fd.sqlFieldName)
        .toList();

    return 'PRIMARY KEY (${primaryKeyFieldNames.join(',')})';
  }

  static String _generateDartAllowedName(
    String typeName,
    String suffix, {
    String? prefix,
  }) {
    var allowedName =
        '$typeName$suffix'.replaceAll(RegExp(r'[^A-Za-z0-9]+'), '');
    if (prefix?.isNotEmpty ?? false) {
      allowedName = '$prefix$allowedName';
    }

    return allowedName;
  }

  static String _generateEntityFromRawDataFactory(String typeName) =>
      _generateDartAllowedName(typeName, 'FromSqlDataMap', prefix: r'_$');

  static String _generateEntityToRawDataFactory(String typeName) =>
      _generateDartAllowedName(typeName, 'ToSqlDataMap', prefix: r'_$');

  static String _generateSqlAdapterName(String typeName) =>
      _generateDartAllowedName(typeName, 'SqlAdapter');

  static String _generateSqlColumnsDeclarationName(String typeName) =>
      _generateDartAllowedName(typeName, 'ColumnsDeclaration');
}
