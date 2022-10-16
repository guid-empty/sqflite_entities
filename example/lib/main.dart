import 'package:example/models/image_entity.dart';
import 'package:example/models/profile_entity.dart';
import 'package:example/sqlite/application_db_engine.dart';
import 'package:example/sqlite/sqlite_codec.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Sqflite.setDebugModeOn(true);

  dbEngine.registryAdapters(
    [
      const ImageEntitySqlAdapter(),
      const ProfileEntitySqlAdapter(),
    ],
  );
  await dbEngine.initialize(
    databaseIdentity: 'test_only',
  );

  await dbEngine.storeEntity(
    ImageEntity(
      id: 33,
      width: 100,
      height: 200,
      createdAt: DateTime.now(),
      isDeleted: false,
    ),
  );

  await dbEngine.retrieveCollection<ImageEntity>();

  await dbEngine.queryEntities<ImageEntity>(
    where: '${ImageEntitySqlAdapter.columns.id} = ? '
        ' AND ${ImageEntitySqlAdapter.columns.isDeleted} = ?',
    whereArgs: [
      33,
      SqliteCodec.boolEncode(false),
    ],
  );

  await dbEngine.storeEntity(
    ProfileEntity(
      firstName: 'A',
      lastName: 'B',
    ),
  );

  await dbEngine.retrieveCollection<ProfileEntity>();

  runApp(const MyApp());
}

final dbEngine = ApplicationDBEngine();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  const MyHomePage({Key? key, required this.title}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late Future<List<ProfileEntity>> profileEntitiesLoaderFuture;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: FutureBuilder(
        future: profileEntitiesLoaderFuture,
        initialData: const [],
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return ListView(
              children: (snapshot.requireData as List<ProfileEntity>)
                  .map((e) => SizedBox(
                        height: 40,
                        child: Text('${e.firstName} ${e.lastName}'.toString()),
                      ))
                  .toList(),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await dbEngine.storeEntity(
            ProfileEntity(
              firstName: 'John',
              lastName: 'Smith',
            ),
          );
          fetchProfileEntities();
        },
        tooltip: 'Add profile',
        child: const Icon(Icons.add),
      ),
    );
  }

  void fetchProfileEntities() {
    profileEntitiesLoaderFuture = dbEngine.retrieveCollection<ProfileEntity>();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    fetchProfileEntities();
  }
}
