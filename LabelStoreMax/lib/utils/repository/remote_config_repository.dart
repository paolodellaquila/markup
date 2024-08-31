typedef ModelFromJson<T> = T Function(Map<String, dynamic> json);

abstract class RemoteConfigRepository {
  Future<bool> initialize({Map<String, dynamic>? defaultParameters});

  String getString(String key);

  bool getBool(String key);

  int getInt(String key);

  double getDouble(String key);

  T getMap<T>(String key, {ModelFromJson<T>? fromJson});

  List<T> getList<T>(String key, {ModelFromJson<T>? fromJson});
}
