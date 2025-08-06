import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opration/core/di.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:opration/features/transactions/presentation/screens/transaction_details_screen.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/add_category_dialog.dart';
import 'package:opration/features/transactions/presentation/screens/widgets/category_selector.dart';
import 'package:uuid/uuid.dart';

class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('إضافة معاملة جديدة'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(text: 'مصروف', icon: Icon(Icons.arrow_downward)),
              Tab(text: 'دخل', icon: Icon(Icons.arrow_upward)),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.analytics_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: sl<TransactionCubit>(),
                      child: const TransactionDetailsScreen(),
                    ),
                  ),
                );
              },
              tooltip: 'عرض التفاصيل',
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (_selectedCategoryId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('الرجاء اختيار فئة'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final transaction = Transaction(
        id: sl<Uuid>().v4(),
        amount: double.parse(_amountController.text),
        categoryId: _selectedCategoryId!,
        date: DateTime.now(),
        note: _noteController.text.isNotEmpty ? _noteController.text : null,
        type: widget.type,
      );

      context.read<TransactionCubit>().addTransaction(transaction);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تمت إضافة ${widget.type == TransactionType.income ? 'الدخل' : 'المصروف'} بنجاح',
          ),
          backgroundColor: Colors.green,
        ),
      );

      _amountController.clear();
      _noteController.clear();
      setState(() {
        _selectedCategoryId = null;
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'اختر الفئة',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                CategorySelector(
                  categories: categories,
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: (id) =>
                      setState(() => _selectedCategoryId = id),
                  onAddCategory: () =>
                      _showAddCategoryDialog(context, widget.type),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'المبلغ',
                    prefixIcon: Icon(Icons.monetization_on_outlined),
                  ),
                  validator: (value) => value == null || value.isEmpty
                      ? 'الرجاء إدخال المبلغ'
                      : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'ملاحظة (اختياري)',
                    prefixIcon: Icon(Icons.note_alt_outlined),
                  ),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    'حفظ ال${widget.type == TransactionType.income ? 'دخل' : 'مصروف'}',
                  ),
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
