import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/expense_category.dart';

class ExpenseCategorySelector extends ConsumerWidget {
  final ExpenseCategory category;
  final bool selected;
  final Function()? onPressed;

  const ExpenseCategorySelector({
    super.key,
    required this.category,
    required this.selected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, ref) {
    return FilledButton(
      style: ButtonStyle(
        backgroundColor: WidgetStatePropertyAll(category.backgroundColor),
      ),
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 5,
        children: [
          selected
              ? Icon(Icons.check, color: category.textColor)
              : SizedBox.shrink(),
          Text(
            category.name,
            style: TextStyle(color: category.textColor, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
