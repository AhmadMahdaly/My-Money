import 'package:opration/features/financial_goals/domain/entities/financial_goal.dart';
import 'package:opration/features/financial_goals/domain/repositories/financial_goal_repository.dart';

class UpdateFinancialGoalUseCase {
  UpdateFinancialGoalUseCase({required this.repository});
  final FinancialGoalRepository repository;
  Future<void> call(FinancialGoal goal) => repository.updateGoal(goal);
}
