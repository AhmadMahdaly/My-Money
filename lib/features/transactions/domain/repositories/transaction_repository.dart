import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';

abstract class TransactionRepository {
  Future<List<Transaction>> getTransactions();
  Future<void> addTransaction(Transaction transaction);
  Future<List<TransactionCategory>> getCategories();
  Future<void> addCategory(TransactionCategory category);
  Future<void> saveFilterSettings(DateTime startDate, DateTime endDate);
  Future<Map<String, DateTime?>> getFilterSettings();
}
