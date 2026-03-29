import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:opration/features/debt/domain/entities/debt.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

part 'debt_state.dart';

class DebtCubit extends Cubit<DebtState> {
  DebtCubit({required this.sharedPreferences}) : super(const DebtState()) {
    loadDebts();
  }

  final SharedPreferences sharedPreferences;
  final String _cacheKey = 'cached_debts_list';

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

  Future<void> _saveDebts(List<Debt> debts) async {
    final jsonList = debts.map((d) => d.toJson()).toList();
    await sharedPreferences.setString(_cacheKey, json.encode(jsonList));
    emit(state.copyWith(debts: debts));
  }

  Future<void> addDebt(Debt debt) async {
    final updatedList = List<Debt>.from(state.items)..add(debt);
    await _saveDebts(updatedList);
  }

  Future<void> deleteDebt(String id) async {
    final updatedList = state.items.where((d) => d.id != id).toList();
    await _saveDebts(updatedList);
  }

  Future<void> processDueDebts(
    TransactionCubit transactionCubit,
    WalletCubit walletCubit,
  ) async {
    final now = DateTime.now();
    var needsUpdate = false;
    final updatedDebts = List<Debt>.from(state.items);

    for (var i = 0; i < updatedDebts.length; i++) {
      final debt = updatedDebts[i];
      if (debt.isFullyPaid) continue;

      var isDue = false;

      if (debt.recurrence == DebtRecurrence.once && debt.dueDate != null) {
        isDue =
            now.isAfter(debt.dueDate!.subtract(const Duration(days: 1))) &&
            debt.lastProcessedDate == null;
      } else if (debt.recurrence == DebtRecurrence.monthly &&
          debt.recurrenceValue != null) {
        isDue =
            now.day >= debt.recurrenceValue! &&
            (debt.lastProcessedDate == null ||
                debt.lastProcessedDate!.month != now.month ||
                debt.lastProcessedDate!.year != now.year);
      } else if (debt.recurrence == DebtRecurrence.weekly &&
          debt.recurrenceValue != null) {
        isDue =
            now.weekday == debt.recurrenceValue! &&
            (debt.lastProcessedDate == null ||
                now.difference(debt.lastProcessedDate!).inDays >= 7);
      }

      if (isDue &&
          debt.autoDeduct &&
          debt.targetWalletId != null &&
          debt.categoryId != null) {
        var amountToDeduct = debt.installmentAmount > 0
            ? debt.installmentAmount
            : debt.remainingAmount;

        if (amountToDeduct > debt.remainingAmount) {
          amountToDeduct = debt.remainingAmount;
        }

        final transaction = Transaction(
          id: const Uuid().v4(),
          amount: amountToDeduct,
          categoryId: debt.categoryId!,
          date: now,
          type: TransactionType.expense,
          walletId: debt.targetWalletId!,
          note: 'سداد آلي: ${debt.name}',
        );
        await transactionCubit.addTransaction(transaction);

        await walletCubit.updateWalletBalance(
          debt.targetWalletId!,
          -amountToDeduct,
        );

        updatedDebts[i] = debt.copyWith(
          paidAmount: debt.paidAmount + amountToDeduct,
          lastProcessedDate: now,
        );
        needsUpdate = true;
      } else if (isDue && !debt.autoDeduct) {}
    }

    if (needsUpdate) {
      await _saveDebts(updatedDebts);
    }
  }

  Future<void> recordManualPayment({
    required Debt debt,
    required double amount,
    required String walletId,
    required String categoryId,
    required TransactionCubit transactionCubit,
    required WalletCubit walletCubit,
  }) async {
    final now = DateTime.now();

    final transaction = Transaction(
      id: const Uuid().v4(),
      amount: amount,
      categoryId: categoryId,
      date: now,
      type: TransactionType.expense,
      walletId: walletId,
      note: 'دفعة يدوية: ${debt.name}',
    );
    await transactionCubit.addTransaction(transaction);
    await walletCubit.updateWalletBalance(walletId, -amount);

    final updatedList = state.items.map((d) {
      if (d.id == debt.id) {
        return d.copyWith(
          paidAmount: d.paidAmount + amount,
          lastProcessedDate: now,
        );
      }
      return d;
    }).toList();

    await _saveDebts(updatedList);
  }
}
