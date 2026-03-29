import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/add_category_dialog.dart';
import 'package:uuid/uuid.dart';

class ManageCategoriesDrawer extends StatelessWidget {
  const ManageCategoriesDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageHeader(
        isLeading: true,
        title: 'إدارة فئاتك',
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        onPressed: () => _showAddTypeSelectionDialog(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(320.r),
        ),
        child: const Icon(
          Icons.add,
          color: AppColors.scaffoldBackgroundLightColor,
        ),
      ),
    );
  }

  void _showAddTypeSelectionDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        titleTextStyle: AppTextStyles.style18W600,
        title: Text(
          textAlign: TextAlign.center,
          'اختار نوع الفئة',
          style: AppTextStyles.style14W500.copyWith(
            color: AppColors.primaryColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.add, color: AppColors.successColor),
              title: Text(
                'دخل (Income)',
                style: AppTextStyles.style14W500.copyWith(
                  color: AppColors.successColor,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _openCategoryDialog(context, TransactionType.income);
              },
            ),
            ListTile(
              leading: const Icon(Icons.minimize, color: AppColors.errorColor),
              title: Text(
                'صرف (Expense)',
                style: AppTextStyles.style14W500.copyWith(
                  color: AppColors.errorColor,
                ),
              ),
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
    showModalBottomSheet<TransactionCategory>(
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      context: context,
      builder: (_) => AddCategoryWidget(
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
    final mainCategories = categories.where((c) => c.parentId == null).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.r),
          child: Text(title, style: AppTextStyles.style16Bold),
        ),
        ...mainCategories.map((mainCat) {
          final subCategories = categories
              .where((c) => c.parentId == mainCat.id)
              .toList();

          return Theme(
            data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
            child: ExpansionTile(
              initiallyExpanded: subCategories.isNotEmpty,
              leading: CircleAvatar(
                backgroundColor: mainCat.color,
                radius: 14.r,
                child: mainCat.isRecurring
                    ? const Icon(Icons.refresh, size: 12, color: Colors.white)
                    : null,
              ),
              title: Text(
                mainCat.name,
                style: AppTextStyles.style14W500,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit_outlined, size: 20.r),
                    onPressed: () => _editCategory(context, mainCat),
                  ),
                ],
              ),

              children: [
                ...subCategories.map(
                  (subCat) => Padding(
                    padding: EdgeInsets.only(
                      right: 32.w,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: subCat.color,
                        radius: 8.r,
                      ),
                      title: Text(
                        subCat.name,
                        style: AppTextStyles.style12W400,
                      ),
                      subtitle: subCat.isRecurring
                          ? Text(
                              'مكرر: ${subCat.fixedAmount?.truncate()} ج.م',
                              style: AppTextStyles.style9W400,
                            )
                          : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit_outlined, size: 16.r),
                            onPressed: () => _editCategory(context, subCat),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(right: 32.w, bottom: 8.h),
                  child: ListTile(
                    leading: Icon(
                      Icons.add_circle_outline,
                      color: mainCat.color,
                      size: 18.r,
                    ),
                    title: Text(
                      'إضافة تفريعة لـ "${mainCat.name}"',
                      style: AppTextStyles.style12W300.copyWith(
                        color: mainCat.color,
                      ),
                    ),
                    onTap: () => showAddSubCategoryDialog(context, mainCat),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void showAddSubCategoryDialog(
    BuildContext context,
    TransactionCategory parentCategory,
  ) {
    final dummyCategoryForParent = TransactionCategory(
      id: '',
      name: '',
      colorValue: parentCategory.colorValue,
      type: parentCategory.type,
      parentId: parentCategory.id,
    );

    showModalBottomSheet<TransactionCategory>(
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      context: context,
      builder: (_) => AddCategoryWidget(
        type: parentCategory.type,

        categoryToEdit: dummyCategoryForParent,
      ),
    ).then((result) {
      if (result != null) {
        final newSubCategory = result.copyWith(id: const Uuid().v4());
        context.read<TransactionCubit>().addCategory(newSubCategory);
      }
    });
  }

  void _editCategory(BuildContext context, TransactionCategory category) {
    showModalBottomSheet<TransactionCategory>(
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      context: context,
      builder: (_) => AddCategoryWidget(
        type: category.type,
        categoryToEdit: category,
      ),
    ).then((updated) {
      if (updated != null) {
        context.read<TransactionCubit>().updateCategory(updated);
      }
    });
  }
}
