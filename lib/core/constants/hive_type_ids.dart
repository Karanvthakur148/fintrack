/// Unique Hive type IDs. Never change or reuse an ID once released,
/// otherwise previously stored data cannot be read.
abstract final class HiveTypeIds {
  static const int transaction = 0;
  static const int budget = 1;
}
