import 'package:opration/features/transactions/domain/repositories/transaction_repository.dart';

class DeleteCategoryUseCase {
  DeleteCategoryUseCase({required this.repository});
  final TransactionRepository repository;
  Future<void> call(String categoryId) => repository.deleteCategory(categoryId);
}
