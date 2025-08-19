import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/shared_widgets/custom_dropdown_button.dart';
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
        appBar: PageHeader(),
        body: TabBarView(
          children: [
            _TransactionForm(type: TransactionType.expense),
            _TransactionForm(type: TransactionType.income),
          ],
        ),
      ),
    );
  }
}

class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  const PageHeader({super.key});

  @override
  Size get preferredSize => Size.fromHeight(180.h);

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
                  const WelcomeUserWidget(),

                  Row(
                    children: [
                      SvgImage(
                        imagePath: 'assets/image/svg/quote-1.svg',
                        height: 14.h,
                      ),
                      4.horizontalSpace,
                      Text(
                        kAppQuote,
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

              InkWell(
                onTap: () =>
                    context.read<WalletCubit>().toggleShowMainWalletPref(),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (walletState is WalletLoaded)
                      Icon(
                        showMainWallet
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,

                        color: AppColors.cardColor,
                        size: 16.r,
                      ),
                    6.horizontalSpace,
                    if (walletState is WalletLoaded && mainWallet != null)
                      Flexible(
                        child: Text(
                          showMainWallet
                              ? 'محفظتك: ${mainWallet.name} ( ${mainWallet.balance.truncate()}  ج.م)'
                              : 'محفظتك: ${mainWallet.name} ( ******  ج.م)',
                          style: AppTextStyles.style12Bold.copyWith(
                            color: AppColors.scaffoldBackgroundLightColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

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

      final amount = double.parse(_amountController.text);
      final transaction = Transaction(
        id: getIt<Uuid>().v4(),
        amount: amount,
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        note: _noteController.text.isNotEmpty ? _noteController.text : '',
        type: widget.type,
        walletId: _selectedWalletId!,
      );
      context.read<TransactionCubit>().addTransaction(transaction);
      context.read<WalletCubit>().updateWalletBalance(
        _selectedWalletId!,
        widget.type == TransactionType.income ? amount : -amount,
      );

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
                    Row(
                      spacing: 8.w,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12.h,
                            children: [
                              Text(
                                'المحفظة',
                                style: AppTextStyles.style14W400.copyWith(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                              CustomDropdownButtonFormField<String>(
                                value: _selectedWalletId,
                                hintText: 'المحفظة',
                                items: wallets
                                    .map(
                                      (w) => DropdownMenuItem(
                                        value: w.id,
                                        child: Text(
                                          w.name,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (value) =>
                                    setState(() => _selectedWalletId = value),

                                validator: (v) =>
                                    v == null ? 'اختار محفظة' : null,
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            spacing: 12.h,
                            children: [
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
                            ],
                          ),
                        ),
                      ],
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
