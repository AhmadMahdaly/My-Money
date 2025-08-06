part of 'transactions_cubit.dart';

@immutable
class TransactionState {
  const TransactionState({
    this.isLoading = false,
    this.error,
    this.allTransactions = const [],
    this.allCategories = const [],
    this.filterStartDate,
    this.filterEndDate,
  });
  final bool isLoading;
  final String? error;
  final List<Transaction> allTransactions;
  final List<TransactionCategory> allCategories;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;

  List<Transaction> get filteredTransactions {
    if (filterStartDate == null || filterEndDate == null) {
      return allTransactions;
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
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      allTransactions: allTransactions ?? this.allTransactions,
      allCategories: allCategories ?? this.allCategories,
      filterStartDate: filterStartDate ?? this.filterStartDate,
      filterEndDate: filterEndDate ?? this.filterEndDate,
    );
  }
}
