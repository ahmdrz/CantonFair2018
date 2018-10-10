class CacheItem {
  DateTime createdAt;
  String name;
  dynamic data;

  CacheItem({this.name, this.data}) {
    this.createdAt = DateTime.now();
  }
}

class Cache {
  Map<String, CacheItem> _cache;

  Cache() {
    _cache = new Map<String, CacheItem>();
  }

  bool exists(key) {
    print("exists $key");
    return _cache.containsKey(key);
  }

  dynamic getValue(key) {
    print("get $key");
    CacheItem item = this._cache[key];
    return item.data;
  }

  void setValue(key, value) {
    print("set $key");
    this._cache[key] = new CacheItem(data: value);
  }

  void clear() {
    print("clean");
    this._cache.clear();
  }
}
