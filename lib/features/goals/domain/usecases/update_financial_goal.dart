import 'package:opration/features/goals/domain/entities/financial_goal.dart';
import 'package:opration/features/goals/domain/repositories/financial_goal_repository.dart';

class UpdateFinancialGoalUseCase {
  UpdateFinancialGoalUseCase({required this.repository});
  final FinancialGoalRepository repository;
  Future<void> call(FinancialGoal goal) => repository.updateGoal(goal);
}
