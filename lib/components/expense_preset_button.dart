import 'package:dash/core/expense_preset.dart';
import 'package:flutter/material.dart';

class ExpensePresetButton extends StatelessWidget {
  final ExpensePreset expensePreset;
  final Function() onPressed;

  const ExpensePresetButton({
    super.key,
    required this.expensePreset,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.tonal(
      style: FilledButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.0),
        ),
      ),
      onPressed: onPressed,
      child: Text(expensePreset.description),
    );
  }
}
