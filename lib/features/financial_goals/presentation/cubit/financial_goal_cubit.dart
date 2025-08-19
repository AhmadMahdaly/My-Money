import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:opration/features/financial_goals/domain/entities/financial_goal.dart';
import 'package:opration/features/financial_goals/domain/usecases/add_financial_goal.dart';
import 'package:opration/features/financial_goals/domain/usecases/delete_financial_goal.dart';
import 'package:opration/features/financial_goals/domain/usecases/get_financial_goals.dart';
import 'package:opration/features/financial_goals/domain/usecases/update_financial_goal.dart';

part 'financial_goal_state.dart';

class FinancialGoalCubit extends Cubit<FinancialGoalState> {
  FinancialGoalCubit({
    required this.getFinancialGoalsUseCase,
    required this.addFinancialGoalUseCase,
    required this.updateFinancialGoalUseCase,
    required this.deleteFinancialGoalUseCase,
  }) : super(FinancialGoalInitial());
  final GetFinancialGoalsUseCase getFinancialGoalsUseCase;
  final AddFinancialGoalUseCase addFinancialGoalUseCase;
  final UpdateFinancialGoalUseCase updateFinancialGoalUseCase;
  final DeleteFinancialGoalUseCase deleteFinancialGoalUseCase;

  Future<void> loadGoals() async {
    try {
      emit(FinancialGoalLoading());
      final goals = await getFinancialGoalsUseCase();
      emit(FinancialGoalLoaded(goals));
    } catch (e) {
      emit(FinancialGoalError(e.toString()));
    }
  }

  Future<void> _performOperation(Future<void> Function() operation) async {
    if (state is! FinancialGoalLoaded) return;
    try {
      await operation();
      await loadGoals();
    } catch (e) {
      emit(FinancialGoalError(e.toString()));
    }
  }

  Future<void> addGoal(FinancialGoal goal) async {
    await _performOperation(() => addFinancialGoalUseCase(goal));
  }

  Future<void> updateGoal(FinancialGoal goal) async {
    await _performOperation(() => updateFinancialGoalUseCase(goal));
  }

  Future<void> deleteGoal(String goalId) async {
    await _performOperation(() => deleteFinancialGoalUseCase(goalId));
  }

  Future<void> addFundsToGoal(String goalId, double amountToAdd) async {
    if (state is! FinancialGoalLoaded) return;
    final currentState = state as FinancialGoalLoaded;
    final goalIndex = currentState.goals.indexWhere((g) => g.id == goalId);

    if (goalIndex != -1) {
      final goal = currentState.goals[goalIndex];
      final updatedGoal = goal.copyWith(
        savedAmount: goal.savedAmount + amountToAdd,
      );
      await updateGoal(updatedGoal);
    }
  }
}
