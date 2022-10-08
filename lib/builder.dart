import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:sqflite_entities/src/sqlite_adapter_generator.dart';

Builder getBuilder(BuilderOptions options) => PartBuilder(
      [
        SqfliteAdapterGenerator(),
      ],
      '.sql.g.dart',
      header: '''
      // coverage:ignore-file
      // GENERATED CODE - DO NOT MODIFY BY HAND
    ''',
    );
