import 'dart:async';

import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';

import './ImageModel.dart';
import './Category.dart';

class Series {
  static Database db;

  static final String dbPhase = "phase";
  static final String dbCreatedAt = "created_at";
  static final String dbCategoryUUID = "category_uuid";
  static final String dbTitle = "title";
  static final String dbDescription = "description";
  static final String dbUUID = "uuid";
  static final String dbRating = "rating";

  static final String tableName = "series";

  static final String dbOnCreate = "CREATE TABLE IF NOT EXISTS $tableName ("
      "${Series.dbUUID} STRING PRIMARY KEY,"
      "${Series.dbPhase} INTEGER,"
      "${Series.dbCategoryUUID} TEXT,"
      "${Series.dbCreatedAt} TEXT,"
      "${Series.dbTitle} TEXT,"
      "${Series.dbDescription} TEXT,"
      "${Series.dbRating} INTEGER"
      ")";

  String title, description, categoryUUID, uuid;
  DateTime createdAt;
  int phase, rating, count;

  Series({
    this.categoryUUID,
    this.title,
    this.description,
    this.phase,
    this.rating,
  }) {
    this.createdAt = new DateTime.now();
    this.uuid = new Uuid().v4();
    this.count = 0;
  }

  Series.fromMap(Map<String, dynamic> map) {
    this.createdAt = DateTime.parse(map[dbCreatedAt]);
    this.phase = map[dbPhase];
    this.title = map[dbTitle];
    this.description = map[dbDescription];
    this.categoryUUID = map[dbCategoryUUID];
    this.uuid = map[dbUUID];
    this.rating = map[dbRating];
  }

  // Currently not used
  Map<String, dynamic> toMap() {
    return {
      dbPhase: phase,
      dbCreatedAt: createdAt.toIso8601String(),
      dbCategoryUUID: categoryUUID,
      dbDescription: description,
      dbTitle: title,
      dbUUID: uuid,
      dbRating: rating,
    };
  }

  fetchCount() async {
    var result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM ${ImageModel.tableName} WHERE ${ImageModel.dbSeriesUUID} = "$uuid";');
    count = result[0]['count'];
  }

  static Future<Category> getCategoryOfSeriesUUID(uuid,
      {inv: 'desc', order: 'created_at'}) async {
    var series = await getSelectedSeriesByUUID(uuid);
    var result = await db.rawQuery(
        'SELECT * FROM ${Category.tableName} WHERE ${Category.dbUUID} = "${series.categoryUUID}" ORDER BY "$order $inv";');
    List<Category> categories = [];
    for (Map<String, dynamic> item in result) {
      categories.add(new Category.fromMap(item));
    }
    if (categories.length > 0) return categories[0];
    return null;
  }

  static Future<Series> getSelectedSeriesByUUID(uuid,
      {inv: 'desc', order: 'created_at'}) async {
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE $dbUUID = "$uuid" ORDER BY "$order $inv";');
    List<Series> series = [];
    for (Map<String, dynamic> item in result) {
      Series s = new Series.fromMap(item);
      await s.fetchCount();
      series.add(s);
    }
    if (series.length > 0) return series[0];
    return null;
  }

  static Future<List<Series>> getSeriesByCategory(String category,
      {inv: 'desc', order: 'created_at'}) async {
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE $dbCategoryUUID = "$category" ORDER BY "$order $inv";');
    List<Series> series = [];
    for (Map<String, dynamic> item in result) {
      Series s = new Series.fromMap(item);
      await s.fetchCount();
      series.add(s);
    }
    return series;
  }

  static Future<List<Series>> getSeriesByPhase(phase,
      {inv: 'desc', order: 'created_at'}) async {
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE $dbPhase = "$phase" ORDER BY "$order $inv";');
    List<Series> series = [];
    for (Map<String, dynamic> item in result) {
      Series s = new Series.fromMap(item);
      await s.fetchCount();
      series.add(s);
    }
    return series;
  }

  static Future<List<Series>> getSeries(
      {bool pagination = false,
      int limit = 10,
      int page = 0,
      inv: 'DESC',
      order: 'created_at'}) async {
    var result = await db.rawQuery(
        'SELECT * FROM $tableName ORDER BY $order $inv' +
            (pagination ? 'LIMIT $limit OFFSET ${page * limit};' : ';'));
    List<Series> series = [];
    for (Map<String, dynamic> item in result) {
      Series s = new Series.fromMap(item);
      await s.fetchCount();
      series.add(s);
    }
    return series;
  }

  static Future updateCategory(Series category) async {
    await db.rawInsert(
        'INSERT OR REPLACE INTO '
        '$tableName(${Series.dbUUID}, ${Series.dbCategoryUUID}, ${Series.dbCreatedAt},'
        '${Series.dbDescription}, ${Series.dbTitle}, ${Series.dbPhase},'
        '${Series.dbRating})'
        ' VALUES(?, ?, ?, ?, ?, ?, ?)',
        [
          category.uuid,
          category.categoryUUID,
          category.createdAt.toIso8601String(),
          category.description,
          category.title,
          category.phase,
          category.rating,
        ]);
  }
}
