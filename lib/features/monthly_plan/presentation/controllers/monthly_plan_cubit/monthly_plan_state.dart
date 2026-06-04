part of 'monthly_plan_cubit.dart';

enum MonthlyPlanStatus { initial, loading, saving, loaded, error }

@immutable
class MonthlyPlanState extends Equatable {
  const MonthlyPlanState({
    required this.status,
    required this.currentMonth,
    this.plan,
    this.error,
    this.allPlans = const [],
  });

  factory MonthlyPlanState.initial() {
    return MonthlyPlanState(
      status: MonthlyPlanStatus.initial,
      currentMonth: DateTime.now(),
    );
  }
  final MonthlyPlanStatus status;
  final MonthlyPlan? plan;
  final DateTime currentMonth;
  final String? error;
  final List<MonthlyPlan> allPlans;
  MonthlyPlanState copyWith({
    MonthlyPlanStatus? status,
    MonthlyPlan? plan,
    DateTime? currentMonth,
    String? error,
    bool clearError = false,
    List<MonthlyPlan>? allPlans,
  }) {
    return MonthlyPlanState(
      status: status ?? this.status,
      plan: plan ?? this.plan,
      currentMonth: currentMonth ?? this.currentMonth,
      error: clearError ? null : error ?? this.error,
      allPlans: allPlans ?? this.allPlans,
    );
  }

  @override
  List<Object?> get props => [
    status,
    plan,
    currentMonth,
    error,
    allPlans,
  ];
}
