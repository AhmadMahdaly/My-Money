import 'dart:ui' as ui;

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/shared_widgets/custom_primary_button.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/show_custom_snackbar.dart';
import 'package:opration/core/shared_widgets/svg_image_widget.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit/transactions_cubit.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/add_category_dialog.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/category_selector.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/welcome_user_widget.dart';
import 'package:opration/features/wallets/domain/entities/wallet.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: PageHeader(
          isLeading: false,
        ),
        body: TabBarView(
          children: [
            _TransactionForm(type: TransactionType.expense),
            _TransactionForm(type: TransactionType.income),
          ],
        ),
        bottomNavigationBar: AppBottomBar(),
      ),
    );
  }
}

class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  const PageHeader({required this.isLeading, super.key});
  final bool isLeading;

  @override
  Size get preferredSize => Size.fromHeight(150.h);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, walletState) {
        var showMainWallet = true;
        Wallet? mainWallet;

        if (walletState is WalletLoaded) {
          showMainWallet = walletState.showMainWallet;
          if (walletState.wallets.isNotEmpty) {
            mainWallet = walletState.wallets.firstWhere(
              (w) => w.isMain,
              orElse: () => walletState.wallets.first,
            );
          }
        }

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
                  WelcomeUserWidget(
                    isLeading: isLeading,
                    title: 'مصاريفك وفلوسك',
                  ),
                ],
              ),
              if (walletState is WalletLoaded && mainWallet != null)
                Expanded(
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.white.withAlpha(0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: SvgImage(
                            imagePath: 'assets/image/svg/change_wallet.svg',
                            height: 20.r,
                            color: AppColors.cardColor,
                          ),

                          onPressed: () {
                            _showChangeMainWalletDialog(
                              context,
                              walletState.wallets,
                              mainWallet!.id,
                            );
                          },
                          tooltip: 'تغيير المحفظة الرئيسية',
                        ),

                        ImageFiltered(
                          imageFilter: ui.ImageFilter.blur(
                            sigmaX: showMainWallet ? 0 : 4.0,
                            sigmaY: showMainWallet ? 0 : 4.0,
                          ),
                          child: Text(
                            showMainWallet
                                ? 'محفظتك: ${mainWallet.name} (${mainWallet.balance.truncate()} ج.م)'
                                : 'محفظتك: ${mainWallet.name} (****** ج.م)',
                            style: AppTextStyles.style16W500.copyWith(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            showMainWallet
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,

                            color: AppColors.cardColor,
                            size: 24.r,
                          ),
                          onPressed: () {
                            context
                                .read<WalletCubit>()
                                .toggleShowMainWalletPref();
                          },
                          tooltip: 'إخفاء المحفظة',
                        ),
                      ],
                    ),
                  ),
                )
              else
                const Spacer(),

              Container(
                height: 50.h,

                decoration: BoxDecoration(
                  border: Border.all(
                    color: AppColors.scaffoldBackgroundLightColor,
                    width: 0.5.w,
                  ),
                  borderRadius: BorderRadius.circular(kRadius),
                ),
                child: TabBar(
                  indicatorPadding: EdgeInsets.all(3.r),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(kRadius),
                    color: AppColors.scaffoldBackgroundLightColor,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 0,
                  labelColor: AppColors.primaryColor,
                  unselectedLabelColor: AppColors.scaffoldBackgroundLightColor,
                  labelStyle: AppTextStyles.style14W600.copyWith(
                    fontFamily: kPrimaryFont,
                  ),
                  unselectedLabelStyle: AppTextStyles.style14W600.copyWith(
                    fontFamily: kPrimaryFont,
                  ),
                  tabs: const [
                    Tab(text: 'مصاريف'),
                    Tab(text: 'فلوس داخلة'),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void _showChangeMainWalletDialog(
  BuildContext context,
  List<Wallet> wallets,
  String currentMainWalletId,
) {
  showDialog<void>(
    context: context,
    builder: (ctx) {
      String? selectedWalletId = currentMainWalletId;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('تغيير المحفظة الرئيسية'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: wallets.length,
                itemBuilder: (context, index) {
                  final wallet = wallets[index];
                  return RadioListTile<String>(
                    title: Text(wallet.name),
                    subtitle: Text('${wallet.balance.truncate()} ج.م'),
                    value: wallet.id,
                    groupValue: selectedWalletId,
                    onChanged: (value) {
                      setState(() {
                        selectedWalletId = value;
                      });
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (selectedWalletId != null &&
                      selectedWalletId != currentMainWalletId) {
                    context.read<WalletCubit>().setMainWallet(
                      selectedWalletId!,
                    );
                  }
                  Navigator.of(ctx).pop();
                },
                child: const Text('حفظ'),
              ),
            ],
          );
        },
      );
    },
  );
}

class _TransactionForm extends StatefulWidget {
  const _TransactionForm({
    required this.type,
  });

  final TransactionType type;

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  String? _selectedWalletId;
  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        showCustomSnackBar(
          context,
          message: widget.type == TransactionType.expense
              ? 'متنساش تسجل صرفت على ايه'
              : 'متنساش تسجل الفلوس جاية منين',
          msgColor: AppColors.scaffoldBackgroundLightColor,
          backgroundColor: AppColors.orangeColor,
        );
        return;
      }
      final walletState = context.read<WalletCubit>().state;
      if (walletState is! WalletLoaded || walletState.wallets.isEmpty) {
        showCustomSnackBar(
          context,
          message: 'لا توجد محافظ. الرجاء إضافة محفظة أولاً.',
        );
        return;
      }
      final mainWallet = walletState.wallets.firstWhere(
        (w) => w.isMain,
        orElse: () => walletState.wallets.first,
      );
      final amount = double.parse(_amountController.text);
      final transaction = Transaction(
        id: getIt<Uuid>().v4(),
        amount: amount,
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        note: _noteController.text.isNotEmpty ? _noteController.text : '',
        type: widget.type,
        walletId: mainWallet.id,
      );
      context.read<TransactionCubit>().addTransaction(transaction);
      context.read<WalletCubit>().updateWalletBalance(
        mainWallet.id,
        widget.type == TransactionType.income ? amount : -amount,
      );
      playTimerSound();
      _amountController.clear();
      _noteController.clear();
      setState(() {
        _selectedCategoryId = null;
        _selectedDate = DateTime.now();
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      barrierColor: Colors.black54,
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primaryColor,
              onPrimary: AppColors.scaffoldBackgroundLightColor,
              onSurface: AppColors.primaryTextColor,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, TransactionState>(
      builder: (context, state) {
        final categories = state.allCategories
            .where((c) => c.type == widget.type)
            .toList();
        // في بناء الواجهة (Build Method)
        if (state.pendingTransactions.isNotEmpty)
          Container(
            margin: EdgeInsets.all(8.r),
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: AppColors.orangeColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.orangeColor),
                8.horizontalSpace,
                const Expanded(
                  child: Text('عندك مصاريف دورية النهاردة، سجلتها؟'),
                ),
                TextButton(
                  onPressed: () => _showPendingDialog(
                    context,
                    state.pendingTransactions,
                  ),
                  child: const Text('مراجعة الآن'),
                ),
              ],
            ),
          );
        return BlocBuilder<WalletCubit, WalletState>(
          builder: (context, walletState) {
            final wallets = (walletState is WalletLoaded)
                ? walletState.wallets
                : <Wallet>[];

            if (_selectedWalletId == null && wallets.isNotEmpty) {
              final mainWallet = wallets.firstWhere(
                (w) => w.isMain,
                orElse: () => wallets.first,
              );
              _selectedWalletId = mainWallet.id;
            }
            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  spacing: 16.h,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.type == TransactionType.income
                          ? 'معاك كام (المبلغ)'
                          : 'صرفت كام (المبلغ)',
                      style: AppTextStyles.style14W400.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    CustomPrimaryTextfield(
                      suffix: IconButton(
                        icon: Icon(
                          Icons.calendar_month_outlined,
                          size: 22.r,
                          color: AppColors.primaryColor,
                        ),
                        onPressed: () => _selectDate(context),
                      ),
                      controller: _amountController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      text: 'المبلغ',

                      validator: (value) =>
                          value == null || value.isEmpty ? 'سجل المبلغ' : null,
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          widget.type == TransactionType.income
                              ? 'الفلوس دي جاية منين (الفئة)'
                              : 'صرفتها على ايه (الفئة)',
                          style: AppTextStyles.style14W400.copyWith(
                            color: AppColors.primaryColor,
                          ),
                        ),
                        InkWell(
                          child: Text(
                            'عدّل',
                            style: AppTextStyles.style12W300.copyWith(
                              color: AppColors.primaryColor,
                            ),
                          ),
                          onTap: () => context.pushNamed(
                            AppRoutes.manageCategoriesScreen,
                          ),
                        ),
                      ],
                    ),

                    CategorySelector(
                      categories: categories,
                      selectedCategoryId: _selectedCategoryId,
                      onCategorySelected: (id) =>
                          setState(() => _selectedCategoryId = id),
                      onAddCategory: () =>
                          _showAddCategoryDialog(context, widget.type),
                    ),

                    Text(
                      'ملاحظات',
                      style: AppTextStyles.style14W400.copyWith(
                        color: AppColors.primaryColor,
                      ),
                    ),
                    CustomPrimaryTextfield(
                      controller: _noteController,
                      text: 'ملاحظات (اختياري)',
                    ),

                    10.verticalSpace,
                    CustomPrimaryButton(
                      onPressed: _submit,
                      width: SizeConfig.screenWidth,
                      text: 'إضافة',
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showPendingDialog(
    BuildContext context,
    List<TransactionCategory> pendingCategories,
  ) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.pending_actions, color: AppColors.orangeColor),
              8.horizontalSpace,
              const Text('عمليات بانتظار تأكيدك'),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: pendingCategories.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final category = pendingCategories[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: category.color,
                    radius: 15.r,
                  ),
                  title: Text(category.name),
                  subtitle: Text(
                    'المبلغ المتوقع: ${category.fixedAmount?.truncate()} ج.م',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // زر الرفض/التجاهل
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.errorColor,
                        ),
                        onPressed: () {
                          // هنا يمكنك إضافة منطق لإزالة العملية من القائمة المؤقتة فقط
                          Navigator.of(ctx).pop();
                        },
                      ),
                      // زر التأكيد
                      IconButton(
                        icon: Icon(
                          Icons.check_circle,
                          color: AppColors.successColor,
                        ),
                        onPressed: () {
                          // تنفيذ العملية فوراً
                          context.read<TransactionCubit>().executeRecurring(
                            category,
                          );
                          Navigator.of(ctx).pop();
                          showCustomSnackBar(
                            context,
                            message: 'تم تسجيل ${category.name} بنجاح',
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('راجع لاحقاً'),
            ),
          ],
        );
      },
    );
  }
}

