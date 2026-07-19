import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/services/format_currency.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/add_category_widget.dart';
import 'package:uuid/uuid.dart';

class ManageCategoriesDrawer extends StatelessWidget {
  const ManageCategoriesDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const PageHeader(
        isLeading: true,
        title: 'إدارة الفئات',
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          final excludedCategories = [
            'رصيد افتتاحي',
            'تحويل وارد',
            'تحويل صادر',
          ];

          final incomeCategories = state.allCategories
              .where(
                (c) =>
                    c.type == TransactionType.income &&
                    !excludedCategories.contains(c.name),
              )
              .toList();

          final expenseCategories = state.allCategories
              .where(
                (c) =>
                    c.type == TransactionType.expense &&
                    !excludedCategories.contains(c.name),
              )
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
              60.verticalSpace,
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

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
        titleTextStyle: AppTextStyle.style18W600,
        title: Text(
          textAlign: TextAlign.center,
          'اختار نوع الفئة',
          style: AppTextStyle.style16W700.copyWith(
            color: AppColors.forthColor,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                CupertinoIcons.add_circled,
                color: AppColors.successColor,
              ),
              title: Text(
                'فئة دخل',
                style: AppTextStyle.style14W500.copyWith(
                  color: AppColors.successColor,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _openCategoryDialog(context, TransactionType.income);
              },
            ),
            ListTile(
              leading: const Icon(
                CupertinoIcons.minus_circle,
                color: AppColors.errorColor,
              ),
              title: Text(
                'فئة صرف',
                style: AppTextStyle.style14W500.copyWith(
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
          child: Text(title, style: AppTextStyle.style16Bold),
        ),
        ...mainCategories.map((mainCat) {
          final subCategories = categories
              .where((c) => c.parentId == mainCat.id)
              .toList();

          return Theme(
            data: Theme.of(
              context,
            ).copyWith(dividerColor: AppColors.primaryColor.withAlpha(15)),
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
                style: AppTextStyle.style14W500,
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
                        style: AppTextStyle.style12W400,
                      ),
                      subtitle: subCat.isRecurring
                          ? Text(
                              'مكرر: ${formatCurrency(subCat.fixedAmount != null ? subCat.fixedAmount! : 0)} $appCurrencySymbol',
                              style: AppTextStyle.style9W400,
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
                      style: AppTextStyle.style12W300.copyWith(
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
