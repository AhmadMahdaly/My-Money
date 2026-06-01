import 'package:equatable/equatable.dart';
import 'package:opration/features/goals/domain/entities/saving_entry.dart';

enum GoalType { goal, saving }

class FinancialGoal extends Equatable {
  const FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
    required this.type,
    this.history = const [],
  });

  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime targetDate;
  final GoalType type;
  final List<SavingEntry> history;

  bool get isSaving => type == GoalType.saving;

  /// الرصيد الحالي للمدخرات (نفس savedAmount).
  double get balance => savedAmount;

  double get progress {
    if (isSaving || targetAmount <= 0) return 0;
    return (savedAmount / targetAmount).clamp(0.0, 1.0);
  }

  bool get isGoalCompleted => !isSaving && progress >= 1.0;

  List<SavingEntry> get sortedHistory {
    final entries = List<SavingEntry>.from(history);
    entries.sort((a, b) => b.date.compareTo(a.date));
    return entries;
  }

  FinancialGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? targetDate,
    GoalType? type,
    List<SavingEntry>? history,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
      type: type ?? this.type,
      history: history ?? this.history,
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
    history,
  ];
}