void _showAddCategoryDialog(BuildContext context, TransactionType type) {
  showDialog<TransactionCategory>(
    context: context,
    builder: (_) => AddCategoryDialog(type: type),
  ).then((newCategory) {
    if (newCategory != null) {
      context.read<TransactionCubit>().addCategory(newCategory);
    }
  });
}

void playTimerSound() {
  final player = AudioPlayer();
  const sound = appSound;
  player.play(AssetSource(sound));
}

class AppBottomBar extends StatelessWidget {
  const AppBottomBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          1.horizontalSpace,
          SizedBox(
            height: 56.h,
            width: 70.w,
            child: IconButton(
              onPressed: () {
                context.pushNamed(AppRoutes.transactionDetailsScreen);
              },
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgImage(
                    imagePath: 'assets/image/svg/money-bag-outline.svg',
                    height: 24.r,
                    color: AppColors.textGreyColor,
                  ),
                  4.verticalSpace,
                  Text(
                    'الفلوس',
                    style: AppTextStyles.style10W400.copyWith(
                      color: AppColors.textGreyColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 56.h,
            width: 70.w,
            child: IconButton(
              onPressed: () {
                context.pushNamed(AppRoutes.walletsScreen);
              },
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgImage(
                    imagePath: 'assets/image/svg/wallet-money (1).svg',
                    height: 24.r,
                    color: AppColors.textGreyColor,
                  ),
                  4.verticalSpace,
                  Text(
                    'المحافظ',
                    style: AppTextStyles.style10W400.copyWith(
                      color: AppColors.textGreyColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          1.horizontalSpace,
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: const Icon(
              Icons.add,
              color: AppColors.scaffoldBackgroundLightColor,
            ),
          ),
          1.horizontalSpace,
          SizedBox(
            height: 56.h,
            width: 70.w,
            child: IconButton(
              onPressed: () {
                context.pushNamed(AppRoutes.monthlyPlanScreen);
              },
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgImage(
                    imagePath: 'assets/image/svg/big-data-analytics 1.svg',
                    height: 24.r,
                    color: AppColors.textGreyColor,
                  ),
                  4.verticalSpace,
                  Text(
                    'بادجت الشهر',
                    style: AppTextStyles.style10W400.copyWith(
                      color: AppColors.textGreyColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 56.h,
            width: 70.w,
            child: IconButton(
              onPressed: () {
                context.pushNamed(AppRoutes.financialGoalsScreen);
              },
              icon: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgImage(
                    imagePath: 'assets/image/svg/mage_goals.svg',
                    height: 24.r,
                    color: AppColors.textGreyColor,
                  ),
                  4.verticalSpace,
                  Text(
                    'الأهداف',
                    style: AppTextStyles.style10W400.copyWith(
                      color: AppColors.textGreyColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          1.horizontalSpace,
        ],
      ),
    );
  }
}
