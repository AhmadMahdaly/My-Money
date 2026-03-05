// ignore_for_file: inference_failure_on_collection_literal

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/wallets/presentation/cubit/wallet_cubit.dart';
import 'package:uuid/uuid.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({required this.type, super.key, this.categoryToEdit});
  final TransactionType type;
  final TransactionCategory? categoryToEdit;

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late Color _selectedColor;

  // حقول التكرار والجدولة
  bool _isRecurring = false;
  RecurrenceType _recurrenceType = RecurrenceType.none;
  int? _dayOfMonth;
  List<int> _selectedDaysOfWeek = []; // 1 للاثنين ... 7 للأحد
  bool _autoDeduct = false;
  String? _targetWalletId;

  final List<Color> _availableColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
    Colors.cyan,
    Colors.brown,
    Colors.black,
    Colors.indigo,
  ];

  @override
  void initState() {
    super.initState();
    final edit = widget.categoryToEdit;
    _nameController = TextEditingController(text: edit?.name);
    _amountController = TextEditingController(
      text: edit?.fixedAmount?.toString() ?? '',
    );
    _selectedColor = edit?.color ?? AppColors.primaryColor;
    _isRecurring = edit?.isRecurring ?? false;
    _recurrenceType = edit?.recurrenceType ?? RecurrenceType.none;
    _dayOfMonth = edit?.dayOfMonth;
    _selectedDaysOfWeek = List.from(edit?.daysOfWeek ?? []);
    _autoDeduct = edit?.autoDeduct ?? false;
    _targetWalletId = edit?.targetWalletId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final category = TransactionCategory(
      id: widget.categoryToEdit?.id ?? getIt<Uuid>().v4(),
      name: _nameController.text,
      colorValue: _selectedColor.toARGB32(),
      type: widget.type,
      isRecurring: _isRecurring,
      fixedAmount: double.tryParse(_amountController.text),
      recurrenceType: _isRecurring ? _recurrenceType : RecurrenceType.none,
      dayOfMonth: _dayOfMonth,
      daysOfWeek: _selectedDaysOfWeek,
      autoDeduct: _autoDeduct,
      targetWalletId: _targetWalletId,
    );
    context.pop(category);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WalletCubit, WalletState>(
      builder: (context, walletState) {
        final wallets = (walletState is WalletLoaded)
            ? walletState.wallets
            : [];

        return AlertDialog(
          title: Text(
            widget.categoryToEdit != null ? 'تعديل الفئة' : 'إضافة فئة ذكية',
            style: AppTextStyles.style12W300,
          ),
          content: SizedBox(
            width: SizeConfig.screenWidth * 0.9,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomPrimaryTextfield(
                      controller: _nameController,
                      text: 'اسم الفئة (إيجار، مواصلات...)',
                      validator: (v) => v!.isEmpty ? 'سجل الاسم' : null,
                    ),
                    16.verticalSpace,

                    Text('اختر اللون:', style: AppTextStyles.style12W300),
                    8.verticalSpace,
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableColors
                          .map(
                            (color) => GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedColor = color),
                              child: CircleAvatar(
                                backgroundColor: color,
                                radius: 18.r,
                                child: _selectedColor.value == color.value
                                    ? const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                      )
                                    : null,
                              ),
                            ),
                          )
                          .toList(),
                    ),

                    const Divider(height: 32),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'فئة مكررة (التزامات ثابتة)',
                        style: AppTextStyles.style14W600,
                      ),
                      subtitle: Text(
                        'تخصم/تضاف تلقائياً في موعدها',
                        style: AppTextStyles.style10W400,
                      ),
                      value: _isRecurring,
                      onChanged: (v) => setState(() {
                        _isRecurring = v;
                        if (v && _recurrenceType == RecurrenceType.none) {
                          _recurrenceType = RecurrenceType.monthly;
                        }
                      }),
                    ),

                    if (_isRecurring) ...[
                      12.verticalSpace,
                      DropdownButtonFormField<RecurrenceType>(
                        initialValue: _recurrenceType == RecurrenceType.none
                            ? RecurrenceType.monthly
                            : _recurrenceType,
                        decoration: const InputDecoration(
                          labelText: 'نوع التكرار',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: RecurrenceType.weekly,
                            child: Text('أيام محددة في الأسبوع (مواصلات)'),
                          ),
                          DropdownMenuItem(
                            value: RecurrenceType.monthly,
                            child: Text('يوم محدد في الشهر (إيجار/دخل)'),
                          ),
                        ],
                        onChanged: (v) => setState(() => _recurrenceType = v!),
                      ),
                      12.verticalSpace,
                      CustomPrimaryTextfield(
                        controller: _amountController,
                        text: 'المبلغ الثابت',
                        keyboardType: TextInputType.number,
                        validator: (v) =>
                            _isRecurring && (v == null || v.isEmpty)
                            ? 'سجل المبلغ'
                            : null,
                      ),
                      12.verticalSpace,
                      DropdownButtonFormField<dynamic>(
                        initialValue: _targetWalletId,
                        decoration: const InputDecoration(
                          labelText: 'من أي محفظة؟',
                        ),
                        items: wallets
                            .map(
                              (w) => DropdownMenuItem<dynamic>(
                                value: w.id,
                                child: Text(w.name as String),
                              ),
                            )
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _targetWalletId = v as String),
                        validator: (v) =>
                            _isRecurring && v == null ? 'اختر محفظة' : null,
                      ),

                      if (_recurrenceType == RecurrenceType.weekly) ...[
                        16.verticalSpace,
                        Text(
                          'اختر أيام الأسبوع:',
                          style: AppTextStyles.style12W300,
                        ),
                        Wrap(
                          spacing: 4,
                          children: List.generate(7, (index) {
                            final day = index + 1;
                            final days = ['ن', 'ث', 'ر', 'خ', 'ج', 'س', 'ح'];
                            final isSelected = _selectedDaysOfWeek.contains(
                              day,
                            );
                            return FilterChip(
                              label: Text(days[index]),
                              selected: isSelected,
                              onSelected: (v) => setState(
                                () => v
                                    ? _selectedDaysOfWeek.add(day)
                                    : _selectedDaysOfWeek.remove(day),
                              ),
                            );
                          }),
                        ),
                      ],

                      if (_recurrenceType == RecurrenceType.monthly) ...[
                        12.verticalSpace,
                        DropdownButtonFormField<int>(
                          initialValue: _dayOfMonth,
                          decoration: const InputDecoration(
                            labelText: 'يوم الخصم في الشهر',
                          ),
                          items: List.generate(
                            31,
                            (i) => DropdownMenuItem(
                              value: i + 1,
                              child: Text('${i + 1}'),
                            ),
                          ),
                          onChanged: (v) => setState(() => _dayOfMonth = v),
                        ),
                      ],

                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          'تفعيل الخصم التلقائي',
                          style: AppTextStyles.style12W700,
                        ),
                        subtitle: Text(
                          'إذا لم تفعل، سيسألك التطبيق قبل الخصم',
                          style: AppTextStyles.style10W400,
                        ),
                        value: _autoDeduct,
                        onChanged: (v) => setState(() => _autoDeduct = v),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
              ),
              onPressed: _submit,
              child: const Text(
                'حفظ الفئة',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}
