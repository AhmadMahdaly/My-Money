import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:opration/core/di.dart';
import 'package:opration/features/goals/domain/entities/financial_goal.dart';
import 'package:opration/features/goals/domain/entities/saving_entry.dart';
import 'package:opration/features/goals/domain/usecases/add_financial_goal.dart';
import 'package:opration/features/goals/domain/usecases/delete_financial_goal.dart';
import 'package:opration/features/goals/domain/usecases/get_financial_goals.dart';
import 'package:opration/features/goals/domain/usecases/update_financial_goal.dart';
import 'package:uuid/uuid.dart';

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
    // await CloudSyncService.touchLocalUpdate();
  }

  Future<void> updateGoal(FinancialGoal goal) async {
    await _performOperation(() => updateFinancialGoalUseCase(goal));
    // await CloudSyncService.touchLocalUpdate();
  }

  Future<void> deleteGoal(String goalId) async {
    await _performOperation(() => deleteFinancialGoalUseCase(goalId));
    // await CloudSyncService.touchLocalUpdate();
  }

  Future<void> addFundsToGoal(String goalId, double amountToAdd) async {
    if (state is! FinancialGoalLoaded) return;
    final currentState = state as FinancialGoalLoaded;
    final goalIndex = currentState.goals.indexWhere((g) => g.id == goalId);

    if (goalIndex != -1) {
      final goal = currentState.goals[goalIndex];
      if (goal.isSaving) {
        await recordSavingMovement(
          goalId: goalId,
          amount: amountToAdd,
          type: SavingMovementType.deposit,
        );
        return;
      }
      final updatedGoal = goal.copyWith(
        savedAmount: goal.savedAmount + amountToAdd,
      );
      await updateGoal(updatedGoal);
    }
  }

  Future<void> recordSavingMovement({
    required String goalId,
    required double amount,
    required SavingMovementType type,
    String? note,
  }) async {
    if (state is! FinancialGoalLoaded) return;
    if (amount <= 0) return;

    final currentState = state as FinancialGoalLoaded;
    final goalIndex = currentState.goals.indexWhere((g) => g.id == goalId);
    if (goalIndex == -1) return;

    final saving = currentState.goals[goalIndex];
    if (!saving.isSaving) return;

    final delta = type == SavingMovementType.deposit ? amount : -amount;
    final newBalance = saving.balance + delta;
    if (newBalance < 0) {
      emit(const FinancialGoalError('الرصيد لا يكفي لسحب هذا المبلغ'));
      final goals = currentState.goals;
      emit(FinancialGoalLoaded(goals));
      return;
    }

    final entry = SavingEntry(
      id: getIt<Uuid>().v4(),
      amount: amount,
      date: DateTime.now(),
      type: type,
      note: (note == null || note.trim().isEmpty) ? null : note.trim(),
    );

    final updatedSaving = saving.copyWith(
      savedAmount: newBalance,
      history: [...saving.history, entry],
    );
    await updateGoal(updatedSaving);
  }
}
