import 'package:opration/features/financial_goals/domain/entities/financial_goal.dart';

abstract class FinancialGoalRepository {
  Future<List<FinancialGoal>> getGoals();
  Future<void> addGoal(FinancialGoal goal);
  Future<void> updateGoal(FinancialGoal goal);
  Future<void> deleteGoal(String goalId);
}
