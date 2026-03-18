import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'transactions_state.dart';

class TransactionCubit extends Cubit<TransactionState> {
  TransactionCubit({
    required this.uuid,
    required this.sharedPreferences,
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
    required this.walletCubit,
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
  final WalletCubit walletCubit;
  final SharedPreferences sharedPreferences;
  final Uuid uuid;
  Future<void> loadInitialData() async {
    emit(state.copyWith(isLoading: true));
    try {
      final filterSettings = await getFilterSettingsUseCase();
      final lastFilter = filterSettings['activeFilter'] as PredefinedFilter;
      var startDate = filterSettings['startDate'] as DateTime?;
      var endDate = filterSettings['endDate'] as DateTime?;

      if (lastFilter == PredefinedFilter.today ||
          lastFilter == PredefinedFilter.week ||
          lastFilter == PredefinedFilter.month ||
          lastFilter == PredefinedFilter.year) {
        final range = _getDateRangeForFilter(lastFilter, DateTime.now());
        startDate = range.start;
        endDate = range.end;
      }

      final transactions = await getTransactionsUseCase();
      final categories = await getCategoriesUseCase();

      emit(
        state.copyWith(
          isLoading: false,
          filterStartDate: startDate,
          filterEndDate: endDate,
          activeFilter: lastFilter,
          allTransactions: transactions,
          allCategories: categories,
        ),
      );
      await checkScheduledTransactions();
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> checkScheduledTransactions() async {
    final now = DateTime.now();
    final pending = <TransactionCategory>[];

    for (final category in state.allCategories.where((c) => c.isRecurring)) {
      var isDue = false;

      if (category.recurrenceType == RecurrenceType.monthly &&
          category.dayOfMonth != null) {
        if (now.day >= category.dayOfMonth!) {
          isDue = true;
        }
      } else if (category.recurrenceType == RecurrenceType.weekly &&
          category.daysOfWeek != null) {
        if (category.daysOfWeek!.contains(now.weekday)) {
          isDue = true;
        }
      }

      if (isDue) {
        final alreadyExecuted = _checkIfAlreadyExecuted(category, now);

        if (!alreadyExecuted) {
          if (category.autoDeduct) {
            await executeRecurringTransaction(category);
          } else {
            pending.add(category);
          }
        }
      }
    }

    if (pending.isNotEmpty || state.pendingTransactions.isNotEmpty) {
      emit(state.copyWith(pendingTransactions: pending));
    }
  }

  bool _checkIfAlreadyExecuted(TransactionCategory category, DateTime now) {
    final categoryTransactions = state.allTransactions.where(
      (t) => t.categoryId == category.id,
    );

    if (category.recurrenceType == RecurrenceType.monthly) {
      return categoryTransactions.any(
        (t) =>
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.note != null &&
            t.note!.contains('تلقائي'),
      );
    } else if (category.recurrenceType == RecurrenceType.weekly) {
      return categoryTransactions.any(
        (t) =>
            t.date.year == now.year &&
            t.date.month == now.month &&
            t.date.day == now.day &&
            t.note != null &&
            t.note!.contains('تلقائي'),
      );
    }
    return false;
  }

  Future<void> executeRecurringTransaction(TransactionCategory category) async {
    var finalWalletId = category.targetWalletId ?? '';

    if (finalWalletId.isEmpty) {
      final walletState = walletCubit.state;
      if (walletState is WalletLoaded && walletState.wallets.isNotEmpty) {
        final mainWallet = walletState.wallets.firstWhere(
          (w) => w.isMain,
          orElse: () => walletState.wallets.first,
        );
        finalWalletId = mainWallet.id;
      } else {
        return;
      }
    }

    final amount = category.fixedAmount ?? 0.0;
    if (amount <= 0) return;

    final newTx = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      categoryId: category.id,
      date: DateTime.now(),
      type: category.type,
      walletId: finalWalletId,
      note: 'عملية تسجيل تلقائي',
    );

    await addTransactionUseCase(newTx);

    final amountWithSign = category.type == TransactionType.income
        ? amount
        : -amount;
    await walletCubit.updateWalletBalance(finalWalletId, amountWithSign);

    final transactions = await getTransactionsUseCase();
    emit(state.copyWith(allTransactions: transactions));
  }

  Future<void> executeScheduledTransaction(TransactionCategory category) async {
    final transaction = Transaction(
      id: const Uuid().v4(),
      amount: category.fixedAmount ?? 0,
      categoryId: category.id,
      date: DateTime.now(),
      type: category.type,
      walletId: 'default_wallet',
      note: 'معاملة دورية تلقائية',
    );
    await addTransaction(transaction);
  }

  Future<void> processRecurringTransactions() async {
    final now = DateTime.now();
    final lastCheck = sharedPreferences.getString('last_recurring_check');

    if (lastCheck == DateFormat('yyyy-MM-dd').format(now)) return;

    for (final category in state.allCategories.where((c) => c.isRecurring)) {
      var shouldProcess = false;

      if (category.recurrenceType == RecurrenceType.monthly &&
          now.day == category.dayOfMonth) {
        shouldProcess = true;
      } else if (category.recurrenceType == RecurrenceType.weekly &&
          category.daysOfWeek!.contains(now.weekday)) {
        shouldProcess = true;
      }

      if (shouldProcess) {
        if (category.autoDeduct) {
          await executeRecurring(category);
        } else {
          emit(
            state.copyWith(
              pendingTransactions: [...state.pendingTransactions, category],
            ),
          );
        }
      }
    }
    await sharedPreferences.setString(
      'last_recurring_check',
      DateFormat('yyyy-MM-dd').format(now),
    );
  }

  Future<void> executeRecurring(TransactionCategory category) async {
    var finalWalletId = category.targetWalletId ?? '';

    if (finalWalletId.isEmpty) {
      final walletState = walletCubit.state;
      if (walletState is WalletLoaded) {
        finalWalletId = walletState.wallets.firstWhere((w) => w.isMain).id;
      }
    }

    final newTx = Transaction(
      id: const Uuid().v4(),
      amount: category.fixedAmount ?? 0,
      categoryId: category.id,
      date: DateTime.now(),
      type: category.type,
      walletId: finalWalletId,
      note: 'تلقائي: ${category.name}',
    );

    await addTransaction(newTx);

    final amountWithSign = category.type == TransactionType.income
        ? category.fixedAmount!
        : -category.fixedAmount!;

    await walletCubit.updateWalletBalance(finalWalletId, amountWithSign);
  }

  Future<void> setSingleDayFilter(DateTime date) async {
    emit(state.copyWith(isLoading: true));

    final start = DateTime(date.year, date.month, date.day, 0, 0, 0);
    final end = DateTime(date.year, date.month, date.day, 23, 59, 59);

    await saveFilterSettingsUseCase(
      startDate: start,
      endDate: end,
      activeFilter: PredefinedFilter.singleDay,
    );

    emit(
      state.copyWith(
        isLoading: false,
        filterStartDate: start,
        filterEndDate: end,
        activeFilter: PredefinedFilter.singleDay,
      ),
    );
  }

  DateTimeRange _getDateRangeForFilter(PredefinedFilter filter, DateTime now) {
    switch (filter) {
      case PredefinedFilter.today:
        final start = DateTime(now.year, now.month, now.day);
        return DateTimeRange(start: start, end: start);
      case PredefinedFilter.week:
        final daysToSubtract = (now.weekday == DateTime.saturday)
            ? 0
            : (now.weekday + 1) % 7;
        final start = DateTime(now.year, now.month, now.day - daysToSubtract);
        return DateTimeRange(start: start, end: now);
      case PredefinedFilter.month:
        return DateTimeRange(start: DateTime(now.year, now.month, 1), end: now);
      case PredefinedFilter.year:
        return DateTimeRange(start: DateTime(now.year, 1, 1), end: now);
      case PredefinedFilter.singleDay:
        return DateTimeRange(
          start: state.filterStartDate ?? now,
          end: state.filterEndDate ?? now,
        );
      case PredefinedFilter.since:
        return DateTimeRange(start: state.filterStartDate ?? now, end: now);
      case PredefinedFilter.custom:
        return DateTimeRange(
          start: state.filterStartDate ?? now,
          end: state.filterEndDate ?? now,
        );
    }
  }

  Future<void> _performDatabaseOperation(
    Future<void> Function() operation,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await operation();

      final transactions = await getTransactionsUseCase();
      final categories = await getCategoriesUseCase();
      emit(
        state.copyWith(
          isLoading: false,
          allTransactions: transactions,
          allCategories: categories,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _performDatabaseOperation(() => addTransactionUseCase(transaction));
  }

  Future<void> updateTransaction(Transaction updatedTransaction) async {
    emit(state.copyWith(isLoading: true));
    try {
      final originalTransaction = state.allTransactions.firstWhere(
        (t) => t.id == updatedTransaction.id,
      );

      final oldSignedAmount =
          originalTransaction.amount *
          (originalTransaction.type == TransactionType.income ? 1 : -1);
      final newSignedAmount =
          updatedTransaction.amount *
          (updatedTransaction.type == TransactionType.income ? 1 : -1);
      final amountDifference = newSignedAmount - oldSignedAmount;

      await updateTransactionUseCase(updatedTransaction);

      await walletCubit.updateWalletBalance(
        updatedTransaction.walletId,
        amountDifference,
      );

      final transactions = await getTransactionsUseCase();
      emit(state.copyWith(isLoading: false, allTransactions: transactions));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final transactionToDelete = state.allTransactions.firstWhere(
        (t) => t.id == transactionId,
      );

      final amountToRevert =
          transactionToDelete.amount *
          (transactionToDelete.type == TransactionType.income ? -1 : 1);

      await deleteTransactionUseCase(transactionId);

      await walletCubit.updateWalletBalance(
        transactionToDelete.walletId,
        amountToRevert,
      );

      final transactions = await getTransactionsUseCase();
      emit(state.copyWith(isLoading: false, allTransactions: transactions));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addCategory(TransactionCategory category) async {
    await _performDatabaseOperation(() => addCategoryUseCase(category));
  }

  Future<void> updateCategory(TransactionCategory category) async {
    await _performDatabaseOperation(() => updateCategoryUseCase(category));
  }

  Future<void> deleteCategory(String categoryId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final transactionsToDelete = state.allTransactions
          .where((t) => t.categoryId == categoryId)
          .toList();

      await deleteCategoryUseCase(categoryId);

      for (final transaction in transactionsToDelete) {
        final amountToRevert =
            transaction.amount *
            (transaction.type == TransactionType.income ? -1 : 1);
        await walletCubit.updateWalletBalance(
          transaction.walletId,
          amountToRevert,
        );
      }

      final transactions = await getTransactionsUseCase();
      final categories = await getCategoriesUseCase();
      emit(
        state.copyWith(
          isLoading: false,
          allTransactions: transactions,
          allCategories: categories,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> setSinceFilter(DateTime startDate) async {
    emit(state.copyWith(isLoading: true));
    final endDate = DateTime.now();
    await saveFilterSettingsUseCase(
      startDate: startDate,
      endDate: endDate,
      activeFilter: PredefinedFilter.since,
    );
    emit(
      state.copyWith(
        isLoading: false,
        filterStartDate: startDate,
        filterEndDate: endDate,
        activeFilter: PredefinedFilter.since,
      ),
    );
  }

  Future<void> setPredefinedFilter(PredefinedFilter filter) async {
    emit(state.copyWith(isLoading: true));
    final range = _getDateRangeForFilter(filter, DateTime.now());
    await saveFilterSettingsUseCase(
      startDate: range.start,
      endDate: range.end,
      activeFilter: filter,
    );
    emit(
      state.copyWith(
        isLoading: false,
        filterStartDate: range.start,
        filterEndDate: range.end,
        activeFilter: filter,
      ),
    );
  }

  Future<void> setCustomDateFilter(DateTime startDate, DateTime endDate) async {
    emit(state.copyWith(isLoading: true));
    await saveFilterSettingsUseCase(
      startDate: startDate,
      endDate: endDate,
      activeFilter: PredefinedFilter.custom,
    );
    emit(
      state.copyWith(
        isLoading: false,
        filterStartDate: startDate,
        filterEndDate: endDate,
        activeFilter: PredefinedFilter.custom,
      ),
    );
  }

  void setWalletFilter(String? walletId) {
    if (walletId == null) {
      emit(state.copyWith(clearSelectedWalletId: true));
    } else {
      emit(state.copyWith(selectedWalletId: walletId));
    }
  }
}
