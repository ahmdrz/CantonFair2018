import 'dart:async';

import 'package:uuid/uuid.dart';
import 'package:sqflite/sqflite.dart';

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
  int phase, rating;

  Series({
    this.categoryUUID,
    this.title,
    this.description,
    this.phase,
    this.rating,
  }) {
    this.createdAt = new DateTime.now();
    this.uuid = new Uuid().v4();
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

  Future<List<Series>> getSeries() async {
    var result = await db.rawQuery('SELECT * FROM $tableName');
    List<Series> series = [];
    for (Map<String, dynamic> item in result) {
      series.add(new Series.fromMap(item));
    }
    return series;
  }

  Future updateCategory(Series category) async {
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
