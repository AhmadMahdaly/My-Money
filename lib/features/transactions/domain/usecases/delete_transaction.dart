import 'package:opration/features/transactions/domain/repositories/transaction_repository.dart';

class DeleteTransactionUseCase {
  DeleteTransactionUseCase({required this.repository});
  final TransactionRepository repository;
  Future<void> call(String transactionId) =>
      repository.deleteTransaction(transactionId);
}
