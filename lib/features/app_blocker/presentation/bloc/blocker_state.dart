part of 'blocker_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object> get props => [];
}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  const HomeLoaded(this.apps, this.usageStats, this.rules);
  final List<AppInfo> apps; // Changed type
  final List<AppUsageInfo> usageStats;
  final List<AppRule> rules;

  @override
  List<Object> get props => [apps, usageStats, rules];
}

class HomeError extends HomeState {
  const HomeError(this.message);
  final String message;

  @override
  List<Object> get props => [message];
}
