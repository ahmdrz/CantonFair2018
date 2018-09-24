import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class Category {
  static Database db;

  static final String dbName = "name";
  static final String dbCreatedAt = "created_at";
  static final String dbUUID = "uuid";

  static final String tableName = "categories";
  static final String dbOnCreate = "CREATE TABLE IF NOT EXISTS $tableName ("
      "${Category.dbUUID} STRING PRIMARY KEY,"
      "${Category.dbName} STRING UNIQUE,"
      "${Category.dbCreatedAt} TEXT"
      ")";

  String uuid;
  String name;
  DateTime createdAt;
  int id;

  Category({this.name}) {
    this.createdAt = new DateTime.now();
    this.uuid = new Uuid().v4();    
  }

  Category.fromMap(Map<String, dynamic> map) {
    this.createdAt = DateTime.parse(map[dbCreatedAt]);
    this.name = map[dbName];
    this.uuid = map[dbUUID];
  }

  Future<List<Category>> getCategories() async {
    var result = await db.rawQuery('SELECT * FROM $tableName');
    List<Category> books = [];
    for (Map<String, dynamic> item in result) {
      books.add(new Category.fromMap(item));
    }
    return books;
  }

  Future<Category> getCategoryByName(String name) async {
    var result =
        await db.rawQuery('SELECT * FROM $tableName WHERE $dbName = ?', [name]);
    if (result.length == 0) return null;
    return Category.fromMap(result[0]);
  }

  Future updateCategory(Category category) async {
    await db.rawInsert(
        'INSERT OR REPLACE INTO '
        '$tableName(${Category.dbUUID}, ${Category.dbName}, ${Category.dbCreatedAt})'
        ' VALUES(?, ?, ?)',
        [
          category.uuid,
          category.name,
          category.createdAt.toIso8601String(),
        ]);
  }

  Map<String, dynamic> toMap() {
    return {
      dbName: name,
      dbUUID: uuid,
      dbCreatedAt: createdAt.toIso8601String(),
    };
  }
}
