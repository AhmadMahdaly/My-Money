import 'package:opration/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit/transactions_cubit.dart';

class SaveFilterSettingsUseCase {
  SaveFilterSettingsUseCase({required this.repository});
  final TransactionRepository repository;
  Future<void> call({
    required DateTime startDate,
    required DateTime endDate,
    required PredefinedFilter activeFilter,
  }) => repository.saveFilterSettings(startDate, endDate, activeFilter);
}
