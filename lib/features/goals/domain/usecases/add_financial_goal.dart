import 'package:opration/features/goals/domain/entities/financial_goal.dart';
import 'package:opration/features/goals/domain/repositories/financial_goal_repository.dart';

class AddFinancialGoalUseCase {
  AddFinancialGoalUseCase({required this.repository});
  final FinancialGoalRepository repository;
  Future<void> call(FinancialGoal goal) => repository.addGoal(goal);
}
