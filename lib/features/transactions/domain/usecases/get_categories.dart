import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/domain/repositories/transaction_repository.dart';

class GetCategoriesUseCase {
  GetCategoriesUseCase({required this.repository});
  final TransactionRepository repository;
  Future<List<TransactionCategory>> call() => repository.getCategories();
}
