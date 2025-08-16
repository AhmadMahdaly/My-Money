import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/shared_widgets/custom_primary_textfield.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:uuid/uuid.dart';

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({required this.type, super.key});
  final TransactionType type;

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final _nameController = TextEditingController();
  Color _selectedColor = Colors.blue;
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

  void _submit() {
    if (_nameController.text.isEmpty) return;
    final newCategory = TransactionCategory(
      id: getIt<Uuid>().v4(),
      name: _nameController.text,
      colorValue: _selectedColor.toARGB32(),
      type: widget.type,
    );
    context.pop(newCategory);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('ضيف فئة جديدة'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomPrimaryTextfield(
              controller: _nameController,
              text: 'اسم الفئة',
              autofocus: true,
            ),
            20.verticalSpace,
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _availableColors.map((color) {
                return GestureDetector(
                  onTap: () => setState(() => _selectedColor = color),
                  child: CircleAvatar(
                    backgroundColor: color,
                    radius: 20.r,
                    child: _selectedColor == color
                        ? const Icon(Icons.check, color: Colors.white)
                        : null,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: const Text('إضافة'),
        ),
      ],
    );
  }
}
