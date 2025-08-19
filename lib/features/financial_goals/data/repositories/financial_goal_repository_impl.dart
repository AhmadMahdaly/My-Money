import 'package:opration/features/financial_goals/data/datasources/financial_goal_local_data_source.dart';
import 'package:opration/features/financial_goals/data/models/financial_goal_model.dart';
import 'package:opration/features/financial_goals/domain/entities/financial_goal.dart';
import 'package:opration/features/financial_goals/domain/repositories/financial_goal_repository.dart';

class FinancialGoalRepositoryImpl implements FinancialGoalRepository {
  FinancialGoalRepositoryImpl({required this.localDataSource});
  final FinancialGoalLocalDataSource localDataSource;

  @override
  Future<void> addGoal(FinancialGoal goal) async {
    final goals = await localDataSource.getGoals();
    goals.add(FinancialGoalModel.fromEntity(goal));
    await localDataSource.saveGoals(goals);
  }

  @override
  Future<void> deleteGoal(String goalId) async {
    final goals = await localDataSource.getGoals();
    goals.removeWhere((g) => g.id == goalId);
    await localDataSource.saveGoals(goals);
  }

  @override
  Future<List<FinancialGoal>> getGoals() async {
    return localDataSource.getGoals();
  }

  @override
  Future<void> updateGoal(FinancialGoal goal) async {
    final goals = await localDataSource.getGoals();
    final index = goals.indexWhere((g) => g.id == goal.id);
    if (index != -1) {
      goals[index] = FinancialGoalModel.fromEntity(goal);
      await localDataSource.saveGoals(goals);
    }
  }
}
