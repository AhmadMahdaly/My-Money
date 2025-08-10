import 'package:opration/features/transactions/domain/entities/monthly_plan.dart';
import 'package:opration/features/transactions/domain/repositories/transaction_repository.dart';

class GetMonthlyPlanUseCase {
  GetMonthlyPlanUseCase({required this.repository});
  final TransactionRepository repository;
  Future<MonthlyPlan> call(String yearMonth) =>
      repository.getMonthlyPlan(yearMonth);
}
