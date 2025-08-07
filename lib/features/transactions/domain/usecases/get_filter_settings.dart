import 'package:opration/features/transactions/domain/repositories/transaction_repository.dart';

class GetFilterSettingsUseCase {
  GetFilterSettingsUseCase({required this.repository});
  final TransactionRepository repository;
  Future<Map<String, dynamic>> call() => repository.getFilterSettings();
}
