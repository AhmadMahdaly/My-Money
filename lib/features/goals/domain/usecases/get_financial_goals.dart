import 'package:opration/features/goals/domain/entities/financial_goal.dart';
import 'package:opration/features/goals/domain/repositories/financial_goal_repository.dart';

class GetFinancialGoalsUseCase {
  GetFinancialGoalsUseCase({required this.repository});
  final FinancialGoalRepository repository;
  Future<List<FinancialGoal>> call() => repository.getGoals();
}
