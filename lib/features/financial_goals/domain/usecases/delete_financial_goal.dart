import 'package:opration/features/financial_goals/domain/repositories/financial_goal_repository.dart';

class DeleteFinancialGoalUseCase {
  DeleteFinancialGoalUseCase({required this.repository});
  final FinancialGoalRepository repository;
  Future<void> call(String goalId) => repository.deleteGoal(goalId);
}
