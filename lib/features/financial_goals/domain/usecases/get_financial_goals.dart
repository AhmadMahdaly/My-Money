import 'package:opration/features/financial_goals/domain/entities/financial_goal.dart';
import 'package:opration/features/financial_goals/domain/repositories/financial_goal_repository.dart';

class GetFinancialGoalsUseCase {
  GetFinancialGoalsUseCase({required this.repository});
  final FinancialGoalRepository repository;
  Future<List<FinancialGoal>> call() => repository.getGoals();
}
