import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/router/app_routes.dart';
import 'package:opration/core/shared_widgets/custom_primary_button.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/shared_widgets/show_custom_snackbar.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/add_category_dialog.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/category_selector.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/manage_categories_drawer.dart'
    hide AddCategoryDialog, CategorySelector;
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
        appBar: AppBar(
          title: const Text('Add new transaction'),
          centerTitle: true,
          bottom: TabBar(
            labelStyle: Styles.style12W800.copyWith(
              color: AppColors.scaffoldBackgroundLightColor,
            ),
            unselectedLabelStyle: Styles.style12W600.copyWith(
              color: AppColors.scaffoldBackgroundLightColor,
            ),
            indicatorColor: AppColors.scaffoldBackgroundLightColor,
            tabs: const [
              Tab(
                text: 'Expense',
                icon: Icon(
                  Icons.arrow_downward,
                  color: AppColors.scaffoldBackgroundLightColor,
                ),
              ),
              Tab(
                text: 'Income',
                icon: Icon(
                  Icons.arrow_upward,
                  color: AppColors.scaffoldBackgroundLightColor,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () {
                context.push(AppRoutes.transactionDetailsScreen);
              },
              tooltip: 'View details',
            ),
            IconButton(
              icon: const Icon(Icons.category),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              tooltip: 'Manage Categories',
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            _TransactionForm(type: TransactionType.expense),
            _TransactionForm(type: TransactionType.income),
          ],
        ),
      ),
    );
  }
}

class _TransactionForm extends StatefulWidget {
  const _TransactionForm({required this.type});
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
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
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
                      color: AppColors.blueLightColor,
                    ),
                    onPressed: () => _selectDate(context),
                  ),
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  text: 'Amount',
                  prefix: const Icon(Icons.monetization_on_outlined),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Please enter the amount'
                      : null,
                ),
                16.verticalSpace,
                CustomPrimaryTextfield(
                  controller: _noteController,
                  text: 'Note (optional)',
                  prefix: const Icon(Icons.note_alt_outlined),
                ),
                16.verticalSpace,
                Text(
                  'Select a category',
                  style: Theme.of(context).textTheme.titleLarge,
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
