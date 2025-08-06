import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/domain/repositories/transaction_repository.dart';

class AddCategoryUseCase {
  AddCategoryUseCase({required this.repository});
  final TransactionRepository repository;
  Future<void> call(TransactionCategory category) =>
      repository.addCategory(category);
}
