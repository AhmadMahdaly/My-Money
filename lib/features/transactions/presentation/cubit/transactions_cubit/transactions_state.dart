part of 'transactions_cubit.dart';

enum PredefinedFilter { today, week, month, year, since, custom, singleDay }

@immutable
class TransactionState extends Equatable {
  const TransactionState({
    this.pendingTransactions = const [],
    this.isLoading = false,
    this.error,
    this.allTransactions = const [],
    this.allCategories = const [],
    this.filterStartDate,
    this.filterEndDate,
    this.activeFilter = PredefinedFilter.month,
    this.selectedWalletId,
  });
  final bool isLoading;
  final String? error;
  final List<Transaction> allTransactions;
  final List<TransactionCategory> allCategories;
  final DateTime? filterStartDate;
  final DateTime? filterEndDate;
  final PredefinedFilter activeFilter;
  final String? selectedWalletId;
  final List<TransactionCategory> pendingTransactions;
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
    var dateFilteredTransactions = allTransactions.where((t) {
      return !t.date.isBefore(filterStartDate!) &&
          !t.date.isAfter(inclusiveEndDate);
    }).toList();

    if (selectedWalletId != null) {
      dateFilteredTransactions = dateFilteredTransactions
          .where((t) => t.walletId == selectedWalletId)
          .toList();
    }

    return dateFilteredTransactions;
  }

  TransactionState copyWith({
    bool? isLoading,
    String? error,
    List<Transaction>? allTransactions,
    List<TransactionCategory>? allCategories,
    DateTime? filterStartDate,
    DateTime? filterEndDate,
    PredefinedFilter? activeFilter,
    String? selectedWalletId,
    bool clearSelectedWalletId = false,
    List<TransactionCategory>? pendingTransactions,
  }) {
    return TransactionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      allTransactions: allTransactions ?? this.allTransactions,
      allCategories: allCategories ?? this.allCategories,
      filterStartDate: filterStartDate ?? this.filterStartDate,
      filterEndDate: filterEndDate ?? this.filterEndDate,
      activeFilter: activeFilter ?? this.activeFilter,
      selectedWalletId: clearSelectedWalletId
          ? null
          : selectedWalletId ?? this.selectedWalletId,
      pendingTransactions: pendingTransactions ?? this.pendingTransactions,
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
    selectedWalletId,
    pendingTransactions,
  ];
}
