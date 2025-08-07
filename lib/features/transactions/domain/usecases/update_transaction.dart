import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/repositories/transaction_repository.dart';

class UpdateTransactionUseCase {
  UpdateTransactionUseCase({required this.repository});
  final TransactionRepository repository;
  Future<void> call(Transaction transaction) =>
      repository.updateTransaction(transaction);
}
