import 'package:meta/meta.dart';

class Category {
  static final dbName = "name";
  static final dbCreatedAt = "created_at";

  String name;
  DateTime createdAt;
  String _createdAt;

  Category({
    @required this.name,    
  }) {
    this.createdAt = new DateTime.now();
    this._createdAt = this.createdAt.toIso8601String();
  }

  Category.fromMap(Map<String, dynamic> map) {
    this._createdAt = map[dbCreatedAt];
    this.createdAt = DateTime.parse(this._createdAt);
    this.name = map[dbName];
  }

  // Currently not used
  Map<String, dynamic> toMap() {
    return {
      dbName: name,
      dbCreatedAt: _createdAt,
    };
  }
}
