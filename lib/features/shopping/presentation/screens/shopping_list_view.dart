// ignore_for_file: deprecated_member_use

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/page_header.dart';
import 'package:opration/core/shared_widgets/show_custom_snackbar.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/shopping/domain/entities/shopping_item.dart';
import 'package:opration/features/shopping/presentation/controllers/shopping_cubit/shopping_cubit.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/controllers/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';
import 'package:uuid/uuid.dart';

class ShoppingListView extends StatelessWidget {
  const ShoppingListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ShoppingCubit, ShoppingState>(
      builder: (context, state) {
        final activeItems = state.items.where((i) => !i.isBought).toList();
        final boughtItems = state.items.where((i) => i.isBought).toList();

        final categoryTotals = <String, double>{};
        for (final item in activeItems) {
          final catId = item.categoryId ?? 'unknown';
          categoryTotals[catId] =
              (categoryTotals[catId] ?? 0) + item.expectedPrice;
        }
        return Scaffold(
          appBar: const PageHeader(
            isLeading: true,
            subTitle: SubTitle(),
            title: 'قائمة المشتريات',
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,

          floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primaryColor,
            onPressed: () => _showAddShoppingItemDialog(context),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(320.r),
            ),
            child: const Icon(Icons.add, color: Colors.white),
          ),
          body: Column(
            children: [
              if (categoryTotals.isNotEmpty)
                Padding(
                  padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.bar_chart,
                            color: AppColors.primaryColor,
                            size: 20.r,
                          ),
                          8.horizontalSpace,
                          Text(
                            'إجمالي المشتريات بالفئات:',
                            style: AppTextStyle.style14W600,
                          ),
                        ],
                      ),
                      12.verticalSpace,
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: categoryTotals.keys.map((catId) {
                            return _buildStatCard(
                              context,
                              catId,
                              categoryTotals[catId]!,
                            );
                          }).toList(),
                        ),
                      ),
                      16.verticalSpace,
                      const Divider(height: 1),
                    ],
                  ),
                ),

              Expanded(
                child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 8.r),
                        child: Text(
                          'حاجات ناوي تشتريها:',
                          style: AppTextStyle.style16W600,
                        ),
                      ),
                    ),

                    if (activeItems.isEmpty)
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 200.h,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                CupertinoIcons.shopping_cart,
                                size: 40.r,
                                color: AppColors.textGreyColor.withAlpha(100),
                              ),
                              12.verticalSpace,
                              Text(
                                'مفيش حاجات مسجلها حالياً.',
                                style: AppTextStyle.style14W400.copyWith(
                                  color: AppColors.textGreyColor.withAlpha(100),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      SliverReorderableList(
                        itemCount: activeItems.length,
                        onReorder: (oldIndex, newIndex) {
                          context.read<ShoppingCubit>().reorderShoppingItems(
                            oldIndex,
                            newIndex,
                            List.from(activeItems),
                          );
                        },
                        itemBuilder: (context, index) {
                          final item = activeItems[index];
                          return ReorderableDelayedDragStartListener(
                            key: ValueKey(item.id),
                            index: index,
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16.r,
                                vertical: 4.r,
                              ),
                              child: _buildItemTile(context, item),
                            ),
                          );
                        },
                      ),

                    if (boughtItems.isNotEmpty)
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              24.verticalSpace,
                              Text(
                                'تم شراؤها (نزلت في المعاملات):',
                                style: AppTextStyle.style14W600.copyWith(
                                  color: AppColors.textGreyColor,
                                ),
                              ),
                              const Divider(),
                              ...boughtItems.map(
                                (item) => Padding(
                                  padding: EdgeInsets.only(bottom: 8.r),
                                  child: _buildItemTile(context, item),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    SliverToBoxAdapter(
                      child: 80.verticalSpace,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String categoryId, double total) {
    final categories = context.read<TransactionCubit>().state.allCategories;
    final category = categories.where((c) => c.id == categoryId).firstOrNull;

    final categoryName = category?.name ?? 'غير محدد';
    final categoryColor = category != null
        ? category.color
        : AppColors.textGreyColor;

    return Container(
      width: 140.w,
      margin: EdgeInsets.only(left: 12.w),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: categoryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: categoryColor.withValues(alpha: 0.5)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  categoryName,
                  style: AppTextStyle.style12W600.copyWith(
                    color: AppColors.primaryTextColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            '${total.truncate()} $appCurrencySymbol',
            style: AppTextStyle.style16W600.copyWith(
              color: categoryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, ShoppingItem item) {
    final categories = context.read<TransactionCubit>().state.allCategories;
    final itemCategory = categories
        .where((c) => c.id == item.categoryId)
        .firstOrNull;

    var cardColor = Colors.white;
    if (itemCategory != null) {
      cardColor = itemCategory.color.withValues(alpha: 0.15);
    }
    if (item.isBought) {
      cardColor = Colors.grey.shade100;
    }

    return Card(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(
          color: itemCategory != null
              ? itemCategory.color
              : Colors.grey.shade300,
        ),
      ),
      child: ListTile(
        leading: Checkbox(
          value: item.isBought,
          onChanged: item.isBought
              ? null
              : (val) {
                  if (val ?? false) {
                    _showPurchaseConfirmDialog(
                      context,
                      item,
                      context.read<ShoppingCubit>(),
                    );
                  }
                },
        ),
        title: Text(
          item.name,
          style: TextStyle(
            decoration: item.isBought ? TextDecoration.lineThrough : null,
            color: item.isBought ? Colors.grey : AppColors.primaryTextColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'المتوقع: ${item.expectedPrice.truncate()} $appCurrencySymbol',
          style: TextStyle(
            decoration: item.isBought ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete,
            color: Colors.red,
            size: 20.r,
          ),
          onPressed: () => _showDeleteConfirmationDialog(context, item),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, ShoppingItem item) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text(
          'هل أنت متأكد أنك تريد مسح "${item.name}" من القائمة؟',
          style: AppTextStyle.style14W400,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              context.read<ShoppingCubit>().deleteItem(item.id);
              Navigator.pop(ctx);
              showCustomSnackBar(message: 'تم المسح بنجاح');
            },
            child: const Text('مسح', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddShoppingItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final allExpenseCategories = context
        .read<TransactionCubit>()
        .state
        .allCategories
        .where((c) => c.type == TransactionType.expense)
        .toList();

    final mainCategories = allExpenseCategories
        .where((c) => c.parentId == null)
        .toList();

    String? selectedMainCategoryId;
    String? selectedSubCategoryId;

    showModalBottomSheet<void>(
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(
                ctx,
              ).viewInsets.bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ضيف حاجة عايز تشتريها',
                  style: AppTextStyle.style14W600,
                ),
                20.verticalSpace,
                Form(
                  key: formKey,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomPrimaryTextfield(
                          autofocus: true,
                          controller: nameController,
                          textInputAction: TextInputAction.next,
                          text: 'اسم الحاجة (لاب توب، هدوم...)',
                          validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                        ),
                        12.verticalSpace,
                        CustomPrimaryTextfield(
                          controller: priceController,
                          text: 'المبلغ المتوقع',
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.number,
                          validator: (v) => v!.isEmpty ? 'مطلوب' : null,
                        ),
                        16.verticalSpace,
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'يندرج تحت فئة (الرئيسية):',
                          ),
                          items: mainCategories
                              .map(
                                (c) => DropdownMenuItem<String>(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              selectedMainCategoryId = v;
                              selectedSubCategoryId = null;
                            });
                          },
                          validator: (v) =>
                              v == null ? 'مطلوب تحديد الفئة' : null,
                        ),
                        ...(() {
                          final subCategories = selectedMainCategoryId != null
                              ? allExpenseCategories
                                    .where(
                                      (c) =>
                                          c.parentId == selectedMainCategoryId,
                                    )
                                    .toList()
                              : <TransactionCategory>[];

                          if (subCategories.isNotEmpty) {
                            return [
                              16.verticalSpace,
                              DropdownButtonFormField(
                                decoration: const InputDecoration(
                                  labelText: 'الفئة الفرعية (اختياري):',
                                ),
                                initialValue: selectedSubCategoryId,
                                items: subCategories
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(c.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  setState(() {
                                    selectedSubCategoryId = v.toString();
                                  });
                                },
                              ),
                            ];
                          }
                          return [const SizedBox.shrink()];
                        }()),
                      ],
                    ),
                  ),
                ),
                16.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Row(
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: const Text('إلغاء'),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (formKey.currentState!.validate()) {
                              final finalCategoryId =
                                  selectedSubCategoryId ??
                                  selectedMainCategoryId;
                              final newItem = ShoppingItem(
                                id: const Uuid().v4(),
                                name: nameController.text,
                                expectedPrice: double.parse(
                                  priceController.text,
                                ),
                                categoryId: finalCategoryId,
                              );
                              context.read<ShoppingCubit>().addItem(newItem);
                              Navigator.pop(ctx);
                            }
                          },
                          child: const Text('إضافة'),
                        ),
                      ),
                    ],
                  ),
                ),
                16.verticalSpace,
              ],
            ),
          );
        },
      ),
    );
  }

  void _showPurchaseConfirmDialog(
    BuildContext context,
    ShoppingItem item,
    ShoppingCubit shoppingCubit,
  ) {
    final actualPriceController = TextEditingController(
      text: item.expectedPrice.toString(),
    );

    final wallets = (context.read<WalletCubit>().state as WalletLoaded).wallets;

    final allExpenseCategories = context
        .read<TransactionCubit>()
        .state
        .allCategories
        .where((c) => c.type == TransactionType.expense)
        .toList();

    final mainCategories = allExpenseCategories
        .where((c) => c.parentId == null)
        .toList();

    String? selectedWalletId;
    String? selectedMainCategoryId;
    String? selectedSubCategoryId;

    if (item.categoryId != null) {
      final preSelectedCat = allExpenseCategories
          .where((c) => c.id == item.categoryId)
          .firstOrNull;
      if (preSelectedCat != null) {
        if (preSelectedCat.parentId != null) {
          selectedSubCategoryId = preSelectedCat.id;
          selectedMainCategoryId = preSelectedCat.parentId;
        } else {
          selectedMainCategoryId = preSelectedCat.id;
        }
      }
    }

    showModalBottomSheet<void>(
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return Column(
            children: [
              Text(
                'ألف مبروك! سجلها في مصاريفك',
                style: AppTextStyle.style14W600,
              ),
              20.verticalSpace,
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,

                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          textAlign: TextAlign.start,
                          'اشتريت "${item.name}" بكام فعلياً؟',
                          style: AppTextStyle.style12W600.copyWith(
                            color: AppColors.forthColor,
                          ),
                        ),
                        16.verticalSpace,
                        CustomPrimaryTextfield(
                          controller: actualPriceController,
                          text: 'المبلغ الفعلي',
                          keyboardType: TextInputType.number,
                        ),
                        16.verticalSpace,
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'اتخصمت من أي محفظة؟',
                          ),
                          items: wallets
                              .map(
                                (w) => DropdownMenuItem(
                                  value: w.id,
                                  child: Text(w.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => selectedWalletId = v),
                        ),
                        16.verticalSpace,

                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'سجلها تحت فئة (الرئيسية):',
                          ),
                          initialValue: selectedMainCategoryId,
                          items: mainCategories
                              .map(
                                (c) => DropdownMenuItem<String>(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              selectedMainCategoryId = v;
                              selectedSubCategoryId = null;
                            });
                          },
                        ),

                        ...(() {
                          final subCategories = selectedMainCategoryId != null
                              ? allExpenseCategories
                                    .where(
                                      (c) =>
                                          c.parentId == selectedMainCategoryId,
                                    )
                                    .toList()
                              : <TransactionCategory>[];

                          if (subCategories.isNotEmpty) {
                            final isSubCatValid = subCategories.any(
                              (c) => c.id == selectedSubCategoryId,
                            );
                            final initialSubCat = isSubCatValid
                                ? selectedSubCategoryId
                                : null;

                            return [
                              16.verticalSpace,
                              DropdownButtonFormField(
                                decoration: const InputDecoration(
                                  labelText: 'الفئة الفرعية (اختياري):',
                                ),
                                initialValue: initialSubCat,
                                items: subCategories
                                    .map(
                                      (c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(c.name),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  setState(() {
                                    selectedSubCategoryId = v.toString();
                                  });
                                },
                              ),
                            ];
                          }
                          return [
                            const SizedBox.shrink(),
                          ];
                        }()),
                        30.verticalSpace,
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('إلغاء'),
                            ),
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  final finalCategoryId =
                                      selectedSubCategoryId ??
                                      selectedMainCategoryId;

                                  if (selectedWalletId == null ||
                                      finalCategoryId == null) {
                                    showCustomSnackBar(
                                      message: 'لازم تختار المحفظة والفئة',
                                      isError: true,
                                    );
                                    return;
                                  }

                                  final actualPrice =
                                      double.tryParse(
                                        actualPriceController.text,
                                      ) ??
                                      item.expectedPrice;

                                  final transaction = Transaction(
                                    id: const Uuid().v4(),
                                    amount: actualPrice,
                                    categoryId: finalCategoryId,
                                    date: DateTime.now(),
                                    type: TransactionType.expense,
                                    walletId: selectedWalletId!,
                                    note: 'مشتريات مخططة: ${item.name}',
                                  );

                                  context
                                      .read<TransactionCubit>()
                                      .addTransaction(transaction);
                                  context
                                      .read<WalletCubit>()
                                      .updateWalletBalance(
                                        selectedWalletId!,
                                        -actualPrice,
                                      );
                                  shoppingCubit.markAsBought(item.id);

                                  Navigator.pop(ctx);
                                  showCustomSnackBar(
                                    message: 'تم الشراء وتسجيل المصروف بنجاح!',
                                  );
                                },
                                child: const Text('تأكيد وتسجيل'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
