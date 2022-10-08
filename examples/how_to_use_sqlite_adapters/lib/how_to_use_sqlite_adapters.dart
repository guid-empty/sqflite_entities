import 'package:how_to_use_sqlite_adapters/models/image_entity.dart';
import 'package:how_to_use_sqlite_adapters/models/profile_entity.dart';
import 'package:how_to_use_sqlite_adapters/sqlite/sqlite_engine.dart';

Future<void> main() async {
  await _initDb();
}

Future<void> _initDb() async {
  final storage = ApplicationDBStorage();
  storage.registryAdapters(
    [
      ImageEntitySqlAdapter(),
      ProfileEntitySqlAdapter(),
    ],
  );
  await storage.initialize(
    databaseIdentity: 'test_only',
  );
}
