import 'package:fintrack/core/constants/hive_type_ids.dart';
import 'package:fintrack/features/budgets/data/models/budget_model.dart';
import 'package:hive/hive.dart';

/// Hand-written Hive adapter for [BudgetModel] (index-based, default-safe).
class BudgetModelAdapter extends TypeAdapter<BudgetModel> {
  @override
  final int typeId = HiveTypeIds.budget;

  @override
  BudgetModel read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < count; i++) reader.readByte(): reader.read(),
    };
    return BudgetModel(
      id: fields[0] as String? ?? '',
      categoryId: fields[1] as String? ?? 'other_expense',
      limitMinor: fields[2] as int? ?? 0,
      monthKey: fields[3] as String? ?? '1970-01',
      updatedAtMs: fields[4] as int? ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, BudgetModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.limitMinor)
      ..writeByte(3)
      ..write(obj.monthKey)
      ..writeByte(4)
      ..write(obj.updatedAtMs);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BudgetModelAdapter && typeId == other.typeId;
}
