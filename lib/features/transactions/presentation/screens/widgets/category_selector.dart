import 'package:flutter/material.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.onAddCategory,
    super.key,
  });
  final List<TransactionCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onCategorySelected;
  final VoidCallback onAddCategory;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...categories.map((category) {
          final isSelected = category.id == selectedCategoryId;
          return ChoiceChip(
            shape: ContinuousRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
            label: Text(category.name),
            avatar: CircleAvatar(backgroundColor: category.color, radius: 30.r),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                onCategorySelected(category.id);
              }
            },
            selectedColor: category.color.withAlpha(55),
          );
        }),
        ActionChip(
          avatar: const Icon(Icons.add),
          label: const Text('Add'),
          onPressed: onAddCategory,
        ),
      ],
    );
  }
}
