import 'package:opration/features/transactions/domain/entities/monthly_plan.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit/transactions_cubit.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions();
  Future<void> addTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String transactionId);

  Future<List<TransactionCategory>> getCategories();
  Future<void> addCategory(TransactionCategory category);
  Future<void> updateCategory(TransactionCategory category);
  Future<void> deleteCategory(String categoryId);

  Future<void> saveFilterSettings(
    DateTime startDate,
    DateTime endDate,
    PredefinedFilter activeFilter,
  );
  Future<Map<String, dynamic>> getFilterSettings();
  Future<MonthlyPlan> getMonthlyPlan(String yearMonth);
  Future<void> saveMonthlyPlan(MonthlyPlan plan);
}
