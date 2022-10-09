import 'package:example/models/image_entity.dart';
import 'package:example/models/profile_entity.dart';
import 'package:example/sqlite/application_db_engine.dart';
import 'package:example/sqlite/sqlite_codec.dart';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Sqflite.setDebugModeOn(true);
  final dbEngine = ApplicationDBEngine();
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
  int _counter = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }
}
