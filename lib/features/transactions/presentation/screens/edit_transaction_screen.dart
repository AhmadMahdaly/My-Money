import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/shared_widgets/custom_primary_button.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit.dart';

class EditTransactionScreen extends StatefulWidget {
  const EditTransactionScreen({required this.transaction, super.key});
  final Transaction transaction;

  @override
  State<EditTransactionScreen> createState() => _EditTransactionScreenState();
}

class _EditTransactionScreenState extends State<EditTransactionScreen> {
  late final TextEditingController _amountController;
  late final TextEditingController _noteController;
  late String _selectedCategoryId;
  late DateTime _selectedDate;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.transaction.amount.toString(),
    );
    _noteController = TextEditingController(
      text: widget.transaction.note ?? '',
    );
    _selectedCategoryId = widget.transaction.categoryId;
    _selectedDate = widget.transaction.date;
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _updateTransaction() {
    if (!_formKey.currentState!.validate()) return;

    final updatedTransaction = Transaction(
      id: widget.transaction.id,
      amount: double.parse(_amountController.text),
      categoryId: _selectedCategoryId,
      date: _selectedDate,
      note: _noteController.text,
      type: widget.transaction.type,
    );

    context.read<TransactionCubit>().updateTransaction(updatedTransaction);
    if (context.mounted) {
      context.pop();
    }
  }

  void _deleteTransaction() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: const Text(
          'Are you sure you want to delete this transaction? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => ctx.pop(),
          ),
          TextButton(
            child: Text(
              'Delete',
              style: Styles.style12W700.copyWith(color: AppColors.errorColor),
            ),
            onPressed: () {
              context.read<TransactionCubit>().deleteTransaction(
                widget.transaction.id,
              );
              context.pop();
              if (ctx.mounted) {
                ctx.pop();
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _deleteTransaction,
            tooltip: 'Delete',
          ),
        ],
      ),
      body: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          final categories = state.allCategories
              .where((c) => c.type == widget.transaction.type)
              .toList();
          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16.r),
              children: [
                TextFormField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: 'Amount'),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Amount required' : null,
                ),
                16.verticalSpace,
                DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  items: categories
                      .map(
                        (cat) => DropdownMenuItem(
                          value: cat.id,
                          child: Text(cat.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategoryId = value);
                    }
                  },
                  decoration: const InputDecoration(labelText: 'Category'),
                ),
                16.verticalSpace,
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Note'),
                ),
                16.verticalSpace,
                ListTile(
                  title: const Text('Date'),
                  subtitle: Text(
                    DateFormat.yMMMd().format(_selectedDate),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (pickedDate != null) {
                      setState(() => _selectedDate = pickedDate);
                    }
                  },
                ),
                32.verticalSpace,
                CustomPrimaryButton(
                  onPressed: _updateTransaction,
                  width: SizeConfig.screenWidth,
                  text: 'Save',
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
