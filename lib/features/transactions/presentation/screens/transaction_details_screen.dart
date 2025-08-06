// ignore_for_file: prefer_int_literals

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المصاريف'),
        centerTitle: true,
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state.isLoading && state.allTransactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenseTransactions = state.filteredTransactions
              .where((t) => t.type == TransactionType.expense)
              .toList();

          final expenseByCategory = <String, double>{};
          for (final t in expenseTransactions) {
            expenseByCategory.update(
              t.categoryId,
              (value) => value + t.amount,
              ifAbsent: () => t.amount,
            );
          }

          final totalExpense = expenseByCategory.values.fold(
            0.0,
            (sum, item) => sum + item,
          );

          return Column(
            children: [
              _DateFilterBar(),
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(child: LinearProgressIndicator()),
                )
              else if (expenseTransactions.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text('لا توجد مصاريف لعرضها في هذا النطاق الزمني'),
                  ),
                )
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      _PieChartCard(
                        expenseByCategory: expenseByCategory,
                        categories: state.allCategories,
                        totalExpense: totalExpense,
                      ),
                      const SizedBox(height: 16),
                      _ExpenseListCard(
                        expenseByCategory: expenseByCategory,
                        categories: state.allCategories,
                      ),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _DateFilterBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<TransactionCubit>();
    final startDate = cubit.state.filterStartDate;
    final endDate = cubit.state.filterEndDate;
    final dateFormat = DateFormat('yyyy/MM/dd');

    var filterText = 'اضغط لتحديد فترة الفلترة';
    if (startDate != null && endDate != null) {
      filterText =
          'من: ${dateFormat.format(startDate)}   إلى: ${dateFormat.format(endDate)}';
    }

    return InkWell(
      onTap: () async {
        final now = DateTime.now();
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(now.year - 5),
          lastDate: now,
          initialDateRange: startDate != null && endDate != null
              ? DateTimeRange(start: startDate, end: endDate)
              : null,
        );
        if (picked != null) {
          await context.read<TransactionCubit>().setDateFilter(
            picked.start,
            picked.end,
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.all(8),
        elevation: 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today_outlined, size: 20),
              const SizedBox(width: 12),
              Text(
                filterText,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PieChartCard extends StatelessWidget {
  const _PieChartCard({
    required this.expenseByCategory,
    required this.categories,
    required this.totalExpense,
  });
  final Map<String, double> expenseByCategory;
  final List<TransactionCategory> categories;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'توزيع المصاريف',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  sections: expenseByCategory.entries.map((entry) {
                    final category = categories.firstWhere(
                      (c) => c.id == entry.key,
                      orElse: () => TransactionCategory(
                        id: '',
                        name: 'غير معروف',
                        colorValue: Colors.grey.value,
                        type: TransactionType.expense,
                      ),
                    );
                    final percentage = totalExpense > 0
                        ? (entry.value / totalExpense) * 100
                        : 0;
                    return PieChartSectionData(
                      color: category.color,
                      value: entry.value,
                      title: '${percentage.toStringAsFixed(1)}%',
                      radius: 60,
                      titleStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseListCard extends StatelessWidget {
  const _ExpenseListCard({
    required this.expenseByCategory,
    required this.categories,
  });
  final Map<String, double> expenseByCategory;
  final List<TransactionCategory> categories;

  @override
  Widget build(BuildContext context) {
    final sortedEntries = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'قائمة المصاريف',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedEntries.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final entry = sortedEntries[index];
              final category = categories.firstWhere(
                (c) => c.id == entry.key,
                orElse: () => TransactionCategory(
                  id: '',
                  name: 'غير معروف',
                  colorValue: Colors.grey.value,
                  type: TransactionType.expense,
                ),
              );
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: category.color,
                  radius: 10,
                ),
                title: Text(category.name),
                trailing: Text(
                  '${entry.value.toStringAsFixed(2)} جنيه',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
