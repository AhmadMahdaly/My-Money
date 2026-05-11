import 'package:equatable/equatable.dart';
import 'package:opration/features/monthly_plan/domain/entities/monthly_plan.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';

class MonthlyAnalyticsData extends Equatable {
  const MonthlyAnalyticsData({
    required this.month,
    required this.previousBalance,
    required this.currentMonthIncome,
    required this.totalAvailable,
    required this.totalExpense,
    required this.actualSavings,
    required this.spendingPercentage,
    required this.currentMonthTransactions,
    required this.sortedMainCategorySpending,
    required this.sortedSubCategorySpending,
    required this.plan,
    required this.allCategories,
    required this.expectedIncome,
    required this.plannedBudget,
    required this.expectedSavings,
  });

  factory MonthlyAnalyticsData.from({
    required DateTime month,
    required MonthlyPlan plan,
    required List<Transaction> allTransactions,
    required List<TransactionCategory> allCategories,
  }) {
    final startOfMonth = DateTime(month.year, month.month, 1);

    final previousTransactions = allTransactions.where(
      (t) => t.date.isBefore(startOfMonth),
    );

    final previousIncome = previousTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final previousExpense = previousTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final previousBalance = previousIncome - previousExpense;

    final currentMonthTransactions = allTransactions
        .where(
          (t) => t.date.year == month.year && t.date.month == month.month,
        )
        .toList();

    final currentMonthIncome = currentMonthTransactions
        .where((t) => t.type == TransactionType.income)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalExpense = currentMonthTransactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    final totalAvailable = previousBalance + currentMonthIncome;
    final actualSavings = totalAvailable - totalExpense;
    final spendingPercentage = totalAvailable > 0
        ? (totalExpense / totalAvailable) * 100
        : 0.0;

    final expenseMainCategories = allCategories
        .where(
          (c) => c.type == TransactionType.expense && c.parentId == null,
        )
        .toList();

    final mainSpending = <TransactionCategory, double>{};
    final subSpending = <TransactionCategory, double>{};

    for (final main in expenseMainCategories) {
      final subIds = allCategories
          .where((c) => c.parentId == main.id)
          .map((c) => c.id);
      final spent = currentMonthTransactions
          .where(
            (t) =>
                t.type == TransactionType.expense &&
                (t.categoryId == main.id || subIds.contains(t.categoryId)),
          )
          .fold(0.0, (sum, t) => sum + t.amount);
      if (spent > 0) {
        mainSpending[main] = spent;
      }
    }

    for (final sub in allCategories.where(
      (c) => c.type == TransactionType.expense && c.parentId != null,
    )) {
      final spent = currentMonthTransactions
          .where(
            (t) => t.type == TransactionType.expense && t.categoryId == sub.id,
          )
          .fold(0.0, (sum, t) => sum + t.amount);
      if (spent > 0) {
        subSpending[sub] = spent;
      }
    }

    final sortedMain = mainSpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final sortedSub = subSpending.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // تم التحديث هنا ليتطابق مع الـ Getters الموجودة في كلاس MonthlyPlan الخاص بك
    final expectedIncome = plan.totalPlannedIncome;
    final plannedBudget = plan.totalBudgetedExpense;
    final expectedSavings = plan.projectedSavings;

    return MonthlyAnalyticsData(
      month: month,
      previousBalance: previousBalance,
      currentMonthIncome: currentMonthIncome,
      totalAvailable: totalAvailable,
      totalExpense: totalExpense,
      actualSavings: actualSavings,
      spendingPercentage: spendingPercentage,
      currentMonthTransactions: currentMonthTransactions,
      sortedMainCategorySpending: sortedMain,
      sortedSubCategorySpending: sortedSub,
      plan: plan,
      allCategories: allCategories,
      expectedIncome: expectedIncome,
      plannedBudget: plannedBudget,
      expectedSavings: expectedSavings,
    );
  }

  final DateTime month;
  final double previousBalance;
  final double currentMonthIncome;
  final double totalAvailable;
  final double totalExpense;
  final double actualSavings;
  final double spendingPercentage;

  // الخصائص الخاصة بالتخطيط
  final double expectedIncome;
  final double plannedBudget;
  final double expectedSavings;

  final List<Transaction> currentMonthTransactions;
  final List<MapEntry<TransactionCategory, double>> sortedMainCategorySpending;
  final List<MapEntry<TransactionCategory, double>> sortedSubCategorySpending;

  final MonthlyPlan plan;
  final List<TransactionCategory> allCategories;

  @override
  List<Object?> get props => [
    month,
    previousBalance,
    currentMonthIncome,
    totalAvailable,
    totalExpense,
    actualSavings,
    spendingPercentage,
    currentMonthTransactions,
    sortedMainCategorySpending,
    sortedSubCategorySpending,
    plan,
    allCategories,
    expectedIncome,
    plannedBudget,
    expectedSavings,
  ];
}
