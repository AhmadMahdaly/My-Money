import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/repositories/transaction_repository.dart';

class GetTransactionsUseCase {
  GetTransactionsUseCase({required this.repository});
  final TransactionRepository repository;
  Future<List<Transaction>> call() => repository.getTransactions();
}
