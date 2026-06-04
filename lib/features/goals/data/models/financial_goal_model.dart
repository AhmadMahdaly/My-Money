import 'package:opration/features/goals/data/models/saving_entry_model.dart';
import 'package:opration/features/goals/domain/entities/financial_goal.dart';
import 'package:opration/features/goals/domain/entities/saving_entry.dart';
import 'package:uuid/uuid.dart';

class FinancialGoalModel extends FinancialGoal {
  const FinancialGoalModel({
    required super.id,
    required super.name,
    required super.targetAmount,
    required super.savedAmount,
    required super.targetDate,
    required super.type,
    super.history,
  });

  factory FinancialGoalModel.fromEntity(FinancialGoal goal) {
    return FinancialGoalModel(
      id: goal.id,
      name: goal.name,
      targetAmount: goal.targetAmount,
      savedAmount: goal.savedAmount,
      targetDate: goal.targetDate,
      type: goal.type,
      history: goal.history,
    );
  }

  factory FinancialGoalModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] != null
        ? GoalType.values.firstWhere(
            (e) => e.name == json['type'].toString(),
            orElse: () => GoalType.goal,
          )
        : GoalType.goal;
    final savedAmount = (json['savedAmount'] as num).toDouble();
    var history = <SavingEntry>[];
    if (json['history'] is List) {
      history = (json['history'] as List)
          .map((e) => SavingEntryModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    if (type == GoalType.saving && history.isEmpty && savedAmount > 0) {
      history = [
        SavingEntryModel(
          id: const Uuid().v4(),
          amount: savedAmount,
          date: DateTime.tryParse(json['targetDate'].toString()) ??
              DateTime.now(),
          type: SavingMovementType.deposit,
          note: 'رصيد سابق',
        ),
      ];
    }
    return FinancialGoalModel(
      id: json['id'].toString(),
      name: json['name'].toString(),
      targetAmount: (json['targetAmount'] as num).toDouble(),
      savedAmount: savedAmount,
      targetDate: DateTime.parse(json['targetDate'].toString()),
      type: type,
      history: history,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'targetDate': targetDate.toIso8601String(),
      'type': type.name,
      if (history.isNotEmpty)
        'history': history
            .map((e) => SavingEntryModel.fromEntity(e).toJson())
            .toList(),
    };
  }
}
