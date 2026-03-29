import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/shared_widgets/custom_floating_action_buttom.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/goals/domain/entities/financial_goal.dart';
import 'package:opration/features/goals/presentation/controllers/financial_goal_cubit/financial_goal_cubit.dart';
import 'package:uuid/uuid.dart';

class FinancialGoalsScreen extends StatelessWidget {
  const FinancialGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: PageHeader(
        isLeading: true,
        subTitle: SubTitle(),
        title: 'الأهداف المالية',
        // bottom: Container(
        //   height: 50.h,
        //   decoration: BoxDecoration(
        //     border: Border.all(
        //       color: AppColors.scaffoldBackgroundLightColor,
        //       width: 0.5.w,
        //     ),
        //     borderRadius: BorderRadius.circular(kRadius),
        //   ),
        //   child: TabBar(
        //     indicatorPadding: EdgeInsets.all(3.r),
        //     indicator: BoxDecoration(
        //       borderRadius: BorderRadius.circular(kRadius),
        //       color: AppColors.scaffoldBackgroundLightColor,
        //     ),
        //     indicatorSize: TabBarIndicatorSize.tab,
        //     dividerHeight: 0,
        //     labelColor: AppColors.primaryColor,
        //     unselectedLabelColor: AppColors.scaffoldBackgroundLightColor,
        //     labelStyle: AppTextStyles.style14W600.copyWith(
        //       fontFamily: kPrimaryFont,
        //     ),
        //     unselectedLabelStyle: AppTextStyles.style14W600.copyWith(
        //       fontFamily: kPrimaryFont,
        //     ),
        //     tabs: const [
        //       Tab(text: 'الأهداف'),
        //       Tab(text: 'المشتريات'),
        //       Tab(text: 'الديون'),
        //     ],
        //   ),
        // ),
        // // heightBar: 170.h,
      ),
      body: _GoalsView(),
    );
  }
}

