import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/domain/repositories/transaction_repository.dart';

class UpdateCategoryUseCase {
  UpdateCategoryUseCase({required this.repository});
  final TransactionRepository repository;
  Future<void> call(TransactionCategory category) =>
      repository.updateCategory(category);
}
