import 'package:opration/features/monthly_plan/domain/entities/monthly_plan.dart';
import 'package:opration/features/transactions/domain/repositories/transaction_repository.dart';

class GetAllMonthlyPlansUseCase {
  GetAllMonthlyPlansUseCase({required this.repository});

  final TransactionRepository repository;

  Future<List<MonthlyPlan>> call() => repository.getAllMonthlyPlans();
}