class _GoalsView extends StatelessWidget {
  const _GoalsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<FinancialGoalCubit, FinancialGoalState>(
        builder: (context, state) {
          if (state is FinancialGoalLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FinancialGoalError) {
            return Center(child: Text('فيه غلطة: ${state.message}'));
          }
          if (state is FinancialGoalLoaded) {
            if (state.goals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.wb_incandescent_outlined,
                      size: 36.r,
                      color: AppColors.textGreyColor,
                    ),
                    12.verticalSpace,

                    Text(
                      'مفيش أهداف لسا، ضيف هدف جديد!',
                      style: AppTextStyles.style14W500.copyWith(
                        color: AppColors.textGreyColor,
                      ),
                    ),
                    12.verticalSpace,
                  ],
                ),
              );
            }
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              child: ListView.builder(
                padding: EdgeInsets.all(8.r),
                itemCount: state.goals.length,
                itemBuilder: (context, index) {
                  final goal = state.goals[index];
                  return _GoalCard(goal: goal);
                },
              ),
            );
          }
          return const Center(child: Text('شاشة الأهداف المالية'));
        },
      ),
      floatingActionButton: CustomFloatingActionButton(
        onPressed: () => _showAddEditGoalDialog(context),
        tooltip: 'ضيف هدف جديد',
      ),
    );
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({required this.goal});
  final FinancialGoal goal;

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م',
      decimalDigits: 0,
    );
    final remaining = goal.targetAmount - goal.savedAmount;
    final isCompleted = goal.progress >= 1.0;
    final textStyle = Theme.of(context).textTheme.titleMedium;
    final strikethroughStyle = textStyle?.copyWith(
      decoration: TextDecoration.lineThrough,
      color: Colors.grey,
    );
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 8.h),
      child: Padding(
        padding: EdgeInsets.all(12.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  goal.name,
                  style: isCompleted ? strikethroughStyle : textStyle,
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'add_funds') {
                      _showAddFundsDialog(context, goal);
                    }
                    if (value == 'edit') {
                      _showAddEditGoalDialog(context, goal: goal);
                    }
                    if (value == 'delete') {
                      context.read<FinancialGoalCubit>().deleteGoal(goal.id);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'add_funds',
                      enabled: !isCompleted,
                      child: const Text('ضيف رصيد'),
                    ),
                    const PopupMenuItem(value: 'edit', child: Text('عدّل')),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('مسح', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ],
            ),
            8.verticalSpace,
            Text(
              'تم تجميع ${currencyFormat.format(goal.savedAmount.truncate())} من ${currencyFormat.format(goal.targetAmount.truncate())}',
              style: isCompleted
                  ? const TextStyle(
                      decoration: TextDecoration.lineThrough,
                      color: Colors.grey,
                    )
                  : null,
            ),
            8.verticalSpace,
            LinearProgressIndicator(
              value: goal.progress,
              minHeight: 8.h,
              borderRadius: BorderRadius.circular(4.r),
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(
                isCompleted ? Colors.green : Theme.of(context).primaryColor,
              ),
            ),
            8.verticalSpace,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (!isCompleted)
                  Text(
                    'اتبقى: ${currencyFormat.format(remaining.truncate())}',
                    style: TextStyle(color: Colors.grey.shade600),
                  )
                else
                  const Text(
                    '🎉 حققت هدفك',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                Text(
                  'الهدف: ${DateFormat.yMMMd('ar').format(goal.targetDate)}',
                  style: isCompleted
                      ? TextStyle(
                          decoration: TextDecoration.lineThrough,
                          color: Colors.grey.shade600,
                        )
                      : TextStyle(color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

void _showAddEditGoalDialog(BuildContext context, {FinancialGoal? goal}) {
  final isEditing = goal != null;
  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController(text: goal?.name);
  final targetAmountController = TextEditingController(
    text: isEditing ? goal.targetAmount.truncate().toString() : '',
  );
  final savedAmountController = TextEditingController(
    text: isEditing ? goal.savedAmount.truncate().toString() : '0',
  );
  var targetDate =
      goal?.targetDate ?? DateTime.now().add(const Duration(days: 365));

  showModalBottomSheet<void>(
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    context: context,
    builder: (ctx) {
      return Column(
        children: [
          Text(
            isEditing ? 'عدّل الهدف' : 'ضيف هدف جديد',
            style: AppTextStyles.style16Bold.copyWith(
              color: AppColors.primaryColor,
            ),
          ),
          20.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: StatefulBuilder(
              builder: (context, setState) {
                return Form(
                  key: formKey,
                  child: SingleChildScrollView(
                    child: Column(
                      spacing: 12.h,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomPrimaryTextfield(
                          controller: nameController,
                          text: 'اسم الهدف',
                        ),
                        CustomPrimaryTextfield(
                          controller: targetAmountController,
                          text: 'المبلغ المستهدف',

                          keyboardType: TextInputType.number,
                        ),
                        if (isEditing)
                          CustomPrimaryTextfield(
                            controller: savedAmountController,
                            text: 'المبلغ المدخر حالياً',

                            keyboardType: TextInputType.number,
                          ),

                        ListTile(
                          title: const Text('تاريخ الهدف'),
                          subtitle: Text(
                            DateFormat.yMMMd('ar').format(targetDate),
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: targetDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              setState(() => targetDate = picked);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          30.verticalSpace,
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('إلغاء'),
                ),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final newGoal = FinancialGoal(
                          id: goal?.id ?? getIt<Uuid>().v4(),
                          name: nameController.text,
                          targetAmount: double.parse(
                            targetAmountController.text,
                          ),
                          savedAmount: double.parse(savedAmountController.text),
                          targetDate: targetDate,
                        );

                        if (isEditing) {
                          context.read<FinancialGoalCubit>().updateGoal(
                            newGoal,
                          );
                        } else {
                          context.read<FinancialGoalCubit>().addGoal(newGoal);
                        }
                        Navigator.of(ctx).pop();
                      }
                    },
                    child: const Text('حفظ'),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    },
  );
}

void _showAddFundsDialog(BuildContext context, FinancialGoal goal) {
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();

  showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text('ضيف رصيد لهدف: ${goal.name}'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'المبلغ المراد إضافته',
            ),
            keyboardType: TextInputType.number,
            validator: (v) =>
                v == null || v.isEmpty || double.tryParse(v) == null
                ? 'أدخل مبلغ صحيح'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final amount = double.parse(amountController.text);
                context.read<FinancialGoalCubit>().addFundsToGoal(
                  goal.id,
                  amount,
                );
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('إضافة'),
          ),
        ],
      );
    },
  );
}
