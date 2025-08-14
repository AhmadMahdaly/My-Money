import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/shared_widgets/custom_dropdown_button.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/show_custom_snackbar.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/transactions/domain/entities/monthly_plan.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/cubit/monthly_plan_cubit/monthly_plan_cubit.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/add_category_dialog.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/calculator_dialog.dart';
import 'package:uuid/uuid.dart';

class MonthlyPlanScreen extends StatelessWidget {
  const MonthlyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _MonthlyPlanView();
  }
}

class _MonthlyPlanView extends StatefulWidget {
  const _MonthlyPlanView();

  @override
  State<_MonthlyPlanView> createState() => _MonthlyPlanViewState();
}

class _MonthlyPlanViewState extends State<_MonthlyPlanView> {
  late final MonthlyPlanCubit _monthlyPlanCubit;

  @override
  void initState() {
    super.initState();
    _monthlyPlanCubit = context.read<MonthlyPlanCubit>();

    final transactionCubit = context.read<TransactionCubit>();
    if (transactionCubit.state.allCategories.isEmpty) {
      transactionCubit.loadInitialData();
    }
  }

  @override
  void dispose() {
    _monthlyPlanCubit.saveCurrentPlan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final transactionCubit = context.watch<TransactionCubit>();
    if (transactionCubit.state.allCategories.isEmpty &&
        !transactionCubit.state.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<TransactionCubit>().loadInitialData();
        }
      });
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
        title: const Text('Monthly Financial Plan'),
        actions: [
          BlocBuilder<MonthlyPlanCubit, MonthlyPlanState>(
            builder: (context, state) {
              if (state.status == MonthlyPlanStatus.saving) {
                return Padding(
                  padding: EdgeInsets.all(16.r),
                  child: SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(color: Colors.white),
                  ),
                );
              }
              return IconButton(
                icon: const Icon(Icons.save),
                tooltip: 'Save Plan',
                onPressed: () {
                  _monthlyPlanCubit.saveCurrentPlan();
                  showCustomSnackBar(
                    context,
                    msgColor: AppColors.scaffoldBackgroundLightColor,
                    message: 'Plan saved!',
                  );
                },
              );
            },
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
              if (planState.status == MonthlyPlanStatus.error) {
                return Center(child: Text('Error: ${planState.error}'));
              }
              if (planState.plan == null) {
                return const Center(child: Text('No plan data available.'));
              }

              return Column(
                children: [
                  _MonthSelector(),
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.all(8.r),
                      children: [
                        _SummarySection(plan: planState.plan!),
                        16.verticalSpace,
                        _PlannedIncomeSection(plan: planState.plan!),
                        16.verticalSpace,
                        _PlannedExpensesSection(plan: planState.plan!),
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
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              final prevMonth = DateTime(
                currentMonth.year,
                currentMonth.month - 1,
              );
              cubit.loadPlanForMonth(prevMonth);
            },
          ),
          Text(
            DateFormat.yMMMM().format(currentMonth),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
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
    final existingExpenseCategoryIds = context
        .watch<TransactionCubit>()
        .state
        .allCategories
        .where((c) => c.type == TransactionType.expense)
        .map((c) => c.id)
        .toSet();

    final validPlannedExpenses = plan.expenses.where(
      (p) => existingExpenseCategoryIds.contains(p.categoryId),
    );

    final totalBudgetedExpense = validPlannedExpenses.fold(
      // ignore: prefer_int_literals
      0.0,
      (sum, item) => sum + item.budgetedAmount,
    );

    final projectedSavings = plan.totalPlannedIncome - totalBudgetedExpense;

    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            Text('Plan Summary', style: Theme.of(context).textTheme.titleLarge),
            16.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _SummaryItem(
                  title: 'Income',
                  amount: plan.totalPlannedIncome,
                  color: AppColors.successColor,
                ),
                _SummaryItem(
                  title: 'Expenses',
                  amount: totalBudgetedExpense,
                  color: AppColors.errorColor,
                ),
                _SummaryItem(
                  title: 'Savings',
                  amount: projectedSavings,
                  color: projectedSavings >= 0
                      ? AppColors.primaryColor
                      : AppColors.orangeColor,
                ),
              ],
            ),
          ],
        ),
      ),
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
    return Column(
      children: [
        Text(title, style: AppTextStyles.style16W600),
        4.verticalSpace,
        Text(
          '${amount.truncate()} EGP',
          style: AppTextStyles.style16Bold.copyWith(
            color: color,
          ),
        ),
      ],
    );
  }
}

class _PlannedIncomeSection extends StatelessWidget {
  const _PlannedIncomeSection({required this.plan});
  final MonthlyPlan plan;
  void _deleteIncome(BuildContext context, PlannedIncome incomeToDelete) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
          'Are you sure you want to delete the planned income "${incomeToDelete.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final monthlyPlanCubit = context.read<MonthlyPlanCubit>();
              final updatedIncomes = plan.incomes
                  .where((i) => i.id != incomeToDelete.id)
                  .toList();
              monthlyPlanCubit.updatePlan(
                plan.copyWith(incomes: updatedIncomes),
              );
              ctx.pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _addOrEditIncome(BuildContext context, [PlannedIncome? income]) {
    final monthlyPlanCubit = context.read<MonthlyPlanCubit>();
    final transactionCubit = context.read<TransactionCubit>();

    final incomeCategories = transactionCubit.state.allCategories
        .where((c) => c.type == TransactionType.income)
        .toList();

    if (incomeCategories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add an income category first!')),
      );
      return;
    }

