import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/shared_widgets/custom_floating_action_buttom.dart';
import 'package:opration/core/shared_widgets/svg_image_widget.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/financial_goals/domain/entities/financial_goal.dart';
import 'package:opration/features/financial_goals/presentation/cubit/financial_goal_cubit.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/welcome_user_widget.dart';
import 'package:uuid/uuid.dart';

class FinancialGoalsScreen extends StatelessWidget {
  const FinancialGoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageHeader(),
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
              return const Center(
                child: Text('مفيش أهداف لسا، ضيف هدف جديد!'),
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
    final currencyFormat = NumberFormat.compactCurrency(
      locale: 'ar_EG',
      symbol: 'ج.م',
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
              'تم تجميع ${currencyFormat.format(goal.savedAmount)} من ${currencyFormat.format(goal.targetAmount)}',
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
                    'اتبقى: ${currencyFormat.format(remaining)}',
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
    text: isEditing ? goal.targetAmount.toString() : '',
  );
  final savedAmountController = TextEditingController(
    text: isEditing ? goal.savedAmount.toString() : '0',
  );
  var targetDate =
      goal?.targetDate ?? DateTime.now().add(const Duration(days: 365));

  showDialog<void>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(
          isEditing ? 'عدّل الهدف' : 'ضيف هدف جديد',
          style: AppTextStyles.style16Bold,
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  spacing: 12.h,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'اسم الهدف'),
                    ),
                    TextFormField(
                      controller: targetAmountController,
                      decoration: const InputDecoration(
                        labelText: 'المبلغ المستهدف',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    if (isEditing)
                      TextFormField(
                        controller: savedAmountController,
                        decoration: const InputDecoration(
                          labelText: 'المبلغ المدخر حالياً',
                        ),
                        keyboardType: TextInputType.number,
                      ),

                    ListTile(
                      title: const Text('تاريخ الهدف'),
                      subtitle: Text(DateFormat.yMMMd('ar').format(targetDate)),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: targetDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) setState(() => targetDate = picked);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                final newGoal = FinancialGoal(
                  id: goal?.id ?? getIt<Uuid>().v4(),
                  name: nameController.text,
                  targetAmount: double.parse(targetAmountController.text),
                  savedAmount: double.parse(savedAmountController.text),
                  targetDate: targetDate,
                );

                if (isEditing) {
                  context.read<FinancialGoalCubit>().updateGoal(newGoal);
                } else {
                  context.read<FinancialGoalCubit>().addGoal(newGoal);
                }
                Navigator.of(ctx).pop();
              }
            },
            child: const Text('حفظ'),
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

class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  const PageHeader({super.key});

  @override
  Size get preferredSize => Size.fromHeight(90.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        right: 16.w,
        left: 16.w,
        bottom: 10.h,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, -0),
          end: Alignment(0.50, 1),
          colors: [AppColors.primaryColor, AppColors.secondaryTextColor],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const WelcomeUserWidget(),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgImage(
                    imagePath: 'assets/image/svg/quote-1.svg',
                    height: 14.h,
                  ),
                  4.horizontalSpace,
                  Text(
                    'ما تفعله الآن هو ما تجني ثماره في الغد',
                    style: AppTextStyles.style14W400.copyWith(
                      color: AppColors.scaffoldBackgroundLightColor,
                    ),
                  ),
                  4.horizontalSpace,
                  SvgImage(
                    imagePath: 'assets/image/svg/quote-1.svg',
                    height: 14.h,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
