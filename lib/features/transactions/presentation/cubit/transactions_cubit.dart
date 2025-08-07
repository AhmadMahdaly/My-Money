import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/domain/usecases/add_category.dart';
import 'package:opration/features/transactions/domain/usecases/add_transaction.dart';
import 'package:opration/features/transactions/domain/usecases/delete_category.dart';
import 'package:opration/features/transactions/domain/usecases/delete_transaction.dart';
import 'package:opration/features/transactions/domain/usecases/get_categories.dart';
import 'package:opration/features/transactions/domain/usecases/get_filter_settings.dart';
import 'package:opration/features/transactions/domain/usecases/get_transactions.dart';
import 'package:opration/features/transactions/domain/usecases/save_filter_settings.dart';
import 'package:opration/features/transactions/domain/usecases/update_category.dart';
import 'package:opration/features/transactions/domain/usecases/update_transaction.dart';

part 'transactions_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit({
    required this.getTransactionsUseCase,
    required this.addTransactionUseCase,
    required this.updateTransactionUseCase,
    required this.deleteTransactionUseCase,
    required this.getCategoriesUseCase,
    required this.addCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.getFilterSettingsUseCase,
    required this.saveFilterSettingsUseCase,
  }) : super(const TransactionState());
  final GetTransactionsUseCase getTransactionsUseCase;
  final AddTransactionUseCase addTransactionUseCase;
  final UpdateTransactionUseCase updateTransactionUseCase;
  final DeleteTransactionUseCase deleteTransactionUseCase;
  final GetCategoriesUseCase getCategoriesUseCase;
  final AddCategoryUseCase addCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final GetFilterSettingsUseCase getFilterSettingsUseCase;
  final SaveFilterSettingsUseCase saveFilterSettingsUseCase;

  Future<void> _reloadData() async {
    final transactions = await getTransactionsUseCase();
    final categories = await getCategoriesUseCase();
    emit(
      state.copyWith(
        isLoading: false,
        allTransactions: transactions,
        allCategories: categories,
      ),
    );
  }

  Future<void> loadInitialData() async {
    emit(state.copyWith(isLoading: true));
    try {
      final filterSettings = await getFilterSettingsUseCase();
      final lastFilter = filterSettings['activeFilter'] as PredefinedFilter;
      DateTime? startDate = filterSettings['startDate'] as DateTime;
      DateTime? endDate = filterSettings['endDate'] as DateTime;

      if (startDate == null ||
          endDate == null ||
          lastFilter != PredefinedFilter.custom) {
        final range = _getDateRangeForFilter(lastFilter);
        startDate = range.start;
        endDate = range.end;
      }

      emit(
        state.copyWith(
          filterStartDate: startDate,
          filterEndDate: endDate,
          activeFilter: lastFilter,
        ),
      );
      await _reloadData();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    await addTransactionUseCase(transaction);
    await _reloadData();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await updateTransactionUseCase(transaction);
    await _reloadData();
  }

  Future<void> deleteTransaction(String transactionId) async {
    await deleteTransactionUseCase(transactionId);
    await _reloadData();
  }

  Future<void> addCategory(TransactionCategory category) async {
    await addCategoryUseCase(category);
    await _reloadData();
  }

  Future<void> updateCategory(TransactionCategory category) async {
    await updateCategoryUseCase(category);
    await _reloadData();
  }

  Future<void> deleteCategory(String categoryId) async {
    await deleteCategoryUseCase(categoryId);
    await _reloadData();
  }

  Future<void> setPredefinedFilter(PredefinedFilter filter) async {
    final range = _getDateRangeForFilter(filter);
    await saveFilterSettingsUseCase(
      startDate: range.start,
      endDate: range.end,
      activeFilter: filter,
    );
    emit(
      state.copyWith(
        filterStartDate: range.start,
        filterEndDate: range.end,
        activeFilter: filter,
      ),
    );
  }

  Future<void> setCustomDateFilter(DateTime startDate, DateTime endDate) async {
    await saveFilterSettingsUseCase(
      startDate: startDate,
      endDate: endDate,
      activeFilter: PredefinedFilter.custom,
    );
    emit(
      state.copyWith(
        filterStartDate: startDate,
        filterEndDate: endDate,
        activeFilter: PredefinedFilter.custom,
      ),
    );
  }

  DateTimeRange _getDateRangeForFilter(PredefinedFilter filter) {
    final now = DateTime.now();
    switch (filter) {
      case PredefinedFilter.today:
        final startOfDay = DateTime(now.year, now.month, now.day);
        return DateTimeRange(start: startOfDay, end: startOfDay);
      case PredefinedFilter.week:
        final daysToSubtract = (now.weekday == DateTime.saturday)
            ? 0
            : (now.weekday + 1) % 7;
        final startOfWeek = DateTime(
          now.year,
          now.month,
          now.day - daysToSubtract,
        );
        final endOfWeek = startOfWeek.add(const Duration(days: 5));
        return DateTimeRange(start: startOfWeek, end: endOfWeek);
      case PredefinedFilter.month:
        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth = DateTime(now.year, now.month + 1, 0);
        return DateTimeRange(start: startOfMonth, end: endOfMonth);
      case PredefinedFilter.year:
        final startOfYear = DateTime(now.year, 1, 1);
        final endOfYear = DateTime(now.year, 12, 31);
        return DateTimeRange(start: startOfYear, end: endOfYear);
      case PredefinedFilter.custom:
        return DateTimeRange(
          start: state.filterStartDate ?? now,
          end: state.filterEndDate ?? now,
        );
    }
  }
}