    final amountController = TextEditingController(
      text: income?.amount.truncate().toString() ?? '',
    );
    final selectedDate = income?.date ?? DateTime.now();
    String? selectedCategoryId = incomeCategories
        .firstWhere(
          (cat) => cat.name == income?.name,
          orElse: () => incomeCategories.first,
        )
        .id;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return BlocProvider.value(
          value: monthlyPlanCubit,
          child: StatefulBuilder(
            builder: (context, setDialogState) {
              return AlertDialog(
                title: Row(
                  children: [
                    Text(
                      income == null
                          ? 'Add Planned Income'
                          : 'Edit Planned Income',
                    ),
                    if (income != null)
                      IconButton(
                        icon: Icon(
                          Icons.delete,
                          size: 20.r,
                          color: AppColors.errorColor,
                        ),
                        onPressed: () => _deleteIncome(context, income),
                      )
                    else
                      const SizedBox.shrink(),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomDropdownButtonFormField<String>(
                      value: selectedCategoryId,
                      hintText: 'Category',
                      items: incomeCategories.map((
                        TransactionCategory category,
                      ) {
                        return DropdownMenuItem<String>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedCategoryId = newValue;
                        });
                      },
                    ),
                    6.verticalSpace,
                    CustomPrimaryTextfield(
                      controller: amountController,
                      text: 'Amount',
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => ctx.pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      final amount =
                          double.tryParse(amountController.text) ?? 0.0;
                      final selectedCategory = incomeCategories.firstWhere(
                        (cat) => cat.id == selectedCategoryId,
                      );

                      if (amount <= 0) return;

                      final newIncome = PlannedIncome(
                        id: income?.id ?? sl<Uuid>().v4(),
                        name: selectedCategory.name,
                        amount: amount,
                        date: selectedDate,
                      );

                      List<PlannedIncome> updatedIncomes;
                      if (income == null) {
                        updatedIncomes = [...plan.incomes, newIncome];
                      } else {
                        updatedIncomes = plan.incomes
                            .map((i) => i.id == income.id ? newIncome : i)
                            .toList();
                      }
                      monthlyPlanCubit.updatePlan(
                        plan.copyWith(incomes: updatedIncomes),
                      );
                      ctx.pop();
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            'Planned Income',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          initiallyExpanded: true,
          children: [
            ...plan.incomes.map(
              (income) => ListTile(
                title: Text(income.name),
                subtitle: Text(DateFormat.yMMMd().format(income.date)),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${income.amount.truncate()} EGP', // **FIX: Remove decimal points**
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                onTap: () => _addOrEditIncome(context, income),
              ),
            ),
            ListTile(
              title: const Text('Add Income Source...'),
              leading: const Icon(Icons.add, color: Colors.green),
              onTap: () => _addOrEditIncome(context),
            ),
          ],
        ),
      ),
    );
  }
}

void _showAddExpenseCategoryDialog(BuildContext context) {
  final transactionCubit = context.read<TransactionCubit>();

  showDialog<TransactionCategory>(
    context: context,
    builder: (_) => BlocProvider.value(
      value: transactionCubit,

      child: const AddCategoryDialog(type: TransactionType.expense),
    ),
  ).then((newCategory) {
    if (newCategory != null) {
      transactionCubit.addCategory(newCategory);
    }
  });
}

class _PlannedExpensesSection extends StatelessWidget {
  const _PlannedExpensesSection({required this.plan});
  final MonthlyPlan plan;

  @override
  Widget build(BuildContext context) {
    final expenseCategories = context
        .watch<TransactionCubit>()
        .state
        .allCategories
        .where((c) => c.type == TransactionType.expense)
        .toList();

    return Card(
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            'Budgeted Expenses',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          initiallyExpanded: true,
          children: [
            if (expenseCategories.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('No expense categories found.'),
                    8.verticalSpace,
                    ElevatedButton(
                      onPressed: () {
                        context.push(AppRoutes.manageCategoriesScreen);
                      },
                      child: const Text('Add Expense Category'),
                    ),
                  ],
                ),
              )
            else
              ...expenseCategories.map((category) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: _ExpenseBudgetTile(category: category, plan: plan),
                );
              }),
            ListTile(
              title: const Text('Add Expense Category...'),
              leading: const Icon(Icons.add, color: Colors.red),
              onTap: () => _showAddExpenseCategoryDialog(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseBudgetTile extends StatefulWidget {
  const _ExpenseBudgetTile({required this.category, required this.plan});
  final TransactionCategory category;
  final MonthlyPlan plan;

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
    if (widget.plan != oldWidget.plan) {
      _updateControllerText();
    }
  }

  void _updateControllerText() {
    final existingExpense = widget.plan.getExpenseForCategory(
      widget.category.id,
    );
    final amount = existingExpense?.budgetedAmount ?? 0.0;

    if (amount == amount.truncate()) {
      _controller.text = amount.truncate().toString();
    } else {
      _controller.text = amount.toString();
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
    final updatedExpenses = [...otherExpenses, newExpense];
    context.read<MonthlyPlanCubit>().updatePlan(
      widget.plan.copyWith(expenses: updatedExpenses),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: widget.category.color,
        radius: 15.r,
      ),
      title: Text(widget.category.name),
      trailing: SizedBox(
        width: 150.w,
        child: CustomPrimaryTextfield(
          controller: _controller,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,

          suffix: const Text('\n EGP'),
          prefix: IconButton(
            icon: Icon(Icons.calculate_outlined, size: 20.r),
            onPressed: () async {
              final result = await showDialog<double>(
                context: context,
                builder: (_) => CalculatorDialog(
                  initialValue: double.tryParse(_controller.text) ?? 0.0,
                ),
              );
              if (result != null) {
                _controller.text = result.truncate().toString();
                _updateExpenseInCubit(result);
              }
            },
          ),
          onChanged: (value) {
            final amount = double.tryParse(value) ?? 0.0;
            _updateExpenseInCubit(amount);
          },
        ),
      ),
    );
  }
}
