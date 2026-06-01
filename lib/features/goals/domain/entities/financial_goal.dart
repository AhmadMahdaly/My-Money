import 'package:equatable/equatable.dart';

enum GoalType { goal, saving }

class FinancialGoal extends Equatable {
  const FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
    required this.type,
  });

  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime targetDate;
  final GoalType type;

  double get progress => (savedAmount / targetAmount).clamp(0.0, 1.0);

  FinancialGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? targetDate,
    GoalType? type,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    targetAmount,
    savedAmount,
    targetDate,
    type,
  ];
}
