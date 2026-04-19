import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/monthly_plan/domain/entities/monthly_plan.dart';
import 'package:opration/features/monthly_plan/presentation/controllers/monthly_plan_cubit/monthly_plan_cubit.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/calculator_dialog.dart';
import 'package:uuid/uuid.dart';

class MonthlyPlanScreen extends StatelessWidget {
  const MonthlyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MonthlyPlanView();
  }
}

class _MonthlyPlanView extends StatelessWidget {
  const _MonthlyPlanView();

  @override
  Widget build(BuildContext context) {
    final transactionCubit = context.watch<TransactionCubit>();
    if (transactionCubit.state.allCategories.isEmpty &&
        !transactionCubit.state.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.read<TransactionCubit>().loadInitialData();
        }
      });
    }
    return Scaffold(
      appBar: PageHeader(
        isLeading: false,
        height: 16.h,
        title: 'الخطة الشهرية',
        actions: [
          InkWell(
            onTap: () {
              _showResetDialog(context);
            },
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, transactionState) {
          if (transactionState.isLoading &&
              transactionState.allCategories.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          return BlocBuilder<MonthlyPlanCubit, MonthlyPlanState>(
            builder: (context, planState) {
              if (planState.status == MonthlyPlanStatus.loading &&
                  planState.plan == null) {
                return const Center(child: CircularProgressIndicator());
              }
              if (planState.status == MonthlyPlanStatus.saving) {
                return Padding(
                  padding: EdgeInsets.all(16.r),
                  child: SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }
              if (planState.status == MonthlyPlanStatus.error) {
                return Center(child: Text('فيه غلطة: ${planState.error}'));
              }
              if (planState.plan == null) {
                return const Center(child: Text('مفيش أي خطط متسجلة.'));
              }

              return Column(
                children: [
                  _MonthSelector(),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(8.r),
                      children: [
                        _PlannedSummarySection(plan: planState.plan!),
                        // 8.verticalSpace,
                        _SummarySection(plan: planState.plan!),

                        // 10.verticalSpace,
                        _PlannedIncomeSection(plan: planState.plan!),
                        8.verticalSpace,
                        _PlannedExpensesSection(plan: planState.plan!),

                        30.verticalSpace,
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  void _showResetDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('تأكيد'),
        content: const Text('هل تريد إعادة تعيين كل الميزانية لهذا الشهر؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              context.read<MonthlyPlanCubit>().resetPlan();
              Navigator.pop(context);
            },
            child: const Text('نعم، امسح'),
          ),
        ],
      ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cubit = context.watch<MonthlyPlanCubit>();
    final currentMonth = cubit.state.currentMonth;

    return Padding(
      padding: EdgeInsets.all(8.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(
              Icons.chevron_left,
              color: AppColors.primaryColor,
            ),
            onPressed: () {
              final prevMonth = DateTime(
                currentMonth.year,
                currentMonth.month - 1,
              );
              cubit.loadPlanForMonth(prevMonth);
            },
          ),
          Text(
            DateFormat.yMMMM('ar').format(currentMonth),
            style: AppTextStyle.style16W400.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.chevron_right,
              color: AppColors.primaryColor,
            ),
            onPressed: () {
              final nextMonth = DateTime(
                currentMonth.year,
                currentMonth.month + 1,
              );
              cubit.loadPlanForMonth(nextMonth);
            },
          ),
        ],
      ),
    );
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.plan});
  final MonthlyPlan plan;

  @override
  Widget build(BuildContext context) {
    final transactionState = context.watch<TransactionCubit>().state;
    final planState = context.watch<MonthlyPlanCubit>().state;

    final currentMonth = planState.currentMonth;
    final year = currentMonth.year;
    final month = currentMonth.month;

    final actualTotalIncome = transactionState.allTransactions
        .where(
          (t) =>
              t.type == TransactionType.income &&
              t.date.year == year &&
              t.date.month == month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final actualTotalExpense = transactionState.allTransactions
        .where(
          (t) =>
              t.type == TransactionType.expense &&
              t.date.year == year &&
              t.date.month == month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final actualSavings = actualTotalIncome - actualTotalExpense;

    return Theme(
      data: Theme.of(
        context,
      ).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: const Text('ملخص عملياتك الفعلية'),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryItem(
                title: 'الدخل الفعلي',
                amount: actualTotalIncome,
                color: AppColors.successColor.withAlpha(200),
              ),
              _SummaryItem(
                title: 'المصروف الفعلي',
                amount: actualTotalExpense,
                color: AppColors.errorColor.withAlpha(200),
              ),
              _SummaryItem(
                title: 'الباقي الفعلي',
                amount: actualSavings,
                color: actualSavings >= 0
                    ? AppColors.primaryColor.withAlpha(200)
                    : AppColors.orangeColor.withAlpha(200),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlannedSummarySection extends StatelessWidget {
  const _PlannedSummarySection({required this.plan});
  final MonthlyPlan plan;

  @override
  Widget build(BuildContext context) {
    final plannedIncome = plan.totalPlannedIncome;
    final plannedExpense = plan.totalBudgetedExpense;
    final expectedSavings = plan.projectedSavings;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _SummaryItem(
          title: 'دخل متوقع',
          amount: plannedIncome,
          color: AppColors.successColor.withAlpha(200),
        ),
        _SummaryItem(
          title: 'الميزانية',
          amount: plannedExpense,
          color: AppColors.errorColor.withAlpha(200),
        ),
        _SummaryItem(
          title: 'توفير متوقع',
          amount: expectedSavings,
          color: expectedSavings >= 0
              ? AppColors.primaryColor.withAlpha(200)
              : AppColors.orangeColor.withAlpha(200),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.title,
    required this.amount,
    required this.color,
  });
  final String title;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 100.h,
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Column(
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    title,
                    style: AppTextStyle.style16W300.copyWith(
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                4.verticalSpace,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    '${amount.truncate()}',
                    style: AppTextStyle.style20Bold.copyWith(
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlannedIncomeSection extends StatelessWidget {
  const _PlannedIncomeSection({required this.plan});
  final MonthlyPlan plan;

  @override
  Widget build(BuildContext context) {
    final allIncomeCategories = context
        .watch<TransactionCubit>()
        .state
        .allCategories
        .where((c) => c.type == TransactionType.income)
        .toList();

    final mainCategories = allIncomeCategories
        .where((c) => c.parentId == null)
        .toList();

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            'الدخل المتوقع',
            style: AppTextStyle.style14W500.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          initiallyExpanded: false,
          children: [
            if (mainCategories.isEmpty)
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    const Text('لسا مضيفتش فئات للدخل'),
                    8.verticalSpace,
                    ElevatedButton(
                      onPressed: () {
                        context.push(AppRoutes.manageCategoriesScreen);
                      },
                      child: const Text('ضيف فئة دخل جديدة'),
                    ),
                  ],
                ),
              )
            else
              ...mainCategories.map((mainCat) {
                final subCategories = allIncomeCategories
                    .where((c) => c.parentId == mainCat.id)
                    .toList();

                return Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(bottom: 6.h),
                      child: _IncomeBudgetTile(
                        category: mainCat,
                        plan: plan,
                        isSubCategory: false,
                      ),
                    ),
                    if (subCategories.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(right: 24.w),
                        child: Column(
                          children: subCategories.map((subCat) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 6.h),
                              child: _IncomeBudgetTile(
                                category: subCat,
                                plan: plan,
                                isSubCategory: true,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                  ],
                );
              }),
            ListTile(
              tileColor: AppColors.primaryColor,

              title: Text(
                'إدارة فئات الدخل...',
                style: AppTextStyle.style12Bold.copyWith(
                  color: AppColors.scaffoldBackgroundLightColor,
                ),
              ),
              leading: Icon(
                Icons.settings,
                size: 16.r,
                color: AppColors.scaffoldBackgroundLightColor,
              ),
              onTap: () => context.push(AppRoutes.manageCategoriesScreen),
            ),
          ],
        ),
      ),
    );
  }
}

class _IncomeBudgetTile extends StatefulWidget {
  const _IncomeBudgetTile({
    required this.category,
    required this.plan,
    this.isSubCategory = false,
  });
  final TransactionCategory category;
  final MonthlyPlan plan;
  final bool isSubCategory;

  @override
  State<_IncomeBudgetTile> createState() => _IncomeBudgetTileState();
}

class _IncomeBudgetTileState extends State<_IncomeBudgetTile> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _updateControllerText();
  }

  @override
  void didUpdateWidget(covariant _IncomeBudgetTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.plan != oldWidget.plan ||
        widget.category.id != oldWidget.category.id) {
      _updateControllerText();
    }
  }

  void _updateControllerText() {
    final budgetedAmount = widget.plan.incomes
        .where((i) => i.name == widget.category.name)
        .fold(0.0, (sum, item) => sum + item.amount);

    final textValue = (budgetedAmount == budgetedAmount.truncate())
        ? budgetedAmount.truncate().toString()
        : budgetedAmount.toString();

    if (_controller.text != textValue) {
      _controller.text = textValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateIncomeInCubit(double amount) {
    final category = widget.category;
    final planState = context.read<MonthlyPlanCubit>().state;

    final otherIncomes = widget.plan.incomes
        .where((i) => i.name != category.name)
        .toList();

    final updatedIncomes = [...otherIncomes];

    if (amount > 0) {
      final existingIncome = widget.plan.incomes.firstWhere(
        (i) => i.name == category.name,
        orElse: () => PlannedIncome(
          id: getIt<Uuid>().v4(),
          name: '',
          amount: 0,
          date: DateTime.now(),
        ),
      );

      final newIncome = PlannedIncome(
        id: existingIncome.id,
        name: category.name,
        amount: amount,
        date: DateTime(
          planState.currentMonth.year,
          planState.currentMonth.month,
          1,
        ),
      );
      updatedIncomes.add(newIncome);
    }

    context.read<MonthlyPlanCubit>().updatePlan(
      widget.plan.copyWith(incomes: updatedIncomes),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = context.watch<TransactionCubit>().state;
    final planState = context.watch<MonthlyPlanCubit>().state;

    final currentMonth = planState.currentMonth;
    final year = currentMonth.year;
    final month = currentMonth.month;

    final allCategories = transactionState.allCategories;
    final subCategories = allCategories
        .where(
          (c) =>
              c.parentId == widget.category.id &&
              c.type == TransactionType.income,
        )
        .toList();
    final hasSubCategories = subCategories.isNotEmpty;
    final subCategoryIds = subCategories.map((c) => c.id).toList();
    final subCategoryNames = subCategories.map((c) => c.name).toList();

    var budgetedAmount = widget.plan.incomes
        .where((i) => i.name == widget.category.name)
        .fold(0.0, (sum, item) => sum + item.amount);

    for (final subName in subCategoryNames) {
      budgetedAmount += widget.plan.incomes
          .where((i) => i.name == subName)
          .fold(0.0, (sum, item) => sum + item.amount);
    }

    final actualReceivedAmount = transactionState.allTransactions
        .where(
          (t) =>
              (t.categoryId == widget.category.id ||
                  subCategoryIds.contains(t.categoryId)) &&
              t.type == TransactionType.income &&
              t.date.year == year &&
              t.date.month == month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final progressValue = (budgetedAmount > 0)
        ? (actualReceivedAmount / budgetedAmount).clamp(0.0, 1.0)
        : 0.0;

    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 16.r),
      title: Row(
        children: [
          if (widget.isSubCategory) ...[
            Icon(
              Icons.subdirectory_arrow_left,
              size: 16.r,
              color: widget.category.color.withAlpha(150),
            ),
            4.horizontalSpace,
          ],
          CircleAvatar(
            backgroundColor: widget.category.color,
            radius: widget.isSubCategory ? 12.r : 15.r,
          ),
          8.horizontalSpace,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.category.name,
                        style: AppTextStyle.style12Bold.copyWith(
                          fontSize: widget.isSubCategory ? 12.sp : 14.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (hasSubCategories)
                      SizedBox(
                        width: 80.w,
                        child: Center(
                          child: Text(
                            '${budgetedAmount.truncate()} ج.م',
                            style: AppTextStyle.style14W700.copyWith(
                              color: widget.category.color,
                            ),
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => _showEditBudgetSheet(context, true),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withAlpha(16),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColors.primaryColor.withAlpha(77),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _controller.text.isEmpty
                                    ? '0'
                                    : '${_controller.text}  ج.م',
                                style: AppTextStyle.style14W500.copyWith(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              8.horizontalSpace,
                              Icon(
                                Icons.edit_note,
                                size: 18.r,
                                color: AppColors.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                8.verticalSpace,
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: AppColors.secondaryColor,
                  color: widget.category.color,
                  minHeight: 6.h,
                ),
                4.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الإفتراضي: ${budgetedAmount.truncate()} ج.م',
                      style: AppTextStyle.style9W400.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    Text(
                      'الفعلي: ${actualReceivedAmount.truncate()} ج.م',
                      style: AppTextStyle.style9W400.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),

      //  SizedBox(
      //   width: 120.w,
      //   child: CustomPrimaryTextfield(
      //     controller: _controller,
      //     text: 'المخطط',
      //     textAlign: TextAlign.center,
      //     keyboardType: TextInputType.number,
      //     suffix: IconButton(
      //       icon: Icon(
      //         Icons.calculate_outlined,
      //         size: 24.r,
      //         color: AppColors.primaryColor,
      //       ),
      //       onPressed: () async {
      //         final result = await showDialog<double>(
      //           context: context,
      //           builder: (_) => CalculatorDialog(
      //             initialValue: double.tryParse(_controller.text) ?? 0,
      //           ),
      //         );
      //         if (result != null && mounted) {
      //           _controller.text = result.truncate().toString();
      //           _updateIncomeInCubit(result);
      //         }
      //       },
      //     ),
      //     onChanged: (value) {
      //       final amount = double.tryParse(value) ?? 0.0;
      //       _updateIncomeInCubit(amount);
      //     },
      //   ),
      // ),
    );
  }

  void _showEditBudgetSheet(BuildContext context, bool isIn) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(
              context,
            ).viewInsets.bottom,
            left: 20.w,
            right: 20.w,
            top: 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تعديل ميزانية ${widget.category.name}',
                style: AppTextStyle.style16W600,
              ),
              20.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: CustomPrimaryTextfield(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      text: 'المبلغ',
                    ),
                  ),
                  10.horizontalSpace,
                  IconButton(
                    onPressed: () async {
                      final result = await showDialog<double>(
                        context: context,
                        builder: (_) => CalculatorDialog(
                          initialValue: double.tryParse(_controller.text) ?? 0,
                        ),
                      );
                      if (result != null) {
                        _controller.text = result.truncate().toString();
                      }
                    },
                    icon: Icon(
                      Icons.calculate_outlined,
                      size: 35.r,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              20.verticalSpace,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: () {
                    final amount = double.tryParse(_controller.text) ?? 0.0;
                    if (isIn) {
                      _updateIncomeInCubit(amount);
                    } else {
                      _updateExpenseInCubit(amount);
                    }

                    Navigator.pop(context);
                    setState(
                      () {},
                    );
                  },
                  child: const Text(
                    'حفظ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              20.verticalSpace,
            ],
          ),
        );
      },
    );
  }

  void _updateExpenseInCubit(double amount) {
    final newExpense = PlannedExpense(
      categoryId: widget.category.id,
      budgetedAmount: amount,
    );
    final otherExpenses = widget.plan.expenses
        .where((e) => e.categoryId != widget.category.id)
        .toList();

    final updatedExpenses = [...otherExpenses];
    if (amount > 0) {
      updatedExpenses.add(newExpense);
    }

    context.read<MonthlyPlanCubit>().updatePlan(
      widget.plan.copyWith(expenses: updatedExpenses),
    );
  }
}

class _PlannedExpensesSection extends StatelessWidget {
  const _PlannedExpensesSection({required this.plan});
  final MonthlyPlan plan;

  @override
  Widget build(BuildContext context) {
    final allExpenseCategories = context
        .watch<TransactionCubit>()
        .state
        .allCategories
        .where((c) => c.type == TransactionType.expense)
        .toList();

    final mainCategories = allExpenseCategories
        .where((c) => c.parentId == null)
        .toList();

    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Text(
              'مصاريفك المتوقعة (الإلتزامات الثابتة)',
              style: AppTextStyle.style14W500.copyWith(
                color: AppColors.primaryColor,
              ),
            ),
          ),
          if (mainCategories.isEmpty)
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  const Text('لسا مضيفتش فئات'),
                  8.verticalSpace,
                  ElevatedButton(
                    onPressed: () {
                      context.push(AppRoutes.manageCategoriesScreen);
                    },
                    child: const Text('إدارة الفئات'),
                  ),
                ],
              ),
            )
          else
            ...mainCategories.map((mainCat) {
              return Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: _ExpenseBudgetTile(
                  category: mainCat,
                  plan: plan,
                  isSubCategory: false,
                ),
              );
            }),
          ListTile(
            tileColor: AppColors.primaryColor,
            title: Text(
              'إدارة فئات المصاريف...',
              style: AppTextStyle.style12Bold.copyWith(
                color: AppColors.scaffoldBackgroundLightColor,
              ),
            ),
            leading: Icon(
              Icons.settings,
              size: 18.r,
              color: AppColors.scaffoldBackgroundLightColor,
            ),
            onTap: () => context.push(AppRoutes.manageCategoriesScreen),
          ),
        ],
      ),
    );
  }
}

