import 'package:opration/features/goals/domain/entities/saving_entry.dart';

class SavingEntryModel extends SavingEntry {
  const SavingEntryModel({
    required super.id,
    required super.amount,
    required super.date,
    required super.type,
    super.note,
  });

  factory SavingEntryModel.fromEntity(SavingEntry entry) {
    return SavingEntryModel(
      id: entry.id,
      amount: entry.amount,
      date: entry.date,
      type: entry.type,
      note: entry.note,
    );
  }

  factory SavingEntryModel.fromJson(Map<String, dynamic> json) {
    final typeName = json['type']?.toString() ?? 'deposit';
    return SavingEntryModel(
      id: json['id'].toString(),
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'].toString()),
      type: SavingMovementType.values.firstWhere(
        (e) => e.name == typeName,
        orElse: () => SavingMovementType.deposit,
      ),
      note: json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'date': date.toIso8601String(),
      'type': type.name,
      if (note != null && note!.isNotEmpty) 'note': note,
    };
  }
}
