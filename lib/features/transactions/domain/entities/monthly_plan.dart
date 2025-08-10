import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

@immutable
class PlannedIncome extends Equatable {
  const PlannedIncome({
    required this.id,
    required this.name,
    required this.amount,
    required this.date,
  });

  factory PlannedIncome.fromJson(Map<String, dynamic> map) {
    return PlannedIncome(
      id: map['id'] as String? ?? const Uuid().v4(),
      name: map['name'] as String? ?? '',
      amount: map['amount'] as double? ?? 0.0,
      date: DateTime.parse(map['date'].toString()),
    );
  }
  final String id;
  final String name;
  final double amount;
  final DateTime date;

  @override
  List<Object> get props => [id, name, amount, date];

  PlannedIncome copyWith({
    String? id,
    String? name,
    double? amount,
    DateTime? date,
  }) {
    return PlannedIncome(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'date': date.toIso8601String(),
    };
  }
}

@immutable
class PlannedExpense extends Equatable {
  const PlannedExpense({
    required this.categoryId,
    required this.budgetedAmount,
  });

  factory PlannedExpense.fromJson(Map<String, dynamic> map) {
    return PlannedExpense(
      categoryId: map['categoryId'] as String? ?? '',
      budgetedAmount: map['budgetedAmount'] as double? ?? 0.0,
    );
  }
  final String categoryId;
  final double budgetedAmount;

  @override
  List<Object> get props => [categoryId, budgetedAmount];

  PlannedExpense copyWith({
    String? categoryId,
    double? budgetedAmount,
  }) {
    return PlannedExpense(
      categoryId: categoryId ?? this.categoryId,
      budgetedAmount: budgetedAmount ?? this.budgetedAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'budgetedAmount': budgetedAmount,
    };
  }
}

@immutable
class MonthlyPlan extends Equatable {
  const MonthlyPlan({
    required this.id,
    this.incomes = const [],
    this.expenses = const [],
  });

  factory MonthlyPlan.fromJson(Map<String, dynamic> map) {
    return MonthlyPlan(
      id: map['id'] as String? ?? '',
      incomes: List<PlannedIncome>.from(
        (map['incomes'] as List<dynamic>?)?.map(
              (x) => PlannedIncome.fromJson(x as Map<String, dynamic>),
            ) ??
            [],
      ),
      expenses: List<PlannedExpense>.from(
        (map['expenses'] as List<dynamic>?)?.map(
              (x) => PlannedExpense.fromJson(x as Map<String, dynamic>),
            ) ??
            [],
      ),
    );
  }
  final String id; // Format: 'YYYY-MM'
  final List<PlannedIncome> incomes;
  final List<PlannedExpense> expenses;

  double get totalPlannedIncome =>
      incomes.fold(0, (sum, item) => sum + item.amount);

  double get totalBudgetedExpense =>
      expenses.fold(0, (sum, item) => sum + item.budgetedAmount);

  double get projectedSavings => totalPlannedIncome - totalBudgetedExpense;

  @override
  List<Object> get props => [id, incomes, expenses];

  MonthlyPlan copyWith({
    String? id,
    List<PlannedIncome>? incomes,
    List<PlannedExpense>? expenses,
  }) {
    return MonthlyPlan(
      id: id ?? this.id,
      incomes: incomes ?? this.incomes,
      expenses: expenses ?? this.expenses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'incomes': incomes.map((x) => x.toJson()).toList(),
      'expenses': expenses.map((x) => x.toJson()).toList(),
    };
  }

  // Helper to get expense for a category
  PlannedExpense? getExpenseForCategory(String categoryId) {
    try {
      return expenses.firstWhere((e) => e.categoryId == categoryId);
    } catch (e) {
      return null;
    }
  }
}
