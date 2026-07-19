import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opration/features/monthly_plan/domain/entities/monthly_plan.dart';
import 'package:opration/features/monthly_plan/domain/usecases/get_all_monthly_plans.dart';
import 'package:opration/features/monthly_plan/domain/usecases/get_monthly_plan.dart';
import 'package:opration/features/monthly_plan/domain/usecases/save_monthly_plan.dart';

part 'monthly_plan_state.dart';

class MonthlyPlanCubit extends Cubit<MonthlyPlanState> {
  MonthlyPlanCubit({
    required this.getMonthlyPlanUseCase,
    required this.saveMonthlyPlanUseCase,
    required this.getAllMonthlyPlansUseCase,
  }) : super(MonthlyPlanState.initial());
  final GetMonthlyPlanUseCase getMonthlyPlanUseCase;
  final SaveMonthlyPlanUseCase saveMonthlyPlanUseCase;
  final GetAllMonthlyPlansUseCase getAllMonthlyPlansUseCase;

  // String _getYearMonth(DateTime date) {
  //   return DateFormat('yyyy-MM').format(date);
  // }

  // void resetPlan() {
  //   final currentPlan = state.plan;
  //   if (currentPlan == null) return;

  //   final clearedPlan = currentPlan.copyWith(
  //     incomes: [],
  //     expenses: [],
  //   );

  //   updatePlan(clearedPlan);
  // }
  Future<void> loadAllPlans() async {
    emit(state.copyWith(status: MonthlyPlanStatus.loading));

    try {
      final allPlans = await getAllMonthlyPlansUseCase();

      emit(
        state.copyWith(
          status: MonthlyPlanStatus.loaded,
          allPlans: allPlans,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MonthlyPlanStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> saveCurrentPlan() async {
    if (isClosed ||
        state.plan == null ||
        state.status == MonthlyPlanStatus.saving) {
      return;
    }
    emit(state.copyWith(status: MonthlyPlanStatus.saving));
    try {
      await saveMonthlyPlanUseCase(state.plan!);
      // await CloudSyncService.touchLocalUpdate();
      if (!isClosed) {
        emit(state.copyWith(status: MonthlyPlanStatus.loaded));
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(status: MonthlyPlanStatus.error, error: e.toString()),
        );
      }
    }
  }

  Future<void> resetPlan() async {
    if (state.plan == null) return;

    final emptyPlan = MonthlyPlan(id: state.plan!.id);

    await saveMonthlyPlanUseCase(emptyPlan);

    emit(
      state.copyWith(
        plan: emptyPlan,
        status: MonthlyPlanStatus.loaded,
      ),
    );
  }

  String _formatYearMonth(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}';
  }

  Future<void> loadPlanForMonth(DateTime date) async {
    emit(state.copyWith(status: MonthlyPlanStatus.loading));

    try {
      final yearMonth = _formatYearMonth(date);

      final plan = await getMonthlyPlanUseCase(yearMonth);

      emit(
        state.copyWith(
          status: MonthlyPlanStatus.loaded,
          plan: plan,
          currentMonth: date,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MonthlyPlanStatus.error,
          error: e.toString(),
        ),
      );
    }
  }

  Future<void> updatePlan(MonthlyPlan updatedPlan) async {
    emit(state.copyWith(status: MonthlyPlanStatus.saving));

    try {
      await saveMonthlyPlanUseCase(updatedPlan);
      // await CloudSyncService.touchLocalUpdate();
      emit(
        state.copyWith(
          status: MonthlyPlanStatus.loaded,
          plan: updatedPlan,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: MonthlyPlanStatus.error,
          error: e.toString(),
        ),
      );
    }
  }
  // Future<void> loadPlanForMonth(DateTime month) async {
  //   if (state.plan != null) {
  //     await saveCurrentPlan();
  //   }

  //   if (isClosed) return;

  //   emit(state.copyWith(status: MonthlyPlanStatus.loading));
  //   try {
  //     final yearMonth = _getYearMonth(month);
  //     final plan = await getMonthlyPlanUseCase(yearMonth);
  //     if (!isClosed) {
  //       emit(
  //         state.copyWith(
  //           status: MonthlyPlanStatus.loaded,
  //           plan: plan,
  //           currentMonth: month,
  //         ),
  //       );
  //     }
  //   } catch (e) {
  //     if (!isClosed) {
  //       emit(
  //         state.copyWith(status: MonthlyPlanStatus.error, error: e.toString()),
  //       );
  //     }
  //   }
  // }

  // Future<void> updatePlan(MonthlyPlan plan) async {
  //   if (isClosed) return;

  //   emit(state.copyWith(plan: plan));

  //   try {
  //     await saveMonthlyPlanUseCase(plan);
  //   } catch (e) {
  //     if (!isClosed) {
  //       emit(state.copyWith(error: 'فشل الحفظ التلقائي: $e'));
  //     }
  //   }
  // }
}
