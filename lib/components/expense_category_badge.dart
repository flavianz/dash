import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/expense_category.dart';

class ExpenseCategoryBadge extends ConsumerWidget {
  final ExpenseCategory category;

  const ExpenseCategoryBadge({super.key, required this.category});

  @override
  Widget build(BuildContext context, ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: category.backgroundColor,
        borderRadius: BorderRadius.all(Radius.circular(100)),
      ),
      child: Text(
        category.name,
        style: TextStyle(color: category.textColor, fontSize: 13),
      ),
    );
  }
}
