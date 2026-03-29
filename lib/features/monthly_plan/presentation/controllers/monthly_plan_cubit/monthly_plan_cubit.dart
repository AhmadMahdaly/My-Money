import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:opration/features/monthly_plan/domain/entities/monthly_plan.dart';
import 'package:opration/features/monthly_plan/domain/usecases/get_monthly_plan.dart';
import 'package:opration/features/monthly_plan/domain/usecases/save_monthly_plan.dart';

part 'monthly_plan_state.dart';

class MonthlyPlanCubit extends Cubit<MonthlyPlanState> {
  MonthlyPlanCubit({
    required this.getMonthlyPlanUseCase,
    required this.saveMonthlyPlanUseCase,
  }) : super(MonthlyPlanState.initial());
  final GetMonthlyPlanUseCase getMonthlyPlanUseCase;
  final SaveMonthlyPlanUseCase saveMonthlyPlanUseCase;

  String _getYearMonth(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
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

  Future<void> loadPlanForMonth(DateTime month) async {
    if (state.plan != null) {
      await saveCurrentPlan();
    }

    if (isClosed) return;

    emit(state.copyWith(status: MonthlyPlanStatus.loading));
    try {
      final yearMonth = _getYearMonth(month);
      final plan = await getMonthlyPlanUseCase(yearMonth);
      if (!isClosed) {
        emit(
          state.copyWith(
            status: MonthlyPlanStatus.loaded,
            plan: plan,
            currentMonth: month,
          ),
        );
      }
    } catch (e) {
      if (!isClosed) {
        emit(
          state.copyWith(status: MonthlyPlanStatus.error, error: e.toString()),
        );
      }
    }
  }

  Future<void> updatePlan(MonthlyPlan plan) async {
    if (isClosed) return;

    emit(state.copyWith(plan: plan));

    try {
      await saveMonthlyPlanUseCase(plan);
    } catch (e) {
      if (!isClosed) {
        emit(state.copyWith(error: 'فشل الحفظ التلقائي: $e'));
      }
    }
  }
}
