import 'package:meta/meta.dart';

class Category {
  static final dbName = "name";
  static final dbCreatedAt = "created_at";

  String name;
  DateTime createdAt;

  Category({
    @required this.name,    
  }) {
    this.createdAt = new DateTime.now();
  }

  Category.fromMap(Map<String, dynamic> map) {
    this.createdAt = map[dbCreatedAt];
    this.name = map[dbName];
  }

  // Currently not used
  Map<String, dynamic> toMap() {
    return {
      dbName: name,
      dbCreatedAt: createdAt,
    };
  }
}
