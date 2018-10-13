import 'dart:async';
import 'package:sqflite/sqflite.dart';

class Settings {
  static Database db;

  static final String dbKey = "key";
  static final String dbValue = "value";

  static final String tableName = "settings";
  static final String dbOnCreate = "CREATE TABLE IF NOT EXISTS $tableName ("
      "${Settings.dbKey} STRING PRIMARY KEY,"
      "${Settings.dbValue} Text"
      ")";

  String key;
  String value;

  Settings({this.key, this.value});

  Settings.fromMap(Map<String, dynamic> map) {
    this.key = map[dbKey];
    this.value = map[dbValue];
  }

  Map<String, dynamic> toMap() {
    return {
      dbValue: value,
      dbKey: key,
    };
  }

  static Future<Settings> fetch(String key) async {
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE $dbKey = "$key";');
    List<Settings> items = [];
    for (Map<String, dynamic> item in result) {
      items.add(new Settings.fromMap(item));
    }
    return items.length > 0 ? items[0] : null;
  }

  static Future save(Settings item) async {
    await db.rawInsert(
        'INSERT OR REPLACE INTO '
        '$tableName(${Settings.dbKey}, ${Settings.dbValue})'
        ' VALUES(?, ?)',
        [
          item.key,
          item.value,
        ]);
  }
}