class _ExpenseBudgetTile extends StatefulWidget {
  const _ExpenseBudgetTile({
    required this.isSubCategory,
    required this.category,
    required this.plan,
  });
  final TransactionCategory category;
  final MonthlyPlan plan;
  final bool isSubCategory;

  @override
  State<_ExpenseBudgetTile> createState() => _ExpenseBudgetTileState();
}

class _ExpenseBudgetTileState extends State<_ExpenseBudgetTile> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _updateControllerText();
  }

  @override
  void didUpdateWidget(covariant _ExpenseBudgetTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.plan != oldWidget.plan ||
        widget.category.id != oldWidget.category.id) {
      _updateControllerText();
    }
  }

  void _updateControllerText() {
    final existingExpense = widget.plan.getExpenseForCategory(
      widget.category.id,
    );
    final amount = existingExpense?.budgetedAmount ?? 0.0;

    final textValue = (amount == amount.truncate())
        ? amount.truncate().toString()
        : amount.toString();

    if (_controller.text != textValue ||
        (textValue == '0' && _controller.text.isEmpty)) {
      _controller.text = textValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateExpenseInCubit(double amount) {
    final newExpense = PlannedExpense(
      categoryId: widget.category.id,
      budgetedAmount: amount,
    );
    final otherExpenses = widget.plan.expenses
        .where((e) => e.categoryId != widget.category.id)
        .toList();

    final updatedExpenses = [...otherExpenses];
    if (amount > 0) {
      updatedExpenses.add(newExpense);
    }

    context.read<MonthlyPlanCubit>().updatePlan(
      widget.plan.copyWith(expenses: updatedExpenses),
    );
  }

  @override
  Widget build(BuildContext context) {
    final transactionState = context.watch<TransactionCubit>().state;
    final planState = context.watch<MonthlyPlanCubit>().state;

    final currentMonth = planState.currentMonth;
    final year = currentMonth.year;
    final month = currentMonth.month;

    final allCategories = transactionState.allCategories;
    final subCategories = allCategories
        .where(
          (c) =>
              c.parentId == widget.category.id &&
              c.type == TransactionType.expense,
        )
        .toList();
    final hasSubCategories = subCategories.isNotEmpty;
    final subCategoryIds = subCategories.map((c) => c.id).toList();

    var budgetedAmount =
        widget.plan.getExpenseForCategory(widget.category.id)?.budgetedAmount ??
        0.0;
    for (final subId in subCategoryIds) {
      budgetedAmount +=
          widget.plan.getExpenseForCategory(subId)?.budgetedAmount ?? 0.0;
    }

    final actualSpentAmount = transactionState.allTransactions
        .where(
          (t) =>
              (t.categoryId == widget.category.id ||
                  subCategoryIds.contains(t.categoryId)) &&
              t.type == TransactionType.expense &&
              t.date.year == year &&
              t.date.month == month,
        )
        .fold(0.0, (sum, t) => sum + t.amount);

    final remainingAmount = budgetedAmount - actualSpentAmount;

    final progressValue = (budgetedAmount > 0)
        ? (actualSpentAmount / budgetedAmount).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: widget.category.color.withAlpha(50),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.r),
          onTap: () {
            if (hasSubCategories) {
              _showSubCategoriesSheet(context, subCategories);
            } else {
              _showEditBudgetSheet(context);
            }
          },
          child: Padding(
            padding: EdgeInsets.all(12.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (widget.isSubCategory) ...[
                      Icon(
                        Icons.subdirectory_arrow_left,
                        size: 16.r,
                        color: AppColors.primaryColor.withAlpha(150),
                      ),
                      4.horizontalSpace,
                    ],
                    CircleAvatar(
                      backgroundColor: widget.category.color,
                      radius: widget.isSubCategory ? 10.r : 15.r,
                    ),
                    8.horizontalSpace,
                    Expanded(
                      child: Text(
                        widget.category.name,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyle.style14Bold.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    if (hasSubCategories && !widget.isSubCategory)
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.forthColor.withAlpha(16),
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: AppColors.forthColor.withAlpha(77),
                          ),
                        ),
                        child: Text(
                          '${budgetedAmount.truncate()} ج.م',
                          style: AppTextStyle.style12W500.copyWith(
                            color: AppColors.forthColor.withAlpha(200),
                          ),
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: () => _showEditBudgetSheet(context),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withAlpha(16),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: AppColors.primaryColor.withAlpha(77),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _controller.text.isEmpty
                                    ? '0'
                                    : '${_controller.text} ج.م',
                                style: AppTextStyle.style12W500.copyWith(
                                  color: AppColors.primaryTextColor,
                                ),
                              ),
                              4.horizontalSpace,
                              Icon(
                                Icons.edit_note,
                                size: 18.r,
                                color: AppColors.primaryColor,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                8.verticalSpace,
                LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: AppColors.secondaryColor,
                  color: widget.category.color,
                  minHeight: 6.h,
                ),
                4.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'صرفت: ${actualSpentAmount.truncate()} ج.م',
                        style: AppTextStyle.style9W400.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        textAlign: TextAlign.end,
                        'باقي: ${remainingAmount.truncate()} ج.م',
                        style: AppTextStyle.style9W400.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                if (hasSubCategories && !widget.isSubCategory) ...[
                  8.verticalSpace,
                  Wrap(
                    spacing: 6.w,
                    runSpacing: 6.h,
                    children: subCategories.map((sub) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: sub.color.withAlpha(20),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: sub.color.withAlpha(80),
                          ),
                        ),
                        child: Text(
                          sub.name,
                          style: AppTextStyle.style9W400.copyWith(
                            color: sub.color.withAlpha(200),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSubCategoriesSheet(
    BuildContext context,
    List<TransactionCategory> subCategories,
  ) {
    showModalBottomSheet<TransactionCategory>(
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      context: context,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.5,
          maxChildSize: 0.9,
          minChildSize: 0.3,
          builder: (_, controller) {
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'الفئات الفرعية لـ ${widget.category.name}',
                        style: AppTextStyle.style16W600,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppColors.secondaryColor),
                Expanded(
                  child: ListView.builder(
                    controller: controller,
                    padding: EdgeInsets.symmetric(vertical: 4.h),
                    itemCount: subCategories.length,
                    itemBuilder: (context, index) {
                      return _ExpenseBudgetTile(
                        category: subCategories[index],
                        plan: widget.plan,
                        isSubCategory: true,
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showEditBudgetSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 20.w,
            right: 20.w,
            top: 20.h,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تعديل ميزانية ${widget.category.name}',
                style: AppTextStyle.style16W600,
              ),
              20.verticalSpace,
              Row(
                children: [
                  Expanded(
                    child: CustomPrimaryTextfield(
                      controller: _controller,
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      text: 'المبلغ',
                    ),
                  ),
                  10.horizontalSpace,
                  IconButton(
                    onPressed: () async {
                      final result = await showDialog<double>(
                        context: context,
                        builder: (_) => CalculatorDialog(
                          initialValue: double.tryParse(_controller.text) ?? 0,
                        ),
                      );
                      if (result != null) {
                        _controller.text = result.truncate().toString();
                      }
                    },
                    icon: Icon(
                      Icons.calculate_outlined,
                      size: 35.r,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
              20.verticalSpace,
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  onPressed: () {
                    final amount = double.tryParse(_controller.text) ?? 0.0;
                    _updateExpenseInCubit(amount);
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text(
                    'حفظ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              20.verticalSpace,
            ],
          ),
        );
      },
    );
  }
}
