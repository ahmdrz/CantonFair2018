import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import '../models/Category.dart';

class CategoryDatabase {
  static final CategoryDatabase _categoryDatabase =
      new CategoryDatabase._internal();

  final String tableName = "categories";

  Database db;

  bool didInit = false;

  static CategoryDatabase get() {
    return _categoryDatabase;
  }

  CategoryDatabase._internal();

  /// Use this method to access the database, because initialization of the database (it has to go through the method channel)
  Future<Database> _getDb() async {
    if (!didInit) await _init();
    return db;
  }

  Future init() async {
    return await _init();
  }

  Future _init() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, "cantonfair.db");
    print('Init for database, Path $path');
    db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute("CREATE TABLE $tableName ("
          "${Category.dbName} STRING PRIMARY KEY,"
          "${Category.dbCreatedAt} TEXT"
          ")");
    });
    didInit = true;
  }

  Future<List<Category>> getCategories() async {
    var db = await _getDb();
    var result = await db.rawQuery('SELECT * FROM $tableName');
    List<Category> books = [];
    for (Map<String, dynamic> item in result) {
      books.add(new Category.fromMap(item));
    }
    return books;
  }

  Future updateCategory(Category category) async {
    var db = await _getDb();
    await db.rawInsert(
        'INSERT OR REPLACE INTO '
        '$tableName(${Category.dbName}, ${Category.dbCreatedAt})'
        ' VALUES(?, ?)',
        [
          category.name,
          category.createdAt.toIso8601String(),
        ]);
  }

  Future deleteCategory(Category category) async {
    var db = await _getDb();
    await db.rawInsert(
        'DELETE FROM '
        '$tableName WHERE ${Category.dbName} = ?',
        [
          category.name,
        ]);
  }

  Future close() async {
    var db = await _getDb();
    return db.close();
  }
}
