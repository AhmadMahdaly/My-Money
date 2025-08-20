part of 'financial_goal_cubit.dart';

abstract class FinancialGoalState extends Equatable {
  const FinancialGoalState();

  @override
  List<Object> get props => [];
}

class FinancialGoalInitial extends FinancialGoalState {}

class FinancialGoalLoading extends FinancialGoalState {}

class FinancialGoalLoaded extends FinancialGoalState {
  const FinancialGoalLoaded(this.goals);
  final List<FinancialGoal> goals;

  @override
  List<Object> get props => [goals];
}

class FinancialGoalError extends FinancialGoalState {
  const FinancialGoalError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
