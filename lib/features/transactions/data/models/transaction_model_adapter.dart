import 'package:fintrack/core/constants/hive_type_ids.dart';
import 'package:fintrack/features/transactions/data/models/transaction_model.dart';
import 'package:hive/hive.dart';

/// Hand-written Hive adapter (no code generation required).
///
/// Fields are written as `index -> value` pairs and read back by index with
/// safe defaults, so new fields can be appended later without losing data.
class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = HiveTypeIds.transaction;

  @override
  TransactionModel read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < count; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      id: fields[0] as String? ?? '',
      title: fields[1] as String? ?? '',
      amountMinor: fields[2] as int? ?? 0,
      categoryId: fields[3] as String? ?? 'other_expense',
      type: fields[4] as String? ?? 'expense',
      dateMs: fields[5] as int? ?? 0,
      notes: fields[6] as String?,
      createdAtMs: fields[7] as int? ?? 0,
      updatedAtMs: fields[8] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.amountMinor)
      ..writeByte(3)
      ..write(obj.categoryId)
      ..writeByte(4)
      ..write(obj.type)
      ..writeByte(5)
      ..write(obj.dateMs)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.createdAtMs)
      ..writeByte(8)
      ..write(obj.updatedAtMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter && typeId == other.typeId;
}
