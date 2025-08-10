import 'package:opration/features/transactions/domain/entities/monthly_plan.dart';
import 'package:opration/features/transactions/domain/repositories/transaction_repository.dart';

class SaveMonthlyPlanUseCase {
  SaveMonthlyPlanUseCase({required this.repository});
  final TransactionRepository repository;
  Future<void> call(MonthlyPlan plan) => repository.saveMonthlyPlan(plan);
}
