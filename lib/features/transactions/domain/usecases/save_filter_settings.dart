import 'package:opration/features/transactions/domain/repositories/transaction_repository.dart';

class SaveFilterSettingsUseCase {
  SaveFilterSettingsUseCase({required this.repository});
  final TransactionRepository repository;
  Future<void> call(DateTime startDate, DateTime endDate) =>
      repository.saveFilterSettings(startDate, endDate);
}
