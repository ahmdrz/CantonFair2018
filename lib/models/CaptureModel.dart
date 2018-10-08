import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

enum CaptureMode {
  audio,
  video,
  picture
}

class CaptureModel {
  static Database db;

  static final String dbFilePath = "file_path";
  static final String dbCaptureMode = "capture_mode";
  static final String dbCreatedAt = "created_at";
  static final String dbUUID = "uuid";
  static final String dbSeriesUUID = "series_uuid";

  static final String tableName = "images";
  static final String dbOnCreate = "CREATE TABLE IF NOT EXISTS $tableName ("
      "${CaptureModel.dbUUID} STRING PRIMARY KEY,"
      "${CaptureModel.dbFilePath} Text,"
      "${CaptureModel.dbCreatedAt} TEXT,"
      "${CaptureModel.dbSeriesUUID} TEXT,"
      "${CaptureModel.dbCaptureMode} INTEGER"
      ")";

  String uuid;
  String filePath;
  DateTime createdAt;
  String seriesUUID;
  CaptureMode captureMode;

  CaptureModel({this.filePath, this.seriesUUID, this.captureMode}) {
    this.createdAt = new DateTime.now();
    this.uuid = new Uuid().v4();
  }

  CaptureModel.fromMap(Map<String, dynamic> map) {    
    this.createdAt = DateTime.parse(map[dbCreatedAt]);
    this.seriesUUID = map[dbSeriesUUID];
    this.filePath = map[dbFilePath];
    this.uuid = map[dbUUID];
    this.captureMode = CaptureMode.values.elementAt(map[dbCaptureMode] as int);
  }

  static Future<List<CaptureModel>> getItemsOfSeries(seriesUUID) async {
    var result = await db.rawQuery(
        'SELECT * FROM $tableName WHERE $dbSeriesUUID = "$seriesUUID" ORDER BY ${CaptureModel.dbCreatedAt};');
    List<CaptureModel> items = [];
    for (Map<String, dynamic> item in result) {
      items.add(new CaptureModel.fromMap(item));
    }
    return items;
  }

  static Future<List<CaptureModel>> getLatestItems(int limit,
      {int page = 0}) async {
    var result = await db.rawQuery(
        'SELECT * FROM $tableName ORDER BY ${CaptureModel.dbCreatedAt} LIMIT $limit OFFSET ${page * limit};');
    List<CaptureModel> items = [];
    for (Map<String, dynamic> item in result) {
      items.add(new CaptureModel.fromMap(item));
    }
    return items;
  }

  static Future updateItem(CaptureModel item) async {
    await db.rawInsert(
        'INSERT OR REPLACE INTO '
        '$tableName(${CaptureModel.dbUUID}, ${CaptureModel.dbFilePath}, ${CaptureModel.dbCreatedAt}, ${CaptureModel.dbSeriesUUID}, ${CaptureModel.dbCaptureMode})'
        ' VALUES(?, ?, ?, ?, ?)',
        [
          item.uuid,
          item.filePath,
          item.createdAt.toIso8601String(),
          item.seriesUUID,
          item.captureMode.index
        ]);
  }

  Map<String, dynamic> toMap() {
    return {
      dbSeriesUUID: seriesUUID,
      dbFilePath: filePath,
      dbUUID: uuid,
      dbCreatedAt: createdAt.toIso8601String(),
      dbCaptureMode: captureMode.index
    };
  }
}
