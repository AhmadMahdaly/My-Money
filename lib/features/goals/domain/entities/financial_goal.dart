import 'package:equatable/equatable.dart';

class FinancialGoal extends Equatable {
  const FinancialGoal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.savedAmount,
    required this.targetDate,
  });
  final String id;
  final String name;
  final double targetAmount;
  final double savedAmount;
  final DateTime targetDate;

  double get progress => (savedAmount / targetAmount).clamp(0.0, 1.0);

  FinancialGoal copyWith({
    String? id,
    String? name,
    double? targetAmount,
    double? savedAmount,
    DateTime? targetDate,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      savedAmount: savedAmount ?? this.savedAmount,
      targetDate: targetDate ?? this.targetDate,
    );
  }

  @override
  List<Object?> get props => [id, name, targetAmount, savedAmount, targetDate];
}
