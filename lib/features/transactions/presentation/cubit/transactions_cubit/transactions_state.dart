part of 'transactions_cubit.dart';

enum PredefinedFilter { today, week, month, year, custom }

@immutable
class TransactionState extends Equatable {
  const TransactionState({
    this.isLoading = false,
    this.error,
    this.allTransactions = const [],
    this.allCategories = const [],
    this.filterStartDate,
    this.filterEndDate,
    this.activeFilter = PredefinedFilter.month,
  });
  final bool isLoading;
  final String? error;
  final List<Transaction> allTransactions;
  final List<TransactionCategory> allCategories;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final PredefinedFilter activeFilter;

  List<Transaction> get filteredTransactions {
    if (filterStartDate == null || filterEndDate == null) {
      return [];
    }
    final inclusiveEndDate = DateTime(
      filterEndDate!.year,
      filterEndDate!.month,
      filterEndDate!.day,
      23,
      59,
      59,
    );
    return allTransactions.where((t) {
      return !t.date.isBefore(filterStartDate!) &&
          !t.date.isAfter(inclusiveEndDate);
    }).toList();
  }

  TransactionState copyWith({
    bool? isLoading,
    String? error,
    List<Transaction>? allTransactions,
    List<TransactionCategory>? allCategories,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    PredefinedFilter? activeFilter,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      allTransactions: allTransactions ?? this.allTransactions,
      allCategories: allCategories ?? this.allCategories,
      filterStartDate: filterStartDate ?? this.filterStartDate,
      filterEndDate: filterEndDate ?? this.filterEndDate,
      activeFilter: activeFilter ?? this.activeFilter,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    error,
    allTransactions,
    allCategories,
    filterStartDate,
    filterEndDate,
    activeFilter,
  ];
}
