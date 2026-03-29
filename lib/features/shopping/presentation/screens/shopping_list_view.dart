import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opration/core/di.dart';
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
    return BlocProvider.value(
      value: getIt<ShoppingCubit>(),

      child: BlocBuilder<ShoppingCubit, ShoppingState>(
        builder: (context, state) {
          final activeItems = state.items.where((i) => !i.isBought).toList();
          final boughtItems = state.items.where((i) => i.isBought).toList();

          return Scaffold(
            appBar: const PageHeader(
              isLeading: true,
              subTitle: SubTitle(),
              title: 'قائمة المشتريات',
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
            floatingActionButton: FloatingActionButton(
              backgroundColor: AppColors.primaryColor,
              onPressed: () => _showAddShoppingItemDialog(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(320.r),
              ),
              child: const Icon(Icons.add, color: Colors.white),
            ),
            body: ListView(
              padding: EdgeInsets.all(16.r),
              children: [
                Text('حاجات ناوي تشتريها:', style: AppTextStyles.style16W600),
                8.verticalSpace,
                if (activeItems.isEmpty) ...[
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.r),
                        child: SizedBox(
                          height: SizeConfig.screenHeight / 1.5,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.wysiwyg_rounded,
                                size: 36.r,
                                color: AppColors.textGreyColor,
                              ),
                              12.verticalSpace,
                              Center(
                                child: Text(
                                  'مفيش حاجات مسجلها حالياً.',
                                  style: AppTextStyles.style14W500.copyWith(
                                    color: AppColors.textGreyColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else
                  ...activeItems.map((item) => _buildItemTile(context, item)),

                if (boughtItems.isNotEmpty) ...[
                  24.verticalSpace,
                  Text(
                    'تم شراؤها (نزلت في المعاملات):',
                    style: AppTextStyles.style14W600.copyWith(
                      color: AppColors.textGreyColor,
                    ),
                  ),
                  const Divider(),
                  ...boughtItems.map((item) => _buildItemTile(context, item)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildItemTile(BuildContext context, ShoppingItem item) {
    return Card(
      elevation: 0,
      color: item.isBought ? Colors.grey.shade100 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.r),
        side: BorderSide(color: Colors.grey.shade300),
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
          'المتوقع: ${item.expectedPrice.truncate()} ج.م',
          style: TextStyle(
            decoration: item.isBought ? TextDecoration.lineThrough : null,
          ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline, color: Colors.red),
          onPressed: () => context.read<ShoppingCubit>().deleteItem(item.id),
        ),
      ),
    );
  }

  void _showAddShoppingItemDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet<void>(
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      context: context,
      builder: (ctx) => Column(
        children: [
          Text(
            'ضيف حاجة عايز تشتريها',
            style: AppTextStyles.style14W600,
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
                        final newItem = ShoppingItem(
                          id: const Uuid().v4(),
                          name: nameController.text,
                          expectedPrice: double.parse(priceController.text),
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
        ],
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
                style: AppTextStyles.style14W600,
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
                          style: AppTextStyles.style12W600.copyWith(
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
                                      context,
                                      message: 'لازم تختار المحفظة والفئة',
                                      backgroundColor: Colors.red,
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
                                      .addTransaction(
                                        transaction,
                                      );
                                  context
                                      .read<WalletCubit>()
                                      .updateWalletBalance(
                                        selectedWalletId!,
                                        -actualPrice,
                                      );

                                  shoppingCubit.markAsBought(
                                    item.id,
                                  );

                                  Navigator.pop(ctx);
                                  showCustomSnackBar(
                                    context,
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
