import 'package:opration/features/financial_goals/domain/entities/financial_goal.dart';

class FinancialGoalModel extends FinancialGoal {
  const FinancialGoalModel({
    required super.id,
    required super.name,
    required super.targetAmount,
    required super.savedAmount,
    required super.targetDate,
  });

  factory FinancialGoalModel.fromEntity(FinancialGoal goal) {
    return FinancialGoalModel(
      id: goal.id,
      name: goal.name,
      targetAmount: goal.targetAmount,
      savedAmount: goal.savedAmount,
      targetDate: goal.targetDate,
    );
  }

  factory FinancialGoalModel.fromJson(Map<String, dynamic> json) {
    return FinancialGoalModel(
      id: json['id'].toString(),
      name: json['name'].toString(),
      targetAmount: (json['targetAmount'] as num).toDouble(),
      savedAmount: (json['savedAmount'] as num).toDouble(),
      targetDate: DateTime.parse(json['targetDate'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'savedAmount': savedAmount,
      'targetDate': targetDate.toIso8601String(),
    };
  }
}
