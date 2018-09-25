import 'dart:async';
import 'dart:io';

import 'package:fluro/fluro.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../models/Category.dart';
import '../models/ImageModel.dart';
import '../models/Series.dart';

class Application {
  static Router router;
  static Database db;
  static bool _dbIsOpened = false;
  static String _databaseName = 'cantonfair.db';
  static Map<String, dynamic> cache;

  static Future initDatabase() async {
    print("init database !");
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    db = await openDatabase(
      path,
      version: 1,
      onOpen: (Database db) async {
        print("Database opened !");
        _dbIsOpened = true;

        // only on development
        // print("Droping ${Category.tableName} ...");
        // await db.execute("DROP TABLE ${Category.tableName};");

        // print("Droping ${Series.tableName} ...");
        // await db.execute("DROP TABLE ${Series.tableName};");

        // print("Droping ${Image.tableName} ...");
        // await db.execute("DROP TABLE ${Image.tableName};");

        print("Creating ${ImageModel.tableName} ...");
        await db.execute(ImageModel.dbOnCreate);
        ImageModel.db = db;

        print("Creating ${Category.tableName} ...");
        await db.execute(Category.dbOnCreate);
        Category.db = db;

        print("Creating ${Series.tableName} ...");
        await db.execute(Series.dbOnCreate);
        Series.db = db;
      },
      onCreate: (Database db, int version) async {
        // only on production
        print("Creating ${Category.tableName} ...");
        await db.execute(Category.dbOnCreate);

        print("Creating ${Series.tableName} ...");
        await db.execute(Series.dbOnCreate);
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
