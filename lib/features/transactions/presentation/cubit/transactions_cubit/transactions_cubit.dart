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
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';

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
  Future<void> loadInitialData() async {
    emit(state.copyWith(isLoading: true));
    try {
      final filterSettings = await getFilterSettingsUseCase();
      final lastFilter = filterSettings['activeFilter'] as PredefinedFilter;
      var startDate = filterSettings['startDate'] as DateTime?;
      var endDate = filterSettings['endDate'] as DateTime?;

      // المنطق الجديد:
      // إذا كان الفلتر (اليوم، الأسبوع، الشهر، السنة) نعيد حسابه بناءً على تاريخ "الآن"
      // أما إذا كان (منذ تاريخ، فترة مخصصة، يوم محدد) نستخدم التواريخ المحفوظة
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
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  // إضافة ميثود لفلتر اليوم الواحد
  Future<void> setSingleDayFilter(DateTime date) async {
    emit(state.copyWith(isLoading: true));
    // بداية اليوم ونهايته
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

  // تحديث دالة حساب المدى الزمني
  DateTimeRange _getDateRangeForFilter(PredefinedFilter filter, DateTime now) {
    switch (filter) {
      case PredefinedFilter.today:
        final start = DateTime(now.year, now.month, now.day);
        return DateTimeRange(start: start, end: start);
      case PredefinedFilter.week:
        // بداية الأسبوع (السبت مثلاً)
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
      // After operation, reload all data
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
      // ١. الحصول على النسخة الأصلية من العملية قبل التعديل
      final originalTransaction = state.allTransactions.firstWhere(
        (t) => t.id == updatedTransaction.id,
      );

      // ٢. حساب الفرق في المبلغ
      final oldSignedAmount =
          originalTransaction.amount *
          (originalTransaction.type == TransactionType.income ? 1 : -1);
      final newSignedAmount =
          updatedTransaction.amount *
          (updatedTransaction.type == TransactionType.income ? 1 : -1);
      final amountDifference = newSignedAmount - oldSignedAmount;

      // ٣. تحديث العملية في قاعدة البيانات
      await updateTransactionUseCase(updatedTransaction);

      // ٤. تحديث رصيد المحفظة
      // (يفترض أن المحفظة لم تتغير، لو تغيرت فالمنطق سيكون أعقد)
      await walletCubit.updateWalletBalance(
        updatedTransaction.walletId,
        amountDifference,
      );

      // ٥. إعادة تحميل البيانات
      final transactions = await getTransactionsUseCase();
      emit(state.copyWith(isLoading: false, allTransactions: transactions));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> deleteTransaction(String transactionId) async {
    emit(state.copyWith(isLoading: true));
    try {
      // ١. الحصول على العملية قبل حذفها
      final transactionToDelete = state.allTransactions.firstWhere(
        (t) => t.id == transactionId,
      );

      // ٢. حساب المبلغ الذي يجب إعادته للمحفظة
      final amountToRevert =
          transactionToDelete.amount *
          (transactionToDelete.type == TransactionType.income ? -1 : 1);

      // ٣. حذف العملية من قاعدة البيانات
      await deleteTransactionUseCase(transactionId);

      // ٤. تحديث رصيد المحفظة
      await walletCubit.updateWalletBalance(
        transactionToDelete.walletId,
        amountToRevert,
      );

      // ٥. إعادة تحميل البيانات
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
      // ١. إيجاد كل العمليات المرتبطة بهذه الفئة قبل حذفها
      final transactionsToDelete = state.allTransactions
          .where((t) => t.categoryId == categoryId)
          .toList();

      // ٢. حذف الفئة والعمليات المرتبطة بها
      await deleteCategoryUseCase(categoryId);

      // ٣. تحديث رصيد المحفظة لكل عملية تم حذفها
      for (final transaction in transactionsToDelete) {
        final amountToRevert =
            transaction.amount *
            (transaction.type == TransactionType.income ? -1 : 1);
        await walletCubit.updateWalletBalance(
          transaction.walletId,
          amountToRevert,
        );
      }

      // ٤. إعادة تحميل البيانات
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
