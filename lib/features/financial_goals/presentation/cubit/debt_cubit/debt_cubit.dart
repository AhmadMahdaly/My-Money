

import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:opration/features/financial_goals/domain/entities/debt.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';
import 'package:uuid/uuid.dart';

part 'debt_state.dart';

class DebtCubit extends Cubit<DebtState> {
  DebtCubit({required this.sharedPreferences}) : super(const DebtState()) {
    loadDebts();
  }

  final SharedPreferences sharedPreferences;
  final String _cacheKey = 'cached_debts_list';

  // 1. تحميل الديون
  void loadDebts() {
    final jsonString = sharedPreferences.getString(_cacheKey);
    if (jsonString != null && jsonString.isNotEmpty) {
      final list = (json.decode(jsonString) as List)
          .cast<Map<String, dynamic>>()
          .map(Debt.fromJson)
          .toList();
      emit(state.copyWith(debts: list));
    }
  }

  // 2. حفظ الديون
  Future<void> _saveDebts(List<Debt> debts) async {
    final jsonList = debts.map((d) => d.toJson()).toList();
    await sharedPreferences.setString(_cacheKey, json.encode(jsonList));
    emit(state.copyWith(debts: debts));
  }

  // 3. إضافة دين جديد
  Future<void> addDebt(Debt debt) async {
    final updatedList = List<Debt>.from(state.items)..add(debt);
    await _saveDebts(updatedList);
  }

  // 4. حذف دين
  Future<void> deleteDebt(String id) async {
    final updatedList = state.items.where((d) => d.id != id).toList();
    await _saveDebts(updatedList);
  }

  // =========================================================================
  // الدالة السحرية: فحص الديون المستحقة والخصم التلقائي (تُستدعى عند فتح التطبيق)
  // =========================================================================
  Future<void> processDueDebts(
    TransactionCubit transactionCubit,
    WalletCubit walletCubit,
  ) async {
    final now = DateTime.now();
    bool needsUpdate = false;
    List<Debt> updatedDebts = List.from(state.items);

    for (int i = 0; i < updatedDebts.length; i++) {
      final debt = updatedDebts[i];
      if (debt.isFullyPaid) continue; // الدين مسدد بالكامل

      bool isDue = false;

      // أ. التحقق من موعد الاستحقاق
      if (debt.recurrence == DebtRecurrence.once && debt.dueDate != null) {
        // إذا كان الموعد اليوم أو فات، ولم يتم الدفع
        isDue = now.isAfter(debt.dueDate!.subtract(const Duration(days: 1))) && 
                debt.lastProcessedDate == null;
      } 
      else if (debt.recurrence == DebtRecurrence.monthly && debt.recurrenceValue != null) {
        // إذا جاء يوم القسط في الشهر، ولم يتم دفعه هذا الشهر
        isDue = now.day >= debt.recurrenceValue! &&
            (debt.lastProcessedDate == null || debt.lastProcessedDate!.month != now.month || debt.lastProcessedDate!.year != now.year);
      } 
      else if (debt.recurrence == DebtRecurrence.weekly && debt.recurrenceValue != null) {
        // إذا جاء يوم القسط في الأسبوع
        isDue = now.weekday == debt.recurrenceValue! &&
            (debt.lastProcessedDate == null || now.difference(debt.lastProcessedDate!).inDays >= 7);
      }

      // ب. إذا كان مستحقاً و "خصم تلقائي" مفعل
      if (isDue && debt.autoDeduct && debt.targetWalletId != null && debt.categoryId != null) {
        double amountToDeduct = debt.installmentAmount > 0 ? debt.installmentAmount : debt.remainingAmount;
        
        // لا تخصم أكثر من المتبقي
        if (amountToDeduct > debt.remainingAmount) {
          amountToDeduct = debt.remainingAmount;
        }

        // 1. تسجيل كمعاملة (Expense)
        final transaction = Transaction(
          id: const Uuid().v4(),
          amount: amountToDeduct,
          categoryId: debt.categoryId!,
          date: now,
          type: TransactionType.expense,
          walletId: debt.targetWalletId!,
          note: 'سداد آلي: ${debt.name}',
        );
        transactionCubit.addTransaction(transaction);

        // 2. خصم من المحفظة
        walletCubit.updateWalletBalance(debt.targetWalletId!, -amountToDeduct);

        // 3. تحديث الدين (زيادة المدفوع، وتحديث تاريخ آخر دفعة)
        updatedDebts[i] = debt.copyWith(
          paidAmount: debt.paidAmount + amountToDeduct,
          lastProcessedDate: now,
        );
        needsUpdate = true;
      }
      // ج. إذا كان مستحقاً ولكن الخصم ليس تلقائياً
      else if (isDue && !debt.autoDeduct) {
        // هنا يمكننا إرسال إشعار للمستخدم (سنربطها لاحقاً بـ pendingTransactions)
      }
    }

    if (needsUpdate) {
      await _saveDebts(updatedDebts);
    }
  }

  // 5. تسجيل دفعة يدوياً (إذا أراد المستخدم الدفع بنفسه من الشاشة)
  Future<void> recordManualPayment({
    required Debt debt,
    required double amount,
    required String walletId,
    required String categoryId,
    required TransactionCubit transactionCubit,
    required WalletCubit walletCubit,
  }) async {
    final now = DateTime.now();
    
    // 1. معاملة
    final transaction = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      categoryId: categoryId,
      date: now,
      type: TransactionType.expense,
      walletId: walletId,
      note: 'دفعة يدوية: ${debt.name}',
    );
    transactionCubit.addTransaction(transaction);
    walletCubit.updateWalletBalance(walletId, -amount);

    // 2. تحديث الدين
    final updatedList = state.items.map((d) {
      if (d.id == debt.id) {
        return d.copyWith(
          paidAmount: d.paidAmount + amount,
          lastProcessedDate: now, // نعتبرها دفعة هذا الشهر
        );
      }
      return d;
    }).toList();
    
    await _saveDebts(updatedList);
  }
}