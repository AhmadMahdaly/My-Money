import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opration/core/di.dart';
import 'package:opration/core/responsive/responsive_config.dart';
import 'package:opration/core/theme/colors.dart';
import 'package:opration/core/theme/text_style.dart';
import 'package:opration/features/transactions/domain/entities/transaction.dart';
import 'package:opration/features/transactions/domain/entities/transaction_category.dart';
import 'package:opration/features/transactions/presentation/cubit/transactions_cubit.dart';
import 'package:uuid/uuid.dart';

class ManageCategoriesDrawer extends StatelessWidget {
  const ManageCategoriesDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: BlocBuilder<TransactionCubit, TransactionState>(
        builder: (context, state) {
          final incomeCategories = state.allCategories
              .where((c) => c.type == TransactionType.income)
              .toList();
          final expenseCategories = state.allCategories
              .where((c) => c.type == TransactionType.expense)
              .toList();

          return ListView(
            children: [
              SizedBox(
                height: 80.h,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                  ),
                  child: Text(
                    'Manage Categories',
                    style: Styles.style20Bold.copyWith(
                      color: AppColors.scaffoldBackgroundLightColor,
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Add new category...'),
                onTap: () {
                  // Ask user for type before showing dialog
                  _showAddCategoryDialog(context);
                },
              ),
              const Divider(),
              _CategoryListSection(
                title: 'Income Categories',
                categories: incomeCategories,
              ),
              const Divider(),
              _CategoryListSection(
                title: 'Expense Categories',
                categories: expenseCategories,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryListSection extends StatelessWidget {
  const _CategoryListSection({required this.title, required this.categories});
  final String title;
  final List<TransactionCategory> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(title, style: Theme.of(context).textTheme.titleSmall),
        ),
        ...categories.map(
          (category) => ListTile(
            leading: CircleAvatar(backgroundColor: category.color, radius: 10),
            title: Text(category.name),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () => _showEditCategoryDialog(context, category),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline,
                    size: 20,
                    color: Colors.red,
                  ),
                  onPressed: () => _confirmDeleteCategory(context, category),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

void _showAddCategoryDialog(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Select category type'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('Income'),
            onTap: () {
              Navigator.of(ctx).pop();
              showDialog<TransactionCategory>(
                context: context,
                builder: (_) =>
                    const AddCategoryDialog(type: TransactionType.income),
              ).then((newCategory) {
                if (newCategory != null) {
                  context.read<TransactionCubit>().addCategory(newCategory);
                }
              });
            },
          ),
          ListTile(
            title: const Text('Expense'),
            onTap: () {
              Navigator.of(ctx).pop();
              showDialog<TransactionCategory>(
                context: context,
                builder: (_) =>
                    const AddCategoryDialog(type: TransactionType.expense),
              ).then((newCategory) {
                if (newCategory != null) {
                  context.read<TransactionCubit>().addCategory(newCategory);
                }
              });
            },
          ),
        ],
      ),
    ),
  );
}

void _showEditCategoryDialog(
  BuildContext context,
  TransactionCategory category,
) {
  showDialog<TransactionCategory>(
    context: context,
    builder: (_) => AddCategoryDialog(
      type: category.type,
      categoryToEdit: category,
    ),
  ).then((updatedCategory) {
    if (updatedCategory != null) {
      context.read<TransactionCubit>().updateCategory(updatedCategory);
    }
  });
}

void _confirmDeleteCategory(
  BuildContext context,
  TransactionCategory category,
) {
  showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text('Confirm Deletion'),
      content: Text(
        'Are you sure you want to delete the category "${category.name}"? All associated transactions will also be deleted.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('Cancel'),
        ),
        TextButton(
          child: const Text('Delete', style: TextStyle(color: Colors.red)),
          onPressed: () {
            context.read<TransactionCubit>().deleteCategory(category.id);
            ctx.pop();
          },
        ),
      ],
    ),
  );
}

class AddCategoryDialog extends StatefulWidget {
  const AddCategoryDialog({required this.type, super.key, this.categoryToEdit});
  final TransactionType type;
  final TransactionCategory? categoryToEdit;

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  late TextEditingController _nameController;
  late Color _selectedColor;

  final _formKey = GlobalKey<FormState>();
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
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.categoryToEdit?.name);
    _selectedColor = widget.categoryToEdit?.color ?? Colors.blue;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final category = TransactionCategory(
      id: widget.categoryToEdit?.id ?? sl<Uuid>().v4(),
      name: _nameController.text,
      colorValue: _selectedColor.value,
      type: widget.type,
    );
    Navigator.of(context).pop(category);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.categoryToEdit != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit' : 'Add'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Category name'),
              autofocus: true,
              validator: (v) => v == null || v.isEmpty ? 'Name required' : null,
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
                    child: _selectedColor.value == color.value
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
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    super.key,
  });
  final List<TransactionCategory> categories;
  final String? selectedCategoryId;
  final ValueChanged<String> onCategorySelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((category) {
        final isSelected = category.id == selectedCategoryId;
        return ChoiceChip(
          label: Text(category.name),
          avatar: CircleAvatar(backgroundColor: category.color, radius: 10.r),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              onCategorySelected(category.id);
            }
          },
          selectedColor: category.color.withAlpha(55),
        );
      }).toList(),
    );
  }
}
