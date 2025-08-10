import 'package:opration/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:opration/features/transactions/domain/entities/monthly_plan.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit/transactions_cubit.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({required this.localDataSource});
  final TransactionLocalDataSource localDataSource;

  @override
  Future<void> addCategory(TransactionCategory category) =>
      localDataSource.saveCategory(category);
  @override
  Future<void> updateCategory(TransactionCategory category) =>
      localDataSource.updateCategory(category);
  @override
  Future<void> deleteCategory(String categoryId) =>
      localDataSource.deleteCategory(categoryId);
  @override
  Future<List<TransactionCategory>> getCategories() =>
      localDataSource.getCategories();

  @override
  Future<void> addTransaction(Transaction transaction) =>
      localDataSource.saveTransaction(transaction);
  @override
  Future<void> updateTransaction(Transaction transaction) =>
      localDataSource.updateTransaction(transaction);
  @override
  Future<void> deleteTransaction(String transactionId) =>
      localDataSource.deleteTransaction(transactionId);
  @override
  Future<List<Transaction>> getTransactions() =>
      localDataSource.getTransactions();

  @override
  Future<Map<String, dynamic>> getFilterSettings() =>
      localDataSource.getDateFilter();
  @override
  Future<void> saveFilterSettings(
    DateTime startDate,
    DateTime endDate,
    PredefinedFilter activeFilter,
  ) => localDataSource.saveDateFilter(startDate, endDate, activeFilter);
  @override
  Future<MonthlyPlan> getMonthlyPlan(String yearMonth) =>
      localDataSource.getMonthlyPlan(yearMonth);

  @override
  Future<void> saveMonthlyPlan(MonthlyPlan plan) =>
      localDataSource.saveMonthlyPlan(plan);
}
