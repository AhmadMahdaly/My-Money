import 'package:opration/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/domain/repositories/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl({required this.localDataSource});
  final TransactionLocalDataSource localDataSource;

  @override
  Future<void> addCategory(TransactionCategory category) =>
      localDataSource.saveCategory(category);
  @override
  Future<void> addTransaction(Transaction transaction) =>
      localDataSource.saveTransaction(transaction);
  @override
  Future<List<TransactionCategory>> getCategories() =>
      localDataSource.getCategories();
  @override
  Future<List<Transaction>> getTransactions() =>
      localDataSource.getTransactions();
  @override
  Future<Map<String, DateTime?>> getFilterSettings() =>
      localDataSource.getDateFilter();
  @override
  Future<void> saveFilterSettings(DateTime startDate, DateTime endDate) =>
      localDataSource.saveDateFilter(startDate, endDate);
}
