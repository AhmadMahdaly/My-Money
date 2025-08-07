// ignore_for_file: prefer_int_literals

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        centerTitle: true,
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          if (state.isLoading && state.allTransactions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          final filtered = state.filteredTransactions;
          final totalIncome = filtered
              .where((t) => t.type == TransactionType.income)
              .fold(0.0, (sum, item) => sum + item.amount);
          final totalExpense = filtered
              .where((t) => t.type == TransactionType.expense)
              .fold(0.0, (sum, item) => sum + item.amount);

          final expenseTransactions = filtered
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

          return Column(
            children: [
              _FilterControlBar(),
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Center(child: LinearProgressIndicator()),
                )
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(8),
                    children: [
                      _SummaryCards(
                        totalIncome: totalIncome,
                        totalExpense: totalExpense,
                      ),
                      const SizedBox(height: 8),
                      if (filtered.isEmpty)
                        const Card(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Center(
                              child: Text(
                                'No expenses to display in this time range',
                              ),
                            ),
                          ),
                        )
                      else ...[
                        _TransactionList(
                          transactions: filtered,
                          categories: state.allCategories,
                        ),
                        if (expenseByCategory.isNotEmpty) ...[
                          16.verticalSpace,
                          _PieChartCard(
                            expenseByCategory: expenseByCategory,
                            categories: state.allCategories,
                            totalExpense: totalExpense,
                          ),
                        ],
                      ],
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

class _FilterControlBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<TransactionCubit>();
    final activeFilter = cubit.state.activeFilter;
    final startDate = cubit.state.filterStartDate;
    final endDate = cubit.state.filterEndDate;

    final filterText = _getFilterText(activeFilter, startDate, endDate);

    return InkWell(
      onTap: () => _showFilterOptions(context),
      child: Card(
        margin: const EdgeInsets.all(8),
        elevation: 1,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.filter_list, size: 20),
              const SizedBox(width: 12),
              Text(
                filterText,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  String _getFilterText(
    PredefinedFilter filter,
    DateTime? start,
    DateTime? end,
  ) {
    switch (filter) {
      case PredefinedFilter.today:
        return 'Today';
      case PredefinedFilter.week:
        return 'This week';
      case PredefinedFilter.month:
        return 'This month';
      case PredefinedFilter.year:
        return 'This year';
      case PredefinedFilter.custom:
        if (start != null && end != null) {
          final format = DateFormat('d MMM');
          return '${format.format(start)} - ${format.format(end)}';
        }
        return 'Filter period';
    }
  }

  void _showFilterOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.today),
                title: const Text('Today'),
                onTap: () {
                  context.read<TransactionCubit>().setPredefinedFilter(
                    PredefinedFilter.today,
                  );
                  sheetContext.pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.view_week_outlined),
                title: const Text('This week (Sat - Fri)'),
                onTap: () {
                  context.read<TransactionCubit>().setPredefinedFilter(
                    PredefinedFilter.week,
                  );
                  sheetContext.pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('This month'),
                onTap: () {
                  context.read<TransactionCubit>().setPredefinedFilter(
                    PredefinedFilter.month,
                  );
                  sheetContext.pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('This year'),
                onTap: () {
                  context.read<TransactionCubit>().setPredefinedFilter(
                    PredefinedFilter.year,
                  );
                  sheetContext.pop();
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.date_range),
                title: const Text('Select filter period...'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final cubit = context.read<TransactionCubit>();
                  final now = DateTime.now();
                  final picked = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(now.year - 5),
                    lastDate: now,
                    initialDateRange: cubit.state.filterStartDate != null
                        ? DateTimeRange(
                            start: cubit.state.filterStartDate!,
                            end: cubit.state.filterEndDate!,
                          )
                        : null,
                  );
                  if (picked != null && context.mounted) {
                    await context.read<TransactionCubit>().setCustomDateFilter(
                      picked.start,
                      picked.end,
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryCards extends StatelessWidget {
  const _SummaryCards({required this.totalIncome, required this.totalExpense});
  final double totalIncome;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    final expenseRatio = totalIncome > 0
        ? (totalExpense / totalIncome) * 100
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: Card(
            color: Colors.green[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Totle income',
                    style: TextStyle(color: Colors.green),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${totalIncome.toStringAsFixed(2)} EGP',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        8.horizontalSpace,
        Expanded(
          child: Card(
            color: Colors.red[50],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text(
                    'Totle Expense',
                    style: TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${totalExpense.toStringAsFixed(2)} EGP',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  if (totalIncome > 0) ...[
                    4.verticalSpace,
                    Text(
                      '(${expenseRatio.toStringAsFixed(1)}% From income)',
                      style: TextStyle(fontSize: 12, color: Colors.red[700]),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Expense Distribution',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            20.verticalSpace,
            SizedBox(
              height: 200.h,
              child: PieChart(
                PieChartData(
                  sectionsSpace: 2,
                  centerSpaceRadius: 40.r,
                  sections: expenseByCategory.entries.map((entry) {
                    final category = categories.firstWhere(
                      (c) => c.id == entry.key,
                      orElse: () => TransactionCategory(
                        id: '',
                        name: 'Unknown',
                        colorValue: 0,
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
                      radius: 60.r,
                      titleStyle: Styles.style12Bold.copyWith(
                        color: AppColors.scaffoldBackgroundLightColor,
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

class _TransactionList extends StatelessWidget {
  const _TransactionList({
    required this.transactions,
    required this.categories,
  });
  final List<Transaction> transactions;
  final List<TransactionCategory> categories;

  @override
  Widget build(BuildContext context) {
    transactions.sort((a, b) => b.date.compareTo(a.date));

    return Card(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Expenses List',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: transactions.length,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              final category = categories.firstWhere(
                (c) => c.id == transaction.categoryId,
                orElse: () => TransactionCategory(
                  id: '',
                  name: 'Unknown',
                  colorValue: 0,
                  type: TransactionType.expense,
                ),
              );
              final isIncome = transaction.type == TransactionType.income;
              final color = isIncome ? Colors.green : Colors.red;

              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: category.color,
                  radius: 18.r,
                  child: Icon(
                    isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                    color: Colors.white,
                    size: 16.r,
                  ),
                ),
                title: Text(category.name),
                subtitle: Text(
                  DateFormat.yMMMd().format(transaction.date),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${isIncome ? '+' : '-'}${transaction.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: color,
                        fontSize: 16.sp,
                      ),
                    ),
                    8.horizontalSpace,
                    IconButton(
                      icon: Icon(Icons.edit_outlined, size: 20.r),
                      onPressed: () {
                        context.push(
                          AppRoutes.editTransactionScreen,
                          extra: transaction,
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
