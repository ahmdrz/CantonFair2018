import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

class ImageModel {
  static Database db;

  static final String dbFilePath = "file_path";
  static final String dbCreatedAt = "created_at";
  static final String dbUUID = "uuid";
  static final String dbSeriesUUID = "series_uuid";

  static final String tableName = "images";
  static final String dbOnCreate = "CREATE TABLE IF NOT EXISTS $tableName ("
      "${ImageModel.dbUUID} STRING PRIMARY KEY,"
      "${ImageModel.dbFilePath} Text,"
      "${ImageModel.dbCreatedAt} TEXT,"
      "${ImageModel.dbSeriesUUID} TEXT"
      ")";

  String uuid;
  String filePath;
  DateTime createdAt;
  String seriesUUID;

  ImageModel({this.filePath, this.seriesUUID}) {
    this.createdAt = new DateTime.now();
    this.uuid = new Uuid().v4();    
  }

  ImageModel.fromMap(Map<String, dynamic> map) {
    this.createdAt = DateTime.parse(map[dbCreatedAt]);
    this.seriesUUID = map[dbSeriesUUID];
    this.filePath = map[dbFilePath];
    this.uuid = map[dbUUID];
  }

  static Future<List<ImageModel>> getLatestImages(int limit) async {
    var result = await db.rawQuery('SELECT * FROM $tableName ORDER BY ${ImageModel.dbCreatedAt} LIMIT $limit;');
    List<ImageModel> images = [];
    for (Map<String, dynamic> item in result) {
      images.add(new ImageModel.fromMap(item));
    }
    return images;
  }

  static Future updateImage(ImageModel image) async {
    await db.rawInsert(
        'INSERT OR REPLACE INTO '
        '$tableName(${ImageModel.dbUUID}, ${ImageModel.dbFilePath}, ${ImageModel.dbCreatedAt}, ${ImageModel.dbSeriesUUID})'
        ' VALUES(?, ?, ?, ?)',
        [
          image.uuid,
          image.filePath,
          image.createdAt.toIso8601String(),
          image.seriesUUID,
        ]);
  }

  Map<String, dynamic> toMap() {
    return {
      dbSeriesUUID: seriesUUID,
      dbFilePath: filePath,
      dbUUID: uuid,
      dbCreatedAt: createdAt.toIso8601String(),
    };
  }
}
