import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/domain/usecases/add_category.dart';
import 'package:opration/features/transactions/domain/usecases/add_transaction.dart';
import 'package:opration/features/transactions/domain/usecases/get_categories.dart';
import 'package:opration/features/transactions/domain/usecases/get_filter_settings.dart';
import 'package:opration/features/transactions/domain/usecases/get_transactions.dart';
import 'package:opration/features/transactions/domain/usecases/save_filter_settings.dart';

part 'transactions_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit({
    required this.getTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.getCategoriesUseCase,
    required this.addCategoryUseCase,
    required this.getFilterSettingsUseCase,
    required this.saveFilterSettingsUseCase,
  }) : super(const TransactionState());
  final GetTransactionsUseCase getTransactionsUseCase;
  final AddTransactionUseCase addTransactionUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;
  final GetFilterSettingsUseCase getFilterSettingsUseCase;
  final SaveFilterSettingsUseCase saveFilterSettingsUseCase;

  Future<void> loadInitialData() async {
    emit(state.copyWith(isLoading: true));
    try {
      final transactions = await getTransactionsUseCase();
      final categories = await getCategoriesUseCase();
      final filterSettings = await getFilterSettingsUseCase();

      emit(
        state.copyWith(
          isLoading: false,
          allTransactions: transactions,
          allCategories: categories,
          filterStartDate: filterSettings['startDate'],
          filterEndDate: filterSettings['endDate'],
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    emit(state.copyWith(isLoading: true));
    try {
      await addTransactionUseCase(transaction);
      await loadInitialData();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addCategory(TransactionCategory category) async {
    emit(state.copyWith(isLoading: true));
    try {
      await addCategoryUseCase(category);
      await loadInitialData();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> setDateFilter(DateTime startDate, DateTime endDate) async {
    emit(state.copyWith(isLoading: true));
    try {
      await saveFilterSettingsUseCase(startDate, endDate);
      emit(
        state.copyWith(
          isLoading: false,
          filterStartDate: startDate,
          filterEndDate: endDate,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
