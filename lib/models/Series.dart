import 'package:meta/meta.dart';
import 'package:sqflite/sqflite.dart';

class Series {
  static Database db;
  
  static final String dbPhase = "phase";
  static final String dbCreatedAt = "created_at";
  static final String dbCategoryID = "category_id";
  static final String dbTitle = "title";
  static final String dbDescription = "description";

  static final String tableName = "series";

  static final String dbOnCreate = "CREATE TABLE IF NOT EXISTS $tableName ("
      "id INTEGER PRIMARY KEY AUTOINCREMENT,"
      "${Series.dbPhase} INTEGER,"
      "${Series.dbCategoryID} INTEGER,"
      "${Series.dbCreatedAt} TEXT,"
      "${Series.dbTitle} TEXT,"
      "${Series.dbDescription} TEXT"
      ")";

  String name;
  DateTime createdAt;
  String _createdAt;

  Series({
    @required this.name,
  }) {
    this.createdAt = new DateTime.now();
    this._createdAt = this.createdAt.toIso8601String();
  }

  Series.fromMap(Map<String, dynamic> map) {
    this._createdAt = map[dbCreatedAt];
    this.createdAt = DateTime.parse(this._createdAt);
    this.name = map[dbPhase];
  }

  // Currently not used
  Map<String, dynamic> toMap() {
    return {
      dbPhase: name,
      dbCreatedAt: _createdAt,
    };
  }
}
