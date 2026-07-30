import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:opration/core/services/cache_helper/cache_helper.dart';
import 'package:opration/features/debt/domain/entities/credit.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';
import 'package:uuid/uuid.dart';

part 'credit_state.dart';

class CreditCubit extends Cubit<CreditState> {
  CreditCubit() : super(const CreditState()) {
    loadCredits();
  }

  final String _cacheKey = 'cached_credits_list'; // كاش مختلف عن الديون

  void loadCredits() {
    final jsonString = CacheHelper.getData(_cacheKey) as String?;
    if (jsonString != null && jsonString.isNotEmpty) {
      final list = (json.decode(jsonString) as List)
          .cast<Map<String, dynamic>>()
          .map(Credit.fromJson)
          .toList();
      emit(state.copyWith(credits: list));
    }
  }

  Future<void> _saveCredits(List<Credit> credits) async {
    final jsonList = credits.map((c) => c.toJson()).toList();
    await CacheHelper.saveData(key: _cacheKey, value: json.encode(jsonList));
    emit(state.copyWith(credits: credits));
  }

  Future<void> addCredit(Credit credit) async {
    final updatedList = List<Credit>.from(state.items)..add(credit);
    await _saveCredits(updatedList);
  }

  Future<void> deleteCredit(String id) async {
    final updatedList = state.items.where((c) => c.id != id).toList();
    await _saveCredits(updatedList);
  }

  Future<void> updateCredit(Credit updatedCredit) async {
    final updatedList = state.items.map((c) {
      return c.id == updatedCredit.id ? updatedCredit : c;
    }).toList();
    await _saveCredits(updatedList);
  }

  Future<void> reactivateCredit(String id) async {
    final updatedList = state.items.map((credit) {
      if (credit.id == id) {
        return credit.copyWith(
          paidAmount: 0,
          lastProcessedDate: null,
        );
      }
      return credit;
    }).toList();
    await _saveCredits(updatedList);
  }

  // --- التسجيل اليدوي لمستحق ---
  Future<void> recordManualPayment({
    required Credit credit,
    required double amount,
    required String walletId,
    required String categoryId,
    required DateTime paymentDate,
    required TransactionCubit transactionCubit,
    required WalletCubit walletCubit,
  }) async {
    final transaction = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      categoryId: categoryId,
      date: paymentDate,
      type: TransactionType.income, // <--- هام: إيراد
      walletId: walletId,
      note: 'تحصيل يدوي: ${credit.name}',
    );

    await transactionCubit.addTransaction(transaction);
    await walletCubit.updateWalletBalance(
      walletId,
      amount,
    ); // <--- هام: زيادة الرصيد بالموجب

    final updatedList = state.items.map((c) {
      if (c.id == credit.id) {
        return c.copyWith(
          paidAmount: c.paidAmount + amount,
          lastProcessedDate: paymentDate,
        );
      }
      return c;
    }).toList();

    await _saveCredits(updatedList);
  }

  // --- التحصيل التلقائي ---
  Future<void> processDueCredits(
    TransactionCubit transactionCubit,
    WalletCubit walletCubit,
  ) async {
    final now = DateTime.now();
    var needsUpdate = false;
    final updatedCredits = List<Credit>.from(state.items);

    for (var i = 0; i < updatedCredits.length; i++) {
      final credit = updatedCredits[i];
      if (credit.isFullyPaid) continue;

      var isDue = false;

      // منطق التحقق من التاريخ (نفس كود الديون)
      if (credit.recurrence == CreditRecurrence.once &&
          credit.dueDate != null) {
        isDue =
            now.isAfter(credit.dueDate!.subtract(const Duration(days: 1))) &&
            credit.lastProcessedDate == null;
      } else if (credit.recurrence == CreditRecurrence.monthly &&
          credit.recurrenceValue != null) {
        isDue =
            now.day >= credit.recurrenceValue! &&
            (credit.lastProcessedDate == null ||
                credit.lastProcessedDate!.month != now.month ||
                credit.lastProcessedDate!.year != now.year);
      } else if (credit.recurrence == CreditRecurrence.weekly &&
          credit.recurrenceValue != null) {
        isDue =
            now.weekday == credit.recurrenceValue! &&
            (credit.lastProcessedDate == null ||
                now.difference(credit.lastProcessedDate!).inDays >= 7);
      } else if (credit.recurrence == CreditRecurrence.custom &&
          credit.customDates != null) {
        final today = DateTime(now.year, now.month, now.day);
        isDue =
            credit.customDates!.any(
              (d) => DateTime(d.year, d.month, d.day).isAtSameMomentAs(today),
            ) &&
            (credit.lastProcessedDate == null ||
                DateTime(
                      credit.lastProcessedDate!.year,
                      credit.lastProcessedDate!.month,
                      credit.lastProcessedDate!.day,
                    ) !=
                    today);
      }

      if (isDue &&
          credit.autoDeduct &&
          credit.targetWalletId != null &&
          credit.categoryId != null) {
        var amountToDeduct = credit.installmentAmount > 0
            ? credit.installmentAmount
            : credit.remainingAmount;

        if (amountToDeduct > credit.remainingAmount) {
          amountToDeduct = credit.remainingAmount;
        }

        final transaction = Transaction(
          id: const Uuid().v4(),
          amount: amountToDeduct,
          categoryId: credit.categoryId!,
          date: now,
          type: TransactionType.income, // <--- إيراد
          walletId: credit.targetWalletId!,
          note: 'تحصيل آلي: ${credit.name}',
        );
        await transactionCubit.addTransaction(transaction);

        await walletCubit.updateWalletBalance(
          credit.targetWalletId!,
          amountToDeduct, // <--- إضافة للمحفظة بالموجب
        );

        updatedCredits[i] = credit.copyWith(
          paidAmount: credit.paidAmount + amountToDeduct,
          lastProcessedDate: now,
        );
        needsUpdate = true;
      }
    }

    if (needsUpdate) {
      await _saveCredits(updatedCredits);
    }
  }
}

// State Class:
