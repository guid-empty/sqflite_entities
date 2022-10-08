import 'dart:convert';

abstract class SqliteCodec {
  static bool boolDecode(int value) => value > 0;

  static bool boolDecodeNullable(int? value) =>
      (value != null) ? value > 0 : false;

  static int boolEncode(bool value) => (value ? 1 : 0);

  static int? boolEncodeNullable(bool? value) =>
      (value != null) ? (value ? 1 : 0) : null;

  static DateTime dateTimeDecode(int microsecondsSinceEpoch) =>
      DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch);

  static DateTime? dateTimeDecodeNullable(int? microsecondsSinceEpoch) =>
      microsecondsSinceEpoch != null
          ? DateTime.fromMicrosecondsSinceEpoch(microsecondsSinceEpoch)
          : null;

  static int dateTimeEncode(DateTime value) => value.microsecondsSinceEpoch;

  static int? dateTimeEncodeNullable(DateTime? value) =>
      value?.microsecondsSinceEpoch;

  static List<int> integerCollectionDecode(String serialized) =>
      jsonDecode(serialized) as List<int>;

  static List<String> stringCollectionDecode(String serialized) =>
      List.from(jsonDecode(serialized) as List<dynamic>);
}
