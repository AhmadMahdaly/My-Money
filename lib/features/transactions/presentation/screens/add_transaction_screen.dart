import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opration/core/constants.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
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
import 'package:opration/features/transactions/presentation/screens/widgets/manage_categories_drawer.dart'
    hide AddCategoryDialog, CategorySelector;
import 'package:opration/features/transactions/presentation/screens/widgets/welcome_user_widget.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        key: _scaffoldKey,
        endDrawer: const ManageCategoriesDrawer(),
        appBar: const PageHeader(),
        body: TabBarView(
          children: [
            _TransactionForm(
              type: TransactionType.expense,
              scaffoldKey: _scaffoldKey,
            ),
            _TransactionForm(
              type: TransactionType.income,
              scaffoldKey: _scaffoldKey,
            ),
          ],
        ),
      ),
    );
  }
}

class PageHeader extends StatelessWidget implements PreferredSizeWidget {
  const PageHeader({
    super.key,
  });

  @override
  Size get preferredSize => Size.fromHeight(170.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170.h,
      padding: EdgeInsets.only(right: 16.w, left: 16.w),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.50, -0),
          end: Alignment(0.50, 1),
          colors: [AppColors.primaryColor, AppColors.secondaryTextColor],
        ),
      ),
      child: Column(
        spacing: 10.h,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const WelcomeUserWidget(),
          Row(
            children: [
              SvgImage(imagePath: 'assets/image/svg/quote-1.svg', height: 16.h),
              Text(
                ' من راقب ماله، زاد ماله ',
                style: AppTextStyles.style14W400.copyWith(
                  color: AppColors.scaffoldBackgroundLightColor,
                ),
              ),
              SvgImage(imagePath: 'assets/image/svg/quote-2.svg', height: 16.h),
            ],
          ),
          Container(
            height: 55.h,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.scaffoldBackgroundLightColor,
                width: 0.5.w,
              ),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: TabBar(
              indicatorPadding: EdgeInsets.all(2.r),
              indicator: BoxDecoration(
                borderRadius: BorderRadius.circular(8.r),
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
  }
}

class _TransactionForm extends StatefulWidget {
  const _TransactionForm({
    required this.type,
    required this.scaffoldKey,
  });

  final TransactionType type;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  State<_TransactionForm> createState() => _TransactionFormState();
}

class _TransactionFormState extends State<_TransactionForm> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();

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
          message: 'Please select a category',
          backgroundColor: AppColors.orangeColor,
        );
        return;
      }

      final transaction = Transaction(
        id: sl<Uuid>().v4(),
        amount: double.parse(_amountController.text),
        categoryId: _selectedCategoryId!,
        date: _selectedDate,
        note: _noteController.text.isNotEmpty ? _noteController.text : '',
        type: widget.type,
      );

      context.read<TransactionCubit>().addTransaction(transaction);

      showCustomSnackBar(
        context,
        msgColor: AppColors.scaffoldBackgroundLightColor,
        message:
            '${widget.type == TransactionType.income ? 'Income' : 'Expense'} Successfully added',
        backgroundColor: AppColors.successColor,
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

        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                  text: 'Amount',
                  prefix: const Icon(
                    Icons.monetization_on_outlined,
                    color: AppColors.secondaryColor,
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter the amount'
                      : null,
                ),
                16.verticalSpace,
                CustomPrimaryTextfield(
                  controller: _noteController,
                  text: 'Note (optional)',
                  prefix: const Icon(
                    Icons.note_alt_outlined,
                    color: AppColors.secondaryColor,
                  ),
                ),
                16.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select a category',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    InkWell(
                      child: Text(
                        'Edit',
                        style: AppTextStyles.style12W300.copyWith(
                          color: AppColors.primaryColor,
                        ),
                      ),
                      onTap: () =>
                          widget.scaffoldKey.currentState?.openEndDrawer(),
                    ),
                  ],
                ),
                8.verticalSpace,
                CategorySelector(
                  categories: categories,
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: (id) =>
                      setState(() => _selectedCategoryId = id),
                  onAddCategory: () =>
                      _showAddCategoryDialog(context, widget.type),
                ),
                24.verticalSpace,
                CustomPrimaryButton(
                  onPressed: _submit,
                  width: SizeConfig.screenWidth,
                  text:
                      'Save the ${widget.type == TransactionType.income ? 'Income' : 'Expense'}',
                ),
              ],
            ),
          ),
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
