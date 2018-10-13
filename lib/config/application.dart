import 'dart:async';
import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/Category.dart';
import '../models/CaptureModel.dart';
import '../models/Series.dart';
import '../models/Settings.dart';

class Application {
  static Router router;
  static Database db;
  static bool _dbIsOpened = false;
  static String _databaseName = 'cantonfair.db';
  static Map<String, dynamic> cache;
  static String databasePath = "";
  static String appDir;
  static String mainDir;

  static String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  static Future backupDatabase() async {
    await closeDatabase();
    File f = new File(join(databasePath, _databaseName));
    var backup = join(appDir, "Backup");
    String newPath = join(backup, '${timestamp()}.db');
    await Directory(backup).create(recursive: true);
    print("Coping to $newPath");
    await f.copy(newPath);
    await openDB();
  }

  static Future forceDelete() async {
    await closeDatabase();
    File f = new File(join(databasePath, _databaseName));    
    if (await f.exists()) await f.delete();
    await openDB();
  }

  static Future initDatabase() async {        
    Directory extDir = await getExternalStorageDirectory(); 
    mainDir = extDir.path;
    appDir = join(mainDir, "CantonFair");
    await Directory(appDir).create(recursive: true);
    databasePath = join(appDir, "Database");
    await openDB();
  }

  static Future openDB() async {
    String path = join(databasePath, _databaseName);
    print("db path is $path");
    db = await openDatabase(
      path,
      version: 1,
      onOpen: (Database db) async {
        print("Database opened !");
        _dbIsOpened = true;

        print("Creating ${Settings.tableName} ...");
        await db.execute(Settings.dbOnCreate);
        Settings.db = db;

        print("Creating ${CaptureModel.tableName} ...");
        await db.execute(CaptureModel.dbOnCreate);
        CaptureModel.db = db;

        print("Creating ${Category.tableName} ...");
        await db.execute(Category.dbOnCreate);
        Category.db = db;

        print("Creating ${Series.tableName} ...");
        await db.execute(Series.dbOnCreate);
        Series.db = db;
      },
      onCreate: (Database db, int version) async {
        // only on production
      },
    );
  }

  static Future closeDatabase() async {
    if (_dbIsOpened) {
      _dbIsOpened = false;
      return db.close();
    }
  }
}
