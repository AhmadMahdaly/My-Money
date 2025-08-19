part of 'financial_goal_cubit.dart';

abstract class FinancialGoalState extends Equatable {
  const FinancialGoalState();

  @override
  List<Object> get props => [];
}

class FinancialGoalInitial extends FinancialGoalState {}

class FinancialGoalLoading extends FinancialGoalState {}

class FinancialGoalLoaded extends FinancialGoalState {
  final List<FinancialGoal> goals;
  const FinancialGoalLoaded(this.goals);

  @override
  List<Object> get props => [goals];
}

class FinancialGoalError extends FinancialGoalState {
  final String message;
  const FinancialGoalError(this.message);

  @override
  List<Object> get props => [message];
}
