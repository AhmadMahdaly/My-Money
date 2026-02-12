import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/add_category_dialog.dart';

class ManageCategoriesDrawer extends StatelessWidget {
  const ManageCategoriesDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('إدارة فئاتك', style: AppTextStyles.style20Bold),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          final incomeCategories = state.allCategories
              .where((c) => c.type == TransactionType.income)
              .toList();
          final expenseCategories = state.allCategories
              .where((c) => c.type == TransactionType.expense)
              .toList();

          return ListView(
            children: [
              ListTile(
                leading: Icon(
                  Icons.add,
                  color: AppColors.primaryColor,
                  size: 22.r,
                ),
                title: Text(
                  'ضيف فئة جديدة...',
                  style: AppTextStyles.style14W300.copyWith(
                    color: AppColors.primaryColor,
                  ),
                ),
                onTap: () => _showAddTypeSelectionDialog(context),
              ),
              const Divider(),
              _CategoryListSection(
                title: 'فئات الدخل',
                categories: incomeCategories,
              ),
              const Divider(),
              _CategoryListSection(
                title: 'فئات الصرف',
                categories: expenseCategories,
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddTypeSelectionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اختار نوع الفئة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('دخل (Income)'),
              onTap: () {
                Navigator.pop(ctx);
                _openCategoryDialog(context, TransactionType.income);
              },
            ),
            ListTile(
              title: const Text('صرف (Expense)'),
              onTap: () {
                Navigator.pop(ctx);
                _openCategoryDialog(context, TransactionType.expense);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _openCategoryDialog(
    BuildContext context,
    TransactionType type, [
    TransactionCategory? category,
  ]) {
    showDialog<TransactionCategory>(
      context: context,
      builder: (_) => AddCategoryDialog(
        type: type,
        categoryToEdit: category,
      ),
    ).then((result) {
      if (result != null) {
        if (category == null) {
          context.read<TransactionCubit>().addCategory(result);
        } else {
          context.read<TransactionCubit>().updateCategory(result);
        }
      }
    });
  }
}

class _CategoryListSection extends StatelessWidget {
  const _CategoryListSection({required this.title, required this.categories});
  final String title;
  final List<TransactionCategory> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.r),
          child: Text(title, style: AppTextStyles.style16W600),
        ),
        ...categories.map(
          (category) => ListTile(
            leading: CircleAvatar(
              backgroundColor: category.color,
              radius: 12.r,
              child: category.isRecurring
                  ? const Icon(Icons.refresh, size: 12, color: Colors.white)
                  : null,
            ),
            title: Text(category.name),
            subtitle: category.isRecurring
                ? Text(
                    'مكرر: ${category.fixedAmount?.truncate()} ج.م',
                    style: AppTextStyles.style10W400,
                  )
                : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit_outlined, size: 20.r),
                  onPressed: () {
                    // هنا نقوم باستدعاء الديالوج الجديد للتعديل
                    showDialog<TransactionCategory>(
                      context: context,
                      builder: (_) => AddCategoryDialog(
                        type: category.type,
                        categoryToEdit: category,
                      ),
                    ).then((updated) {
                      if (updated != null) {
                        context.read<TransactionCubit>().updateCategory(
                          updated,
                        );
                      }
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20.r,
                    color: AppColors.errorColor,
                  ),
                  onPressed: () => _confirmDelete(context, category),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context, TransactionCategory category) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('حذف الفئة؟'),
        content: Text(
          'سيتم حذف "${category.name}" وجميع العمليات المرتبطة بها.',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<TransactionCubit>().deleteCategory(category.id);
              context.pop();
            },
            child: const Text(
              'حذف',
              style: TextStyle(color: AppColors.errorColor),
            ),
          ),
        ],
      ),
    );
  }
}
