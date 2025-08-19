// ignore_for_file: prefer_int_literals

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/main_layout/cubit/main_layout_cubit.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/transactions/presentation/screens/add_transaction_screen.dart';

class TransactionDetailsScreen extends StatelessWidget {
  const TransactionDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: const PageHeader(),
        body: BlocBuilder<TransactionCubit, TransactionState>(
          builder: (context, state) {
            if (state.isLoading && state.allTransactions.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              children: [
                4.verticalSpace,
                _FilterControlBar(),
                4.verticalSpace,
                if (state.isLoading)
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.r),
                    child: const LinearProgressIndicator(),
                  )
                else
                  Expanded(
                    child: TabBarView(
                      children: [
                        _TransactionDetailsPage(
                          type: TransactionType.expense,
                          state: state,
                        ),
                        _TransactionDetailsPage(
                          type: TransactionType.income,
                          state: state,
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TransactionDetailsPage extends StatelessWidget {
  const _TransactionDetailsPage({
    required this.type,
    required this.state,
  });

  final TransactionType type;
  final TransactionState state;

  @override
  Widget build(BuildContext context) {
    final transactionsForType = state.filteredTransactions
        .where((t) => t.type == type)
        .toList();
    final totalAmount = transactionsForType.fold(
      0.0,
      (sum, item) => sum + item.amount,
    );

    if (transactionsForType.isEmpty) {
      return Padding(
        padding: EdgeInsets.all(32.r),
        child: Center(
          child: Text(
            'مفيش ${type == TransactionType.expense ? 'مصروفات' : 'فلوس داخلة'} الفترة دي',
          ),
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.all(8.r),
      children: [
        _SingleSummaryCard(
          title: type == TransactionType.income ? 'فلوسك' : 'مصاريفك',
          totalAmount: totalAmount,
          type: type,
        ),
        8.verticalSpace,

        _CategoryTransactionList(
          transactions: transactionsForType,
          categories: state.allCategories,
          type: type,
        ),
        if (type == TransactionType.expense) ...[
          16.verticalSpace,
          _PieChartCard(
            transactions: transactionsForType,
            categories: state.allCategories,
            totalExpense: totalAmount,
          ),
        ],
      ],
    );
  }
}

class _CategoryTransactionList extends StatelessWidget {
  const _CategoryTransactionList({
    required this.transactions,
    required this.categories,
    required this.type,
  });

  final TransactionType type;
  final List<Transaction> transactions;
  final List<TransactionCategory> categories;

  @override
  Widget build(BuildContext context) {
    final groupedTransactions = <String, List<Transaction>>{};
    for (final transaction in transactions) {
      (groupedTransactions[transaction.categoryId] ??= []).add(transaction);
    }

    final sortedCategoryIds = groupedTransactions.keys.toList()
      ..sort((a, b) {
        final totalA = groupedTransactions[a]!.fold(
          0.0,
          (sum, item) => sum + item.amount,
        );
        final totalB = groupedTransactions[b]!.fold(
          0.0,
          (sum, item) => sum + item.amount,
        );
        return totalB.compareTo(totalA);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.r),
          child: Text(
            type == TransactionType.income
                ? 'فلوسك جت منين؟'
                : 'فلوسك راحت فين؟',
            style: AppTextStyles.style18W600.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: sortedCategoryIds.length,
          separatorBuilder: (context, index) => 8.verticalSpace,
          itemBuilder: (context, index) {
            final categoryId = sortedCategoryIds[index];
            final categoryTransactions = groupedTransactions[categoryId]!;
            final categoryTotal = categoryTransactions.fold(
              0.0,
              (sum, item) => sum + item.amount,
            );

            final category = categories.firstWhere(
              (c) => c.id == categoryId,
              orElse: () => TransactionCategory(
                id: '',
                name: 'في المجهول',
                colorValue: 0,
                type: type,
              ),
            );

            return Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(kRadius),
              ),
              clipBehavior: Clip.antiAlias,
              margin: EdgeInsets.zero,
              child: Theme(
                data: Theme.of(
                  context,
                ).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: category.color,
                    radius: 18.r,
                    child: Icon(
                      type == TransactionType.income
                          ? Icons.arrow_upward
                          : Icons.arrow_downward,
                      color: Colors.white,
                      size: 16.r,
                    ),
                  ),
                  title: Text(category.name, style: AppTextStyles.style14W600),
                  trailing: Text(
                    '$categoryTotal ج.م',
                    style: AppTextStyles.style14W700.copyWith(
                      color: type == TransactionType.income
                          ? AppColors.greenLightColor
                          : AppColors.errorColor,
                    ),
                  ),
                  children: categoryTransactions.map((transaction) {
                    return _TransactionListItem(transaction: transaction);
                  }).toList(),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TransactionListItem extends StatelessWidget {
  const _TransactionListItem({
    required this.transaction,
  });

  final Transaction transaction;

  void _handleMenuSelection(BuildContext context, String value) {
    if (value == 'edit') {
      context.push(AppRoutes.editTransactionScreen, extra: transaction);
    } else if (value == 'delete') {
      _showDeleteConfirmation(context);
    }
  }

  void _showDeleteConfirmation(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('متأكد؟'),
        content: const Text('أنت كدا هتمسح العملية دي كلها'),
        actions: [
          TextButton(
            child: const Text('إلغاء'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          TextButton(
            child: Text(
              'مسح',
              style: AppTextStyles.style12W700.copyWith(
                color: AppColors.errorColor,
              ),
            ),
            onPressed: () {
              context.read<TransactionCubit>().deleteTransaction(
                transaction.id,
              );
              ctx.pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;

    return ListTile(
      title: Row(
        children: [
          Text(
            '${transaction.amount.truncate()} ج.م',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: color,
              fontSize: 16.sp,
            ),
          ),
          if (transaction.note != null && transaction.note!.isNotEmpty)
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  '(${transaction.note!})',
                  style: AppTextStyles.style12W300,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        DateFormat.yMMMd('ar').format(transaction.date),
      ),
      trailing: PopupMenuButton<String>(
        onSelected: (value) => _handleMenuSelection(context, value),
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
          const PopupMenuItem<String>(
            value: 'edit',
            child: ListTile(
              leading: Icon(Icons.edit_outlined, color: AppColors.orangeColor),
              title: Text(
                'عدّل',
                style: TextStyle(color: AppColors.orangeColor),
              ),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'delete',
            child: ListTile(
              leading: Icon(Icons.delete_outline, color: AppColors.errorColor),
              title: Text('مسح', style: TextStyle(color: AppColors.errorColor)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SingleSummaryCard extends StatelessWidget {
  const _SingleSummaryCard({
    required this.title,
    required this.totalAmount,
    required this.type,
  });

  final String title;
  final double totalAmount;
  final TransactionType type;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardColor,
      child: Column(
        children: [
          16.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 16.w,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.style16W500.copyWith(
                        color: AppColors.primaryTextColor,
                      ),
                    ),
                    8.verticalSpace,
                    Text.rich(
                      TextSpan(
                        text: totalAmount.truncate().toString(),
                        style: AppTextStyles.style20W700.copyWith(
                          color: AppColors.primaryColor,
                          fontSize: 32.sp,
                        ),
                        children: [
                          TextSpan(
                            text: ' ج.م',
                            style: AppTextStyles.style16W700.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  type == TransactionType.income
                      ? 'assets/image/png/wallet-money.png'
                      : 'assets/image/png/flying-money.png',
                  height: 96.h,
                ),
              ],
            ),
          ),
          8.verticalSpace,
          const Divider(
            color: AppColors.primaryColor,
            thickness: 0.5,
            height: 0,
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
            child: InkWell(
              onTap: () {
                context.read<MainLayoutCubit>().changeNavBarIndex(2);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    type == TransactionType.expense
                        ? 'إضافة مصاريف جديدة'
                        : 'إضافة دخل جديد',
                    style: AppTextStyles.style14W500.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const Icon(Icons.add, color: AppColors.primaryColor),
                ],
              ),
            ),
          ),
        ],
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            filterText,
            style: AppTextStyles.style14W600.copyWith(
              color: AppColors.greenLightColor,
            ),
          ),
          const Icon(
            Icons.arrow_drop_down,
            color: AppColors.primaryTextColor,
          ),
        ],
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
        return 'النهاردة';
      case PredefinedFilter.week:
        return 'من أول الأسبوع';
      case PredefinedFilter.month:
        return 'من أول الشهر';
      case PredefinedFilter.year:
        return 'السنادي كلها';

      case PredefinedFilter.custom:
        if (start != null && end != null) {
          final format = DateFormat('d MMM');
          return '${format.format(start)} - ${format.format(end)}';
        }
        return 'فترة معينة';
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
                title: const Text('النهاردة'),
                onTap: () {
                  context.read<TransactionCubit>().setPredefinedFilter(
                    PredefinedFilter.today,
                  );
                  sheetContext.pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.view_week_outlined),
                title: const Text('من أول الأسبوع'),
                onTap: () {
                  context.read<TransactionCubit>().setPredefinedFilter(
                    PredefinedFilter.week,
                  );
                  sheetContext.pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_month),
                title: const Text('من أول الشهر'),
                onTap: () {
                  context.read<TransactionCubit>().setPredefinedFilter(
                    PredefinedFilter.month,
                  );
                  sheetContext.pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: const Text('السنادي كلها'),
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
                title: const Text('اختار فترة معينة...'),
                onTap: () async {
                  sheetContext.pop();

                  if (!context.mounted) return;

                  final cubit = context.read<TransactionCubit>();
                  final now = DateTime.now();

                  DateTimeRange? initialRange;
                  if (cubit.state.filterStartDate != null &&
                      cubit.state.filterEndDate != null) {
                    var initialEnd = cubit.state.filterEndDate!;
                    if (initialEnd.isAfter(now)) {
                      initialEnd = now;
                    }
                    var initialStart = cubit.state.filterStartDate!;
                    if (initialStart.isAfter(initialEnd)) {
                      initialStart = initialEnd;
                    }
                    initialRange = DateTimeRange(
                      start: initialStart,
                      end: initialEnd,
                    );
                  }

                  final picked = await showDateRangePicker(
                    helpText: 'اختار فترة معينة',
                    saveText: 'حفظ',
                    context: context,
                    firstDate: DateTime(now.year - 5),
                    lastDate: now,
                    initialDateRange: initialRange,
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

class _PieChartCard extends StatelessWidget {
  const _PieChartCard({
    required this.transactions,
    required this.categories,
    required this.totalExpense,
  });
  final List<Transaction> transactions;
  final List<TransactionCategory> categories;
  final double totalExpense;

  @override
  Widget build(BuildContext context) {
    final expenseByCategory = <String, double>{};
    for (final t in transactions) {
      expenseByCategory.update(
        t.categoryId,
        (value) => value + t.amount,
        ifAbsent: () => t.amount,
      );
    }

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            Text(
              'فلوسك على الشارت',
              style: AppTextStyles.style18W600.copyWith(
                color: AppColors.primaryColor,
              ),
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
                        name: 'في المجهول',
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
                      title: '${percentage.truncate()}%',
                      radius: 60.r,
                      titleStyle: AppTextStyles.style12Bold.copyWith(
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
