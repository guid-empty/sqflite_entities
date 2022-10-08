abstract class SqlAdapter<T> {
  String get createEntityTableScript;

  Type get modelType => T;

  String get tableName;

  T deserialize(Map<String, dynamic> raw);

  Map<String, dynamic> serialize(T entity);
}
